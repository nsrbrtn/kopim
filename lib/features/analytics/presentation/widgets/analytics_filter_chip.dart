import 'package:flutter/material.dart';

class AnalyticsFilterChip extends StatelessWidget {
  const AnalyticsFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.trailingIcon,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    return ActionChip(
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      shape: const StadiumBorder(),
      backgroundColor: selected ? colors.primary : colors.surfaceContainerHigh,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: selected ? colors.onPrimary : colors.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (trailingIcon != null) ...<Widget>[
            const SizedBox(width: 4),
            Icon(
              trailingIcon,
              size: 14,
              color: selected ? colors.onPrimary : colors.onSurface,
            ),
          ],
        ],
      ),
      labelStyle: theme.textTheme.labelMedium?.copyWith(
        color: selected ? colors.onPrimary : colors.onSurface,
        fontWeight: FontWeight.w500,
      ),
      side: BorderSide(
        color: selected ? Colors.transparent : colors.surfaceContainerHigh,
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      onPressed: onTap,
    );
  }
}
