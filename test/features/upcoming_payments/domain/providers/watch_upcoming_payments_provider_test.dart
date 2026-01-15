import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod/src/framework.dart' show Override;

import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';
import 'package:kopim/features/upcoming_payments/domain/providers/upcoming_payments_providers.dart';
import 'package:kopim/features/upcoming_payments/domain/services/schedule_policy.dart';
import 'package:kopim/features/upcoming_payments/domain/usecases/recalc_upcoming_payment_uc.dart';

import '../../test_utils/fakes.dart';

class _CountingRecalcUpcomingPaymentUC extends RecalcUpcomingPaymentUC {
  _CountingRecalcUpcomingPaymentUC({
    required super.repo,
    required super.time,
    required super.policy,
  });

  int callCount = 0;

  @override
  Future<UpcomingPayment?> call(RecalcUpcomingPaymentRequest request) {
    callCount += 1;
    return super.call(request);
  }
}

void main() {
  late FixedTimeService timeService;
  late InMemoryUpcomingPaymentsRepository repo;
  late _CountingRecalcUpcomingPaymentUC recalcUC;
  late ProviderContainer container;

  UpcomingPayment buildPayment({
    required int? nextRunAt,
    required int? nextNotifyAt,
  }) {
    return UpcomingPayment(
      id: 'rule-1',
      title: 'Аренда',
      accountId: 'acc',
      categoryId: 'cat',
      amount: 2000,
      dayOfMonth: 15,
      notifyDaysBefore: 3,
      notifyTimeHhmm: '09:30',
      note: 'Напоминание',
      autoPost: false,
      isActive: true,
      nextRunAtMs: nextRunAt,
      nextNotifyAtMs: nextNotifyAt,
      createdAtMs: 0,
      updatedAtMs: 0,
    );
  }

  setUp(() {
    timeService = FixedTimeService(DateTime(2024, 1, 20, 12));
    repo = InMemoryUpcomingPaymentsRepository();
    recalcUC = _CountingRecalcUpcomingPaymentUC(
      repo: repo,
      time: timeService,
      policy: const SchedulePolicy(),
    );
    container = ProviderContainer(
      overrides: <Override>[
        upcomingPaymentsRepositoryProvider.overrideWithValue(repo),
        timeServiceProvider.overrideWithValue(timeService),
        recalcUpcomingPaymentUCProvider.overrideWithValue(recalcUC),
      ],
    );
  });

  tearDown(() async {
    repo.dispose();
    container.dispose();
    await pumpEventQueue();
  });

  test('пересчитывает просроченные правила при чтении списка', () async {
    final UpcomingPayment overdue = buildPayment(
      nextRunAt: timeService.toEpochMs(DateTime(2024, 1, 15, 0, 1)),
      nextNotifyAt: timeService.toEpochMs(DateTime(2024, 1, 12, 9, 30)),
    );
    repo.emitAll(<UpcomingPayment>[overdue]);

    final Completer<List<UpcomingPayment>> firstCompleter =
        Completer<List<UpcomingPayment>>();
    final Completer<List<UpcomingPayment>> secondCompleter =
        Completer<List<UpcomingPayment>>();
    int received = 0;
    final ProviderSubscription<AsyncValue<List<UpcomingPayment>>> sub =
        container.listen(watchUpcomingPaymentsProvider, (
          AsyncValue<List<UpcomingPayment>>? _,
          AsyncValue<List<UpcomingPayment>> next,
        ) {
          if (next.hasError) {
            if (!firstCompleter.isCompleted) {
              firstCompleter.completeError(next.error!, next.stackTrace);
            }
            if (!secondCompleter.isCompleted) {
              secondCompleter.completeError(next.error!, next.stackTrace);
            }
            return;
          }
          if (!next.hasValue) {
            return;
          }
          received += 1;
          if (received == 1 && !firstCompleter.isCompleted) {
            firstCompleter.complete(next.value!);
            return;
          }
          if (received == 2 && !secondCompleter.isCompleted) {
            secondCompleter.complete(next.value!);
          }
        }, fireImmediately: true);

    final List<UpcomingPayment> first = await firstCompleter.future;
    expect(first.single.nextRunAtMs, overdue.nextRunAtMs);

    await pumpEventQueue();

    final List<UpcomingPayment> second = await secondCompleter.future;
    expect(
      second.single.nextRunAtMs,
      timeService.toEpochMs(DateTime(2024, 2, 15, 0, 1)),
    );
    expect(recalcUC.callCount, 1);

    sub.close();
  });

  test('не запускает пересчёт для актуальных дат', () async {
    final UpcomingPayment upcoming = buildPayment(
      nextRunAt: timeService.toEpochMs(DateTime(2024, 2, 15, 0, 1)),
      nextNotifyAt: timeService.toEpochMs(DateTime(2024, 2, 12, 9, 30)),
    );
    repo.emitAll(<UpcomingPayment>[upcoming]);

    final Completer<List<UpcomingPayment>> firstCompleter =
        Completer<List<UpcomingPayment>>();
    final ProviderSubscription<AsyncValue<List<UpcomingPayment>>> sub =
        container.listen(watchUpcomingPaymentsProvider, (
          AsyncValue<List<UpcomingPayment>>? _,
          AsyncValue<List<UpcomingPayment>> next,
        ) {
          if (next.hasError && !firstCompleter.isCompleted) {
            firstCompleter.completeError(next.error!, next.stackTrace);
            return;
          }
          if (next.hasValue && !firstCompleter.isCompleted) {
            firstCompleter.complete(next.value!);
          }
        }, fireImmediately: true);

    final List<UpcomingPayment> first = await firstCompleter.future;
    expect(first.single.nextRunAtMs, upcoming.nextRunAtMs);

    await pumpEventQueue();

    expect(recalcUC.callCount, 0);

    sub.close();
  });
}
