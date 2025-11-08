import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kopim/features/analytics/presentation/analytics_screen.dart';
import 'package:kopim/features/budgets/presentation/budgets_screen.dart';
import 'package:kopim/features/categories/presentation/screens/manage_categories_screen.dart';
import 'package:kopim/features/home/domain/entities/home_dashboard_preferences.dart';
import 'package:kopim/features/home/presentation/controllers/home_dashboard_preferences_controller.dart';
import 'package:kopim/features/profile/presentation/screens/general_settings_screen.dart';
import 'package:kopim/features/profile/presentation/widgets/home_dashboard_visibility_card.dart';
import 'package:kopim/features/savings/presentation/screens/savings_list_screen.dart';
import 'package:kopim/features/upcoming_payments/presentation/screens/upcoming_payments_screen.dart';
import 'package:kopim/l10n/app_localizations.dart';

class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  static const String routeName = '/menu';

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
        title: Text(strings.profileMenuTitle),
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
                backgroundColor: _settingsMenuContainerColor(theme),
                borderRadius: 28,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              ),
              const SizedBox(height: 8),
            ],
            preferencesAsync.when(
              data: (HomeDashboardPreferences preferences) =>
                  HomeDashboardVisibilityCard(
                    strings: strings,
                    preferences: preferences,
                    onToggleGamification: (bool value) => ref
                        .read(
                          homeDashboardPreferencesControllerProvider.notifier,
                        )
                        .setShowGamification(value),
                    onToggleBudget: (bool value) => ref
                        .read(
                          homeDashboardPreferencesControllerProvider.notifier,
                        )
                        .setShowBudget(value),
                    onToggleRecurring: (bool value) => ref
                        .read(
                          homeDashboardPreferencesControllerProvider.notifier,
                        )
                        .setShowRecurring(value),
                    onToggleSavings: (bool value) => ref
                        .read(
                          homeDashboardPreferencesControllerProvider.notifier,
                        )
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
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 106),
        child: FloatingActionButton(
          tooltip: strings.profileGeneralSettingsTooltip,
          onPressed: () => _openGeneralSettings(context),
          child: const Icon(Icons.settings_outlined),
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
    this.backgroundColor,
    this.borderRadius = 16,
    this.contentPadding =
        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  });

  final IconData icon;
  final String label;
  final TextStyle? textStyle;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double borderRadius;
  final EdgeInsetsGeometry contentPadding;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color iconColor = theme.colorScheme.onSurfaceVariant;

    return Material(
      color: backgroundColor ?? Colors.transparent,
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: contentPadding,
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Color _settingsMenuContainerColor(ThemeData theme) {
  final bool isDark = theme.brightness == Brightness.dark;
  return theme.colorScheme.surfaceContainerHighest.withAlpha(
    (255 * (isDark ? 0.4 : 0.8)).round(),
  );
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


  Future<void> _openGeneralSettings(BuildContext context) async {
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const GeneralSettingsScreen(),
      ),
    );
  }
