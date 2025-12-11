import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/analytics/domain/models/analytics_filter.dart';
import 'package:kopim/features/analytics/domain/models/analytics_overview.dart';
import 'package:kopim/features/analytics/domain/models/monthly_balance_data.dart';
import 'package:kopim/features/analytics/presentation/controllers/analytics_filter_controller.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'analytics_providers.g.dart';

@riverpod
AnalyticsFilter analyticsFilters(Ref ref) {
  final AnalyticsFilterState state = ref.watch(
    analyticsFilterControllerProvider,
  );
  return state.toDomain();
}

@riverpod
Stream<AnalyticsOverview> analyticsFilteredStats(
  Ref ref, {
  int topCategoriesLimit = 5,
}) {
  final AnalyticsFilter filters = ref.watch(analyticsFiltersProvider);
  return ref
      .watch(watchMonthlyAnalyticsUseCaseProvider)
      .call(topCategoriesLimit: topCategoriesLimit, filter: filters);
}

@riverpod
Stream<List<Category>> analyticsCategories(Ref ref) {
  return ref.watch(watchCategoriesUseCaseProvider).call();
}

@riverpod
Stream<List<AccountEntity>> analyticsAccounts(Ref ref) {
  return ref.watch(watchAccountsUseCaseProvider).call();
}

@riverpod
Stream<List<MonthlyBalanceData>> monthlyBalanceData(Ref ref) {
  final Set<String> selectedAccountIds = ref.watch(
    analyticsFilterControllerProvider.select(
      (AnalyticsFilterState s) => s.accountIds,
    ),
  );
  final AsyncValue<List<AccountEntity>> accountsAsync = ref.watch(
    analyticsAccountsProvider,
  );

  final List<AccountEntity> accounts =
      accountsAsync.value ?? const <AccountEntity>[];

  return ref.watch(transactionRepositoryProvider).watchTransactions().map((
    List<TransactionEntity> transactions,
  ) {
    final DateTime now = DateTime.now();
    final List<MonthlyBalanceData> result = <MonthlyBalanceData>[];

    // Фильтруем счета
    final List<AccountEntity> relevantAccounts = accounts.where((
      AccountEntity account,
    ) {
      if (selectedAccountIds.isEmpty) {
        return true;
      }
      return selectedAccountIds.contains(account.id);
    }).toList();

    // Начальный баланс (текущий)
    double currentBalance = 0;
    for (final AccountEntity account in relevantAccounts) {
      currentBalance += account.balance;
    }

    // Сортируем транзакции по дате (от новых к старым)
    // Предполагаем, что репозиторий может возвращать не сортированные
    final List<TransactionEntity> sortedTransactions =
        transactions.where((TransactionEntity t) {
          if (selectedAccountIds.isEmpty) {
            return true;
          }
          return selectedAccountIds.contains(t.accountId);
        }).toList()..sort(
          (TransactionEntity a, TransactionEntity b) =>
              b.date.compareTo(a.date),
        );

    int txIndex = 0;
    double runningBalance = currentBalance;

    // Генерируем данные за последние 6 месяцев (от текущего назад)
    for (int i = 0; i < 6; i++) {
      // Для текущего месяца берем now как конец диапазона, чтобы не учитывать будущие транзакции (если они есть)
      // Но для алгоритма "отката" нам нужно просто знать границы месяца.
      // Если есть транзакции в будущем (позже now), их нужно откатить до начала обработки.

      final DateTime monthDate = DateTime(now.year, now.month - i, 1);
      final DateTime monthEnd = DateTime(
        monthDate.year,
        monthDate.month + 1,
        0,
        23,
        59,
        59,
      );
      final DateTime monthStart = DateTime(
        monthDate.year,
        monthDate.month,
        1,
        0,
        0,
        0,
      );

      // 1. Откатываем транзакции, которые произошли ПОЗЖЕ конца этого месяца
      while (txIndex < sortedTransactions.length &&
          sortedTransactions[txIndex].date.isAfter(monthEnd)) {
        final TransactionEntity t = sortedTransactions[txIndex];
        if (t.type == TransactionType.income.storageValue) {
          runningBalance -= t.amount;
        } else if (t.type == TransactionType.expense.storageValue) {
          runningBalance += t.amount;
        }
        txIndex++;
      }

      // Теперь runningBalance соответствует балансу на конец месяца (monthEnd)
      double maxBalanceInMonth = runningBalance;

      // 2. Проходим по транзакциям ВНУТРИ месяца, отслеживая макс. баланс
      while (txIndex < sortedTransactions.length &&
          sortedTransactions[txIndex].date.isAfter(
            monthStart.subtract(const Duration(microseconds: 1)),
          )) {
        // runningBalance здесь - это баланс ПОСЛЕ транзакции t
        if (runningBalance > maxBalanceInMonth) {
          maxBalanceInMonth = runningBalance;
        }

        final TransactionEntity t = sortedTransactions[txIndex];
        // Откатываем транзакцию
        if (t.type == TransactionType.income.storageValue) {
          runningBalance -= t.amount;
        } else if (t.type == TransactionType.expense.storageValue) {
          runningBalance += t.amount;
        }

        // runningBalance теперь - это баланс ДО транзакции t
        // Проверяем его тоже, так как это могло быть пиковое значение до списания
        if (runningBalance > maxBalanceInMonth) {
          maxBalanceInMonth = runningBalance;
        }

        txIndex++;
      }

      // После цикла runningBalance соответствует балансу на начало месяца
      if (runningBalance > maxBalanceInMonth) {
        maxBalanceInMonth = runningBalance;
      }

      // Добавляем в начало списка, чтобы порядок был хронологический (если нужно)
      // Но исходный код добавлял через .add в цикле 5..0, то есть от старого к новому.
      // Здесь мы идем 0..5 (от нового к старому).
      // Значит, результат будет [Текущий, -1 мес, -2 мес...].
      // Если график ожидает хронологический порядок, нужно будет развернуть.
      result.add(
        MonthlyBalanceData(month: monthDate, totalBalance: maxBalanceInMonth),
      );
    }

    return result.reversed.toList();
  });
}
