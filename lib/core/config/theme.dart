import 'package:flutter/material.dart';

import 'theme_extensions.dart';
import '../theme/data/dto/kopim_theme_tokens.dart';
import '../theme/data/generated/kopim_theme_tokens.g.dart';

ThemeData buildAppTheme({required Brightness brightness}) {
  const KopimThemeTokenBundle tokens = kopimThemeTokens;
  final KopimSystemColorTokens systemColors = brightness == Brightness.dark
      ? tokens.darkColors
      : tokens.lightColors;

  final ColorScheme colorScheme = ColorScheme(
    brightness: brightness,
    primary: systemColors.primary,
    onPrimary: systemColors.onPrimary,
    primaryContainer: systemColors.primaryContainer,
    onPrimaryContainer: systemColors.onPrimaryContainer,
    primaryFixed: systemColors.primaryFixed,
    primaryFixedDim: systemColors.primaryFixedDim,
    onPrimaryFixed: systemColors.onPrimaryFixed,
    onPrimaryFixedVariant: systemColors.onPrimaryFixedVariant,
    secondary: systemColors.secondary,
    onSecondary: systemColors.onSecondary,
    secondaryContainer: systemColors.secondaryContainer,
    onSecondaryContainer: systemColors.onSecondaryContainer,
    secondaryFixed: systemColors.secondaryFixed,
    secondaryFixedDim: systemColors.secondaryFixedDim,
    onSecondaryFixed: systemColors.onSecondaryFixed,
    onSecondaryFixedVariant: systemColors.onSecondaryFixedVariant,
    tertiary: systemColors.tertiary,
    onTertiary: systemColors.onTertiary,
    tertiaryContainer: systemColors.tertiaryContainer,
    onTertiaryContainer: systemColors.onTertiaryContainer,
    tertiaryFixed: systemColors.tertiaryFixed,
    tertiaryFixedDim: systemColors.tertiaryFixedDim,
    onTertiaryFixed: systemColors.onTertiaryFixed,
    onTertiaryFixedVariant: systemColors.onTertiaryFixedVariant,
    error: systemColors.error,
    onError: systemColors.onError,
    errorContainer: systemColors.errorContainer,
    onErrorContainer: systemColors.onErrorContainer,
    surface: systemColors.surface,
    onSurface: systemColors.onSurface,
    surfaceDim: systemColors.surfaceDim,
    surfaceBright: systemColors.surfaceBright,
    surfaceContainerLowest: systemColors.surfaceContainerLowest,
    surfaceContainerLow: systemColors.surfaceContainerLow,
    surfaceContainer: systemColors.surfaceContainer,
    surfaceContainerHigh: systemColors.surfaceContainerHigh,
    surfaceContainerHighest: systemColors.surfaceContainerHighest,
    onSurfaceVariant: systemColors.onSurfaceVariant,
    outline: systemColors.outline,
    outlineVariant: systemColors.outlineVariant,
    shadow: systemColors.shadow,
    scrim: systemColors.scrim,
    inverseSurface: systemColors.inverseSurface,
    onInverseSurface: systemColors.inverseOnSurface,
    inversePrimary: systemColors.inversePrimary,
    surfaceTint: systemColors.surfaceTint,
    // ignore: deprecated_member_use
    background: systemColors.background,
    // ignore: deprecated_member_use
    onBackground: systemColors.onBackground,
    // ignore: deprecated_member_use
    surfaceVariant: systemColors.surfaceVariant,
  );

  final TextTheme textTheme = _buildTextTheme(tokens.typography).apply(
    displayColor: colorScheme.onSurface,
    bodyColor: colorScheme.onSurface,
  );

  final KopimSpecialSurfaces specialSurfaces = KopimSpecialSurfaces(
    fabGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: <Color>[
        tokens.specialSurfaces.fabGradientStart,
        tokens.specialSurfaces.fabGradientEnd,
      ],
    ),
    navigationBarLight: tokens.specialSurfaces.navbarLight,
    navigationBarDark: tokens.specialSurfaces.navbarDark,
  );

  final KopimMotion motionExtension = KopimMotion(
    durations: KopimMotionDurationsData(
      xxs: tokens.motion.durations.xxs,
      xs: tokens.motion.durations.xs,
      sm: tokens.motion.durations.sm,
      md: tokens.motion.durations.md,
      lg: tokens.motion.durations.lg,
      xl: tokens.motion.durations.xl,
      xxl: tokens.motion.durations.xxl,
    ),
    curves: KopimMotionCurvesData(
      standard: tokens.motion.easing.standard,
      decelerate: tokens.motion.easing.decelerate,
      accelerate: tokens.motion.easing.accelerate,
      emphasized: tokens.motion.easing.emphasized,
    ),
  );

  final Map<String, double> spacing = tokens.spacing.values;
  final Map<String, double> radius = tokens.shape.radius;
  final Map<String, double> borderWidth = tokens.shape.borderWidth;
  final Map<String, double> touchSizes = tokens.sizes.touch;

  final Color navigationBarBackground = brightness == Brightness.dark
      ? specialSurfaces.navigationBarDark
      : specialSurfaces.navigationBarLight;

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.surface,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      elevation: 0,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: colorScheme.onSurface,
      ),
      foregroundColor: colorScheme.onSurface,
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: touchSizes['comfortable'] ?? 56.0,
      backgroundColor: navigationBarBackground,
      indicatorColor: colorScheme.secondaryContainer,
      elevation: 0,
      iconTheme: WidgetStateProperty.resolveWith(
        (Set<WidgetState> states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? colorScheme.onSecondaryContainer
              : colorScheme.onSurfaceVariant,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (Set<WidgetState> states) => states.contains(WidgetState.selected)
            ? textTheme.labelMedium
            : textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
      ),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: colorScheme.surface,
      indicatorColor: colorScheme.secondaryContainer,
      useIndicator: true,
      selectedIconTheme: IconThemeData(color: colorScheme.onSecondaryContainer),
      unselectedIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
      selectedLabelTextStyle: textTheme.labelLarge,
      unselectedLabelTextStyle: textTheme.labelLarge?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
    ),
    cardTheme: CardThemeData(
      color: colorScheme.surface,
      elevation: 0,
      margin: EdgeInsets.all(_spacing(spacing, '16', 16)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_spacing(radius, 'lg', 16)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_spacing(radius, 'xl', 24)),
      ),
      titleTextStyle: textTheme.titleLarge,
      contentTextStyle: textTheme.bodyMedium,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest,
      contentPadding: EdgeInsets.symmetric(
        horizontal: _spacing(spacing, '16', 16),
        vertical: _spacing(spacing, '12', 12),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_spacing(radius, 'md', 12)),
        borderSide: BorderSide(
          color: colorScheme.outlineVariant,
          width: _spacing(borderWidth, 'thin', 1),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_spacing(radius, 'md', 12)),
        borderSide: BorderSide(
          color: colorScheme.primary,
          width: _spacing(borderWidth, 'medium', 2),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_spacing(radius, 'md', 12)),
        borderSide: BorderSide(
          color: colorScheme.outlineVariant,
          width: _spacing(borderWidth, 'thin', 1),
        ),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_spacing(radius, 'full', 9999)),
      ),
      foregroundColor: colorScheme.onPrimary,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        elevation: const WidgetStatePropertyAll<double>(0),
        padding: WidgetStatePropertyAll<EdgeInsets>(
          EdgeInsets.symmetric(
            horizontal: _spacing(spacing, '16', 16),
            vertical: _spacing(spacing, '12', 12),
          ),
        ),
        shape: WidgetStatePropertyAll<OutlinedBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_spacing(radius, 'lg', 16)),
          ),
        ),
        textStyle: WidgetStatePropertyAll<TextStyle>(
          textTheme.labelLarge ?? const TextStyle(),
        ),
        backgroundColor: WidgetStateProperty.resolveWith((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.disabled)) {
            return colorScheme.surfaceContainerHighest;
          }
          return colorScheme.primary;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.disabled)) {
            return colorScheme.onSurface.withAlpha(
              _scaledAlpha(colorScheme.onSurface, 0.38),
            );
          }
          return colorScheme.onPrimary;
        }),
        overlayColor: WidgetStateProperty.resolveWith((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.pressed) ||
              states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.focused)) {
            return colorScheme.onPrimary.withAlpha(
              _scaledAlpha(colorScheme.onPrimary, 0.12),
            );
          }
          return null;
        }),
      ),
    ),
    iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
    extensions: <ThemeExtension<dynamic>>[specialSurfaces, motionExtension],
  );
}

TextTheme _buildTextTheme(KopimTypographyTokens tokens) {
  return TextTheme(
    displayLarge: _textStyle(tokens.displayLarge),
    displayMedium: _textStyle(tokens.displayMedium),
    displaySmall: _textStyle(tokens.displaySmall),
    headlineLarge: _textStyle(tokens.headlineLarge),
    headlineMedium: _textStyle(tokens.headlineMedium),
    headlineSmall: _textStyle(tokens.headlineSmall),
    titleLarge: _textStyle(tokens.titleLarge),
    titleMedium: _textStyle(tokens.titleMedium),
    titleSmall: _textStyle(tokens.titleSmall),
    bodyLarge: _textStyle(tokens.bodyLarge),
    bodyMedium: _textStyle(tokens.bodyMedium),
    bodySmall: _textStyle(tokens.bodySmall),
    labelLarge: _textStyle(tokens.labelLarge),
    labelMedium: _textStyle(tokens.labelMedium),
    labelSmall: _textStyle(tokens.labelSmall),
  );
}

TextStyle _textStyle(KopimTextStyleTokens token) {
  final double height = token.fontSize == 0
      ? 1
      : token.lineHeight / token.fontSize;
  return TextStyle(
    fontFamily: token.fontFamily,
    fontWeight: token.fontWeight,
    fontSize: token.fontSize,
    height: height,
    letterSpacing: token.letterSpacing,
  );
}

double _spacing(Map<String, double> values, String key, double fallback) {
  return values[key] ?? fallback;
}

int _scaledAlpha(Color color, double factor) {
  final int computed = (color.a * 255.0 * factor).round();
  return computed.clamp(0, 255);
}
