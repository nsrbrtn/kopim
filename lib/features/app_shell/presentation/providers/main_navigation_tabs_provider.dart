import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kopim/features/ai/presentation/screens/assistant_screen.dart';
import 'package:kopim/features/analytics/presentation/analytics_screen.dart';
import 'package:kopim/features/budgets/presentation/budgets_screen.dart';
import 'package:kopim/features/home/presentation/screens/home_screen.dart';
import 'package:kopim/features/profile/presentation/screens/general_settings_screen.dart';
import 'package:kopim/features/savings/presentation/screens/savings_list_screen.dart';
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
          id: 'savings',
          icon: Icons.savings_outlined,
          activeIcon: Icons.savings,
          labelBuilder: (BuildContext context) =>
              AppLocalizations.of(context)!.homeNavSavings,
          contentBuilder: buildSavingsTabContent,
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
          icon: Icons.settings_outlined,
          activeIcon: Icons.settings,
          labelBuilder: (BuildContext context) =>
              AppLocalizations.of(context)!.homeNavSettings,
          contentBuilder: _buildGeneralSettingsTabContent,
        ),
      ];
    });

NavigationTabContent _buildGeneralSettingsTabContent(
  BuildContext context,
  WidgetRef ref,
) {
  return const NavigationTabContent(bodyBuilder: _generalSettingsBodyBuilder);
}

Widget _generalSettingsBodyBuilder(BuildContext context, WidgetRef ref) {
  return const GeneralSettingsScreen();
}
