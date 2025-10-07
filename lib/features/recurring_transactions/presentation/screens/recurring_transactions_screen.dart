import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/formatting/date_format_providers.dart';
import 'package:kopim/features/recurring_transactions/domain/entities/recurring_rule.dart';
import 'package:kopim/features/recurring_transactions/presentation/controllers/recurring_transactions_providers.dart';
import 'package:kopim/features/recurring_transactions/presentation/models/recurring_rule_form_result.dart';
import 'package:kopim/features/recurring_transactions/presentation/screens/add_recurring_rule_screen.dart';
import 'package:kopim/features/recurring_transactions/domain/services/recurring_rule_scheduler.dart';
import 'package:kopim/features/recurring_transactions/presentation/controllers/exact_alarm_permission_controller.dart';
import 'package:kopim/l10n/app_localizations.dart';

/// Entry point screen that will host recurring transaction management.
class RecurringTransactionsScreen extends ConsumerWidget {
  const RecurringTransactionsScreen({super.key});

  static const String routeName = '/recurring-transactions';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final AsyncValue<List<RecurringRule>> rulesAsync = ref.watch(
      recurringRulesProvider,
    );
    const RecurringRuleScheduler scheduler = RecurringRuleScheduler();
    final DateTime now = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: Text(strings.recurringTransactionsTitle)),
      body: rulesAsync.when(
        data: (List<RecurringRule> rules) {
          if (rules.isEmpty) {
            return _EmptyState(message: strings.recurringTransactionsEmpty);
          }
          final bool isAndroid =
              !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
          final List<Widget> children = <Widget>[];
          if (isAndroid) {
            children.add(const _ExactAlarmPermissionCard());
            children.add(const SizedBox(height: 16));
          }
          for (int index = 0; index < rules.length; index++) {
            final RecurringRule rule = rules[index];
            final DateTime? nextDue = _resolveNextDue(
              rule: rule,
              scheduler: scheduler,
              now: now,
            );
            children
              ..add(
                _RecurringRuleTile(
                  rule: rule,
                  nextDue: nextDue,
                  onToggle: (bool value) async {
                    await ref
                        .read(toggleRecurringRuleUseCaseProvider)
                        .call(id: rule.id, isActive: value);
                  },
                  onEdit: () => _onEditRulePressed(context, rule),
                  onDelete: () => _onDeleteRulePressed(context, ref, rule),
                ),
              )
              ..add(const SizedBox(height: 12));
          }
          if (children.isNotEmpty) {
            children.removeLast();
          }
          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(recurringWindowServiceProvider).rebuildWindow();
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              children: children,
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stackTrace) =>
            Center(child: Text(strings.genericErrorMessage)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onAddRulePressed(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  DateTime? _resolveNextDue({
    required RecurringRule rule,
    required RecurringRuleScheduler scheduler,
    required DateTime now,
  }) {
    final RecurringRuleScheduleResult schedule = scheduler.resolve(
      rule: rule,
      now: now,
    );
    final DateTime today = DateTime(now.year, now.month, now.day);
    DateTime? candidate;
    if (schedule.dueDates.isNotEmpty) {
      final DateTime lastDue = schedule.dueDates.last;
      if (!lastDue.isBefore(today)) {
        candidate = lastDue;
      }
    }
    candidate ??= schedule.nextDue;
    if (candidate.isBefore(today)) {
      return null;
    }
    final int daysAhead = candidate.difference(today).inDays;
    if (daysAhead > 30) {
      return null;
    }
    return candidate;
  }

  Future<void> _onAddRulePressed(BuildContext context) async {
    final RecurringRuleFormResult? result = await Navigator.of(context).push(
      MaterialPageRoute<RecurringRuleFormResult>(
        builder: (_) => const AddRecurringRuleScreen(),
        settings: const RouteSettings(name: AddRecurringRuleScreen.routeName),
      ),
    );
    if (result == RecurringRuleFormResult.created && context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.addRecurringRuleSuccess,
            ),
          ),
        );
    }
  }

  Future<void> _onEditRulePressed(
    BuildContext context,
    RecurringRule rule,
  ) async {
    final RecurringRuleFormResult? result = await Navigator.of(context).push(
      MaterialPageRoute<RecurringRuleFormResult>(
        builder: (_) => AddRecurringRuleScreen(initialRule: rule),
        settings: const RouteSettings(name: AddRecurringRuleScreen.routeName),
      ),
    );
    if (result == RecurringRuleFormResult.updated && context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.editRecurringRuleSuccess,
            ),
          ),
        );
    }
  }

  Future<void> _onDeleteRulePressed(
    BuildContext context,
    WidgetRef ref,
    RecurringRule rule,
  ) async {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(strings.recurringTransactionsDeleteDialogTitle),
          content: Text(strings.recurringTransactionsDeleteConfirmation),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(strings.dialogCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(strings.dialogConfirm),
            ),
          ],
        );
      },
    );
    if (shouldDelete != true) {
      return;
    }
    try {
      await ref.read(deleteRecurringRuleUseCaseProvider).call(rule.id);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(strings.recurringTransactionsDeleteSuccess)),
        );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(strings.genericErrorMessage)));
    }
  }
}

class _RecurringRuleTile extends ConsumerWidget {
  const _RecurringRuleTile({
    required this.rule,
    required this.nextDue,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final RecurringRule rule;
  final DateTime? nextDue;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Locale locale = Localizations.localeOf(context);
    final DateFormat dateFormat = ref.watch(
      dateFormatProvider((locale: locale, format: AppDateFormat.longMonthDay)),
    );
    final String subtitle = nextDue == null
        ? AppLocalizations.of(context)!.recurringTransactionsNoUpcoming
        : '${AppLocalizations.of(context)!.recurringTransactionsNextDue}: '
              '${dateFormat.format(nextDue!.toLocal())}';
    return Material(
      key: ValueKey<String>(rule.id),
      elevation: 1,
      borderRadius: BorderRadius.circular(12),
      child: ListTile(
        title: Text(rule.title),
        subtitle: Text(subtitle),
        onTap: onEdit,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Switch(value: rule.isActive, onChanged: onToggle),
            const SizedBox(width: 8),
            PopupMenuButton<_RecurringRuleTileAction>(
              onSelected: (_RecurringRuleTileAction action) {
                switch (action) {
                  case _RecurringRuleTileAction.edit:
                    onEdit();
                    break;
                  case _RecurringRuleTileAction.delete:
                    onDelete();
                    break;
                }
              },
              itemBuilder: (BuildContext context) {
                final AppLocalizations strings = AppLocalizations.of(context)!;
                return <PopupMenuEntry<_RecurringRuleTileAction>>[
                  PopupMenuItem<_RecurringRuleTileAction>(
                    value: _RecurringRuleTileAction.edit,
                    child: Text(strings.recurringTransactionsEditAction),
                  ),
                  PopupMenuItem<_RecurringRuleTileAction>(
                    value: _RecurringRuleTileAction.delete,
                    child: Text(strings.recurringTransactionsDeleteAction),
                  ),
                ];
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ExactAlarmPermissionCard extends ConsumerWidget {
  const _ExactAlarmPermissionCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final AsyncValue<bool> permissionAsync = ref.watch(
      exactAlarmPermissionControllerProvider,
    );

    return permissionAsync.when(
      data: (bool granted) {
        if (granted) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.alarm_on_outlined),
              title: Text(strings.recurringExactAlarmEnabledTitle),
              subtitle: Text(strings.recurringExactAlarmEnabledSubtitle),
            ),
          );
        }
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Icon(Icons.alarm_add_outlined),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        strings.recurringExactAlarmPromptTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(strings.recurringExactAlarmPromptSubtitle),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton(
                    onPressed: () async {
                      await ref
                          .read(exactAlarmPermissionControllerProvider.notifier)
                          .openSettings();
                    },
                    child: Text(strings.recurringExactAlarmPromptCta),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (Object error, StackTrace _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Icon(Icons.error_outline),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      strings.recurringExactAlarmErrorTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(strings.recurringExactAlarmErrorSubtitle(error.toString())),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton(
                  onPressed: () => ref
                      .read(exactAlarmPermissionControllerProvider.notifier)
                      .refresh(),
                  child: Text(strings.recurringExactAlarmRetryCta),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _RecurringRuleTileAction { edit, delete }

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
