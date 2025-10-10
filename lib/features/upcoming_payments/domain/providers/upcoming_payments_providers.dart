import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/payment_reminder.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';
import 'package:kopim/features/upcoming_payments/domain/models/upcoming_item.dart';
import 'package:kopim/features/upcoming_payments/domain/services/id_service.dart';
import 'package:kopim/features/upcoming_payments/domain/services/schedule_policy.dart';
import 'package:kopim/features/upcoming_payments/domain/services/time_service.dart';
import 'package:kopim/features/upcoming_payments/domain/usecases/create_payment_reminder_uc.dart';
import 'package:kopim/features/upcoming_payments/domain/usecases/create_upcoming_payment_uc.dart';
import 'package:kopim/features/upcoming_payments/domain/usecases/delete_payment_reminder_uc.dart';
import 'package:kopim/features/upcoming_payments/domain/usecases/delete_upcoming_payment_uc.dart';
import 'package:kopim/features/upcoming_payments/domain/usecases/list_home_upcoming_items_uc.dart';
import 'package:kopim/features/upcoming_payments/domain/usecases/mark_reminder_done_uc.dart';
import 'package:kopim/features/upcoming_payments/domain/usecases/recalc_upcoming_payment_uc.dart';
import 'package:kopim/features/upcoming_payments/domain/usecases/update_payment_reminder_uc.dart';
import 'package:kopim/features/upcoming_payments/domain/usecases/update_upcoming_payment_uc.dart';
import 'package:kopim/features/upcoming_payments/domain/validators/payment_reminder_validator.dart';
import 'package:kopim/features/upcoming_payments/domain/validators/upcoming_payment_validator.dart';

part 'upcoming_payments_providers.g.dart';

@riverpod
TimeService timeService(Ref ref) => const SystemTimeService();

@riverpod
SchedulePolicy schedulePolicy(Ref ref) => const SchedulePolicy();

@riverpod
IdService idService(Ref ref) => UuidIdService(ref.watch(uuidGeneratorProvider));

@riverpod
UpcomingPaymentValidator upcomingPaymentValidator(Ref ref) {
  return UpcomingPaymentValidator(timeService: ref.watch(timeServiceProvider));
}

@riverpod
PaymentReminderValidator paymentReminderValidator(Ref ref) {
  return PaymentReminderValidator(timeService: ref.watch(timeServiceProvider));
}

@riverpod
CreateUpcomingPaymentUC createUpcomingPaymentUC(Ref ref) {
  return CreateUpcomingPaymentUC(
    repo: ref.watch(upcomingPaymentsRepositoryProvider),
    time: ref.watch(timeServiceProvider),
    policy: ref.watch(schedulePolicyProvider),
    ids: ref.watch(idServiceProvider),
    validator: ref.watch(upcomingPaymentValidatorProvider),
  );
}

@riverpod
UpdateUpcomingPaymentUC updateUpcomingPaymentUC(Ref ref) {
  return UpdateUpcomingPaymentUC(
    repo: ref.watch(upcomingPaymentsRepositoryProvider),
    time: ref.watch(timeServiceProvider),
    policy: ref.watch(schedulePolicyProvider),
    validator: ref.watch(upcomingPaymentValidatorProvider),
  );
}

@riverpod
DeleteUpcomingPaymentUC deleteUpcomingPaymentUC(Ref ref) {
  return DeleteUpcomingPaymentUC(
    repo: ref.watch(upcomingPaymentsRepositoryProvider),
  );
}

@riverpod
RecalcUpcomingPaymentUC recalcUpcomingPaymentUC(Ref ref) {
  return RecalcUpcomingPaymentUC(
    repo: ref.watch(upcomingPaymentsRepositoryProvider),
    time: ref.watch(timeServiceProvider),
    policy: ref.watch(schedulePolicyProvider),
  );
}

@riverpod
CreatePaymentReminderUC createPaymentReminderUC(Ref ref) {
  return CreatePaymentReminderUC(
    repo: ref.watch(paymentRemindersRepositoryProvider),
    time: ref.watch(timeServiceProvider),
    ids: ref.watch(idServiceProvider),
    validator: ref.watch(paymentReminderValidatorProvider),
  );
}

@riverpod
UpdatePaymentReminderUC updatePaymentReminderUC(Ref ref) {
  return UpdatePaymentReminderUC(
    repo: ref.watch(paymentRemindersRepositoryProvider),
    time: ref.watch(timeServiceProvider),
    validator: ref.watch(paymentReminderValidatorProvider),
  );
}

@riverpod
DeletePaymentReminderUC deletePaymentReminderUC(Ref ref) {
  return DeletePaymentReminderUC(
    repo: ref.watch(paymentRemindersRepositoryProvider),
  );
}

@riverpod
MarkReminderDoneUC markReminderDoneUC(Ref ref) {
  return MarkReminderDoneUC(
    repo: ref.watch(paymentRemindersRepositoryProvider),
    time: ref.watch(timeServiceProvider),
  );
}

@riverpod
ListHomeUpcomingItemsUC listHomeUpcomingItemsUC(Ref ref) {
  return ListHomeUpcomingItemsUC(
    upcomingRepo: ref.watch(upcomingPaymentsRepositoryProvider),
    remindersRepo: ref.watch(paymentRemindersRepositoryProvider),
  );
}

@riverpod
Stream<List<UpcomingItem>> homeUpcomingItems(Ref ref, {int limit = 6}) {
  final ListHomeUpcomingItemsUC uc = ref.watch(listHomeUpcomingItemsUCProvider);
  return uc.watch(limit: limit);
}

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
