import 'package:flutter/material.dart';

import 'package:kopim/core/config/theme_extensions.dart';

/// Универсальный виджет для отображения пустого состояния (Empty State) экрана.
/// Поддерживает иконку в декоративном контейнере, заголовок, описание и кнопку призыва к действию (CTA).
class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onActionPressed,
    this.isCompact = false,
  });

  /// Иконка для отображения
  final IconData icon;

  /// Заголовок пустого состояния
  final String title;

  /// Подробное описание
  final String description;

  /// Текст кнопки действия (опционально)
  final String? actionLabel;

  /// Обработчик нажатия на кнопку действия (опционально)
  final VoidCallback? onActionPressed;

  /// Флаг компактного режима (например, для встраивания в небольшие карточки на Home)
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final KopimLayout layout = context.kopimLayout;
    final KopimSpacingScale spacing = layout.spacing;

    final double iconSize = isCompact ? 32 : 48;
    final double containerSize = isCompact ? 56 : 80;
    final double paddingVertical = isCompact ? 16 : 32;
    final double paddingHorizontal = isCompact ? 16 : 24;

    final Widget iconWidget = Container(
      width: containerSize,
      height: containerSize,
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.25),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(icon, size: iconSize, color: colors.primary),
      ),
    );

    final List<Widget> children = <Widget>[
      iconWidget,
      SizedBox(height: isCompact ? 12 : spacing.section),
      Text(
        title,
        style:
            (isCompact
                    ? theme.textTheme.titleSmall
                    : theme.textTheme.titleMedium)
                ?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
        textAlign: TextAlign.center,
      ),
      SizedBox(height: isCompact ? 6 : spacing.between),
      Text(
        description,
        style:
            (isCompact ? theme.textTheme.bodySmall : theme.textTheme.bodyMedium)
                ?.copyWith(color: colors.onSurfaceVariant),
        textAlign: TextAlign.center,
      ),
      if (actionLabel != null && onActionPressed != null) ...<Widget>[
        SizedBox(height: isCompact ? 12 : spacing.section),
        if (isCompact)
          TextButton(onPressed: onActionPressed, child: Text(actionLabel!))
        else
          FilledButton(onPressed: onActionPressed, child: Text(actionLabel!)),
      ],
    ];

    if (isCompact) {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: paddingHorizontal,
          vertical: paddingVertical,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: children,
        ),
      );
    }

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: paddingHorizontal,
          vertical: paddingVertical,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: children,
        ),
      ),
    );
  }
}
