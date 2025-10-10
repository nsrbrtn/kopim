import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';
import 'package:kopim/features/upcoming_payments/domain/repositories/upcoming_payments_repository.dart';
import 'package:kopim/features/upcoming_payments/domain/services/schedule_policy.dart';
import 'package:kopim/features/upcoming_payments/domain/services/time_service.dart';

part 'recalc_upcoming_payment_uc.freezed.dart';

@freezed
abstract class RecalcUpcomingPaymentRequest
    with _$RecalcUpcomingPaymentRequest {
  const factory RecalcUpcomingPaymentRequest.byId(String id) = _ById;
  const factory RecalcUpcomingPaymentRequest.entity(UpcomingPayment payment) =
      _Entity;
}

class RecalcUpcomingPaymentUC {
  const RecalcUpcomingPaymentUC({
    required UpcomingPaymentsRepository repo,
    required TimeService time,
    required SchedulePolicy policy,
  }) : _repo = repo,
       _time = time,
       _policy = policy;

  final UpcomingPaymentsRepository _repo;
  final TimeService _time;
  final SchedulePolicy _policy;

  Future<UpcomingPayment?> call(RecalcUpcomingPaymentRequest request) async {
    final UpcomingPayment? current = await request.when(
      byId: _repo.getById,
      entity: (UpcomingPayment payment) async => payment,
    );
    if (current == null) {
      return null;
    }

    final DateTime nowLocal = _time.nowLocal();
    final DateTime nextRunLocal = _policy.computeNextRunLocal(
      fromLocal: nowLocal,
      dayOfMonth: current.dayOfMonth,
    );
    final DateTime nextNotifyLocal = _policy.computeNextNotifyLocal(
      nextRunLocal: nextRunLocal,
      notifyDaysBefore: current.notifyDaysBefore,
      notifyTimeHhmm: current.notifyTimeHhmm,
    );

    final int nextRunAtMs = _time.toEpochMs(nextRunLocal);
    final int nextNotifyAtMs = _time.toEpochMs(nextNotifyLocal);

    if (current.nextRunAtMs == nextRunAtMs &&
        current.nextNotifyAtMs == nextNotifyAtMs) {
      return current;
    }

    final UpcomingPayment updated = current.copyWith(
      nextRunAtMs: nextRunAtMs,
      nextNotifyAtMs: nextNotifyAtMs,
      updatedAtMs: _time.toEpochMs(nowLocal),
    );
    await _repo.upsert(updated);
    return updated;
  }
}
