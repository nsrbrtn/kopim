import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kopim/features/analytics/presentation/analytics_screen.dart';
import 'package:kopim/features/budgets/presentation/budgets_screen.dart';
import 'package:kopim/features/categories/presentation/screens/manage_categories_screen.dart';
import 'package:kopim/features/home/domain/entities/home_dashboard_preferences.dart';
import 'package:kopim/features/home/presentation/controllers/home_dashboard_preferences_controller.dart';
import 'package:kopim/features/savings/presentation/screens/savings_list_screen.dart';
import 'package:kopim/features/upcoming_payments/presentation/screens/upcoming_payments_screen.dart';
import 'package:kopim/l10n/app_localizations.dart';

class GeneralSettingsScreen extends ConsumerWidget {
  const GeneralSettingsScreen({super.key});

  static const String routeName = '/settings/general';

  void _pushRoute(BuildContext context, String routeName) {
    final GoRouter? router = GoRouter.maybeOf(context);
    if (router != null) {
      router.push(routeName);
      return;
    }
    final NavigatorState? navigator = Navigator.maybeOf(context);
    if (navigator != null) {
      navigator.pushNamed(routeName);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    final AsyncValue<HomeDashboardPreferences> preferencesAsync = ref.watch(
      homeDashboardPreferencesControllerProvider,
    );

    final List<_SettingsMenuConfig> menuItems = <_SettingsMenuConfig>[
      _SettingsMenuConfig(
        label: strings.analyticsTitle,
        icon: Icons.bar_chart_outlined,
        onTap: () => _pushRoute(context, AnalyticsScreen.routeName),
      ),
      _SettingsMenuConfig(
        label: strings.budgetsTitle,
        icon: Icons.pie_chart_outline,
        onTap: () => _pushRoute(context, BudgetsScreen.routeName),
      ),
      _SettingsMenuConfig(
        label: strings.upcomingPaymentsTitle,
        icon: Icons.event_repeat_outlined,
        onTap: () => _pushRoute(context, UpcomingPaymentsScreen.routeName),
      ),
      _SettingsMenuConfig(
        label: strings.profileManageCategoriesCta,
        icon: Icons.category_outlined,
        onTap: () => _pushRoute(context, ManageCategoriesScreen.routeName),
      ),
      _SettingsMenuConfig(
        label: strings.savingsTitle,
        icon: Icons.savings_outlined,
        onTap: () => _pushRoute(context, SavingsListScreen.routeName),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(strings.profileGeneralSettingsTitle),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            for (final _SettingsMenuConfig config in menuItems) ...<Widget>[
              _SettingsMenuItem(
                icon: config.icon,
                label: config.label,
                onTap: config.onTap,
                textStyle: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
            ],
            preferencesAsync.when(
              data: (HomeDashboardPreferences preferences) =>
                  _HomeDashboardVisibilityMenu(
                strings: strings,
                preferences: preferences,
                onToggleGamification: (bool value) => ref
                    .read(homeDashboardPreferencesControllerProvider.notifier)
                    .setShowGamification(value),
                onToggleBudget: (bool value) => ref
                    .read(homeDashboardPreferencesControllerProvider.notifier)
                    .setShowBudget(value),
                onToggleRecurring: (bool value) => ref
                    .read(homeDashboardPreferencesControllerProvider.notifier)
                    .setShowRecurring(value),
                onToggleSavings: (bool value) => ref
                    .read(homeDashboardPreferencesControllerProvider.notifier)
                    .setShowSavings(value),
              ),
              loading: () => const _SettingsSkeleton(),
              error: (Object error, _) => _SettingsErrorMessage(
                message: strings.homeDashboardPreferencesError(
                  error.toString(),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const _SettingsFooterIcon(),
          ],
        ),
      ),
    );
  }
}

class _SettingsMenuConfig {
  const _SettingsMenuConfig({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
}

class _SettingsMenuItem extends StatelessWidget {
  const _SettingsMenuItem({
    required this.icon,
    required this.label,
    required this.textStyle,
    this.onTap,
    this.trailing,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final TextStyle? textStyle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color iconColor = theme.colorScheme.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(icon, color: iconColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(label, style: textStyle),
                    if (subtitle != null) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              trailing ??
                  Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeDashboardVisibilityMenu extends StatelessWidget {
  const _HomeDashboardVisibilityMenu({
    required this.strings,
    required this.preferences,
    required this.onToggleGamification,
    required this.onToggleBudget,
    required this.onToggleRecurring,
    required this.onToggleSavings,
  });

  final AppLocalizations strings;
  final HomeDashboardPreferences preferences;
  final ValueChanged<bool> onToggleGamification;
  final ValueChanged<bool> onToggleBudget;
  final ValueChanged<bool> onToggleRecurring;
  final ValueChanged<bool> onToggleSavings;

  void _handleToggle(_HomeDashboardToggle toggle) {
    switch (toggle) {
      case _HomeDashboardToggle.gamification:
        onToggleGamification(!preferences.showGamificationWidget);
        break;
      case _HomeDashboardToggle.budgets:
        onToggleBudget(!preferences.showBudgetWidget);
        break;
      case _HomeDashboardToggle.recurring:
        onToggleRecurring(!preferences.showRecurringWidget);
        break;
      case _HomeDashboardToggle.savings:
        onToggleSavings(!preferences.showSavingsWidget);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle? textStyle = theme.textTheme.bodyLarge?.copyWith(
      color: theme.colorScheme.onSurface,
    );
    final List<String> active = <String>[
      if (preferences.showGamificationWidget)
        strings.settingsHomeGamificationTitle,
      if (preferences.showBudgetWidget) strings.settingsHomeBudgetTitle,
      if (preferences.showRecurringWidget) strings.settingsHomeRecurringTitle,
      if (preferences.showSavingsWidget) strings.settingsHomeSavingsTitle,
    ];
    final String subtitle = active.isEmpty
        ? strings.settingsHomeBudgetSelectedNone
        : active.join(', ');
    final GlobalKey<PopupMenuButtonState<_HomeDashboardToggle>> menuKey =
        GlobalKey<PopupMenuButtonState<_HomeDashboardToggle>>();

    return _SettingsMenuItem(
      icon: Icons.home_outlined,
      label: strings.settingsHomeSectionTitle,
      textStyle: textStyle,
      subtitle: subtitle,
      onTap: () => menuKey.currentState?.showButtonMenu(),
      trailing: PopupMenuButton<_HomeDashboardToggle>(
        key: menuKey,
        icon: Icon(
          Icons.expand_more,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        onSelected: _handleToggle,
        itemBuilder: (BuildContext context) {
          return <PopupMenuEntry<_HomeDashboardToggle>>[
            CheckedPopupMenuItem<_HomeDashboardToggle>(
              value: _HomeDashboardToggle.gamification,
              checked: preferences.showGamificationWidget,
              child: Text(strings.settingsHomeGamificationTitle),
            ),
            CheckedPopupMenuItem<_HomeDashboardToggle>(
              value: _HomeDashboardToggle.budgets,
              checked: preferences.showBudgetWidget,
              child: Text(strings.settingsHomeBudgetTitle),
            ),
            CheckedPopupMenuItem<_HomeDashboardToggle>(
              value: _HomeDashboardToggle.recurring,
              checked: preferences.showRecurringWidget,
              child: Text(strings.settingsHomeRecurringTitle),
            ),
            CheckedPopupMenuItem<_HomeDashboardToggle>(
              value: _HomeDashboardToggle.savings,
              checked: preferences.showSavingsWidget,
              child: Text(strings.settingsHomeSavingsTitle),
            ),
          ];
        },
      ),
    );
  }
}

enum _HomeDashboardToggle {
  gamification,
  budgets,
  recurring,
  savings,
}

class _SettingsSkeleton extends StatelessWidget {
  const _SettingsSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _SettingsErrorMessage extends StatelessWidget {
  const _SettingsErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        message,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.error,
        ),
      ),
    );
  }
}

class _SettingsFooterIcon extends StatelessWidget {
  const _SettingsFooterIcon();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      child: Icon(
        Icons.settings_outlined,
        size: 32,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
