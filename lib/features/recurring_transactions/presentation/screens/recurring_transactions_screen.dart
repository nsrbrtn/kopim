import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/recurring_transactions/domain/entities/recurring_occurrence.dart';
import 'package:kopim/features/recurring_transactions/domain/entities/recurring_rule.dart';
import 'package:kopim/features/recurring_transactions/presentation/controllers/recurring_transactions_providers.dart';
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
        onPressed: () => _showComingSoon(context),
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

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.commonComingSoon)),
    );
  }
}

class _RecurringRuleTile extends StatelessWidget {
  const _RecurringRuleTile({
    required this.rule,
    required this.nextOccurrence,
    required this.onToggle,
  });

  final RecurringRule rule;
  final RecurringOccurrence? nextOccurrence;
  final ValueChanged<bool> onToggle;

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
        trailing: Switch(value: rule.isActive, onChanged: onToggle),
      ),
    );
  }
}

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
