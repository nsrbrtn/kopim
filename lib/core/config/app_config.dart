// lib/core/config/app_config.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'theme.dart';

// Provider для locale (init по умолчанию ru, или из хранилища)
final Provider<Locale> appLocaleProvider = Provider<Locale>((Ref ref) {
  // Здесь можно читать из SharedPreferences или Drift для persistent locale
  return const Locale('ru'); // По умолчанию русский, как в стиле проекта
});

// Другие providers: theme, auth и т.д.
final Provider<ThemeData> appThemeProvider = Provider<ThemeData>((Ref ref) {
  return buildAppTheme(brightness: Brightness.light);
});

final Provider<ThemeData> appDarkThemeProvider = Provider<ThemeData>((Ref ref) {
  return buildAppTheme(brightness: Brightness.dark);
});
