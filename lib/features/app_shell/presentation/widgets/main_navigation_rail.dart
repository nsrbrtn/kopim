import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/main_navigation_controller.dart';
import '../models/navigation_tab_config.dart';

class MainNavigationRail extends ConsumerWidget {
  const MainNavigationRail({
    super.key,
    required this.tabs,
    this.extended = false,
  });

  final List<NavigationTabConfig> tabs;
  final bool extended;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final int currentIndex = ref.watch(
      mainNavigationControllerProvider.select((int value) => value),
    );

    return SafeArea(
      child: NavigationRail(
        extended: extended,
        selectedIndex: currentIndex,
        onDestinationSelected: (int index) {
          if (index == currentIndex) {
            final NavigationTabSelectionCallback? onSelected =
                tabs[index].onSelected;
            if (onSelected != null) {
              onSelected(context, ref);
            }
            return;
          }

          ref.read(mainNavigationControllerProvider.notifier).setIndex(index);
          final NavigationTabSelectionCallback? onSelected =
              tabs[index].onSelected;
          if (onSelected != null) {
            onSelected(context, ref);
          }
        },
        backgroundColor: theme.colorScheme.surface,
        labelType: extended
            ? NavigationRailLabelType.none
            : NavigationRailLabelType.selected,
        destinations: <NavigationRailDestination>[
          for (final NavigationTabConfig config in tabs)
            NavigationRailDestination(
              icon: Icon(config.icon),
              selectedIcon: Icon(config.activeIcon),
              label: Text(config.labelBuilder(context)),
            ),
        ],
      ),
    );
  }
}
