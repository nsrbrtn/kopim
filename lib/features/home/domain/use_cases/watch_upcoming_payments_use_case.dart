import 'dart:async';

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
          from: from,
          to: to,
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
    required DateTime from,
    required DateTime to,
  }) {
    if (rules.isEmpty) {
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

    if (activeRules.isEmpty) {
      return const <UpcomingPayment>[];
    }

    final DateTime rangeStartUtc = from.toUtc();
    final DateTime rangeEndUtc = to.toUtc();
    final DateTime rangeStartLocal = from.toLocal();
    final DateTime rangeEndLocal = to.toLocal();

    final List<UpcomingPayment> mapped = <UpcomingPayment>[];
    final Set<String> coveredRules = <String>{};

    for (final RecurringOccurrence occurrence in occurrences) {
      if (occurrence.status != RecurringOccurrenceStatus.scheduled) {
        continue;
      }
      final RecurringRule? rule = activeRules[occurrence.ruleId];
      if (rule == null) {
        continue;
      }
      final DateTime dueUtc = occurrence.dueAt.toUtc();
      if (dueUtc.isBefore(rangeStartUtc) || dueUtc.isAfter(rangeEndUtc)) {
        continue;
      }
      mapped.add(
        UpcomingPayment(
          occurrenceId: occurrence.id,
          ruleId: rule.id,
          title: rule.title,
          amount: rule.amount,
          currency: rule.currency,
          dueDate: dueUtc.toLocal(),
          accountId: rule.accountId,
          categoryId: rule.categoryId,
        ),
      );
      coveredRules.add(rule.id);
    }

    for (final RecurringRule rule in activeRules.values) {
      if (coveredRules.contains(rule.id)) {
        continue;
      }
      final DateTime? nextLocal = rule.nextDueLocalDate;
      if (nextLocal == null) {
        continue;
      }
      if (nextLocal.isBefore(rangeStartLocal) ||
          nextLocal.isAfter(rangeEndLocal)) {
        continue;
      }
      final DateTime dueUtc = nextLocal.toUtc();
      mapped.add(
        UpcomingPayment(
          occurrenceId: _fallbackOccurrenceId(rule.id, dueUtc),
          ruleId: rule.id,
          title: rule.title,
          amount: rule.amount,
          currency: rule.currency,
          dueDate: dueUtc.toLocal(),
          accountId: rule.accountId,
          categoryId: rule.categoryId,
        ),
      );
    }

    mapped.sort((UpcomingPayment a, UpcomingPayment b) {
      return a.dueDate.compareTo(b.dueDate);
    });

    return mapped;
  }

  static String _fallbackOccurrenceId(String ruleId, DateTime dueUtc) {
    return '$ruleId-${dueUtc.toIso8601String()}';
  }
}
