import 'dart:async';
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/budgets/domain/entities/budget_progress.dart';
import 'package:kopim/features/budgets/presentation/controllers/budgets_providers.dart';
import 'package:kopim/features/categories/presentation/screens/manage_categories_screen.dart';
import 'package:kopim/features/home/domain/entities/home_dashboard_preferences.dart';
import 'package:kopim/features/home/presentation/controllers/home_dashboard_preferences_controller.dart';
import 'package:kopim/features/settings/domain/repositories/export_file_saver.dart';
import 'package:kopim/features/settings/domain/use_cases/import_user_data_result.dart';
import 'package:kopim/features/settings/presentation/controllers/exact_alarm_controller.dart';
import 'package:kopim/features/settings/presentation/controllers/export_user_data_controller.dart';
import 'package:kopim/features/settings/presentation/controllers/import_user_data_controller.dart';
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
    final AsyncValue<HomeDashboardPreferences> preferencesAsync = ref.watch(
      homeDashboardPreferencesControllerProvider,
    );
    final AsyncValue<List<BudgetProgress>> budgetsAsync = ref.watch(
      budgetsWithProgressProvider,
    );
    final AsyncValue<bool> exactAlarmAsync = ref.watch(
      exactAlarmControllerProvider,
    );
    final AsyncValue<ExportFileSaveResult?> exportAsync = ref.watch(
      exportUserDataControllerProvider,
    );
    final AsyncValue<ImportUserDataResult?> importAsync = ref.watch(
      importUserDataControllerProvider,
    );

    ref.listen<AsyncValue<ExportFileSaveResult?>>(
      exportUserDataControllerProvider,
      (
        AsyncValue<ExportFileSaveResult?>? previous,
        AsyncValue<ExportFileSaveResult?> next,
      ) {
        next.whenOrNull(
          data: (ExportFileSaveResult? result) {
            if (result == null) {
              return;
            }
            final ScaffoldMessengerState messenger = ScaffoldMessenger.of(
              context,
            );
            if (result.isSuccess) {
              final String? filePath = result.filePath;
              final Uri? downloadUrl = result.downloadUrl;
              final String message = (filePath != null && filePath.isNotEmpty)
                  ? strings.profileExportDataSuccessWithPath(filePath)
                  : (downloadUrl != null)
                      ? strings.profileExportDataSuccessWithPath(
                          downloadUrl.toString(),
                        )
                      : strings.profileExportDataSuccess;
              messenger.showSnackBar(SnackBar(content: Text(message)));
            } else {
              final String error =
                  result.errorMessage ?? strings.genericErrorMessage;
              messenger.showSnackBar(
                SnackBar(content: Text(strings.profileExportDataFailure(error))),
              );
            }
            ref.read(exportUserDataControllerProvider.notifier).clearResult();
          },
          error: (Object error, StackTrace stackTrace) {
            final ScaffoldMessengerState messenger = ScaffoldMessenger.of(
              context,
            );
            messenger.showSnackBar(
              SnackBar(
                content: Text(strings.profileExportDataFailure(error.toString())),
              ),
            );
            ref.read(exportUserDataControllerProvider.notifier).clearResult();
          },
        );
      },
    );

    ref.listen<AsyncValue<ImportUserDataResult?>>(
      importUserDataControllerProvider,
      (
        AsyncValue<ImportUserDataResult?>? previous,
        AsyncValue<ImportUserDataResult?> next,
      ) {
        next.whenOrNull(
          data: (ImportUserDataResult? result) {
            if (result == null) {
              return;
            }
            final ScaffoldMessengerState messenger = ScaffoldMessenger.of(
              context,
            );
            result.map(
              success: (ImportUserDataResultSuccess value) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      value.accounts == 0 &&
                              value.categories == 0 &&
                              value.transactions == 0
                          ? strings.profileImportDataSuccess
                          : strings.profileImportDataSuccessWithStats(
                              value.accounts,
                              value.categories,
                              value.transactions,
                            ),
                    ),
                  ),
                );
              },
              cancelled: (_) {
                messenger.showSnackBar(
                  SnackBar(content: Text(strings.profileImportDataCancelled)),
                );
              },
              failure: (ImportUserDataResultFailure value) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      strings.profileImportDataFailure(value.message),
                    ),
                  ),
                );
              },
            );
            ref.read(importUserDataControllerProvider.notifier).clearResult();
          },
          error: (Object error, StackTrace stackTrace) {
            final ScaffoldMessengerState messenger = ScaffoldMessenger.of(
              context,
            );
            messenger.showSnackBar(
              SnackBar(
                content: Text(
                  strings.profileImportDataFailure(error.toString()),
                ),
              ),
            );
            ref.read(importUserDataControllerProvider.notifier).clearResult();
          },
        );
      },
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
              _pushRoute(context, ManageCategoriesScreen.routeName);
            },
          ),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.event_repeat,
            title: strings.profileUpcomingPaymentsCta,
            onTap: () {
              _pushRoute(context, UpcomingPaymentsScreen.routeName);
            },
          ),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.download_outlined,
            title: strings.profileExportDataCta,
            onTap: () async {
              final notifier = ref.read(
                exportUserDataControllerProvider.notifier,
              );
              if (kIsWeb) {
                await notifier.export();
                return;
              }
              final String? path = await FilePicker.platform.getDirectoryPath();
              if (path != null) {
                await notifier.export(directoryPath: path);
              }
            },
            trailing: exportAsync.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
            enabled: !exportAsync.isLoading,
          ),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.upload_outlined,
            title: strings.profileImportDataCta,
            onTap: () {
              ref.read(importUserDataControllerProvider.notifier).importData();
            },
            trailing: importAsync.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
            enabled: !importAsync.isLoading,
          ),
          const SizedBox(height: 24),
          _NotificationsSettingsCard(
            strings: strings,
            exactAlarmAsync: exactAlarmAsync,
            onRequestExactAlarms: () {
              return ref.read(exactAlarmControllerProvider.notifier).request();
            },
            onRefreshStatus: () async {
              await ref.read(exactAlarmControllerProvider.notifier).refresh();
            },
            onSendTest: () async {
              await ref
                  .read(notificationsGatewayProvider)
                  .showTestNotification();
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
    this.trailing,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Icon(icon),
        title: Text(title, style: theme.textTheme.titleMedium),
        trailing: trailing ?? const Icon(Icons.chevron_right),
        onTap: enabled ? onTap : null,
        enabled: enabled,
      ),
    );
  }
}

class _NotificationsSettingsCard extends StatefulWidget {
  const _NotificationsSettingsCard({
    required this.strings,
    required this.exactAlarmAsync,
    required this.onRequestExactAlarms,
    required this.onRefreshStatus,
    required this.onSendTest,
  });

  final AppLocalizations strings;
  final AsyncValue<bool> exactAlarmAsync;
  final Future<bool> Function() onRequestExactAlarms;
  final Future<void> Function() onRefreshStatus;
  final Future<void> Function() onSendTest;

  @override
  State<_NotificationsSettingsCard> createState() =>
      _NotificationsSettingsCardState();
}

class _NotificationsSettingsCardState extends State<_NotificationsSettingsCard>
    with WidgetsBindingObserver {
  bool _awaitingResume = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _awaitingResume) {
      _awaitingResume = false;
      if (mounted) {
        unawaited(widget.onRefreshStatus());
      }
    }
  }

  Future<void> _handleExactAlarmToggle() async {
    final bool launched = await widget.onRequestExactAlarms();
    if (!mounted) {
      return;
    }
    if (launched && !_awaitingResume) {
      setState(() {
        _awaitingResume = true;
      });
    } else if (!launched && _awaitingResume) {
      setState(() {
        _awaitingResume = false;
      });
    }
    await widget.onRefreshStatus();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = widget.strings;
    final AsyncValue<bool> exactAlarmAsync = widget.exactAlarmAsync;
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          exactAlarmAsync.when(
            data: (bool enabled) => SwitchListTile.adaptive(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              secondary: const Icon(Icons.alarm_on_outlined),
              title: Text(strings.settingsNotificationsExactTitle),
              subtitle: Text(strings.settingsNotificationsExactSubtitle),
              value: enabled,
              onChanged: (_) async {
                await _handleExactAlarmToggle();
              },
            ),
            loading: () => ListTile(
              leading: const Icon(Icons.alarm_on_outlined),
              title: Text(strings.settingsNotificationsExactTitle),
              subtitle: const Padding(
                padding: EdgeInsets.only(top: 4),
                child: LinearProgressIndicator(),
              ),
            ),
            error: (Object error, StackTrace stackTrace) => ListTile(
              leading: const Icon(Icons.alarm_on_outlined),
              title: Text(strings.settingsNotificationsExactTitle),
              subtitle: Text(
                strings.settingsNotificationsExactError(error.toString()),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: strings.settingsNotificationsRetryTooltip,
                onPressed: () {
                  unawaited(widget.onRefreshStatus());
                },
              ),
            ),
          ),
          const Divider(height: 0),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await widget.onSendTest();
                },
                icon: const Icon(Icons.notifications_active_outlined),
                label: Text(strings.settingsNotificationsTestCta),
              ),
            ),
          ),
        ],
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
