import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';
import 'package:kopim/features/upcoming_payments/domain/repositories/upcoming_payments_repository.dart';
import 'package:kopim/features/upcoming_payments/domain/services/id_service.dart';
import 'package:kopim/features/upcoming_payments/domain/services/schedule_policy.dart';
import 'package:kopim/features/upcoming_payments/domain/services/time_service.dart';
import 'package:kopim/features/upcoming_payments/domain/validators/upcoming_payment_validator.dart';

part 'create_upcoming_payment_uc.freezed.dart';

@freezed
abstract class CreateUpcomingPaymentInput with _$CreateUpcomingPaymentInput {
  const factory CreateUpcomingPaymentInput({
    String? id,
    required String title,
    required String accountId,
    required String categoryId,
    required MoneyAmount amount,
    required int dayOfMonth,
    required int notifyDaysBefore,
    required String notifyTimeHhmm,
    String? note,
    required bool autoPost,
  }) = _CreateUpcomingPaymentInput;
}

class CreateUpcomingPaymentUC {
  CreateUpcomingPaymentUC({
    required UpcomingPaymentsRepository repo,
    required TimeService time,
    required SchedulePolicy policy,
    required IdService ids,
    required UpcomingPaymentValidator validator,
  }) : _repo = repo,
       _time = time,
       _policy = policy,
       _ids = ids,
       _validator = validator;

  final UpcomingPaymentsRepository _repo;
  final TimeService _time;
  final SchedulePolicy _policy;
  final IdService _ids;
  final UpcomingPaymentValidator _validator;

  Future<UpcomingPayment> call(CreateUpcomingPaymentInput input) async {
    _validator.validate(
      title: input.title,
      amount: input.amount,
      dayOfMonth: input.dayOfMonth,
      notifyDaysBefore: input.notifyDaysBefore,
      notifyTimeHhmm: input.notifyTimeHhmm,
      accountId: input.accountId,
      categoryId: input.categoryId,
    );

    final String id = input.id ?? _ids.generate();
    final DateTime nowLocal = _time.nowLocal();
    final int nowMs = _time.toEpochMs(nowLocal);

    final DateTime nextRunLocal = _policy.computeNextRunLocal(
      fromLocal: nowLocal,
      dayOfMonth: input.dayOfMonth,
    );
    final DateTime nextNotifyLocal = _policy.computeNextNotifyLocal(
      nextRunLocal: nextRunLocal,
      notifyDaysBefore: input.notifyDaysBefore,
      notifyTimeHhmm: input.notifyTimeHhmm,
    );

    final UpcomingPayment payment = UpcomingPayment(
      id: id,
      title: input.title,
      accountId: input.accountId,
      categoryId: input.categoryId,
      amountMinor: input.amount.minor,
      amountScale: input.amount.scale,
      dayOfMonth: input.dayOfMonth,
      notifyDaysBefore: input.notifyDaysBefore,
      notifyTimeHhmm: input.notifyTimeHhmm,
      note: input.note,
      autoPost: input.autoPost,
      isActive: true,
      nextRunAtMs: _time.toEpochMs(nextRunLocal),
      nextNotifyAtMs: _time.toEpochMs(nextNotifyLocal),
      createdAtMs: nowMs,
      updatedAtMs: nowMs,
    );

    await _repo.upsert(payment);
    return payment;
  }
}
