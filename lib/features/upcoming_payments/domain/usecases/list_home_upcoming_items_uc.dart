import 'dart:async';

import 'package:kopim/features/upcoming_payments/domain/entities/payment_reminder.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';
import 'package:kopim/features/upcoming_payments/domain/models/upcoming_item.dart';
import 'package:kopim/features/upcoming_payments/domain/repositories/payment_reminders_repository.dart';
import 'package:kopim/features/upcoming_payments/domain/repositories/upcoming_payments_repository.dart';

class ListHomeUpcomingItemsUC {
  const ListHomeUpcomingItemsUC({
    required UpcomingPaymentsRepository upcomingRepo,
    required PaymentRemindersRepository remindersRepo,
  }) : _upcomingRepo = upcomingRepo,
       _remindersRepo = remindersRepo;

  final UpcomingPaymentsRepository _upcomingRepo;
  final PaymentRemindersRepository _remindersRepo;

  Stream<List<UpcomingItem>> watch({required int limit}) {
    final Stream<List<UpcomingPayment>> paymentsStream = _upcomingRepo
        .watchAll();
    final Stream<List<PaymentReminder>> remindersStream = _remindersRepo
        .watchUpcoming(limit: limit);

    return Stream<List<UpcomingItem>>.multi((
      StreamController<List<UpcomingItem>> controller,
    ) {
      List<UpcomingPayment> latestPayments = const <UpcomingPayment>[];
      List<PaymentReminder> latestReminders = const <PaymentReminder>[];
      bool hasPayments = false;
      bool hasReminders = false;
      bool paymentsDone = false;
      bool remindersDone = false;

      void emitIfReady() {
        if (!hasPayments || !hasReminders) {
          return;
        }
        controller.add(_merge(latestPayments, latestReminders, limit));
      }

      final StreamSubscription<List<UpcomingPayment>> paymentsSub =
          paymentsStream.listen(
            (List<UpcomingPayment> data) {
              hasPayments = true;
              latestPayments = data;
              emitIfReady();
            },
            onError: controller.addError,
            onDone: () {
              paymentsDone = true;
              if (remindersDone && !controller.isClosed) {
                controller.close();
              }
            },
          );

      final StreamSubscription<List<PaymentReminder>> remindersSub =
          remindersStream.listen(
            (List<PaymentReminder> data) {
              hasReminders = true;
              latestReminders = data;
              emitIfReady();
            },
            onError: controller.addError,
            onDone: () {
              remindersDone = true;
              if (paymentsDone && !controller.isClosed) {
                controller.close();
              }
            },
          );

      controller
        ..onPause = () {
          paymentsSub.pause();
          remindersSub.pause();
        }
        ..onResume = () {
          paymentsSub.resume();
          remindersSub.resume();
        }
        ..onCancel = () async {
          await Future.wait<void>(<Future<void>>[
            paymentsSub.cancel(),
            remindersSub.cancel(),
          ]);
        };
    });
  }

  List<UpcomingItem> _merge(
    List<UpcomingPayment> payments,
    List<PaymentReminder> reminders,
    int limit,
  ) {
    final List<UpcomingItem> items = <UpcomingItem>[];

    for (final UpcomingPayment payment in payments) {
      final int? runAt = payment.nextRunAtMs;
      if (runAt == null) {
        continue;
      }
      items.add(
        UpcomingItem(
          type: UpcomingItemType.paymentRule,
          id: payment.id,
          title: payment.title,
          amount: payment.amountValue,
          whenMs: runAt,
          note: payment.note,
        ),
      );
    }

    for (final PaymentReminder reminder in reminders) {
      if (reminder.isDone) {
        continue;
      }
      items.add(
        UpcomingItem(
          type: UpcomingItemType.reminder,
          id: reminder.id,
          title: reminder.title,
          amount: reminder.amountValue,
          whenMs: reminder.whenAtMs,
          note: reminder.note,
        ),
      );
    }

    items.sort(
      (UpcomingItem a, UpcomingItem b) => a.whenMs.compareTo(b.whenMs),
    );
    if (items.length <= limit) {
      return List<UpcomingItem>.unmodifiable(items);
    }
    return List<UpcomingItem>.unmodifiable(items.take(limit));
  }
}
