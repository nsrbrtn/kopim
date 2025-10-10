import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:kopim/features/upcoming_payments/domain/entities/payment_reminder.dart';
import 'package:kopim/features/upcoming_payments/domain/repositories/payment_reminders_repository.dart';
import 'package:kopim/features/upcoming_payments/domain/services/id_service.dart';
import 'package:kopim/features/upcoming_payments/domain/services/time_service.dart';
import 'package:kopim/features/upcoming_payments/domain/validators/payment_reminder_validator.dart';

part 'create_payment_reminder_uc.freezed.dart';

@freezed
abstract class CreatePaymentReminderInput with _$CreatePaymentReminderInput {
  const factory CreatePaymentReminderInput({
    String? id,
    required String title,
    required double amount,
    required DateTime whenLocal,
    String? note,
  }) = _CreatePaymentReminderInput;
}

class CreatePaymentReminderUC {
  CreatePaymentReminderUC({
    required PaymentRemindersRepository repo,
    required TimeService time,
    required IdService ids,
    required PaymentReminderValidator validator,
  }) : _repo = repo,
       _time = time,
       _ids = ids,
       _validator = validator;

  final PaymentRemindersRepository _repo;
  final TimeService _time;
  final IdService _ids;
  final PaymentReminderValidator _validator;

  Future<PaymentReminder> call(CreatePaymentReminderInput input) async {
    _validator.validate(
      title: input.title,
      amount: input.amount,
      whenLocal: input.whenLocal,
    );

    final String id = input.id ?? _ids.generate();
    final DateTime nowLocal = _time.nowLocal();
    final int nowMs = _time.toEpochMs(nowLocal);
    final int whenAtMs = _time.toEpochMs(input.whenLocal);

    final PaymentReminder reminder = PaymentReminder(
      id: id,
      title: input.title,
      amount: input.amount,
      whenAtMs: whenAtMs,
      note: input.note,
      isDone: false,
      createdAtMs: nowMs,
      updatedAtMs: nowMs,
    );
    await _repo.upsert(reminder);
    return reminder;
  }
}
