import 'package:dio/dio.dart';

import '../../../core/config/app_config.dart';

/// VBShop web uygulamasındaki mevcut `/api/ai/*` uçlarını çağırır.
/// Gemini API key'i yalnızca Web tarafında (.env.local) tutulur — mobil
/// istemciye hiçbir sır gömülmez, web sunucusu güvenli bir proxy görevi görür.
class AiApiClient {
  AiApiClient()
      : _dio = Dio(
          BaseOptions(
            baseUrl: AppConfig.webBaseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 20),
            headers: {'Accept': 'application/json'},
          ),
        );

  final Dio _dio;

  Future<bool> status() async {
    try {
      final response =
          await _dio.get<Map<String, dynamic>>('/api/ai/status');
      return response.data?['configured'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<String> chat(String message) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/ai/chat',
        data: {'message': message},
      );
      final reply = response.data?['reply'] as String?;
      if (reply == null || reply.isEmpty) {
        throw Exception('Asistan boş yanıt döndürdü.');
      }
      return reply;
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = data is Map ? data['error'] as String? : null;
      throw Exception(message ?? 'AI isteği başarısız oldu.');
    }
  }
}
