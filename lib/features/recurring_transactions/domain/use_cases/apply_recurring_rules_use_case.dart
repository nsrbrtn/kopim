import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'package:kopim/features/recurring_transactions/domain/entities/recurring_rule.dart';
import 'package:kopim/features/recurring_transactions/domain/repositories/recurring_transactions_repository.dart';
import 'package:kopim/features/recurring_transactions/domain/services/recurring_rule_scheduler.dart';
import 'package:kopim/features/transactions/domain/entities/add_transaction_request.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';

class ApplyRecurringRulesResult {
  const ApplyRecurringRulesResult({
    required this.applied,
    required this.skipped,
  });

  final int applied;
  final int skipped;
}

class ApplyRecurringRulesUseCase {
  ApplyRecurringRulesUseCase({
    required RecurringTransactionsRepository repository,
    required Future<String?> Function(AddTransactionRequest request)
    postTransaction,
    RecurringRuleScheduler? scheduler,
    DateTime Function()? clock,
  }) : _repository = repository,
       _postTransaction = postTransaction,
       _scheduler = scheduler ?? const RecurringRuleScheduler(),
       _clock = clock ?? DateTime.now;

  final RecurringTransactionsRepository _repository;
  final Future<String?> Function(AddTransactionRequest request)
  _postTransaction;
  final RecurringRuleScheduler _scheduler;
  final DateTime Function() _clock;

  Future<ApplyRecurringRulesResult> call() async {
    final DateTime nowLocal = _clock().toLocal();
    final List<RecurringRule> rules = await _repository.getAllRules(
      activeOnly: true,
    );
    int applied = 0;
    int skipped = 0;

    for (final RecurringRule rule in rules) {
      if (!rule.autoPost) {
        continue;
      }
      final RecurringRuleScheduleResult schedule = _scheduler.resolve(
        rule: rule,
        now: nowLocal,
      );

      for (final DateTime due in schedule.dueDates) {
        final AddTransactionRequest request = _buildRequest(
          rule: rule,
          due: due,
        );
        final String occurrenceId = _occurrenceId(rule.id, due);
        final bool appliedNow = await _repository.applyRuleOccurrence(
          rule: rule,
          occurrenceId: occurrenceId,
          occurrenceLocalDate: due,
          postTransaction: () => _postTransaction(request),
        );
        if (appliedNow) {
          applied++;
        } else {
          skipped++;
        }
      }

      final RecurringRule updatedRule = rule.copyWith(
        lastRunAt: nowLocal,
        nextDueLocalDate: schedule.nextDue,
        updatedAt: nowLocal.toUtc(),
      );
      await _repository.upsertRule(updatedRule, regenerateWindow: false);
    }

    return ApplyRecurringRulesResult(applied: applied, skipped: skipped);
  }

  AddTransactionRequest _buildRequest({
    required RecurringRule rule,
    required DateTime due,
  }) {
    final TransactionType type = rule.amount >= 0
        ? TransactionType.expense
        : TransactionType.income;
    return AddTransactionRequest(
      accountId: rule.accountId,
      categoryId: rule.categoryId,
      amount: rule.amount.abs(),
      date: due.toUtc(),
      note: 'Автоплатеж "${rule.title}"',
      type: type,
    );
  }

  String _occurrenceId(String ruleId, DateTime due) {
    final String day = due.day.toString().padLeft(2, '0');
    final String month = due.month.toString().padLeft(2, '0');
    final String dateKey = '${due.year.toString().padLeft(4, '0')}-$month-$day';
    final String raw = '$ruleId$dateKey';
    return sha1.convert(utf8.encode(raw)).toString();
  }
}
