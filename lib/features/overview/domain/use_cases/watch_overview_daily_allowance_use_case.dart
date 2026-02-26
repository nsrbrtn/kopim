import 'dart:async';

import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/repositories/account_repository.dart';
import 'package:kopim/features/overview/domain/models/overview_daily_allowance.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';
import 'package:kopim/features/upcoming_payments/domain/repositories/upcoming_payments_repository.dart';
import 'package:kopim/features/upcoming_payments/domain/services/schedule_policy.dart';

class WatchOverviewDailyAllowanceUseCase {
  WatchOverviewDailyAllowanceUseCase({
    required AccountRepository accountRepository,
    required UpcomingPaymentsRepository upcomingPaymentsRepository,
    SchedulePolicy schedulePolicy = const SchedulePolicy(),
  }) : _accountRepository = accountRepository,
       _upcomingPaymentsRepository = upcomingPaymentsRepository,
       _schedulePolicy = schedulePolicy;

  final AccountRepository _accountRepository;
  final UpcomingPaymentsRepository _upcomingPaymentsRepository;
  final SchedulePolicy _schedulePolicy;

  Stream<OverviewDailyAllowance> call({
    Set<String>? accountIdsFilter,
    DateTime? now,
    String? selectedUpcomingPaymentId,
  }) {
    return _combineLatest2(
      _accountRepository.watchAccounts(),
      _upcomingPaymentsRepository.watchAll(),
      (List<AccountEntity> accounts, List<UpcomingPayment> payments) {
        return _computeDailyAllowance(
          accounts: accounts,
          payments: payments,
          accountIdsFilter: accountIdsFilter,
          now: now ?? DateTime.now(),
          selectedUpcomingPaymentId: selectedUpcomingPaymentId,
        );
      },
    );
  }

  OverviewDailyAllowance _computeDailyAllowance({
    required List<AccountEntity> accounts,
    required List<UpcomingPayment> payments,
    required DateTime now,
    Set<String>? accountIdsFilter,
    String? selectedUpcomingPaymentId,
  }) {
    final DateTime nowLocal = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
      now.second,
      now.millisecond,
      now.microsecond,
    );
    final DateTime today = DateTime(
      nowLocal.year,
      nowLocal.month,
      nowLocal.day,
    );

    final List<AccountEntity> scopedAccounts = accounts
        .where((AccountEntity account) {
          if (account.isDeleted) {
            return false;
          }
          if (accountIdsFilter == null || accountIdsFilter.isEmpty) {
            return true;
          }
          return accountIdsFilter.contains(account.id);
        })
        .toList(growable: false);

    final Set<String> accountIds = scopedAccounts
        .map((AccountEntity account) => account.id)
        .toSet();

    final List<_UpcomingProjection> projections = payments
        .where(
          (UpcomingPayment payment) =>
              payment.isActive &&
              (accountIdsFilter == null ||
                  accountIdsFilter.isEmpty ||
                  accountIds.contains(payment.accountId)),
        )
        .map((UpcomingPayment payment) {
          final DateTime nextRun = _schedulePolicy.computeNextRunLocal(
            fromLocal: nowLocal,
            dayOfMonth: payment.dayOfMonth,
          );
          return _UpcomingProjection(
            payment: payment,
            nextRunDate: DateTime(nextRun.year, nextRun.month, nextRun.day),
          );
        })
        .toList(growable: false);

    _UpcomingProjection? selectedAnchorProjection;
    if (selectedUpcomingPaymentId != null &&
        selectedUpcomingPaymentId.isNotEmpty) {
      for (final _UpcomingProjection projection in projections) {
        if (projection.payment.id == selectedUpcomingPaymentId &&
            projection.payment.flowType == UpcomingPaymentFlowType.income) {
          selectedAnchorProjection = projection;
          break;
        }
      }
    }

    DateTime? nearestIncomeDate;
    for (final _UpcomingProjection projection in projections) {
      if (projection.payment.flowType != UpcomingPaymentFlowType.income) {
        continue;
      }
      if (nearestIncomeDate == null ||
          projection.nextRunDate.isBefore(nearestIncomeDate)) {
        nearestIncomeDate = projection.nextRunDate;
      }
    }

    final DateTime horizon =
        selectedAnchorProjection?.nextRunDate ??
        nearestIncomeDate ??
        today.add(const Duration(days: 30));
    final bool hasIncomeAnchor =
        selectedAnchorProjection != null || nearestIncomeDate != null;

    final MoneyAccumulator balance = MoneyAccumulator();
    for (final AccountEntity account in scopedAccounts) {
      balance.add(account.balanceAmount);
    }

    final MoneyAccumulator plannedIncome = MoneyAccumulator();
    final MoneyAccumulator plannedExpense = MoneyAccumulator();

    for (final _UpcomingProjection projection in projections) {
      if (projection.nextRunDate.isAfter(horizon)) {
        continue;
      }
      final MoneyAmount amount = projection.payment.amountValue.abs();
      if (selectedAnchorProjection != null &&
          projection.payment.id != selectedAnchorProjection.payment.id &&
          projection.payment.flowType == UpcomingPaymentFlowType.income) {
        continue;
      }
      if (projection.payment.flowType == UpcomingPaymentFlowType.income) {
        plannedIncome.add(amount);
      } else {
        plannedExpense.add(amount);
      }
    }

    final MoneyAccumulator disposable = MoneyAccumulator();
    disposable.add(MoneyAmount(minor: balance.minor, scale: balance.scale));
    disposable.add(
      MoneyAmount(minor: plannedIncome.minor, scale: plannedIncome.scale),
    );
    disposable.subtract(
      MoneyAmount(minor: plannedExpense.minor, scale: plannedExpense.scale),
    );

    final int daysLeftRaw = horizon.difference(today).inDays;
    final int daysLeft = daysLeftRaw <= 0 ? 1 : daysLeftRaw;

    final BigInt perDayMinor = disposable.minor ~/ BigInt.from(daysLeft);
    final MoneyAmount dailyAllowance = MoneyAmount(
      minor: perDayMinor,
      scale: disposable.scale,
    );

    return OverviewDailyAllowance(
      dailyAllowance: dailyAllowance,
      daysLeft: daysLeft,
      horizonDate: horizon,
      disposableAtHorizon: MoneyAmount(
        minor: disposable.minor,
        scale: disposable.scale,
      ),
      plannedIncome: MoneyAmount(
        minor: plannedIncome.minor,
        scale: plannedIncome.scale,
      ),
      plannedExpense: MoneyAmount(
        minor: plannedExpense.minor,
        scale: plannedExpense.scale,
      ),
      hasIncomeAnchor: hasIncomeAnchor,
    );
  }
}

class _UpcomingProjection {
  const _UpcomingProjection({required this.payment, required this.nextRunDate});

  final UpcomingPayment payment;
  final DateTime nextRunDate;
}

Stream<R> _combineLatest2<A, B, R>(
  Stream<A> a,
  Stream<B> b,
  R Function(A a, B b) combiner,
) {
  return Stream<R>.multi((StreamController<R> controller) {
    A? latestA;
    B? latestB;
    bool hasA = false;
    bool hasB = false;

    void emit() {
      if (!hasA || !hasB) {
        return;
      }
      try {
        controller.add(combiner(latestA as A, latestB as B));
      } catch (error, stackTrace) {
        controller.addError(error, stackTrace);
      }
    }

    final StreamSubscription<A> subA = a.listen((A value) {
      latestA = value;
      hasA = true;
      emit();
    }, onError: controller.addError);

    final StreamSubscription<B> subB = b.listen((B value) {
      latestB = value;
      hasB = true;
      emit();
    }, onError: controller.addError);

    controller.onCancel = () async {
      await subA.cancel();
      await subB.cancel();
    };
  });
}
