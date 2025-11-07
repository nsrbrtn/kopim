import 'package:flutter/material.dart';
import 'package:kopim/core/config/theme_extensions.dart';

class KopimFloatingActionButton extends StatelessWidget {
  const KopimFloatingActionButton({
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

  bool get _isExtended => label != null;
  static const double _fabSize = 72;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final KopimLayout layout = theme.kopimLayout;
    final BorderRadius borderRadius =
        BorderRadius.circular(layout.radius.card);
    final double iconSize = layout.iconSizes.md * 3;
    final ShapeBorder shape = RoundedRectangleBorder(
      borderRadius: borderRadius,
    );

    final Widget fab = _isExtended
        ? FloatingActionButton.extended(
            onPressed: onPressed,
            tooltip: tooltip,
            heroTag: heroTag,
            focusNode: focusNode,
            materialTapTargetSize: materialTapTargetSize,
            autofocus: autofocus,
            backgroundColor: Colors.transparent,
            foregroundColor: colorScheme.onPrimary,
            elevation: 0,
            shape: shape,
            icon: icon,
            label: label!,
            clipBehavior: clipBehavior,
          )
        : FloatingActionButton(
            onPressed: onPressed,
            tooltip: tooltip,
            heroTag: heroTag,
            focusNode: focusNode,
            materialTapTargetSize: materialTapTargetSize,
            autofocus: autofocus,
            mini: mini,
            clipBehavior: clipBehavior,
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: colorScheme.onPrimary,
            shape: shape,
            child: child ?? icon,
          );

    final Widget sizedFab = SizedBox(
      height: _fabSize,
      width: _isExtended ? null : _fabSize,
      child: fab,
    );

    return IconTheme.merge(
      data: IconThemeData(size: iconSize),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: borderRadius,
          ),
          child: sizedFab,
        ),
      ),
    );
  }
}
