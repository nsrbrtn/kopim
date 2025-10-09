import 'package:collection/collection.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/recurring_transactions/domain/entities/recurring_occurrence.dart';
import 'package:kopim/features/recurring_transactions/domain/entities/recurring_rule.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recurring_transactions_providers.g.dart';

const int kRecurringWindowMonths = 6;

@riverpod
Stream<List<RecurringRule>> recurringRules(Ref ref) {
  return ref.watch(watchRecurringRulesUseCaseProvider).call();
}

@riverpod
AsyncValue<RecurringRule?> recurringRuleById(Ref ref, String id) {
  return ref.watch(recurringRulesProvider).whenData(
        (List<RecurringRule> rules) =>
            rules.firstWhereOrNull((RecurringRule rule) => rule.id == id),
      );
}

@riverpod
Stream<List<RecurringOccurrence>> upcomingRecurringOccurrences(
  Ref ref, {
  DateTime? from,
  DateTime? to,
}) {
  final DateTime start = from ?? DateTime.now();
  final DateTime end =
      to ?? DateTime(start.year, start.month + kRecurringWindowMonths);
  return ref
      .watch(watchUpcomingOccurrencesUseCaseProvider)
      .call(from: start, to: end);
}
