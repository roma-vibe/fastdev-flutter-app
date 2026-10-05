import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/storage/preferences.dart';

class SettingsController extends AsyncNotifier<ThemeMode> {
  bool _saving = false;
  String get _key => '${ref.read(appConfigProvider).slug}.theme.v1';
  @override
  Future<ThemeMode> build() async {
    final value = await ref.watch(preferencesProvider).getString(_key);
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setTheme(ThemeMode mode) async {
    if (_saving) return;
    _saving = true;
    try {
      await ref.read(preferencesProvider).setString(_key, mode.name);
      if (ref.mounted) state = AsyncData(mode);
    } finally {
      _saving = false;
    }
  }
}

final settingsControllerProvider =
    AsyncNotifierProvider<SettingsController, ThemeMode>(
      SettingsController.new,
      retry: (retryCount, error) => null,
    );
