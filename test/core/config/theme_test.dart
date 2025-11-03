import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/config/theme.dart';
import 'package:kopim/core/config/theme_extensions.dart';
import 'package:kopim/core/theme/data/generated/kopim_theme_tokens.g.dart';

void main() {
  group('buildAppTheme', () {
    test('возвращает тему с токенами светлой палитры', () {
      final ThemeData theme = buildAppTheme(brightness: Brightness.light);

      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.primary, kopimThemeTokens.lightColors.primary);
      expect(theme.textTheme.displayLarge?.fontFamily, 'Onest');
      expect(theme.textTheme.bodyMedium?.fontFamily, 'Inter');
      expect(
        theme.navigationBarTheme.backgroundColor,
        kopimThemeTokens.specialSurfaces.navbarLight,
      );

      final KopimSpecialSurfaces surfaces = theme
          .extension<KopimSpecialSurfaces>()!;
      expect(
        surfaces.fabGradient.colors.first,
        kopimThemeTokens.specialSurfaces.fabGradientStart,
      );
      expect(
        surfaces.navigationBarLight,
        kopimThemeTokens.specialSurfaces.navbarLight,
      );
    });

    test('возвращает тему с токенами тёмной палитры', () {
      final ThemeData theme = buildAppTheme(brightness: Brightness.dark);

      expect(theme.colorScheme.primary, kopimThemeTokens.darkColors.primary);
      expect(
        theme.navigationBarTheme.backgroundColor,
        kopimThemeTokens.specialSurfaces.navbarDark,
      );

      final KopimMotion motion = theme.extension<KopimMotion>()!;
      expect(motion.durations.md, kopimThemeTokens.motion.durations.md);
      expect(motion.curves.standard, kopimThemeTokens.motion.easing.standard);
    });
  });
}
