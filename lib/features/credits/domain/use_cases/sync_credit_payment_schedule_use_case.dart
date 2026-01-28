import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/features/credits/domain/repositories/credit_repository.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';
import 'package:kopim/features/upcoming_payments/domain/repositories/upcoming_payments_repository.dart';
import 'package:kopim/features/upcoming_payments/domain/services/schedule_policy.dart';
import 'package:kopim/features/upcoming_payments/domain/services/time_service.dart';

class SyncCreditPaymentScheduleUseCase {
  const SyncCreditPaymentScheduleUseCase({
    required CreditRepository creditRepository,
    required TransactionRepository transactionRepository,
    required UpcomingPaymentsRepository upcomingPaymentsRepository,
    required SchedulePolicy schedulePolicy,
    required TimeService timeService,
  }) : _creditRepository = creditRepository,
       _transactionRepository = transactionRepository,
       _upcomingPaymentsRepository = upcomingPaymentsRepository,
       _schedulePolicy = schedulePolicy,
       _timeService = timeService;

  final CreditRepository _creditRepository;
  final TransactionRepository _transactionRepository;
  final UpcomingPaymentsRepository _upcomingPaymentsRepository;
  final SchedulePolicy _schedulePolicy;
  final TimeService _timeService;

  Future<void> call({
    TransactionEntity? previous,
    TransactionEntity? current,
  }) async {
    final Set<String> categoryIds = <String>{
      if (previous?.categoryId != null && previous!.categoryId!.isNotEmpty)
        previous.categoryId!,
      if (current?.categoryId != null && current!.categoryId!.isNotEmpty)
        current.categoryId!,
    };
    if (categoryIds.isEmpty) return;

    for (final String categoryId in categoryIds) {
      final CreditEntity? credit = await _creditRepository
          .getCreditByCategoryId(categoryId);
      if (credit == null) {
        continue;
      }

      final UpcomingPayment? upcoming = await _upcomingPaymentsRepository
          .getByCategoryId(categoryId);
      if (upcoming == null) {
        continue;
      }

      final TransactionEntity? latest = await _transactionRepository
          .findLatestByCategoryId(categoryId);
      final DateTime baseLocal = latest != null
          ? _normalizeLocal(latest.date)
          : _timeService.nowLocal();
      final DateTime nextRunLocal = latest != null
          ? _computeNextRunAfterPayment(baseLocal, upcoming.dayOfMonth)
          : _schedulePolicy.computeNextRunLocal(
              fromLocal: baseLocal,
              dayOfMonth: upcoming.dayOfMonth,
            );
      final DateTime nextNotifyLocal = _schedulePolicy.computeNextNotifyLocal(
        nextRunLocal: nextRunLocal,
        notifyDaysBefore: upcoming.notifyDaysBefore,
        notifyTimeHhmm: upcoming.notifyTimeHhmm,
      );
      final int nextRunAtMs = _timeService.toEpochMs(nextRunLocal);
      final int nextNotifyAtMs = _timeService.toEpochMs(nextNotifyLocal);

      if (upcoming.nextRunAtMs == nextRunAtMs &&
          upcoming.nextNotifyAtMs == nextNotifyAtMs) {
        continue;
      }

      final UpcomingPayment updated = upcoming.copyWith(
        nextRunAtMs: nextRunAtMs,
        nextNotifyAtMs: nextNotifyAtMs,
        updatedAtMs: _timeService.nowMs(),
      );
      await _upcomingPaymentsRepository.upsert(updated);
    }
  }

  DateTime _normalizeLocal(DateTime date) {
    return _timeService.toLocal(_timeService.toEpochMs(date));
  }

  DateTime _computeNextRunAfterPayment(DateTime paymentLocal, int dayOfMonth) {
    final DateTime nextMonth = DateTime(
      paymentLocal.year,
      paymentLocal.month + 1,
      1,
    );
    final int lastDay = _schedulePolicy.lastDayOfMonth(
      nextMonth.year,
      nextMonth.month,
    );
    final int targetDay = dayOfMonth > lastDay ? lastDay : dayOfMonth;
    return DateTime(nextMonth.year, nextMonth.month, targetDay, 0, 1);
  }
}
