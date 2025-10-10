import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:kopim/features/upcoming_payments/domain/entities/payment_reminder.dart';
import 'package:kopim/features/upcoming_payments/domain/repositories/payment_reminders_repository.dart';
import 'package:kopim/features/upcoming_payments/domain/services/time_service.dart';

part 'mark_reminder_done_uc.freezed.dart';

@freezed
abstract class MarkReminderDoneInput with _$MarkReminderDoneInput {
  const factory MarkReminderDoneInput({
    required String id,
    required bool isDone,
  }) = _MarkReminderDoneInput;
}

class MarkReminderDoneUC {
  const MarkReminderDoneUC({
    required PaymentRemindersRepository repo,
    required TimeService time,
  }) : _repo = repo,
       _time = time;

  final PaymentRemindersRepository _repo;
  final TimeService _time;

  Future<PaymentReminder> call(MarkReminderDoneInput input) async {
    final PaymentReminder? current = await _repo.getById(input.id);
    if (current == null) {
      throw StateError('Напоминание не найдено: ${input.id}');
    }
    if (current.isDone == input.isDone) {
      return current;
    }
    final DateTime nowLocal = _time.nowLocal();
    final PaymentReminder updated = current.copyWith(
      isDone: input.isDone,
      updatedAtMs: _time.toEpochMs(nowLocal),
    );
    await _repo.upsert(updated);
    return updated;
  }
}
