import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/payment_reminder.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';

part 'upcoming_payments_providers.g.dart';

@riverpod
Stream<List<UpcomingPayment>> watchUpcomingPayments(Ref ref) {
  return ref.watch(upcomingPaymentsRepositoryProvider).watchAll();
}

@riverpod
Stream<List<PaymentReminder>> watchPaymentReminders(Ref ref, {int? limit}) {
  return ref
      .watch(paymentRemindersRepositoryProvider)
      .watchUpcoming(limit: limit);
}
