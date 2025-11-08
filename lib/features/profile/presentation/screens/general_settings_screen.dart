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
                backgroundColor: _settingsMenuContainerColor(theme),
                borderRadius: 28,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
    this.backgroundColor,
    this.borderRadius = 16,
    this.contentPadding =
        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  });

  final IconData icon;
  final String label;
  final TextStyle? textStyle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final String? subtitle;
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
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

Color _settingsMenuContainerColor(ThemeData theme) {
  return theme.colorScheme.surfaceVariant.withOpacity(
    theme.brightness == Brightness.dark ? 0.4 : 0.8,
  );
}

class _HomeDashboardVisibilityMenu extends StatefulWidget {
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

  @override
  State<_HomeDashboardVisibilityMenu> createState() =>
      _HomeDashboardVisibilityMenuState();
}

class _HomeDashboardVisibilityMenuState
    extends State<_HomeDashboardVisibilityMenu> {
  bool _isExpanded = false;

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle? textStyle = theme.textTheme.bodyLarge?.copyWith(
      color: theme.colorScheme.onSurface,
    );
    final Color containerColor = _settingsMenuContainerColor(theme);
    final List<_DashboardToggleConfig> toggles = <_DashboardToggleConfig>[
      _DashboardToggleConfig(
        label: widget.strings.settingsHomeGamificationTitle,
        value: widget.preferences.showGamificationWidget,
        onChanged: widget.onToggleGamification,
      ),
      _DashboardToggleConfig(
        label: widget.strings.settingsHomeBudgetTitle,
        value: widget.preferences.showBudgetWidget,
        onChanged: widget.onToggleBudget,
      ),
      _DashboardToggleConfig(
        label: widget.strings.settingsHomeRecurringTitle,
        value: widget.preferences.showRecurringWidget,
        onChanged: widget.onToggleRecurring,
      ),
      _DashboardToggleConfig(
        label: widget.strings.settingsHomeSavingsTitle,
        value: widget.preferences.showSavingsWidget,
        onChanged: widget.onToggleSavings,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: <Widget>[
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(28),
              onTap: _toggleExpanded,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.home_outlined,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.strings.settingsHomeSectionTitle,
                        style: textStyle,
                      ),
                    ),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ClipRect(
            child: AnimatedCrossFade(
              duration: const Duration(milliseconds: 200),
              sizeCurve: Curves.easeInOut,
              crossFadeState: _isExpanded
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 16),
                    for (int index = 0; index < toggles.length; index++) ...<
                        Widget>[
                      if (index > 0) const SizedBox(height: 16),
                      _DashboardToggleTile(config: toggles[index]),
                    ],
                  ],
                ),
              ),
              secondChild: const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardToggleConfig {
  const _DashboardToggleConfig({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
}

class _DashboardToggleTile extends StatelessWidget {
  const _DashboardToggleTile({required this.config});

  final _DashboardToggleConfig config;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color tileColor =
        theme.colorScheme.surfaceVariant.withOpacity(
          theme.brightness == Brightness.dark ? 0.8 : 0.4,
        );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              config.label,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Switch.adaptive(
            value: config.value,
            onChanged: config.onChanged,
          ),
        ],
      ),
    );
  }
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
