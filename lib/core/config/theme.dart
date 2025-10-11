import 'package:flutter/material.dart';

/// Создаёт тему приложения с учётом Material 3 и новой базовой палитры.
ThemeData buildAppTheme({required Brightness brightness}) {
  const Color accentColor = Color(0xFFE8FD00);
  final bool isDark = brightness == Brightness.dark;
  final ColorScheme baseScheme = ColorScheme.fromSeed(
    seedColor: accentColor,
    brightness: brightness,
  );
  final ColorScheme colorScheme = baseScheme;
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
