import 'dart:async';

import 'package:collection/collection.dart';
import 'package:kopim/features/home/domain/models/upcoming_payment.dart';
import 'package:kopim/features/recurring_transactions/domain/entities/recurring_occurrence.dart';
import 'package:kopim/features/recurring_transactions/domain/entities/recurring_rule.dart';
import 'package:kopim/features/recurring_transactions/domain/repositories/recurring_transactions_repository.dart';
import 'package:meta/meta.dart';

class WatchUpcomingPaymentsUseCase {
  WatchUpcomingPaymentsUseCase({
    required RecurringTransactionsRepository recurringRepository,
  }) : _recurringRepository = recurringRepository;

  final RecurringTransactionsRepository _recurringRepository;

  Stream<List<UpcomingPayment>> call({
    required DateTime from,
    required DateTime to,
  }) {
    final Stream<List<RecurringOccurrence>> occurrencesStream =
        _recurringRepository.watchUpcomingOccurrences(from: from, to: to);
    final Stream<List<RecurringRule>> rulesStream = _recurringRepository
        .watchRules();

    return Stream<List<UpcomingPayment>>.multi((
      StreamController<List<UpcomingPayment>> controller,
    ) {
      List<RecurringOccurrence> latestOccurrences =
          const <RecurringOccurrence>[];
      List<RecurringRule> latestRules = const <RecurringRule>[];
      bool hasOccurrences = false;
      bool hasRules = false;
      bool occurrencesDone = false;
      bool rulesDone = false;

      void emitIfReady() {
        if (!hasOccurrences || !hasRules) {
          return;
        }
        final List<UpcomingPayment> payments = mapToUpcomingPayments(
          occurrences: latestOccurrences,
          rules: latestRules,
        );
        controller.add(payments);
      }

      final StreamSubscription<List<RecurringOccurrence>> occurrencesSub =
          occurrencesStream.listen(
            (List<RecurringOccurrence> value) {
              hasOccurrences = true;
              latestOccurrences = value;
              emitIfReady();
            },
            onError: controller.addError,
            onDone: () {
              occurrencesDone = true;
              if (rulesDone && !controller.isClosed) {
                controller.close();
              }
            },
          );

      final StreamSubscription<List<RecurringRule>> rulesSub = rulesStream
          .listen(
            (List<RecurringRule> value) {
              hasRules = true;
              latestRules = value;
              emitIfReady();
            },
            onError: controller.addError,
            onDone: () {
              rulesDone = true;
              if (occurrencesDone && !controller.isClosed) {
                controller.close();
              }
            },
          );

      controller
        ..onCancel = () async {
          await Future.wait<void>(<Future<void>>[
            occurrencesSub.cancel(),
            rulesSub.cancel(),
          ]);
        }
        ..onPause = () {
          occurrencesSub.pause();
          rulesSub.pause();
        }
        ..onResume = () {
          occurrencesSub.resume();
          rulesSub.resume();
        };
    });
  }

  @visibleForTesting
  static List<UpcomingPayment> mapToUpcomingPayments({
    required List<RecurringOccurrence> occurrences,
    required List<RecurringRule> rules,
  }) {
    if (occurrences.isEmpty || rules.isEmpty) {
      return const <UpcomingPayment>[];
    }

    final Map<String, RecurringRule> activeRules = <String, RecurringRule>{}
      ..addEntries(
        rules
            .where((RecurringRule rule) => rule.isActive)
            .map(
              (RecurringRule rule) =>
                  MapEntry<String, RecurringRule>(rule.id, rule),
            ),
      );

    final Iterable<RecurringOccurrence> filtered = occurrences.where((
      RecurringOccurrence occurrence,
    ) {
      if (occurrence.status != RecurringOccurrenceStatus.scheduled) {
        return false;
      }
      return activeRules.containsKey(occurrence.ruleId);
    });

    final List<RecurringOccurrence> sorted = filtered.sorted((
      RecurringOccurrence a,
      RecurringOccurrence b,
    ) {
      return a.dueAt.compareTo(b.dueAt);
    });

    return sorted
        .map((RecurringOccurrence occurrence) {
          final RecurringRule? rule = activeRules[occurrence.ruleId];
          if (rule == null) {
            return null;
          }
          return UpcomingPayment(
            occurrenceId: occurrence.id,
            ruleId: rule.id,
            title: rule.title,
            amount: rule.amount,
            currency: rule.currency,
            dueDate: occurrence.dueAt.toLocal(),
            accountId: rule.accountId,
            categoryId: rule.categoryId,
          );
        })
        .nonNulls
        .toList(growable: false);
  }
}
