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
  final AnalyticsFilterState filterState = ref.watch(
    analyticsFilterControllerProvider,
  );
  final AsyncValue<List<AccountEntity>> accountsAsync = ref.watch(
    analyticsAccountsProvider,
  );

  final List<AccountEntity> accounts =
      accountsAsync.value ?? const <AccountEntity>[];
  final Set<String> selectedAccountIds = filterState.accountIds;

  return ref.watch(transactionRepositoryProvider).watchTransactions().map((
    List<TransactionEntity> transactions,
  ) {
    final DateTime now = DateTime.now();
    final List<MonthlyBalanceData> result = <MonthlyBalanceData>[];

    // Генерируем данные за последние 6 месяцев
    for (int i = 5; i >= 0; i--) {
      final DateTime monthDate = DateTime(now.year, now.month - i, 1);
      final DateTime monthEnd = DateTime(
        monthDate.year,
        monthDate.month + 1,
        0,
        23,
        59,
        59,
      );

      // Фильтруем счета
      final List<AccountEntity> relevantAccounts = accounts.where((
        AccountEntity account,
      ) {
        if (selectedAccountIds.isEmpty) {
          return true;
        }
        return selectedAccountIds.contains(account.id);
      }).toList();

      // Начинаем с текущего баланса счетов
      double totalBalance = 0;
      for (final AccountEntity account in relevantAccounts) {
        totalBalance += account.balance;
      }

      // Вычитаем транзакции после конца месяца
      for (final TransactionEntity transaction in transactions) {
        if (transaction.date.isAfter(monthEnd)) {
          // Фильтруем по счетам
          if (selectedAccountIds.isNotEmpty &&
              !selectedAccountIds.contains(transaction.accountId)) {
            continue;
          }

          // Вычитаем будущие транзакции
          if (transaction.type == TransactionType.income.storageValue) {
            totalBalance -= transaction.amount.abs();
          } else if (transaction.type == TransactionType.expense.storageValue) {
            totalBalance += transaction.amount.abs();
          }
        }
      }

      result.add(
        MonthlyBalanceData(month: monthDate, totalBalance: totalBalance),
      );
    }

    return result;
  });
}
