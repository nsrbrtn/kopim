import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';
import 'package:kopim/features/upcoming_payments/domain/models/value_update.dart';
import 'package:kopim/features/upcoming_payments/domain/repositories/upcoming_payments_repository.dart';
import 'package:kopim/features/upcoming_payments/domain/services/schedule_policy.dart';
import 'package:kopim/features/upcoming_payments/domain/services/time_service.dart';
import 'package:kopim/features/upcoming_payments/domain/validators/upcoming_payment_validator.dart';

part 'update_upcoming_payment_uc.freezed.dart';

@freezed
abstract class UpdateUpcomingPaymentInput with _$UpdateUpcomingPaymentInput {
  const factory UpdateUpcomingPaymentInput({
    required String id,
    String? title,
    String? accountId,
    String? categoryId,
    double? amount,
    int? dayOfMonth,
    int? notifyDaysBefore,
    String? notifyTimeHhmm,
    @Default(ValueUpdate<String?>.absent()) ValueUpdate<String?> note,
    bool? autoPost,
    bool? isActive,
  }) = _UpdateUpcomingPaymentInput;
}

class UpdateUpcomingPaymentUC {
  UpdateUpcomingPaymentUC({
    required UpcomingPaymentsRepository repo,
    required TimeService time,
    required SchedulePolicy policy,
    required UpcomingPaymentValidator validator,
  }) : _repo = repo,
       _time = time,
       _policy = policy,
       _validator = validator;

  final UpcomingPaymentsRepository _repo;
  final TimeService _time;
  final SchedulePolicy _policy;
  final UpcomingPaymentValidator _validator;

  Future<UpcomingPayment> call(UpdateUpcomingPaymentInput input) async {
    final UpcomingPayment? current = await _repo.getById(input.id);
    if (current == null) {
      throw StateError('Правило не найдено: ${input.id}');
    }

    final String title = input.title ?? current.title;
    final String accountId = input.accountId ?? current.accountId;
    final String categoryId = input.categoryId ?? current.categoryId;
    final double amount = input.amount ?? current.amount;
    final int dayOfMonth = input.dayOfMonth ?? current.dayOfMonth;
    final int notifyDaysBefore =
        input.notifyDaysBefore ?? current.notifyDaysBefore;
    final String notifyTimeHhmm =
        input.notifyTimeHhmm ?? current.notifyTimeHhmm;
    final bool autoPost = input.autoPost ?? current.autoPost;
    final bool isActive = input.isActive ?? current.isActive;
    final String? note = input.note.isPresent ? input.note.value : current.note;

    _validator.validate(
      title: title,
      amount: amount,
      dayOfMonth: dayOfMonth,
      notifyDaysBefore: notifyDaysBefore,
      notifyTimeHhmm: notifyTimeHhmm,
      accountId: accountId,
      categoryId: categoryId,
    );

    final DateTime nowLocal = _time.nowLocal();
    final int updatedAt = _time.toEpochMs(nowLocal);

    final DateTime nextRunLocal = _policy.computeNextRunLocal(
      fromLocal: nowLocal,
      dayOfMonth: dayOfMonth,
    );
    final DateTime nextNotifyLocal = _policy.computeNextNotifyLocal(
      nextRunLocal: nextRunLocal,
      notifyDaysBefore: notifyDaysBefore,
      notifyTimeHhmm: notifyTimeHhmm,
    );

    final UpcomingPayment updated = current.copyWith(
      title: title,
      accountId: accountId,
      categoryId: categoryId,
      amount: amount,
      dayOfMonth: dayOfMonth,
      notifyDaysBefore: notifyDaysBefore,
      notifyTimeHhmm: notifyTimeHhmm,
      note: note,
      autoPost: autoPost,
      isActive: isActive,
      nextRunAtMs: _time.toEpochMs(nextRunLocal),
      nextNotifyAtMs: _time.toEpochMs(nextNotifyLocal),
      updatedAtMs: updatedAt,
    );

    await _repo.upsert(updated);
    return updated;
  }
}
