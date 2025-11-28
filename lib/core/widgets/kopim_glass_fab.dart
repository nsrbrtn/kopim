import 'package:flutter/material.dart';
import 'package:kopim/core/config/theme_extensions.dart';

import 'kopim_floating_action_button.dart';
import 'kopim_glass_surface.dart';

/// FAB в стеклянной капсуле с фирменным оформлением.
///
/// Оборачивает `KopimFloatingActionButton` в `KopimGlassSurface` с
/// единым стилем без ручного хардкода на экранах.
class KopimGlassFab extends StatelessWidget {
  const KopimGlassFab({
    super.key,
    required this.onPressed,
    this.child,
    this.icon,
    this.label,
    this.tooltip,
    this.heroTag,
    this.focusNode,
    this.materialTapTargetSize,
    this.autofocus = false,
    this.mini = false,
    this.clipBehavior = Clip.antiAlias,
    this.foregroundColor,
    this.iconSize,
    this.enableGradientHighlight = false,
  }) : assert(
         child != null || icon != null || label != null,
         'child, icon или label должны быть заданы',
       );

  final VoidCallback? onPressed;
  final Widget? child;
  final Widget? icon;
  final Widget? label;
  final String? tooltip;
  final Object? heroTag;
  final FocusNode? focusNode;
  final MaterialTapTargetSize? materialTapTargetSize;
  final bool autofocus;
  final bool mini;
  final Clip clipBehavior;
  final Color? foregroundColor;
  final double? iconSize;
  final bool enableGradientHighlight;

  static const double defaultIconSizePx = 64;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;
    final KopimLayout layout = theme.kopimLayout;
    final BorderRadius borderRadius = BorderRadius.circular(layout.radius.xxl);
    final double containerSize =
        KopimFloatingActionButton.defaultSize + layout.spacing.section;
    final double resolvedIconSize = iconSize ?? defaultIconSizePx;

    return SizedBox(
      height: containerSize,
      width: containerSize,
      child: KopimGlassSurface(
        padding: EdgeInsets.all(layout.spacing.between / 2),
        borderRadius: borderRadius,
        blurSigma: 7,
        baseOpacity: isDark ? 0.14 : 0.22,
        enableBorder: true,
        enableShadow: true,
        enableGradientHighlight: enableGradientHighlight,
        child: KopimFloatingActionButton(
          onPressed: onPressed,
          child: child,
          icon: icon,
          label: label,
          tooltip: tooltip,
          heroTag: heroTag,
          focusNode: focusNode,
          materialTapTargetSize: materialTapTargetSize,
          autofocus: autofocus,
          mini: mini,
          clipBehavior: clipBehavior,
          decorationColor: Colors.transparent,
          foregroundColor: foregroundColor ?? colorScheme.primary,
          iconSize: resolvedIconSize,
        ),
      ),
    );
  }
}
