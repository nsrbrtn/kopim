import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kopim/features/ai/presentation/screens/assistant_screen.dart';
import 'package:kopim/features/analytics/presentation/analytics_screen.dart';
import 'package:kopim/features/budgets/presentation/budgets_screen.dart';
import 'package:kopim/features/home/presentation/screens/home_screen.dart';
import 'package:kopim/features/profile/presentation/screens/menu_screen.dart';
import 'package:kopim/l10n/app_localizations.dart';

import '../models/navigation_tab_config.dart';
import '../models/navigation_tab_content.dart';

final Provider<List<NavigationTabConfig>> mainNavigationTabsProvider =
    Provider<List<NavigationTabConfig>>((Ref ref) {
      return <NavigationTabConfig>[
        NavigationTabConfig(
          id: 'home',
          icon: Icons.home_outlined,
          activeIcon: Icons.home,
          labelBuilder: (BuildContext context) =>
              AppLocalizations.of(context)!.homeNavHome,
          contentBuilder: buildHomeTabContent,
        ),
        NavigationTabConfig(
          id: 'analytics',
          icon: Icons.show_chart_outlined,
          activeIcon: Icons.show_chart,
          labelBuilder: (BuildContext context) =>
              AppLocalizations.of(context)!.homeNavAnalytics,
          contentBuilder: buildAnalyticsTabContent,
        ),
        NavigationTabConfig(
          id: 'assistant',
          icon: Icons.smart_toy_outlined,
          activeIcon: Icons.smart_toy,
          labelBuilder: (BuildContext context) =>
              AppLocalizations.of(context)!.homeNavAssistant,
          contentBuilder: buildAssistantTabContent,
        ),
        NavigationTabConfig(
          id: 'budgets',
          icon: Icons.account_balance_wallet_outlined,
          activeIcon: Icons.account_balance_wallet,
          labelBuilder: (BuildContext context) =>
              AppLocalizations.of(context)!.homeNavBudgets,
          contentBuilder: buildBudgetsTabContent,
        ),
        NavigationTabConfig(
          id: 'settings',
          icon: Icons.menu,
          activeIcon: Icons.menu_open,
          labelBuilder: (BuildContext context) =>
              AppLocalizations.of(context)!.homeNavSettings,
          contentBuilder: _buildMenuTabContent,
        ),
      ];
    });

NavigationTabContent _buildMenuTabContent(
  BuildContext context,
  WidgetRef ref,
) {
  return const NavigationTabContent(bodyBuilder: _menuBodyBuilder);
}

Widget _menuBodyBuilder(BuildContext context, WidgetRef ref) {
  return const MenuScreen();
}
