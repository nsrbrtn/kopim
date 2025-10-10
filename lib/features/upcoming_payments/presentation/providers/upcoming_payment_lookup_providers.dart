import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/payment_reminder.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';

part 'upcoming_payment_lookup_providers.g.dart';

@riverpod
Future<UpcomingPayment?> upcomingPaymentById(Ref ref, String id) {
  return ref.watch(upcomingPaymentsRepositoryProvider).getById(id);
}

@riverpod
Future<PaymentReminder?> paymentReminderById(Ref ref, String id) {
  return ref.watch(paymentRemindersRepositoryProvider).getById(id);
}
