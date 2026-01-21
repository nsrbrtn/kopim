import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';
import 'package:kopim/features/upcoming_payments/domain/services/schedule_policy.dart';
import 'package:kopim/features/upcoming_payments/domain/usecases/recalc_upcoming_payment_uc.dart';

import '../../test_utils/fakes.dart';

void main() {
  late FixedTimeService timeService;
  late InMemoryUpcomingPaymentsRepository repo;
  late RecalcUpcomingPaymentUC recalcUC;

  setUp(() {
    timeService = FixedTimeService(DateTime(2024, 1, 10, 12));
    repo = InMemoryUpcomingPaymentsRepository();
    recalcUC = RecalcUpcomingPaymentUC(
      repo: repo,
      time: timeService,
      policy: const SchedulePolicy(),
    );
  });

  tearDown(() {
    repo.dispose();
  });

  UpcomingPayment buildPayment({
    int? nextRunAt,
    int? nextNotifyAt,
    int updatedAt = 0,
  }) {
    return UpcomingPayment(
      id: 'rule-1',
      title: 'Аренда',
      accountId: 'acc',
      categoryId: 'cat',
      amountMinor: BigInt.from(200000),
      amountScale: 2,
      dayOfMonth: 15,
      notifyDaysBefore: 3,
      notifyTimeHhmm: '09:30',
      note: 'Напоминание',
      autoPost: false,
      isActive: true,
      nextRunAtMs: nextRunAt,
      nextNotifyAtMs: nextNotifyAt,
      createdAtMs: 0,
      updatedAtMs: updatedAt,
    );
  }

  test('обновляет кеши, если значения устарели', () async {
    final UpcomingPayment initial = buildPayment(
      nextRunAt: timeService.toEpochMs(DateTime(2024, 1, 10, 0, 1)),
      nextNotifyAt: timeService.toEpochMs(DateTime(2024, 1, 8, 9, 30)),
    );
    repo.emitAll(<UpcomingPayment>[initial]);

    final UpcomingPayment? result = await recalcUC(
      const RecalcUpcomingPaymentRequest.byId('rule-1'),
    );

    expect(result, isNotNull);
    expect(
      result!.nextRunAtMs,
      timeService.toEpochMs(DateTime(2024, 1, 15, 0, 1)),
    );
    expect(
      result.nextNotifyAtMs,
      timeService.toEpochMs(DateTime(2024, 1, 12, 9, 30)),
    );
    expect(
      result.updatedAtMs,
      timeService.toEpochMs(DateTime(2024, 1, 10, 12)),
    );
  });

  test('возвращает исходное значение, если кеши актуальны', () async {
    final UpcomingPayment upToDate = buildPayment(
      nextRunAt: timeService.toEpochMs(DateTime(2024, 1, 15, 0, 1)),
      nextNotifyAt: timeService.toEpochMs(DateTime(2024, 1, 12, 9, 30)),
      updatedAt: 42,
    );
    repo.emitAll(<UpcomingPayment>[upToDate]);

    final UpcomingPayment? result = await recalcUC(
      const RecalcUpcomingPaymentRequest.byId('rule-1'),
    );

    expect(result, equals(upToDate));
    final UpcomingPayment? stored = await repo.getById('rule-1');
    expect(stored, equals(upToDate));
  });
}
