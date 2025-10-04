import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/main_navigation_controller.dart';
import '../models/navigation_tab_config.dart';
import '../models/navigation_tab_content.dart';
import '../providers/main_navigation_tabs_provider.dart';

class MainNavigationShell extends ConsumerWidget {
  const MainNavigationShell({super.key});

  static const String routeName = '/home';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<NavigationTabConfig> tabs = ref.watch(
      mainNavigationTabsProvider,
    );
    final int currentIndex = ref.watch(mainNavigationControllerProvider);
    final List<NavigationTabContent> contents = <NavigationTabContent>[
      for (final NavigationTabConfig config in tabs)
        config.contentBuilder(context, ref),
    ];
    final NavigationTabContent activeContent = contents[currentIndex];
    final bool isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? true;
    final PreferredSizeWidget? appBar = activeContent.appBarBuilder?.call(
      context,
      ref,
    );
    final Widget? floatingActionButton = activeContent
        .floatingActionButtonBuilder
        ?.call(context, ref);

    return Scaffold(
      appBar: appBar,
      body: IndexedStack(
        index: currentIndex,
        children: <Widget>[
          for (final NavigationTabContent content in contents)
            content.bodyBuilder(context, ref),
        ],
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: isCurrentRoute
          ? BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: (int index) => ref
                  .read(mainNavigationControllerProvider.notifier)
                  .setIndex(index),
              items: <BottomNavigationBarItem>[
                for (final NavigationTabConfig config in tabs)
                  BottomNavigationBarItem(
                    icon: Icon(config.icon),
                    activeIcon: Icon(config.activeIcon),
                    label: config.labelBuilder(context),
                  ),
              ],
            )
          : null,
    );
  }
}
