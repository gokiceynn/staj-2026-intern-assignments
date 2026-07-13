import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../error/app_exception.dart';
import '../storage/token_store.dart';

/// Gerçek API'ye giden tüm istekler için ortak Dio örneği üretir.
///
/// - Her isteğe otomatik `Authorization: Bearer <token>` ekler.
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

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStore.readAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
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

  /// DioException → AppException dönüşümü. Remote data source'lar
  /// çağrılarını bununla sarar.
  static AppException mapError(Object error) {
    if (error is AppException) return error;
    if (error is DioException) {
      final status = error.response?.statusCode;
      // RFC 9457 Problem Details: {"title": ..., "detail": ...}
      final data = error.response?.data;
      final detail = data is Map ? (data['detail'] ?? data['title']) : null;
      return switch (status) {
        401 || 403 => UnauthorizedException(
            detail?.toString() ?? 'Oturumunuz geçersiz. Yeniden giriş yapın.',
          ),
        404 => NotFoundException(detail?.toString() ?? 'Kayıt bulunamadı.'),
        400 || 409 || 422 => ValidationException(
            detail?.toString() ?? 'İstek doğrulanamadı.',
          ),
        _ => const NetworkException(),
      };
    }
    return const NetworkException();
  }
}
