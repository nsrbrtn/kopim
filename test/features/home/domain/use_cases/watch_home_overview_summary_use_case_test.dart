import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/home/domain/models/home_overview_summary.dart';
import 'package:kopim/features/home/domain/use_cases/watch_home_overview_summary_use_case.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';

void main() {
  group('computeHomeOverviewSummary', () {
    test('учитывает все счета и категории по умолчанию', () {
      final DateTime now = DateTime(2024, 6, 10, 12);
      final List<AccountEntity> accounts = <AccountEntity>[
        AccountEntity(
          id: 'acc-cash',
          name: 'Wallet',
          balanceMinor: BigInt.from(10000),
          currency: 'RUB',
          currencyScale: 2,
          type: 'cash',
          createdAt: now,
          updatedAt: now,
        ),
        AccountEntity(
          id: 'acc-card',
          name: 'Card',
          balanceMinor: BigInt.from(5000),
          currency: 'RUB',
          currencyScale: 2,
          type: 'card',
          createdAt: now,
          updatedAt: now,
        ),
        AccountEntity(
          id: 'acc-credit',
          name: 'Credit',
          balanceMinor: BigInt.from(-20000),
          currency: 'RUB',
          currencyScale: 2,
          type: 'credit_card',
          createdAt: now,
          updatedAt: now,
        ),
        AccountEntity(
          id: 'acc-hidden',
          name: 'Hidden',
          balanceMinor: BigInt.from(2000),
          currency: 'RUB',
          currencyScale: 2,
          type: 'cash',
          createdAt: now,
          updatedAt: now,
          isHidden: true,
        ),
      ];

      final Category food = Category(
        id: 'food',
        name: 'Food',
        type: 'expense',
        createdAt: now,
        updatedAt: now,
      );
      final Category groceries = Category(
        id: 'groceries',
        name: 'Groceries',
        type: 'expense',
        parentId: 'food',
        createdAt: now,
        updatedAt: now,
      );
      final Category transport = Category(
        id: 'transport',
        name: 'Transport',
        type: 'expense',
        createdAt: now,
        updatedAt: now,
      );
      final Category salary = Category(
        id: 'salary',
        name: 'Salary',
        type: 'income',
        createdAt: now,
        updatedAt: now,
      );

      final List<TransactionEntity> transactions = <TransactionEntity>[
        TransactionEntity(
          id: 'tx-income',
          accountId: 'acc-cash',
          amountMinor: BigInt.from(12000),
          amountScale: 2,
          date: DateTime(2024, 6, 10, 9),
          type: TransactionType.income.storageValue,
          createdAt: now,
          updatedAt: now,
        ),
        TransactionEntity(
          id: 'tx-expense-1',
          accountId: 'acc-cash',
          categoryId: 'groceries',
          amountMinor: BigInt.from(-8000),
          amountScale: 2,
          date: DateTime(2024, 6, 10, 10),
          type: TransactionType.expense.storageValue,
          createdAt: now,
          updatedAt: now,
        ),
        TransactionEntity(
          id: 'tx-expense-2',
          accountId: 'acc-card',
          categoryId: 'transport',
          amountMinor: BigInt.from(-5000),
          amountScale: 2,
          date: DateTime(2024, 6, 10, 11),
          type: TransactionType.expense.storageValue,
          createdAt: now,
          updatedAt: now,
        ),
        TransactionEntity(
          id: 'tx-expense-3',
          accountId: 'acc-cash',
          categoryId: 'groceries',
          amountMinor: BigInt.from(-3000),
          amountScale: 2,
          date: DateTime(2024, 6, 2, 12),
          type: TransactionType.expense.storageValue,
          createdAt: now,
          updatedAt: now,
        ),
        TransactionEntity(
          id: 'tx-credit',
          accountId: 'acc-credit',
          categoryId: 'groceries',
          amountMinor: BigInt.from(-30000),
          amountScale: 2,
          date: DateTime(2024, 6, 10, 12),
          type: TransactionType.expense.storageValue,
          createdAt: now,
          updatedAt: now,
        ),
        TransactionEntity(
          id: 'tx-next-month',
          accountId: 'acc-cash',
          categoryId: 'groceries',
          amountMinor: BigInt.from(-7000),
          amountScale: 2,
          date: DateTime(2024, 7, 1, 12),
          type: TransactionType.expense.storageValue,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final HomeOverviewSummary summary = computeHomeOverviewSummary(
        accounts: accounts,
        transactions: transactions,
        categories: <Category>[food, groceries, transport, salary],
        reference: now,
      );

      expect(summary.totalBalance, _amount(-30));
      expect(summary.todayIncome, _amount(120));
      expect(summary.todayExpense, _amount(430));
      expect(summary.topExpenseCategory, isNotNull);
      expect(summary.topExpenseCategory!.categoryId, 'food');
      expect(summary.topExpenseCategory!.amount, _amount(410));
    });

    test('фильтрует по выбранным счетам и категориям', () {
      final DateTime now = DateTime(2024, 6, 10, 12);
      final List<AccountEntity> accounts = <AccountEntity>[
        AccountEntity(
          id: 'acc-cash',
          name: 'Wallet',
          balanceMinor: BigInt.from(10000),
          currency: 'RUB',
          currencyScale: 2,
          type: 'cash',
          createdAt: now,
          updatedAt: now,
        ),
        AccountEntity(
          id: 'acc-card',
          name: 'Card',
          balanceMinor: BigInt.from(5000),
          currency: 'RUB',
          currencyScale: 2,
          type: 'card',
          createdAt: now,
          updatedAt: now,
        ),
        AccountEntity(
          id: 'acc-credit',
          name: 'Credit',
          balanceMinor: BigInt.from(-20000),
          currency: 'RUB',
          currencyScale: 2,
          type: 'credit_card',
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final Category food = Category(
        id: 'food',
        name: 'Food',
        type: 'expense',
        createdAt: now,
        updatedAt: now,
      );
      final Category groceries = Category(
        id: 'groceries',
        name: 'Groceries',
        type: 'expense',
        parentId: 'food',
        createdAt: now,
        updatedAt: now,
      );
      final Category transport = Category(
        id: 'transport',
        name: 'Transport',
        type: 'expense',
        createdAt: now,
        updatedAt: now,
      );

      final List<TransactionEntity> transactions = <TransactionEntity>[
        TransactionEntity(
          id: 'tx-income',
          accountId: 'acc-cash',
          amountMinor: BigInt.from(12000),
          amountScale: 2,
          date: DateTime(2024, 6, 10, 9),
          type: TransactionType.income.storageValue,
          createdAt: now,
          updatedAt: now,
        ),
        TransactionEntity(
          id: 'tx-expense-1',
          accountId: 'acc-cash',
          categoryId: 'groceries',
          amountMinor: BigInt.from(-8000),
          amountScale: 2,
          date: DateTime(2024, 6, 10, 10),
          type: TransactionType.expense.storageValue,
          createdAt: now,
          updatedAt: now,
        ),
        TransactionEntity(
          id: 'tx-expense-2',
          accountId: 'acc-card',
          categoryId: 'transport',
          amountMinor: BigInt.from(-5000),
          amountScale: 2,
          date: DateTime(2024, 6, 10, 11),
          type: TransactionType.expense.storageValue,
          createdAt: now,
          updatedAt: now,
        ),
        TransactionEntity(
          id: 'tx-expense-3',
          accountId: 'acc-cash',
          categoryId: 'groceries',
          amountMinor: BigInt.from(-3000),
          amountScale: 2,
          date: DateTime(2024, 6, 2, 12),
          type: TransactionType.expense.storageValue,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final HomeOverviewSummary summary = computeHomeOverviewSummary(
        accounts: accounts,
        transactions: transactions,
        categories: <Category>[food, groceries, transport],
        reference: now,
        accountIdsFilter: <String>{'acc-cash'},
        categoryIdsFilter: <String>{'food'},
      );

      expect(summary.totalBalance, _amount(100));
      expect(summary.todayIncome, _amount(0));
      expect(summary.todayExpense, _amount(80));
      expect(summary.topExpenseCategory, isNotNull);
      expect(summary.topExpenseCategory!.categoryId, 'food');
      expect(summary.topExpenseCategory!.amount, _amount(110));
    });
  });
}

MoneyAmount _amount(num value, {int scale = 2}) {
  final double scaled = value * 100;
  return MoneyAmount(minor: BigInt.from(scaled.round()), scale: scale);
}
