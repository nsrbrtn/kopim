import 'package:flutter/material.dart';
import 'package:kopim/core/config/theme.dart';
import 'package:kopim/features/accounts/presentation/utils/account_card_gradients.dart';

class HomeAccountCardPalette {
  const HomeAccountCardPalette({
    required this.background,
    required this.emphasis,
    required this.support,
    required this.summaryLabel,
  });

  factory HomeAccountCardPalette.fromAccount({
    required ColorScheme colorScheme,
    Color? accountColor,
    AccountCardGradient? gradient,
    required bool isHighlighted,
  }) {
    final ColorScheme invariantCardColorScheme = buildAppTheme(
      brightness: Brightness.dark,
    ).colorScheme;
    final Color defaultBackground = isHighlighted
        ? invariantCardColorScheme.primary
        : invariantCardColorScheme.tertiary;
    final Color background =
        gradient?.sampleColor ?? accountColor ?? defaultBackground;
    final Brightness brightness = ThemeData.estimateBrightnessForColor(
      background,
    );
    final Color emphasis = brightness == Brightness.dark
        ? colorScheme.surface
        : colorScheme.onSurface;
    final Color support = brightness == Brightness.dark
        ? colorScheme.surface.withValues(alpha: 0.78)
        : colorScheme.onSurface;
    return HomeAccountCardPalette(
      background: background,
      emphasis: emphasis,
      support: support,
      summaryLabel: support,
    );
  }

  final Color background;
  final Color emphasis;
  final Color support;
  final Color summaryLabel;
}
