import 'package:flutter/material.dart';

ThemeData buildSettingsButtonTheme(ThemeData base) {
  final ButtonStyle resolvedStyle =
      FilledButton.styleFrom(
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ).copyWith(
        side: const WidgetStatePropertyAll<BorderSide>(
          BorderSide(style: BorderStyle.none),
        ),
      );

  return base.copyWith(
    filledButtonTheme: FilledButtonThemeData(style: resolvedStyle),
  );
}
