import 'dart:ui';

import 'package:flutter/material.dart';

double _alphaForOpacity(double opacity) {
  return opacity.clamp(0.0, 1.0);
}

/// Универсальная «жидкая стеклянная» поверхность под тему Kopim.
///
/// Используем её для навбара, карточек, тулбаров и других панелей.
class KopimGlassSurface extends StatelessWidget {
  const KopimGlassSurface({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(28)),
    this.padding,
    this.margin,
    this.blurSigma = 18.0,
    this.enableBorder = true,
    this.enableGradientHighlight = true,
    this.enableShadow = true,
    this.onTap,
    this.baseOpacity,
    this.gradientHighlightIntensity = 1.0,
    this.gradientTintColor,
  });

  /// Контент внутри стеклянной поверхности.
  final Widget child;

  /// Скругления краёв, по умолчанию — мягкие, как у карточек.
  final BorderRadius borderRadius;

  /// Внутренние отступы вокруг содержимого.
  final EdgeInsetsGeometry? padding;

  /// Внешние отступы для позиционирования поверхности.
  final EdgeInsetsGeometry? margin;

  /// Sigma для фильтра blur.
  final double blurSigma;

  /// Показывать ли тонкий бордер по краю.
  final bool enableBorder;

  /// Включить лёгкую подсветку-градиент.
  final bool enableGradientHighlight;

  /// Добавлять ли тень для эффекта «парения».
  final bool enableShadow;

  /// Обработчик тапа, если нужно.
  final VoidCallback? onTap;

  /// Основная прозрачность градиентного фона.
  ///
  /// Если не задано, используется 0.78/0.82 для тёмной/светлой темы.
  final double? baseOpacity;

  /// Интенсивность градиентной подсветки (0..1).
  final double gradientHighlightIntensity;

  /// Цвет внутреннего подсвечивания глазури.
  final Color? gradientTintColor;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;

    final double opacity = baseOpacity ?? (isDark ? 0.78 : 0.82);
    final Color baseColor =
        (isDark ? scheme.surfaceContainerHighest : scheme.surfaceContainerHigh)
            .withValues(alpha: _alphaForOpacity(opacity));

    final Color borderColor = scheme.onSurface.withValues(
      alpha: enableBorder ? _alphaForOpacity(isDark ? 0.22 : 0.18) : 0,
    );

    final List<BoxShadow>? shadows = enableShadow
        ? <BoxShadow>[
            BoxShadow(
              color: scheme.shadow.withValues(
                alpha: _alphaForOpacity(isDark ? 0.45 : 0.25),
              ),
              blurRadius: 24,
              offset: const Offset(0, 12),
              spreadRadius: -8,
            ),
          ]
        : null;

    final BoxDecoration decoration = BoxDecoration(
      borderRadius: borderRadius,
      color: baseColor,
      border: enableBorder ? Border.all(color: borderColor, width: 1) : null,
      boxShadow: shadows,
    );

    final List<Widget> stackChildren = <Widget>[];
    if (enableGradientHighlight && gradientHighlightIntensity > 0) {
      final Color lightGlare = Colors.white.withValues(
        alpha: _alphaForOpacity(
          (isDark ? 0.28 : 0.32) * gradientHighlightIntensity,
        ),
      );
      final Color tintedBase =
          gradientTintColor ??
          (isDark ? scheme.primary : scheme.secondaryContainer);
      final Color tintedGlow = tintedBase.withValues(
        alpha: _alphaForOpacity(
          (isDark ? 0.08 : 0.16) * gradientHighlightIntensity,
        ),
      );
      stackChildren.add(
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[lightGlare, Colors.transparent, tintedGlow],
                  stops: const <double>[0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),
        ),
      );
    }
    stackChildren.add(
      Padding(padding: padding ?? const EdgeInsets.all(16), child: child),
    );

    Widget content = DecoratedBox(
      decoration: decoration,
      child: Stack(fit: StackFit.expand, children: stackChildren),
    );

    if (onTap != null) {
      content = Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          splashColor: theme.splashColor.withValues(
            alpha: _alphaForOpacity(0.3),
          ),
          highlightColor: Colors.transparent,
          child: content,
        ),
      );
    }

    content = ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: content,
      ),
    );

    if (margin != null) {
      content = Padding(padding: margin!, child: content);
    }

    return RepaintBoundary(child: content);
  }
}
