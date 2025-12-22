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
    this.size = CategoryChipSize.regular,
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
  final CategoryChipSize size;

  static const double _borderRadius = 32;

  @override
  Widget build(BuildContext context) {
    final _CategoryChipStyle style = _resolveStyle(size);
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final Color resolvedBackground =
        backgroundColor ?? colors.surfaceContainerHighest;
    final Color resolvedForeground = foregroundColor ?? colors.onSurfaceVariant;
    final Color resolvedIconBackground = iconBackgroundColor ?? colors.primary;
    final Color resolvedIconColor = iconColor ?? colors.surface;
    final Color selectedBorder = selected ? colors.primary : Colors.transparent;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(_borderRadius)),
        splashColor: theme.colorScheme.primary.withValues(alpha: 0.12),
        highlightColor: theme.colorScheme.primary.withValues(alpha: 0.08),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: style.height,
          padding: style.padding,
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
                theme.textTheme.labelMedium?.copyWith(
                  color: resolvedForeground,
                  fontWeight: style.fontWeight,
                  fontSize: style.fontSize,
                  letterSpacing: style.letterSpacing,
                  height: style.heightPx / style.fontSize,
                ) ??
                TextStyle(
                  color: resolvedForeground,
                  fontWeight: style.fontWeight,
                  fontSize: style.fontSize,
                  letterSpacing: style.letterSpacing,
                  height: style.heightPx / style.fontSize,
                ),
            child: IconTheme(
              data: IconThemeData(
                color: resolvedIconColor,
                size: style.iconSize,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (leading != null) ...<Widget>[
                    Container(
                      width: style.iconExtent,
                      height: style.iconExtent,
                      decoration: BoxDecoration(
                        color: resolvedIconBackground,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      alignment: Alignment.center,
                      child: leading,
                    ),
                    SizedBox(width: style.gap),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  ),
                  if (trailing != null) ...<Widget>[
                    SizedBox(width: style.gap),
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

enum CategoryChipSize { regular, small }

class _CategoryChipStyle {
  const _CategoryChipStyle({
    required this.height,
    required this.padding,
    required this.iconExtent,
    required this.iconSize,
    required this.gap,
    required this.fontSize,
    required this.fontWeight,
    required this.letterSpacing,
    required this.heightPx,
  });

  final double height;
  final EdgeInsets padding;
  final double iconExtent;
  final double iconSize;
  final double gap;
  final double fontSize;
  final FontWeight fontWeight;
  final double letterSpacing;
  final double heightPx;
}

_CategoryChipStyle _resolveStyle(CategoryChipSize size) {
  switch (size) {
    case CategoryChipSize.small:
      return const _CategoryChipStyle(
        height: 32,
        padding: EdgeInsets.fromLTRB(0, 0, 8, 0),
        iconExtent: 32,
        iconSize: 16,
        gap: 8,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        heightPx: 16,
      );
    case CategoryChipSize.regular:
      return const _CategoryChipStyle(
        height: 47,
        padding: EdgeInsets.fromLTRB(0, 0, 8, 0),
        iconExtent: 39,
        iconSize: 22,
        gap: 8,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        heightPx: 20,
      );
  }
}
