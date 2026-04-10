import 'package:flutter/material.dart';

class AppSplashPlaceholder extends StatelessWidget {
  const AppSplashPlaceholder({super.key});

  static const Color _lightBackground = Color(0xFFFFFFFF);
  static const Color _darkBackground = Color(0xFF121212);
  static const double _logoWidth = 200;
  static const double _logoHeight = 37;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = MediaQuery.platformBrightnessOf(context);
    final bool isDark = brightness == Brightness.dark;
    final String logoAsset = isDark
        ? 'assets/icons/logo_dark.png'
        : 'assets/icons/logo_light.png';

    return ColoredBox(
      color: isDark ? _darkBackground : _lightBackground,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: _logoWidth,
                    maxHeight: _logoHeight,
                  ),
                  child: Image.asset(
                    logoAsset,
                    width: _logoWidth,
                    height: _logoHeight,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 24),
                const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
