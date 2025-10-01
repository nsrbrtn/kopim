import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kopim/features/analytics/presentation/analytics_screen.dart';
import 'package:kopim/features/home/presentation/screens/home_screen.dart';
import 'package:kopim/features/profile/presentation/screens/profile_screen.dart';
import 'package:kopim/l10n/app_localizations.dart';

import '../models/navigation_tab_config.dart';
import '../models/navigation_tab_content.dart';

final mainNavigationTabsProvider =
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
      id: 'settings',
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      labelBuilder: (BuildContext context) =>
          AppLocalizations.of(context)!.homeNavSettings,
      contentBuilder: buildProfileTabContent,
    ),
  ];
});
