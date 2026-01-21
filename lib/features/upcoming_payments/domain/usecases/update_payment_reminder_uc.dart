import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/payment_reminder.dart';
import 'package:kopim/features/upcoming_payments/domain/models/value_update.dart';
import 'package:kopim/features/upcoming_payments/domain/repositories/payment_reminders_repository.dart';
import 'package:kopim/features/upcoming_payments/domain/services/time_service.dart';
import 'package:kopim/features/upcoming_payments/domain/validators/payment_reminder_validator.dart';

part 'update_payment_reminder_uc.freezed.dart';

@freezed
abstract class UpdatePaymentReminderInput with _$UpdatePaymentReminderInput {
  const factory UpdatePaymentReminderInput({
    required String id,
    String? title,
    MoneyAmount? amount,
    DateTime? whenLocal,
    @Default(ValueUpdate<String?>.absent()) ValueUpdate<String?> note,
  }) = _UpdatePaymentReminderInput;
}

class UpdatePaymentReminderUC {
  UpdatePaymentReminderUC({
    required PaymentRemindersRepository repo,
    required TimeService time,
    required PaymentReminderValidator validator,
  }) : _repo = repo,
       _time = time,
       _validator = validator;

  final PaymentRemindersRepository _repo;
  final TimeService _time;
  final PaymentReminderValidator _validator;

  Future<PaymentReminder> call(UpdatePaymentReminderInput input) async {
    final PaymentReminder? current = await _repo.getById(input.id);
    if (current == null) {
      throw StateError('Напоминание не найдено: ${input.id}');
    }

    final String title = input.title ?? current.title;
    final MoneyAmount amount = input.amount ?? current.amountValue;
    final DateTime whenLocal =
        input.whenLocal ?? _time.toLocal(current.whenAtMs);
    final String? note = input.note.isPresent ? input.note.value : current.note;

    _validator.validate(title: title, amount: amount, whenLocal: whenLocal);

    final DateTime nowLocal = _time.nowLocal();
    final PaymentReminder updated = current.copyWith(
      title: title,
      amountMinor: amount.minor,
      amountScale: amount.scale,
      whenAtMs: _time.toEpochMs(whenLocal),
      note: note,
      updatedAtMs: _time.toEpochMs(nowLocal),
    );

    await _repo.upsert(updated);
    return updated;
  }
}
