import 'package:flutter/material.dart';

class AppSplashPlaceholder extends StatelessWidget {
  const AppSplashPlaceholder({super.key});

  static const Color _lightBackground = Color(0xFFFFFFFF);
  static const Color _darkBackground = Color(0xFF121212);

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = MediaQuery.platformBrightnessOf(context);
    final bool isDark = brightness == Brightness.dark;

    return ColoredBox(
      color: isDark ? _darkBackground : _lightBackground,
      child: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ),
    );
  }
}
