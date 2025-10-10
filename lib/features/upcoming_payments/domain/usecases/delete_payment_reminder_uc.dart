import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:kopim/features/upcoming_payments/domain/repositories/payment_reminders_repository.dart';

part 'delete_payment_reminder_uc.freezed.dart';

@freezed
abstract class DeletePaymentReminderInput with _$DeletePaymentReminderInput {
  const factory DeletePaymentReminderInput({required String id}) =
      _DeletePaymentReminderInput;
}

class DeletePaymentReminderUC {
  const DeletePaymentReminderUC({required PaymentRemindersRepository repo})
    : _repo = repo;

  final PaymentRemindersRepository _repo;

  Future<void> call(DeletePaymentReminderInput input) {
    return _repo.delete(input.id);
  }
}
