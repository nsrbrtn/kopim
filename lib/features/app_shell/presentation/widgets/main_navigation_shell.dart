import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/main_navigation_controller.dart';
import '../models/navigation_tab_config.dart';
import '../models/navigation_tab_content.dart';
import '../providers/main_navigation_tabs_provider.dart';
import 'main_navigation_bar.dart';
import 'main_navigation_rail.dart';
import 'navigation_responsive_breakpoints.dart';

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

    final NavigatorState? activeNavigator =
        activeContent.navigatorKey?.currentState;

    final bool canPopNestedRoute = activeNavigator?.canPop() ?? false;
    final bool isOnHomeTab = currentIndex == 0;
    final bool allowSystemPop = !canPopNestedRoute && isOnHomeTab;

    return PopScope(
      canPop: allowSystemPop,
      onPopInvokedWithResult: (bool didPop, Object? _) {
        if (didPop) {
          return;
        }

        if (canPopNestedRoute && activeNavigator != null) {
          unawaited(activeNavigator.maybePop());
          return;
        }

        if (!isOnHomeTab) {
          ref.read(mainNavigationControllerProvider.notifier).setIndex(0);
        }
      },
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final _MainNavigationLayout layout = _MainNavigationLayout.fromWidth(
            constraints.maxWidth,
          );
          final bool showNavigation = isCurrentRoute;
          final bool useRail = showNavigation && layout.usesRail;
          final bool useBottomBar = showNavigation && layout.usesBottomBar;
          final bool enableTwoPane = useRail;

          final Widget stackedContent = IndexedStack(
            index: currentIndex,
            children: <Widget>[
              for (final NavigationTabContent content in contents)
                _NavigationTabPane(
                  primary: content.bodyBuilder(context, ref),
                  secondary: enableTwoPane
                      ? content.secondaryBodyBuilder?.call(context, ref)
                      : null,
                  enableTwoPane: enableTwoPane,
                ),
            ],
          );

          final Widget body = useRail
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    MainNavigationRail(
                      tabs: tabs,
                      extended: layout.isExtendedRail,
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(child: stackedContent),
                  ],
                )
              : stackedContent;

          return Scaffold(
            appBar: appBar,
            body: body,
            floatingActionButton: floatingActionButton,
            bottomNavigationBar: useBottomBar
                ? MainNavigationBar(tabs: tabs)
                : null,
          );
        },
      ),
    );
  }
}

class _NavigationTabPane extends StatelessWidget {
  const _NavigationTabPane({
    required this.primary,
    this.secondary,
    required this.enableTwoPane,
  });

  final Widget primary;
  final Widget? secondary;
  final bool enableTwoPane;

  @override
  Widget build(BuildContext context) {
    if (!enableTwoPane || secondary == null) {
      return primary;
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double totalWidth = constraints.maxWidth;
        final double secondaryWidth = (totalWidth * 0.38)
            .clamp(280, 420)
            .toDouble();

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(child: primary),
            const VerticalDivider(width: 1),
            ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: secondaryWidth,
                maxWidth: secondaryWidth,
              ),
              child: ClipRect(child: secondary!),
            ),
          ],
        );
      },
    );
  }
}

enum _MainNavigationLayout {
  bottom,
  rail,
  extendedRail;

  static _MainNavigationLayout fromWidth(double width) {
    if (width >= kMainNavigationExtendedRailBreakpoint) {
      return _MainNavigationLayout.extendedRail;
    }
    if (width >= kMainNavigationRailBreakpoint) {
      return _MainNavigationLayout.rail;
    }
    return _MainNavigationLayout.bottom;
  }

  bool get usesBottomBar => this == _MainNavigationLayout.bottom;

  bool get usesRail =>
      this == _MainNavigationLayout.rail ||
      this == _MainNavigationLayout.extendedRail;

  bool get isExtendedRail => this == _MainNavigationLayout.extendedRail;
}
