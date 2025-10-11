import 'package:flutter/material.dart';

/// Кастомный чип категории с фиксированной высотой и поддержкой состояния.
class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.label,
    this.backgroundColor,
    this.foregroundColor,
    this.leading,
    this.trailing,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Widget? leading;
  final Widget? trailing;
  final bool selected;
  final VoidCallback? onTap;

  static const double _height = 24;
  static const EdgeInsets _padding = EdgeInsets.symmetric(
    horizontal: 8,
    vertical: 2,
  );
  static const double _borderRadius = 12;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color resolvedBackground =
        backgroundColor ?? theme.colorScheme.surfaceContainerHighest;
    final Brightness backgroundBrightness =
        ThemeData.estimateBrightnessForColor(resolvedBackground);
    final Color resolvedForeground =
        foregroundColor ??
        (backgroundBrightness == Brightness.dark
            ? Colors.white
            : Colors.black87);
    final Color selectedOverlay = theme.colorScheme.primary.withValues(
      alpha: 0.14,
    );

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(_borderRadius)),
        splashColor: theme.colorScheme.primary.withValues(alpha: 0.12),
        highlightColor: theme.colorScheme.primary.withValues(alpha: 0.08),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: _height,
          padding: _padding,
          decoration: BoxDecoration(
            color: selected
                ? Color.alphaBlend(selectedOverlay, resolvedBackground)
                : resolvedBackground,
            borderRadius: const BorderRadius.all(
              Radius.circular(_borderRadius),
            ),
            border: Border.all(
              color: selected ? theme.colorScheme.primary : Colors.transparent,
              width: selected ? 1.2 : 1,
            ),
          ),
          child: DefaultTextStyle(
            style:
                theme.textTheme.labelMedium?.copyWith(
                  color: resolvedForeground,
                  fontWeight: FontWeight.w600,
                ) ??
                TextStyle(
                  color: resolvedForeground,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
            child: IconTheme(
              data: IconThemeData(color: resolvedForeground, size: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (leading != null) ...<Widget>[
                    leading!,
                    const SizedBox(width: 4),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  ),
                  if (trailing != null) ...<Widget>[
                    const SizedBox(width: 4),
                    trailing!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
