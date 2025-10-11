import 'package:flutter/material.dart';

/// Создаёт тему приложения с учётом Material 3 и новой базовой палитры.
ThemeData buildAppTheme({required Brightness brightness}) {
  const Color accentColor = Color(0xFF51AFF7);
  final bool isDark = brightness == Brightness.dark;
  final ColorScheme baseScheme = ColorScheme.fromSeed(
    seedColor: accentColor,
    brightness: brightness,
  );
  final ColorScheme colorScheme = baseScheme.copyWith(
    primary: accentColor,
    secondary: accentColor,
    surfaceTint: accentColor,
  );
  final Color scaffoldBackground = isDark
      ? const Color(0xFF141314)
      : baseScheme.surface;

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: scaffoldBackground,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedIconTheme: IconThemeData(color: colorScheme.onSurface),
      unselectedIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
      selectedItemColor: colorScheme.onSurface,
      unselectedItemColor: colorScheme.onSurfaceVariant,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: accentColor,
      foregroundColor:
          ThemeData.estimateBrightnessForColor(accentColor) == Brightness.dark
          ? Colors.white
          : Colors.black,
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(side: BorderSide.none),
    ),
    dropdownMenuTheme: const DropdownMenuThemeData(
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
      ),
    ),
  );
}
