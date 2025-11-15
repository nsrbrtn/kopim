import 'package:flutter/widgets.dart';

/// Данные для строки внутри свернутого списка.
@immutable
class CollapsibleListItem {
  const CollapsibleListItem({
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
}
