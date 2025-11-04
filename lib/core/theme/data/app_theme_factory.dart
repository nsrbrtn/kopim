import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:kopim/core/config/theme.dart';
import 'dto/kopim_theme_tokens.dart';
import 'generated/kopim_theme_tokens.g.dart';

part 'app_theme_factory.g.dart';

typedef ThemeTokensLoader = Future<KopimThemeTokenBundle> Function();

class AppThemeFactory {
  const AppThemeFactory({ThemeTokensLoader? tokenLoader})
    : _tokenLoader = tokenLoader;

  final ThemeTokensLoader? _tokenLoader;

  KopimThemeTokenBundle get fallbackTokens => kopimThemeTokens;

  Future<KopimThemeTokenBundle> loadTokens() async {
    final ThemeTokensLoader? loader = _tokenLoader;
    if (loader == null) {
      return fallbackTokens;
    }
    return loader();
  }

  ThemeData createTheme({
    required Brightness brightness,
    required KopimThemeTokenBundle tokens,
  }) {
    return buildAppTheme(brightness: brightness, tokensOverride: tokens);
  }
}

@riverpod
AppThemeFactory appThemeFactory(Ref ref) {
  return const AppThemeFactory();
}

@riverpod
Future<KopimThemeTokenBundle> appThemeTokens(Ref ref) async {
  final AppThemeFactory factory = ref.watch(appThemeFactoryProvider);
  return factory.loadTokens();
}
