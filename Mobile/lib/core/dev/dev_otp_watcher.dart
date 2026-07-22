import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../config/app_config.dart';

/// Yerel test ortamında (backend'in SMTP'si Mailpit'e bağlıyken) gerçek
/// e-posta gelmez — bu sınıf Mailpit'in HTTP API'sini periyodik yoklayıp
/// hedef adrese gelen en yeni OTP kodunu bulur, telefona gerçek bir
/// bildirim düşürür ve çağrı sahibine kodu iletir.
///
/// Yalnızca debug modda ve mock kapalıyken anlamlıdır — prod/staging'de
/// Mailpit yoktur, istekler sessizce başarısız olur ve yok sayılır.
class DevOtpWatcher {
  DevOtpWatcher._();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  static Timer? _timer;
  static String? _lastSeenMessageId;
  static int _notificationId = 0;

  static Future<void> _ensureInitialized() async {
    if (_initialized) return;
    _initialized = true;
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(
      const InitializationSettings(android: androidInit),
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// [email] adresine gelen en yeni doğrulama kodunu 2 saniyede bir arar.
  /// Yeni bir kod bulunduğunda hem bildirim gösterir hem [onCode] çağrılır.
  /// Ekrandan çıkarken [stop] çağrılmalı.
  static void start({
    required String email,
    required void Function(String code) onCode,
  }) {
    if (!kDebugMode || AppConfig.useMock) return;
    stop();
    _lastSeenMessageId = null;
    _timer = Timer.periodic(const Duration(seconds: 2), (_) async {
      await _poll(email, onCode);
    });
  }

  static void stop() {
    _timer?.cancel();
    _timer = null;
  }

  static Future<void> _poll(
    String email,
    void Function(String code) onCode,
  ) async {
    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: AppConfig.mailpitBaseUrl,
          connectTimeout: const Duration(seconds: 3),
          receiveTimeout: const Duration(seconds: 3),
        ),
      );
      final response = await dio.get<Map<String, dynamic>>(
        '/api/v1/search',
        queryParameters: {'query': 'to:$email'},
      );
      final messages = response.data?['messages'] as List?;
      if (messages == null || messages.isEmpty) return;

      final latest = messages.first as Map<String, dynamic>;
      final id = latest['ID']?.toString();
      if (id == null || id == _lastSeenMessageId) return;
      _lastSeenMessageId = id;

      final snippet = (latest['Snippet'] ?? '').toString();
      final match = RegExp(r'\d{4,8}').firstMatch(snippet);
      if (match == null) return;
      final code = match.group(0)!;

      onCode(code);
      await _showNotification(code);
    } catch (_) {
      // Mailpit ayakta değilse (gerçek SMTP/prod ortamı) sessizce yok say.
    }
  }

  static Future<void> _showNotification(String code) async {
    await _ensureInitialized();
    await _plugin.show(
      _notificationId++,
      'Doğrulama kodun geldi',
      'Kod: $code (dev/test — Mailpit üzerinden yakalandı)',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'dev_otp_channel',
          'Geliştirme OTP Bildirimleri',
          channelDescription:
              'Yerel test ortamında Mailpit\'ten yakalanan doğrulama kodları',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }
}
