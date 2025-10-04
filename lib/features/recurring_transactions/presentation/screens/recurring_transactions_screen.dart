import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/recurring_transactions/domain/entities/recurring_occurrence.dart';
import 'package:kopim/features/recurring_transactions/domain/entities/recurring_rule.dart';
import 'package:kopim/features/recurring_transactions/presentation/controllers/recurring_transactions_providers.dart';
import 'package:kopim/features/recurring_transactions/presentation/models/recurring_rule_form_result.dart';
import 'package:kopim/features/recurring_transactions/presentation/screens/add_recurring_rule_screen.dart';
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
    final AsyncValue<List<RecurringOccurrence>> upcomingAsync = ref.watch(
      upcomingRecurringOccurrencesProvider(),
    );

    return Scaffold(
      appBar: AppBar(title: Text(strings.recurringTransactionsTitle)),
      body: rulesAsync.when(
        data: (List<RecurringRule> rules) {
          if (rules.isEmpty) {
            return _EmptyState(message: strings.recurringTransactionsEmpty);
          }
          final Map<String, RecurringOccurrence?> nextByRule =
              _mapNextOccurrence(rules: rules, occurrencesAsync: upcomingAsync);
          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(recurringWindowServiceProvider).rebuildWindow();
            },
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              itemBuilder: (BuildContext context, int index) {
                final RecurringRule rule = rules[index];
                final RecurringOccurrence? nextOccurrence = nextByRule[rule.id];
                return _RecurringRuleTile(
                  rule: rule,
                  nextOccurrence: nextOccurrence,
                  onToggle: (bool value) async {
                    await ref
                        .read(toggleRecurringRuleUseCaseProvider)
                        .call(id: rule.id, isActive: value);
                  },
                  onEdit: () => _onEditRulePressed(context, rule),
                  onDelete: () => _onDeleteRulePressed(context, ref, rule),
                );
              },
              separatorBuilder: (BuildContext context, int _) =>
                  const SizedBox(height: 12),
              itemCount: rules.length,
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

  Map<String, RecurringOccurrence?> _mapNextOccurrence({
    required List<RecurringRule> rules,
    required AsyncValue<List<RecurringOccurrence>> occurrencesAsync,
  }) {
    final Map<String, RecurringOccurrence?> map =
        <String, RecurringOccurrence?>{};
    final List<RecurringOccurrence>? occurrences = occurrencesAsync.value;
    if (occurrences == null) {
      for (final RecurringRule rule in rules) {
        map[rule.id] = null;
      }
      return map;
    }
    final Map<String, List<RecurringOccurrence>> grouped =
        <String, List<RecurringOccurrence>>{};
    for (final RecurringOccurrence occurrence in occurrences) {
      final List<RecurringOccurrence> list = grouped.putIfAbsent(
        occurrence.ruleId,
        () => <RecurringOccurrence>[],
      );
      list.add(occurrence);
    }
    grouped.updateAll((String key, List<RecurringOccurrence> value) {
      value.sort(
        (RecurringOccurrence a, RecurringOccurrence b) =>
            a.dueAt.compareTo(b.dueAt),
      );
      return value;
    });
    for (final RecurringRule rule in rules) {
      final List<RecurringOccurrence>? list = grouped[rule.id];
      map[rule.id] = list == null || list.isEmpty ? null : list.first;
    }
    return map;
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

class _RecurringRuleTile extends StatelessWidget {
  const _RecurringRuleTile({
    required this.rule,
    required this.nextOccurrence,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final RecurringRule rule;
  final RecurringOccurrence? nextOccurrence;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat.yMMMMd();
    final String subtitle = nextOccurrence == null
        ? AppLocalizations.of(context)!.recurringTransactionsNoUpcoming
        : '${AppLocalizations.of(context)!.recurringTransactionsNextDue}: '
              '${dateFormat.format(nextOccurrence!.dueAt.toLocal())}';
    return Material(
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
