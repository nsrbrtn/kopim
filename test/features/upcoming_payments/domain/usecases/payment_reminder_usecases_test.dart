import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/payment_reminder.dart';
import 'package:kopim/features/upcoming_payments/domain/models/value_update.dart';
import 'package:kopim/features/upcoming_payments/domain/usecases/create_payment_reminder_uc.dart';
import 'package:kopim/features/upcoming_payments/domain/usecases/mark_reminder_done_uc.dart';
import 'package:kopim/features/upcoming_payments/domain/usecases/update_payment_reminder_uc.dart';
import 'package:kopim/features/upcoming_payments/domain/validators/payment_reminder_validator.dart';

import '../../test_utils/fakes.dart';

void main() {
  late FixedTimeService timeService;
  late InMemoryPaymentRemindersRepository repo;
  late CreatePaymentReminderUC createUC;
  late UpdatePaymentReminderUC updateUC;
  late MarkReminderDoneUC markDoneUC;

  setUp(() {
    timeService = FixedTimeService(DateTime(2024, 1, 1, 9));
    repo = InMemoryPaymentRemindersRepository();
    final PaymentReminderValidator validator = PaymentReminderValidator(
      timeService: timeService,
    );
    createUC = CreatePaymentReminderUC(
      repo: repo,
      time: timeService,
      ids: TestIdService(values: <String>['rem-1']),
      validator: validator,
    );
    updateUC = UpdatePaymentReminderUC(
      repo: repo,
      time: timeService,
      validator: validator,
    );
    markDoneUC = MarkReminderDoneUC(repo: repo, time: timeService);
  });

  tearDown(() {
    repo.dispose();
  });

  test('create сохраняет напоминание с whenAtMs и isDone=false', () async {
    final PaymentReminder reminder = await createUC(
      CreatePaymentReminderInput(
        title: 'Разовый платёж',
        amount: MoneyAmount(minor: BigInt.from(40000), scale: 2),
        whenLocal: DateTime(2024, 1, 2, 10),
        note: 'Примечание',
      ),
    );

    expect(reminder.id, 'rem-1');
    expect(reminder.isDone, isFalse);
    expect(reminder.whenAtMs, timeService.toEpochMs(DateTime(2024, 1, 2, 10)));
    final PaymentReminder? stored = await repo.getById('rem-1');
    expect(stored, equals(reminder));
  });

  test('update обновляет дату и заметку', () async {
    final PaymentReminder created = await createUC(
      CreatePaymentReminderInput(
        title: 'Разовый платёж',
        amount: MoneyAmount(minor: BigInt.from(40000), scale: 2),
        whenLocal: DateTime(2024, 1, 2, 10),
        note: 'Примечание',
      ),
    );

    timeService.now = DateTime(2024, 1, 3, 8);

    final PaymentReminder updated = await updateUC(
      UpdatePaymentReminderInput(
        id: created.id,
        amount: MoneyAmount(minor: BigInt.from(45000), scale: 2),
        whenLocal: DateTime(2024, 1, 5, 12),
        note: const ValueUpdate<String?>.present('Новая заметка'),
      ),
    );

    expect(
      updated.amountValue,
      MoneyAmount(minor: BigInt.from(45000), scale: 2),
    );
    expect(updated.whenAtMs, timeService.toEpochMs(DateTime(2024, 1, 5, 12)));
    expect(updated.note, 'Новая заметка');
    expect(updated.updatedAtMs, timeService.toEpochMs(DateTime(2024, 1, 3, 8)));
  });

  test('markReminderDone переключает статус', () async {
    final PaymentReminder created = await createUC(
      CreatePaymentReminderInput(
        title: 'Разовый платёж',
        amount: MoneyAmount(minor: BigInt.from(40000), scale: 2),
        whenLocal: DateTime(2024, 1, 2, 10),
        note: null,
      ),
    );

    timeService.now = DateTime(2024, 1, 2, 11);

    final PaymentReminder done = await markDoneUC(
      MarkReminderDoneInput(id: created.id, isDone: true),
    );
    expect(done.isDone, isTrue);
    expect(done.updatedAtMs, timeService.toEpochMs(DateTime(2024, 1, 2, 11)));

    final PaymentReminder unchanged = await markDoneUC(
      MarkReminderDoneInput(id: created.id, isDone: true),
    );
    expect(unchanged, equals(done));
  });
}
