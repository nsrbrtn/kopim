import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:kopim/features/budgets/domain/entities/budget_progress.dart';
import 'package:kopim/features/budgets/presentation/controllers/budgets_providers.dart';
import 'package:kopim/features/home/domain/entities/home_dashboard_preferences.dart';
import 'package:kopim/features/home/presentation/controllers/home_dashboard_preferences_controller.dart';
import 'package:kopim/features/categories/presentation/screens/manage_categories_screen.dart';
import 'package:kopim/features/upcoming_payments/presentation/screens/upcoming_payments_screen.dart';
import 'package:kopim/l10n/app_localizations.dart';

class GeneralSettingsScreen extends ConsumerWidget {
  const GeneralSettingsScreen({super.key});

  static const String routeName = '/settings/general';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final AsyncValue<HomeDashboardPreferences> preferencesAsync = ref.watch(
      homeDashboardPreferencesControllerProvider,
    );
    final AsyncValue<List<BudgetProgress>> budgetsAsync = ref.watch(
      budgetsWithProgressProvider,
    );

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(strings.profileGeneralSettingsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: <Widget>[
          _SettingsTile(
            icon: Icons.category_outlined,
            title: strings.profileManageCategoriesCta,
            onTap: () {
              Navigator.of(context).pushNamed(ManageCategoriesScreen.routeName);
            },
          ),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.event_repeat,
            title: strings.profileUpcomingPaymentsCta,
            onTap: () {
              Navigator.of(context).pushNamed(UpcomingPaymentsScreen.routeName);
            },
          ),
          const SizedBox(height: 24),
          preferencesAsync.when(
            data: (HomeDashboardPreferences preferences) =>
                _HomeDashboardSettingsCard(
                  strings: strings,
                  preferences: preferences,
                  budgetsAsync: budgetsAsync,
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
                  onSelectBudget: (List<BudgetProgress> budgets) async {
                    await _showBudgetSelector(
                      context: context,
                      ref: ref,
                      budgets: budgets,
                      selectedId: preferences.budgetId,
                    );
                  },
                ),
            loading: () => const _SettingsLoadingCard(),
            error: (Object error, _) => _SettingsErrorCard(
              message: strings.homeDashboardPreferencesError(error.toString()),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Icon(icon),
        title: Text(title, style: theme.textTheme.titleMedium),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _HomeDashboardSettingsCard extends StatelessWidget {
  const _HomeDashboardSettingsCard({
    required this.strings,
    required this.preferences,
    required this.budgetsAsync,
    required this.onToggleGamification,
    required this.onToggleBudget,
    required this.onToggleRecurring,
    required this.onToggleSavings,
    required this.onSelectBudget,
  });

  final AppLocalizations strings;
  final HomeDashboardPreferences preferences;
  final AsyncValue<List<BudgetProgress>> budgetsAsync;
  final ValueChanged<bool> onToggleGamification;
  final ValueChanged<bool> onToggleBudget;
  final ValueChanged<bool> onToggleRecurring;
  final ValueChanged<bool> onToggleSavings;
  final ValueChanged<List<BudgetProgress>> onSelectBudget;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: EdgeInsets.zero,
        leading: Icon(Icons.home_outlined, color: theme.colorScheme.primary),
        title: Text(
          strings.settingsHomeSectionTitle,
          style: theme.textTheme.titleMedium,
        ),
        children: <Widget>[
          SwitchListTile.adaptive(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            value: preferences.showGamificationWidget,
            onChanged: onToggleGamification,
            title: Text(strings.settingsHomeGamificationTitle),
            subtitle: Text(strings.settingsHomeGamificationSubtitle),
          ),
          const Divider(height: 0),
          SwitchListTile.adaptive(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            value: preferences.showBudgetWidget,
            onChanged: onToggleBudget,
            title: Text(strings.settingsHomeBudgetTitle),
            subtitle: Text(strings.settingsHomeBudgetSubtitle),
          ),
          if (preferences.showBudgetWidget)
            budgetsAsync.when(
              data: (List<BudgetProgress> budgets) {
                if (budgets.isEmpty) {
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    leading: const Icon(Icons.pie_chart_outline),
                    title: Text(strings.settingsHomeBudgetSelectedLabel),
                    subtitle: Text(strings.settingsHomeBudgetNoBudgets),
                    enabled: false,
                  );
                }
                final BudgetProgress? selected = budgets.firstWhereOrNull(
                  (BudgetProgress progress) =>
                      progress.budget.id == preferences.budgetId,
                );
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  leading: const Icon(Icons.pie_chart_outline),
                  title: Text(strings.settingsHomeBudgetSelectedLabel),
                  subtitle: Text(
                    selected?.budget.title ??
                        strings.settingsHomeBudgetSelectedNone,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => onSelectBudget(budgets),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: LinearProgressIndicator(),
              ),
              error: (Object error, _) => ListTile(
                leading: const Icon(Icons.error_outline),
                title: Text(strings.settingsHomeBudgetError(error.toString())),
                enabled: false,
              ),
            ),
          const Divider(height: 0),
          SwitchListTile.adaptive(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            value: preferences.showRecurringWidget,
            onChanged: onToggleRecurring,
            title: Text(strings.settingsHomeRecurringTitle),
            subtitle: Text(strings.settingsHomeRecurringSubtitle),
          ),
          const Divider(height: 0),
          SwitchListTile.adaptive(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            value: preferences.showSavingsWidget,
            onChanged: onToggleSavings,
            title: Text(strings.settingsHomeSavingsTitle),
            subtitle: Text(strings.settingsHomeSavingsSubtitle),
          ),
        ],
      ),
    );
  }
}

class _SettingsLoadingCard extends StatelessWidget {
  const _SettingsLoadingCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _SettingsErrorCard extends StatelessWidget {
  const _SettingsErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(Icons.error_outline, color: theme.colorScheme.error),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showBudgetSelector({
  required BuildContext context,
  required WidgetRef ref,
  required List<BudgetProgress> budgets,
  required String? selectedId,
}) async {
  final AppLocalizations strings = AppLocalizations.of(context)!;
  final NumberFormat currencyFormat = NumberFormat.simpleCurrency(
    locale: strings.localeName,
  );
  final String? result = await showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (BuildContext sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: Text(strings.settingsHomeBudgetPickerTitle),
              dense: true,
            ),
            SizedBox(
              height: math.min(400, budgets.length * 72.0),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: budgets.length,
                itemBuilder: (BuildContext context, int index) {
                  final BudgetProgress progress = budgets[index];
                  final bool isSelected = progress.budget.id == selectedId;
                  return ListTile(
                    leading: Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                    ),
                    title: Text(progress.budget.title),
                    subtitle: Text(
                      strings.settingsHomeBudgetPickerSubtitle(
                        currencyFormat.format(progress.spent),
                        currencyFormat.format(progress.budget.amount),
                      ),
                    ),
                    onTap: () {
                      Navigator.of(sheetContext).pop(progress.budget.id);
                    },
                  );
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.remove_circle_outline),
              title: Text(strings.settingsHomeBudgetPickerClear),
              subtitle: Text(strings.settingsHomeBudgetPickerHint),
              onTap: () => Navigator.of(sheetContext).pop(''),
            ),
          ],
        ),
      );
    },
  );

  if (!context.mounted || result == null) {
    return;
  }

  final String? budgetId = result.isEmpty ? null : result;
  await ref
      .read(homeDashboardPreferencesControllerProvider.notifier)
      .setBudgetId(budgetId);
}
