import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/payment_reminder.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';
import 'package:kopim/features/upcoming_payments/domain/models/upcoming_item.dart';
import 'package:kopim/features/upcoming_payments/domain/usecases/list_home_upcoming_items_uc.dart';

import '../../test_utils/fakes.dart';

void main() {
  late InMemoryUpcomingPaymentsRepository upcomingRepo;
  late InMemoryPaymentRemindersRepository remindersRepo;
  late ListHomeUpcomingItemsUC uc;

  setUp(() {
    upcomingRepo = InMemoryUpcomingPaymentsRepository();
    remindersRepo = InMemoryPaymentRemindersRepository();
    uc = ListHomeUpcomingItemsUC(
      upcomingRepo: upcomingRepo,
      remindersRepo: remindersRepo,
    );
  });

  tearDown(() {
    upcomingRepo.dispose();
    remindersRepo.dispose();
  });

  UpcomingPayment buildPayment({
    required String id,
    required int? nextNotify,
    required int? nextRun,
  }) {
    return UpcomingPayment(
      id: id,
      title: 'Правило $id',
      accountId: 'acc',
      categoryId: 'cat',
      amount: 1000,
      dayOfMonth: 10,
      notifyDaysBefore: 1,
      notifyTimeHhmm: '09:00',
      note: null,
      autoPost: false,
      isActive: true,
      nextRunAtMs: nextRun,
      nextNotifyAtMs: nextNotify,
      createdAtMs: 0,
      updatedAtMs: 0,
    );
  }

  PaymentReminder buildReminder({
    required String id,
    required int when,
    bool isDone = false,
  }) {
    return PaymentReminder(
      id: id,
      title: 'Напоминание $id',
      amount: 200,
      whenAtMs: when,
      note: null,
      isDone: isDone,
      createdAtMs: 0,
      updatedAtMs: 0,
    );
  }

  test('объединяет и сортирует элементы с учётом лимита', () async {
    upcomingRepo.emitAll(<UpcomingPayment>[
      buildPayment(id: 'rule1', nextNotify: 2200, nextRun: 3000),
      buildPayment(id: 'rule2', nextNotify: null, nextRun: 1800),
    ]);
    remindersRepo.emitAll(<PaymentReminder>[
      buildReminder(id: 'rem1', when: 1500),
      buildReminder(id: 'rem2', when: 4000),
      buildReminder(id: 'rem3', when: 1200, isDone: true),
    ]);

    final List<UpcomingItem> items = await uc.watch(limit: 3).first;
    expect(items, hasLength(3));
    final List<String> ids = items.map((UpcomingItem e) => e.id).toList();
    expect(ids, <String>['rem1', 'rule2', 'rule1']);
    expect(items.first.type, UpcomingItemType.reminder);
    expect(items.first.whenMs, 1500);
    expect(items[1].type, UpcomingItemType.paymentRule);
    expect(items[1].whenMs, 1800);
    expect(items[2].whenMs, 2200);
  });
}
