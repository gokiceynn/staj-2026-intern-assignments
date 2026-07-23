import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../error/app_exception.dart';
import '../storage/token_store.dart';

/// Gerçek API'ye giden tüm istekler için ortak Dio örneği üretir.
///
/// - Her isteğe otomatik `Authorization: Bearer <token>` ekler.
/// - `ApiResponse` zarfını (`{data, isSuccess, message, ...}`) açıp
///   `response.data`'yı doğrudan `data` alanına indirger — remote data
///   source'lar zarfı bilmeden JSON'u parse eder.
/// - 401 aldığında `refresh-token` ile oturumu bir kez yeniler ve isteği
///   otomatik tekrar dener; yenileme de başarısızsa oturumu temizler.
/// - DioException'ları kullanıcıya gösterilebilir [AppException]'a çevirir.
/// - Debug modda istek/yanıt loglar.
class DioClient {
  DioClient(this._tokenStore) {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Accept': 'application/json'},
      ),
    );

    // Refresh çağrısı için ayrı, interceptor'suz Dio — aksi halde 401
    // yenileme isteğinin kendisi de aynı zincire girip sonsuz döngü olur.
    _refreshDio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        headers: {'Accept': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStore.readAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          final data = response.data;
          if (data is Map && data.containsKey('isSuccess')) {
            response.data = data['data'];
          }
          handler.next(response);
        },
      ),
    );

    dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onError: (error, handler) async {
          final isRefreshCall =
              error.requestOptions.path.contains('refresh-token');
          if (error.response?.statusCode != 401 || isRefreshCall) {
            return handler.next(error);
          }
          try {
            final refreshed = await _refreshSession();
            if (!refreshed) {
              await _tokenStore.clear();
              return handler.next(error);
            }
            final token = await _tokenStore.readAccessToken();
            final options = error.requestOptions
              ..headers['Authorization'] = 'Bearer $token';
            final response = await dio.fetch<dynamic>(options);
            return handler.resolve(response);
          } catch (_) {
            await _tokenStore.clear();
            return handler.next(error);
          }
        },
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }
  }

  final TokenStore _tokenStore;
  late final Dio dio;
  late final Dio _refreshDio;

  Future<bool> _refreshSession() async {
    final refreshToken = await _tokenStore.readRefreshToken();
    final accessToken = await _tokenStore.readAccessToken();
    if (refreshToken == null || refreshToken.isEmpty) return false;

    final response = await _refreshDio.post<Map<String, dynamic>>(
      '/auth/refresh-token',
      data: {'refreshToken': refreshToken},
      options: Options(
        headers: {
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      ),
    );
    final body = response.data;
    final data = (body?['data'] ?? body) as Map<String, dynamic>?;
    if (data == null) return false;

    final newAccess = data['accessToken'] as String?;
    final newRefresh = data['refreshToken'] as String?;
    final userId = await _tokenStore.readUserId();
    if (newAccess == null || newRefresh == null || userId == null) {
      return false;
    }
    await _tokenStore.saveSession(
      accessToken: newAccess,
      refreshToken: newRefresh,
      userId: userId,
    );
    return true;
  }

  /// DioException → AppException dönüşümü. Remote data source'lar
  /// çağrılarını bununla sarar.
  static AppException mapError(Object error) {
    if (error is AppException) return error;
    if (error is DioException) {
      final status = error.response?.statusCode;
      final data = error.response?.data;
      // Hata gövdeleri `ApiResponse` zarfını korur (başarı yanıtlarının
      // aksine, interceptor yalnızca 2xx'te açar): `{message, errors:
      // {"CODE": ["mesaj"]}}`. `errors` içindeki ilk mesaj, generic
      // `message` alanından daha spesifik olduğu için önceliklidir.
      String? detail;
      String? errorCode;
      if (data is Map) {
        final errors = data['errors'];
        if (errors is Map && errors.isNotEmpty) {
          errorCode = errors.keys.first.toString();
          final firstList = errors.values.first;
          if (firstList is List && firstList.isNotEmpty) {
            detail = firstList.first.toString();
          }
        }
        detail ??= (data['message'] ?? data['detail'] ?? data['title'])
            ?.toString();
      }
      return switch (status) {
        401 || 403 => UnauthorizedException(
            detail?.toString() ?? 'Oturumunuz geçersiz. Yeniden giriş yapın.',
          ),
        404 => NotFoundException(detail?.toString() ?? 'Kayıt bulunamadı.'),
        400 || 409 || 422 => ValidationException(
            detail?.toString() ?? 'İstek doğrulanamadı.',
            code: errorCode,
          ),
        _ => const NetworkException(),
      };
    }
    return const NetworkException();
  }
}
