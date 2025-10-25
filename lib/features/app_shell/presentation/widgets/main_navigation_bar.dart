import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/main_navigation_controller.dart';
import '../models/navigation_tab_config.dart';

class MainNavigationBar extends ConsumerWidget {
  const MainNavigationBar({super.key, required this.tabs});

  final List<NavigationTabConfig> tabs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int currentIndex = ref.watch(
      mainNavigationControllerProvider.select((int value) => value),
    );

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (int index) {
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
      items: <BottomNavigationBarItem>[
        for (final NavigationTabConfig config in tabs)
          BottomNavigationBarItem(
            icon: Icon(config.icon),
            activeIcon: Icon(config.activeIcon),
            label: config.labelBuilder(context),
          ),
      ],
    );
  }
}
