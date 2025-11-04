import 'dart:async';

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/app_theme_factory.dart';
import '../data/dto/kopim_theme_tokens.dart';
import '../data/theme_repository_impl.dart';
import '../domain/app_theme_mode.dart';
import '../domain/repositories/theme_repository.dart';

part 'theme_mode_controller.g.dart';

@riverpod
class ThemeModeController extends _$ThemeModeController {
  bool _initialized = false;
  bool _tokensListenerAttached = false;
  Completer<void>? _initializationCompleter;

  @override
  AppThemeMode build() {
    _attachTokensListener();
    unawaited(_initialize());
    return const AppThemeMode.system();
  }

  Future<void> setMode(AppThemeMode mode) async {
    state = mode;
    final ThemeRepository repository = ref.read(themeRepositoryProvider);
    await repository.saveThemeMode(mode);
  }

  void _attachTokensListener() {
    if (_tokensListenerAttached) {
      return;
    }
    _tokensListenerAttached = true;
    ref.listen<AsyncValue<KopimThemeTokenBundle>>(appThemeTokensProvider, (
      AsyncValue<KopimThemeTokenBundle>? previous,
      AsyncValue<KopimThemeTokenBundle> next,
    ) {
      if (next.hasValue && _initialized) {
        unawaited(_initialize(forceReload: true));
      }
    });
  }

  Future<void> _initialize({bool forceReload = false}) {
    if (forceReload) {
      _initialized = false;
    }
    if (_initialized) {
      return _initializationCompleter?.future ?? Future<void>.value();
    }
    if (_initializationCompleter != null) {
      return _initializationCompleter!.future;
    }

    final Completer<void> completer = Completer<void>();
    _initializationCompleter = completer;

    () async {
      try {
        final ThemeRepository repository = ref.read(themeRepositoryProvider);
        final AppThemeMode storedMode = await repository.loadThemeMode();
        if (!ref.mounted) {
          completer.complete();
          return;
        }
        state = storedMode;
        _initialized = true;
        completer.complete();
      } catch (error, stackTrace) {
        if (!completer.isCompleted) {
          completer.completeError(error, stackTrace);
        }
      } finally {
        if (identical(_initializationCompleter, completer)) {
          _initializationCompleter = null;
        }
      }
    }();

    return completer.future;
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
