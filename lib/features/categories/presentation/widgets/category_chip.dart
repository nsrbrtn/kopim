import 'package:flutter/material.dart';

/// Кастомный чип категории с фиксированной высотой и поддержкой состояния.
class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.label,
    this.backgroundColor,
    this.iconBackgroundColor,
    this.iconColor,
    this.foregroundColor,
    this.leading,
    this.trailing,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final Color? backgroundColor;
  final Color? iconBackgroundColor;
  final Color? iconColor;
  final Color? foregroundColor;
  final Widget? leading;
  final Widget? trailing;
  final bool selected;
  final VoidCallback? onTap;

  static const double _height = 24;
  static const EdgeInsets _padding = EdgeInsets.fromLTRB(2, 2, 8, 2);
  static const double _borderRadius = 32;
  static const double _iconExtent = 20;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color resolvedBackground = backgroundColor ?? const Color(0xFF67696A);
    final Color resolvedForeground = foregroundColor ?? const Color(0xFFEFF0E1);
    final Color resolvedIconBackground =
        iconBackgroundColor ?? theme.colorScheme.primary;
    final Color resolvedIconColor = iconColor ?? const Color(0xFF1C1B1B);
    final Color selectedBorder =
        selected ? theme.colorScheme.primary : Colors.transparent;

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
            color: resolvedBackground,
            borderRadius: const BorderRadius.all(
              Radius.circular(_borderRadius),
            ),
            border: Border.all(
              color: selectedBorder,
              width: selected ? 1.1 : 1,
            ),
          ),
          child: DefaultTextStyle(
            style:
                theme.textTheme.labelSmall?.copyWith(
                  color: resolvedForeground,
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                  letterSpacing: 0.5,
                  height: 16 / 11,
                ) ??
                TextStyle(
                  color: resolvedForeground,
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                  letterSpacing: 0.5,
                  height: 16 / 11,
                ),
            child: IconTheme(
              data: IconThemeData(color: resolvedIconColor, size: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (leading != null) ...<Widget>[
                    Container(
                      width: _iconExtent,
                      height: _iconExtent,
                      decoration: BoxDecoration(
                        color: resolvedIconBackground,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      alignment: Alignment.center,
                      child: leading,
                    ),
                    const SizedBox(width: 8),
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
