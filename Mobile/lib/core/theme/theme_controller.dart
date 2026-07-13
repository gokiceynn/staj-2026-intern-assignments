import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../di/core_providers.dart';

/// Tema tercihi (sistem/açık/koyu) — LocalStore'da kalıcı.
final themeControllerProvider =
    NotifierProvider<ThemeController, ThemeMode>(ThemeController.new);

class ThemeController extends Notifier<ThemeMode> {
  static const _key = 'app.theme_mode';

  @override
  ThemeMode build() {
    final raw = ref.watch(localStoreProvider).getString(_key);
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == raw,
      orElse: () => ThemeMode.system,
    );
  }

  void set(ThemeMode mode) {
    state = mode;
    ref.read(localStoreProvider).setString(_key, mode.name);
  }
}
