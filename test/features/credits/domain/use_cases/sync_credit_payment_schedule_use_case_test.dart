import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/features/credits/domain/repositories/credit_repository.dart';
import 'package:kopim/features/credits/domain/use_cases/sync_credit_payment_schedule_use_case.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/models/account_monthly_totals.dart';
import 'package:kopim/features/transactions/domain/models/budget_expense_totals.dart';
import 'package:kopim/features/transactions/domain/models/monthly_balance_totals.dart';
import 'package:kopim/features/transactions/domain/models/monthly_cashflow_totals.dart';
import 'package:kopim/features/transactions/domain/models/transaction_category_totals.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';
import 'package:kopim/features/upcoming_payments/domain/repositories/upcoming_payments_repository.dart';
import 'package:kopim/features/upcoming_payments/domain/services/schedule_policy.dart';
import 'package:kopim/features/upcoming_payments/domain/services/time_service.dart';

void main() {
  group('SyncCreditPaymentScheduleUseCase', () {
    test('moves next payment to next month after early payment', () async {
      final DateTime now = DateTime(2026, 1, 10, 12);
      final _FixedTimeService time = _FixedTimeService(now);
      final _InMemoryUpcomingPaymentsRepository upcomingRepo =
          _InMemoryUpcomingPaymentsRepository(
            <UpcomingPayment>[
              _upcomingPayment(
                id: 'p1',
                categoryId: 'credit_cat',
                dayOfMonth: 15,
              ),
            ],
          );
      final _InMemoryTransactionRepository txRepo =
          _InMemoryTransactionRepository(<TransactionEntity>[
            _transaction(
              id: 't1',
              categoryId: 'credit_cat',
              date: now,
            ),
          ]);
      final _InMemoryCreditRepository creditRepo =
          _InMemoryCreditRepository(_credit(categoryId: 'credit_cat'));

      final SyncCreditPaymentScheduleUseCase useCase =
          SyncCreditPaymentScheduleUseCase(
            creditRepository: creditRepo,
            transactionRepository: txRepo,
            upcomingPaymentsRepository: upcomingRepo,
            schedulePolicy: const SchedulePolicy(),
            timeService: time,
          );

      await useCase.call(current: txRepo.transactions.first);

      final UpcomingPayment updated = upcomingRepo.lastUpserted!;
      final DateTime expectedNextRun = DateTime(2026, 2, 15, 0, 1);
      final DateTime expectedNextNotify = DateTime(2026, 2, 13, 10, 0);
      expect(updated.nextRunAtMs, time.toEpochMs(expectedNextRun));
      expect(updated.nextNotifyAtMs, time.toEpochMs(expectedNextNotify));
    });

    test('rolls back next payment after delete to previous payment', () async {
      final DateTime now = DateTime(2026, 1, 20, 12);
      final _FixedTimeService time = _FixedTimeService(now);
      final _InMemoryUpcomingPaymentsRepository upcomingRepo =
          _InMemoryUpcomingPaymentsRepository(
            <UpcomingPayment>[
              _upcomingPayment(
                id: 'p1',
                categoryId: 'credit_cat',
                dayOfMonth: 15,
              ),
            ],
          );
      final TransactionEntity deletedPayment = _transaction(
        id: 't2',
        categoryId: 'credit_cat',
        date: DateTime(2026, 1, 10, 12),
      );
      final _InMemoryTransactionRepository txRepo =
          _InMemoryTransactionRepository(<TransactionEntity>[
            _transaction(
              id: 't1',
              categoryId: 'credit_cat',
              date: DateTime(2025, 12, 10, 12),
            ),
          ]);
      final _InMemoryCreditRepository creditRepo =
          _InMemoryCreditRepository(_credit(categoryId: 'credit_cat'));

      final SyncCreditPaymentScheduleUseCase useCase =
          SyncCreditPaymentScheduleUseCase(
            creditRepository: creditRepo,
            transactionRepository: txRepo,
            upcomingPaymentsRepository: upcomingRepo,
            schedulePolicy: const SchedulePolicy(),
            timeService: time,
          );

      await useCase.call(previous: deletedPayment);

      final UpcomingPayment updated = upcomingRepo.lastUpserted!;
      final DateTime expectedNextRun = DateTime(2026, 1, 15, 0, 1);
      final DateTime expectedNextNotify = DateTime(2026, 1, 13, 10, 0);
      expect(updated.nextRunAtMs, time.toEpochMs(expectedNextRun));
      expect(updated.nextNotifyAtMs, time.toEpochMs(expectedNextNotify));
    });
  });
}

UpcomingPayment _upcomingPayment({
  required String id,
  required String categoryId,
  required int dayOfMonth,
}) {
  return UpcomingPayment(
    id: id,
    title: 'Платёж',
    accountId: 'acc',
    categoryId: categoryId,
    amountMinor: BigInt.from(100000),
    amountScale: 2,
    dayOfMonth: dayOfMonth,
    notifyDaysBefore: 2,
    notifyTimeHhmm: '10:00',
    note: null,
    autoPost: false,
    isActive: true,
    nextRunAtMs: null,
    nextNotifyAtMs: null,
    createdAtMs: 0,
    updatedAtMs: 0,
  );
}

TransactionEntity _transaction({
  required String id,
  required String categoryId,
  required DateTime date,
}) {
  return TransactionEntity(
    id: id,
    accountId: 'cash',
    categoryId: categoryId,
    amountMinor: BigInt.from(1000),
    amountScale: 2,
    date: date,
    note: null,
    type: 'expense',
    createdAt: date,
    updatedAt: date,
  );
}

CreditEntity _credit({required String categoryId}) {
  final DateTime now = DateTime(2026, 1, 1);
  return CreditEntity(
    id: 'c1',
    accountId: 'credit_acc',
    categoryId: categoryId,
    interestRate: 0,
    termMonths: 12,
    startDate: now,
    paymentDay: 15,
    createdAt: now,
    updatedAt: now,
  );
}

class _FixedTimeService implements TimeService {
  _FixedTimeService(this._now);

  final DateTime _now;

  @override
  int nowMs() => _now.toUtc().millisecondsSinceEpoch;

  @override
  DateTime nowLocal() => _now;

  @override
  DateTime toLocal(int epochMs) {
    return DateTime.fromMillisecondsSinceEpoch(epochMs, isUtc: true).toLocal();
  }

  @override
  int toEpochMs(DateTime dt) => dt.toUtc().millisecondsSinceEpoch;

  @override
  DateTime atLocalDateTime(int year, int month, int day, int hour, int minute) {
    return DateTime(year, month, day, hour, minute);
  }

  @override
  int parseHhmmToMinutes(String hhmm) {
    final List<String> parts = hhmm.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
}

class _InMemoryUpcomingPaymentsRepository implements UpcomingPaymentsRepository {
  _InMemoryUpcomingPaymentsRepository(this._payments);

  final List<UpcomingPayment> _payments;
  UpcomingPayment? lastUpserted;

  @override
  Stream<List<UpcomingPayment>> watchAll() =>
      Stream<List<UpcomingPayment>>.value(
        List<UpcomingPayment>.unmodifiable(_payments),
      );

  @override
  Future<void> upsert(UpcomingPayment payment) async {
    lastUpserted = payment;
  }

  @override
  Future<void> delete(String id) async {}

  @override
  Future<UpcomingPayment?> getById(String id) async {
    for (final UpcomingPayment payment in _payments) {
      if (payment.id == id) {
        return payment;
      }
    }
    return null;
  }

  @override
  Future<UpcomingPayment?> getByCategoryId(String categoryId) async {
    for (final UpcomingPayment payment in _payments) {
      if (payment.categoryId == categoryId) {
        return payment;
      }
    }
    return null;
  }
}

class _InMemoryTransactionRepository implements TransactionRepository {
  _InMemoryTransactionRepository(this.transactions);

  final List<TransactionEntity> transactions;

  @override
  Future<List<TransactionEntity>> loadTransactions() async => transactions;

  @override
  Future<TransactionEntity?> findLatestByCategoryId(String categoryId) async {
    TransactionEntity? latest;
    for (final TransactionEntity transaction in transactions) {
      if (transaction.categoryId != categoryId) {
        continue;
      }
      if (latest == null || transaction.date.isAfter(latest.date)) {
        latest = transaction;
      } else if (transaction.date.isAtSameMomentAs(latest.date) &&
          transaction.updatedAt.isAfter(latest.updatedAt)) {
        latest = transaction;
      }
    }
    return latest;
  }

  @override
  Stream<List<TransactionEntity>> watchTransactions() =>
      const Stream<List<TransactionEntity>>.empty();

  @override
  Stream<List<TransactionEntity>> watchRecentTransactions({int? limit}) =>
      const Stream<List<TransactionEntity>>.empty();

  @override
  Future<TransactionEntity?> findById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<TransactionEntity?> findByIdempotencyKey(String idempotencyKey) {
    throw UnimplementedError();
  }

  @override
  Future<void> softDelete(String id) {
    throw UnimplementedError();
  }

  @override
  Future<void> upsert(TransactionEntity transaction) {
    throw UnimplementedError();
  }

  @override
  Stream<List<AccountMonthlyTotals>> watchAccountMonthlyTotals({
    required DateTime start,
    required DateTime end,
  }) => const Stream<List<AccountMonthlyTotals>>.empty();

  @override
  Stream<List<TransactionCategoryTotals>> watchAnalyticsCategoryTotals({
    required DateTime start,
    required DateTime end,
    List<String> accountIds = const <String>[],
    String? accountId,
  }) => const Stream<List<TransactionCategoryTotals>>.empty();

  @override
  Stream<List<MonthlyCashflowTotals>> watchMonthlyCashflowTotals({
    required DateTime start,
    required DateTime end,
    required DateTime nowInclusive,
    List<String> accountIds = const <String>[],
  }) => const Stream<List<MonthlyCashflowTotals>>.empty();

  @override
  Stream<List<MonthlyBalanceTotals>> watchMonthlyBalanceTotals({
    required DateTime start,
    required DateTime end,
    List<String> accountIds = const <String>[],
  }) => const Stream<List<MonthlyBalanceTotals>>.empty();

  @override
  Stream<List<BudgetExpenseTotals>> watchBudgetExpenseTotals({
    required DateTime start,
    required DateTime end,
    List<String> accountIds = const <String>[],
  }) => const Stream<List<BudgetExpenseTotals>>.empty();

  @override
  Stream<List<TransactionEntity>> watchCategoryTransactions({
    required DateTime start,
    required DateTime end,
    required List<String> categoryIds,
    required bool includeUncategorized,
    required String type,
    List<String> accountIds = const <String>[],
  }) => const Stream<List<TransactionEntity>>.empty();
}

class _InMemoryCreditRepository implements CreditRepository {
  _InMemoryCreditRepository(this._credit);

  final CreditEntity _credit;

  @override
  Future<CreditEntity?> getCreditByCategoryId(String categoryId) async {
    if (_credit.categoryId == categoryId) {
      return _credit;
    }
    return null;
  }

  @override
  Stream<List<CreditEntity>> watchCredits() =>
      const Stream<List<CreditEntity>>.empty();

  @override
  Future<List<CreditEntity>> getCredits() {
    throw UnimplementedError();
  }

  @override
  Future<CreditEntity?> getCreditByAccountId(String accountId) {
    throw UnimplementedError();
  }

  @override
  Future<void> addCredit(CreditEntity credit) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateCredit(CreditEntity credit) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteCredit(String id) {
    throw UnimplementedError();
  }
}
