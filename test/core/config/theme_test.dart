import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/config/theme.dart';

void main() {
  group('buildAppTheme', () {
    test('использует Material 3 и новый акцентный цвет', () {
      const Color accentColor = Color(0xFF51AFF7);
      final ColorScheme expectedScheme = ColorScheme.fromSeed(
        seedColor: accentColor,
        brightness: Brightness.light,
      );
      final ThemeData theme = buildAppTheme(brightness: Brightness.light);

      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.primary, accentColor);
      expect(theme.colorScheme.secondary, accentColor);
      expect(theme.scaffoldBackgroundColor, expectedScheme.surface);
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
      const Color accentColor = Color(0xFF51AFF7);
      final ThemeData theme = buildAppTheme(brightness: Brightness.dark);

      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.brightness, Brightness.dark);
      expect(theme.colorScheme.primary, accentColor);
      expect(theme.colorScheme.secondary, accentColor);
      expect(theme.scaffoldBackgroundColor, const Color(0xFF141314));
    });
  });
}
