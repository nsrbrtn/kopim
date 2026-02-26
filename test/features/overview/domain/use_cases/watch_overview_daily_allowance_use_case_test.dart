import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/repositories/account_repository.dart';
import 'package:kopim/features/overview/domain/models/overview_daily_allowance.dart';
import 'package:kopim/features/overview/domain/use_cases/watch_overview_daily_allowance_use_case.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';
import 'package:kopim/features/upcoming_payments/domain/repositories/upcoming_payments_repository.dart';

void main() {
  group('WatchOverviewDailyAllowanceUseCase', () {
    test('считает лимит до ближайшего дохода', () async {
      final _AccountRepositoryFake accountRepository = _AccountRepositoryFake(
        accounts: <AccountEntity>[_account(balanceMinor: 100000)],
      );
      final _UpcomingPaymentsRepositoryFake upcomingRepository =
          _UpcomingPaymentsRepositoryFake(
            payments: <UpcomingPayment>[
              _payment(
                id: 'income-1',
                dayOfMonth: 15,
                amountMinor: 50000,
                flowType: UpcomingPaymentFlowType.income,
              ),
              _payment(
                id: 'expense-1',
                dayOfMonth: 12,
                amountMinor: 20000,
                flowType: UpcomingPaymentFlowType.expense,
              ),
              _payment(
                id: 'expense-late',
                dayOfMonth: 18,
                amountMinor: 30000,
                flowType: UpcomingPaymentFlowType.expense,
              ),
            ],
          );

      final WatchOverviewDailyAllowanceUseCase useCase =
          WatchOverviewDailyAllowanceUseCase(
            accountRepository: accountRepository,
            upcomingPaymentsRepository: upcomingRepository,
          );

      final OverviewDailyAllowance result = await useCase
          .call(now: DateTime(2026, 2, 10, 10))
          .first;

      expect(result.hasIncomeAnchor, isTrue);
      expect(result.daysLeft, 5);
      expect(
        result.plannedIncome,
        MoneyAmount(minor: BigInt.from(50000), scale: 2),
      );
      expect(
        result.plannedExpense,
        MoneyAmount(minor: BigInt.from(20000), scale: 2),
      );
      expect(
        result.dailyAllowance,
        MoneyAmount(minor: BigInt.from(26000), scale: 2),
      );
    });

    test('использует fallback 30 дней, когда доходов нет', () async {
      final _AccountRepositoryFake accountRepository = _AccountRepositoryFake(
        accounts: <AccountEntity>[_account(balanceMinor: 90000)],
      );
      final _UpcomingPaymentsRepositoryFake upcomingRepository =
          _UpcomingPaymentsRepositoryFake(
            payments: <UpcomingPayment>[
              _payment(
                id: 'expense-1',
                dayOfMonth: 20,
                amountMinor: 30000,
                flowType: UpcomingPaymentFlowType.expense,
              ),
            ],
          );

      final WatchOverviewDailyAllowanceUseCase useCase =
          WatchOverviewDailyAllowanceUseCase(
            accountRepository: accountRepository,
            upcomingPaymentsRepository: upcomingRepository,
          );

      final OverviewDailyAllowance result = await useCase
          .call(now: DateTime(2026, 2, 10, 10))
          .first;

      expect(result.hasIncomeAnchor, isFalse);
      expect(result.daysLeft, 30);
      expect(
        result.dailyAllowance,
        MoneyAmount(minor: BigInt.from(2000), scale: 2),
      );
    });

    test('возвращает отрицательный лимит при дефиците средств', () async {
      final _AccountRepositoryFake accountRepository = _AccountRepositoryFake(
        accounts: <AccountEntity>[_account(balanceMinor: 10000)],
      );
      final _UpcomingPaymentsRepositoryFake upcomingRepository =
          _UpcomingPaymentsRepositoryFake(
            payments: <UpcomingPayment>[
              _payment(
                id: 'expense-1',
                dayOfMonth: 11,
                amountMinor: 50000,
                flowType: UpcomingPaymentFlowType.expense,
              ),
            ],
          );

      final WatchOverviewDailyAllowanceUseCase useCase =
          WatchOverviewDailyAllowanceUseCase(
            accountRepository: accountRepository,
            upcomingPaymentsRepository: upcomingRepository,
          );

      final OverviewDailyAllowance result = await useCase
          .call(now: DateTime(2026, 2, 10, 10))
          .first;

      expect(result.isNegative, isTrue);
      expect(
        result.dailyAllowance,
        MoneyAmount(minor: BigInt.from(-1333), scale: 2),
      );
    });

    test('использует выбранный anchor payment для горизонта расчета', () async {
      final _AccountRepositoryFake accountRepository = _AccountRepositoryFake(
        accounts: <AccountEntity>[_account(balanceMinor: 100000)],
      );
      final _UpcomingPaymentsRepositoryFake upcomingRepository =
          _UpcomingPaymentsRepositoryFake(
            payments: <UpcomingPayment>[
              _payment(
                id: 'income-early',
                dayOfMonth: 15,
                amountMinor: 30000,
                flowType: UpcomingPaymentFlowType.income,
              ),
              _payment(
                id: 'income-anchor',
                dayOfMonth: 25,
                amountMinor: 50000,
                flowType: UpcomingPaymentFlowType.income,
              ),
              _payment(
                id: 'expense-mid',
                dayOfMonth: 20,
                amountMinor: 10000,
                flowType: UpcomingPaymentFlowType.expense,
              ),
            ],
          );

      final WatchOverviewDailyAllowanceUseCase useCase =
          WatchOverviewDailyAllowanceUseCase(
            accountRepository: accountRepository,
            upcomingPaymentsRepository: upcomingRepository,
          );

      final OverviewDailyAllowance result = await useCase
          .call(
            now: DateTime(2026, 2, 10, 10),
            selectedUpcomingPaymentId: 'income-anchor',
          )
          .first;

      expect(result.daysLeft, 15);
      expect(
        result.plannedIncome,
        MoneyAmount(minor: BigInt.from(50000), scale: 2),
      );
      expect(
        result.dailyAllowance,
        MoneyAmount(minor: BigInt.from(9333), scale: 2),
      );
    });

    test(
      'игнорирует selectedUpcomingPaymentId, если он указывает не на income',
      () async {
        final _AccountRepositoryFake accountRepository = _AccountRepositoryFake(
          accounts: <AccountEntity>[_account(balanceMinor: 100000)],
        );
        final _UpcomingPaymentsRepositoryFake upcomingRepository =
            _UpcomingPaymentsRepositoryFake(
              payments: <UpcomingPayment>[
                _payment(
                  id: 'income-1',
                  dayOfMonth: 15,
                  amountMinor: 30000,
                  flowType: UpcomingPaymentFlowType.income,
                ),
                _payment(
                  id: 'expense-anchor',
                  dayOfMonth: 25,
                  amountMinor: 10000,
                  flowType: UpcomingPaymentFlowType.expense,
                ),
              ],
            );

        final WatchOverviewDailyAllowanceUseCase useCase =
            WatchOverviewDailyAllowanceUseCase(
              accountRepository: accountRepository,
              upcomingPaymentsRepository: upcomingRepository,
            );

        final OverviewDailyAllowance result = await useCase
            .call(
              now: DateTime(2026, 2, 10, 10),
              selectedUpcomingPaymentId: 'expense-anchor',
            )
            .first;

        expect(result.hasIncomeAnchor, isTrue);
        expect(result.daysLeft, 5);
        expect(
          result.dailyAllowance,
          MoneyAmount(minor: BigInt.from(26000), scale: 2),
        );
      },
    );
  });
}

AccountEntity _account({required int balanceMinor}) {
  final DateTime now = DateTime(2026, 1, 1);
  return AccountEntity(
    id: 'acc-1',
    name: 'Main',
    balanceMinor: BigInt.from(balanceMinor),
    openingBalanceMinor: BigInt.from(balanceMinor),
    currency: 'RUB',
    currencyScale: 2,
    type: 'cash',
    createdAt: now,
    updatedAt: now,
  );
}

UpcomingPayment _payment({
  required String id,
  required int dayOfMonth,
  required int amountMinor,
  required UpcomingPaymentFlowType flowType,
}) {
  final DateTime now = DateTime(2026, 1, 1);
  final int nowMs = now.millisecondsSinceEpoch;
  return UpcomingPayment(
    id: id,
    title: id,
    accountId: 'acc-1',
    categoryId: 'cat-1',
    amountMinor: BigInt.from(amountMinor),
    amountScale: 2,
    dayOfMonth: dayOfMonth,
    notifyDaysBefore: 1,
    notifyTimeHhmm: '09:00',
    autoPost: false,
    flowType: flowType,
    isActive: true,
    createdAtMs: nowMs,
    updatedAtMs: nowMs,
  );
}

class _AccountRepositoryFake implements AccountRepository {
  _AccountRepositoryFake({required List<AccountEntity> accounts})
    : _accounts = accounts;

  final List<AccountEntity> _accounts;

  @override
  Future<AccountEntity?> findById(String id) async {
    for (final AccountEntity account in _accounts) {
      if (account.id == id) {
        return account;
      }
    }
    return null;
  }

  @override
  Future<List<AccountEntity>> loadAccounts() async => _accounts;

  @override
  Future<void> softDelete(String id) {
    throw UnimplementedError();
  }

  @override
  Future<void> upsert(AccountEntity account) {
    throw UnimplementedError();
  }

  @override
  Stream<List<AccountEntity>> watchAccounts() {
    return Stream<List<AccountEntity>>.value(_accounts);
  }
}

class _UpcomingPaymentsRepositoryFake implements UpcomingPaymentsRepository {
  _UpcomingPaymentsRepositoryFake({required List<UpcomingPayment> payments})
    : _payments = payments;

  final List<UpcomingPayment> _payments;

  @override
  Future<void> delete(String id) {
    throw UnimplementedError();
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
  Future<void> upsert(UpcomingPayment payment) {
    throw UnimplementedError();
  }

  @override
  Stream<List<UpcomingPayment>> watchAll() {
    return Stream<List<UpcomingPayment>>.value(_payments);
  }
}
