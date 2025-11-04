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

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final KopimSpecialSurfaces surfaces = theme.kopimSpecialSurfaces;
    final KopimLayout layout = theme.kopimLayout;
    final BorderRadius? extendedRadius = _isExtended
        ? BorderRadius.circular(layout.radius.card)
        : null;

    final Widget fab = _isExtended
        ? FloatingActionButton.extended(
            onPressed: onPressed,
            tooltip: tooltip,
            heroTag: heroTag,
            focusNode: focusNode,
            materialTapTargetSize: materialTapTargetSize,
            autofocus: autofocus,
            backgroundColor: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: extendedRadius!),
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
            child: child ?? icon,
          );

    final BorderRadiusGeometry clipRadius =
        extendedRadius ?? BorderRadius.circular(layout.radius.card);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: surfaces.fabGradient,
        shape: _isExtended ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: extendedRadius,
      ),
      child: ClipRRect(borderRadius: clipRadius, child: fab),
    );
  }
}
