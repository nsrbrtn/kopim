import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'navigation_tab_content.dart';

typedef NavigationTabContentBuilder =
    NavigationTabContent Function(BuildContext context, WidgetRef ref);

typedef NavigationTabSelectionCallback =
    void Function(BuildContext context, WidgetRef ref);

typedef NavigationTabLabelBuilder = String Function(BuildContext context);

class NavigationTabConfig {
  const NavigationTabConfig({
    required this.id,
    required this.icon,
    required this.activeIcon,
    required this.labelBuilder,
    required this.contentBuilder,
    this.onSelected,
  });

  final String id;
  final IconData icon;
  final IconData activeIcon;
  final NavigationTabLabelBuilder labelBuilder;
  final NavigationTabContentBuilder contentBuilder;
  final NavigationTabSelectionCallback? onSelected;
}
