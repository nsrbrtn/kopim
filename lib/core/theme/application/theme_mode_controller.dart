import 'dart:async';

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/theme_repository_impl.dart';
import '../domain/app_theme_mode.dart';
import '../domain/repositories/theme_repository.dart';

part 'theme_mode_controller.g.dart';

@riverpod
class ThemeModeController extends _$ThemeModeController {
  bool _initialized = false;

  @override
  AppThemeMode build() {
    _initialize();
    return const AppThemeMode.system();
  }

  Future<void> setMode(AppThemeMode mode) async {
    state = mode;
    final ThemeRepository repository = ref.read(themeRepositoryProvider);
    await repository.saveThemeMode(mode);
  }

  Future<void> _initialize() async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    final ThemeRepository repository = ref.read(themeRepositoryProvider);
    final AppThemeMode storedMode = await repository.loadThemeMode();
    if (!ref.mounted) {
      return;
    }
    state = storedMode;
  }
}

extension AppThemeModeMaterial on AppThemeMode {
  ThemeMode toMaterialThemeMode() {
    return when(
      system: () => ThemeMode.system,
      light: () => ThemeMode.light,
      dark: () => ThemeMode.dark,
    );
  }
}
