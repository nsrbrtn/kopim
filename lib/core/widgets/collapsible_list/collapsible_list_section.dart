import 'package:flutter/widgets.dart';

/// Набор параметров для секции свернутого списка.
@immutable
class CollapsibleListSection {
  const CollapsibleListSection({
    required this.id,
    required this.title,
    required this.child,
    this.description,
    this.initiallyExpanded = false,
    this.duration,
  });

  final String id;
  final String title;
  final Widget child;
  final String? description;
  final bool initiallyExpanded;
  final Duration? duration;
}
