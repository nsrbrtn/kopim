import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/config/theme.dart';

void main() {
  group('buildAppTheme', () {
    test('использует Material 3 и ColorScheme.fromSeed', () {
      const Color seedColor = Color(0xFF8AEDAB);
      final ColorScheme expectedScheme = ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
      );
      final ThemeData theme = buildAppTheme(brightness: Brightness.light);

      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.primary, expectedScheme.primary);
      expect(theme.colorScheme.secondary, expectedScheme.secondary);
      expect(
        theme.bottomNavigationBarTheme.selectedItemColor,
        theme.colorScheme.onSurface,
      );
      expect(
        theme.bottomNavigationBarTheme.unselectedItemColor,
        theme.colorScheme.onSurfaceVariant,
      );
    });

    test('поддерживает тёмную тему', () {
      const Color seedColor = Color(0xFF8AEDAB);
      final ColorScheme expectedScheme = ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
      );
      final ThemeData theme = buildAppTheme(brightness: Brightness.dark);

      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.brightness, Brightness.dark);
      expect(theme.colorScheme.primary, expectedScheme.primary);
    });
  });
}
