import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences üzerinde JSON okuma/yazma yardımcıları.
///
/// Hassas OLMAYAN veriler içindir: sepet, favoriler, tema tercihi, arama
/// geçmişi ve mock modda sipariş/adres kayıtları. Token'lar [TokenStore]'da.
class LocalStore {
  LocalStore(this._prefs);

  final SharedPreferences _prefs;

  Object? getJson(String key) {
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw);
    } on FormatException {
      return null;
    }
  }

  Future<void> setJson(String key, Object value) =>
      _prefs.setString(key, jsonEncode(value));

  String? getString(String key) => _prefs.getString(key);

  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);

  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }
}
