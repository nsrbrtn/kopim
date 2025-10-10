import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';
import 'package:kopim/features/upcoming_payments/domain/models/value_update.dart';
import 'package:kopim/features/upcoming_payments/domain/services/schedule_policy.dart';
import 'package:kopim/features/upcoming_payments/domain/usecases/create_upcoming_payment_uc.dart';
import 'package:kopim/features/upcoming_payments/domain/usecases/update_upcoming_payment_uc.dart';
import 'package:kopim/features/upcoming_payments/domain/validators/upcoming_payment_validator.dart';

import '../../test_utils/fakes.dart';

void main() {
  late FixedTimeService timeService;
  late InMemoryUpcomingPaymentsRepository repo;
  late CreateUpcomingPaymentUC createUC;
  late UpdateUpcomingPaymentUC updateUC;

  setUp(() {
    timeService = FixedTimeService(DateTime(2024, 1, 10, 10));
    repo = InMemoryUpcomingPaymentsRepository();
    createUC = CreateUpcomingPaymentUC(
      repo: repo,
      time: timeService,
      policy: const SchedulePolicy(),
      ids: TestIdService(values: <String>['rule-1']),
      validator: UpcomingPaymentValidator(timeService: timeService),
    );
    updateUC = UpdateUpcomingPaymentUC(
      repo: repo,
      time: timeService,
      policy: const SchedulePolicy(),
      validator: UpcomingPaymentValidator(timeService: timeService),
    );
  });

  tearDown(() {
    repo.dispose();
  });

  test('create рассчитывает nextRunAtMs и nextNotifyAtMs', () async {
    final UpcomingPayment payment = await createUC(
      const CreateUpcomingPaymentInput(
        title: 'Аренда',
        accountId: 'acc',
        categoryId: 'cat',
        amount: 2000,
        dayOfMonth: 15,
        notifyDaysBefore: 3,
        notifyTimeHhmm: '09:30',
        note: 'Напоминание',
        autoPost: false,
      ),
    );

    final int expectedNextRun = timeService.toEpochMs(
      DateTime(2024, 1, 15, 0, 1),
    );
    final int expectedNextNotify = timeService.toEpochMs(
      DateTime(2024, 1, 12, 9, 30),
    );

    expect(payment.id, 'rule-1');
    expect(payment.nextRunAtMs, expectedNextRun);
    expect(payment.nextNotifyAtMs, expectedNextNotify);
    expect(payment.createdAtMs, payment.updatedAtMs);

    final UpcomingPayment? stored = await repo.getById('rule-1');
    expect(stored, isNotNull);
    expect(stored!.nextRunAtMs, expectedNextRun);
    expect(stored.nextNotifyAtMs, expectedNextNotify);
  });

  test('update пересчитывает даты и может очищать заметку', () async {
    final UpcomingPayment created = await createUC(
      const CreateUpcomingPaymentInput(
        title: 'Аренда',
        accountId: 'acc',
        categoryId: 'cat',
        amount: 2000,
        dayOfMonth: 15,
        notifyDaysBefore: 3,
        notifyTimeHhmm: '09:30',
        note: 'Напоминание',
        autoPost: false,
      ),
    );

    timeService.now = DateTime(2024, 1, 20, 10, 0);

    final UpcomingPayment updated = await updateUC(
      UpdateUpcomingPaymentInput(
        id: created.id,
        amount: 2500,
        dayOfMonth: 25,
        notifyDaysBefore: 5,
        notifyTimeHhmm: '08:00',
        note: const ValueUpdate<String?>.present(null),
      ),
    );

    expect(updated.amount, 2500);
    expect(updated.note, isNull);
    expect(updated.dayOfMonth, 25);
    expect(
      updated.nextRunAtMs,
      timeService.toEpochMs(DateTime(2024, 1, 25, 0, 1)),
    );
    expect(
      updated.nextNotifyAtMs,
      timeService.toEpochMs(DateTime(2024, 1, 20, 8, 0)),
    );
    expect(
      updated.updatedAtMs,
      timeService.toEpochMs(DateTime(2024, 1, 20, 10, 0)),
    );
  });
}
