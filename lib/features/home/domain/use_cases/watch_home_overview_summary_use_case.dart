import 'dart:async';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/repositories/account_repository.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/categories/domain/repositories/category_repository.dart';
import 'package:kopim/features/categories/domain/services/category_hierarchy.dart';
import 'package:kopim/features/home/domain/models/home_overview_summary.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';

class WatchHomeOverviewSummaryUseCase {
  WatchHomeOverviewSummaryUseCase({
    required AccountRepository accountRepository,
    required TransactionRepository transactionRepository,
    required CategoryRepository categoryRepository,
  }) : _accountRepository = accountRepository,
       _transactionRepository = transactionRepository,
       _categoryRepository = categoryRepository;

  final AccountRepository _accountRepository;
  final TransactionRepository _transactionRepository;
  final CategoryRepository _categoryRepository;

  Stream<HomeOverviewSummary> call({
    DateTime? reference,
    Set<String>? accountIdsFilter,
    Set<String>? categoryIdsFilter,
  }) {
    return _combineLatest3(
      _accountRepository.watchAccounts(),
      _transactionRepository.watchTransactions(),
      _categoryRepository.watchCategories(),
      (
        List<AccountEntity> accounts,
        List<TransactionEntity> transactions,
        List<Category> categories,
      ) {
        return computeHomeOverviewSummary(
          accounts: accounts,
          transactions: transactions,
          categories: categories,
          reference: reference,
          accountIdsFilter: accountIdsFilter,
          categoryIdsFilter: categoryIdsFilter,
        );
      },
    );
  }
}

@visibleForTesting
HomeOverviewSummary computeHomeOverviewSummary({
  required List<AccountEntity> accounts,
  required List<TransactionEntity> transactions,
  required List<Category> categories,
  DateTime? reference,
  Set<String>? accountIdsFilter,
  Set<String>? categoryIdsFilter,
}) {
  final DateTime now = reference ?? DateTime.now();
  final DateTime dayStart = DateTime(now.year, now.month, now.day);
  final DateTime dayEnd = dayStart.add(const Duration(days: 1));
  final DateTime monthStart = DateTime(now.year, now.month);
  final DateTime monthEnd = DateTime(now.year, now.month + 1);

  final Set<String>? allowedAccountIds = accountIdsFilter;
  final List<AccountEntity> selectedAccounts = allowedAccountIds == null
      ? accounts
      : accounts
            .where(
              (AccountEntity account) => allowedAccountIds.contains(account.id),
            )
            .toList(growable: false);
  final Set<String> selectedAccountIds = selectedAccounts
      .map((AccountEntity account) => account.id)
      .toSet();

  final double totalBalance = selectedAccounts.fold<double>(
    0,
    (double sum, AccountEntity account) => sum + account.balance,
  );

  double todayIncome = 0;
  double todayExpense = 0;
  final CategoryHierarchy hierarchy = CategoryHierarchy(categories);
  final Map<String?, double> expenseByRoot = <String?, double>{};

  for (final TransactionEntity transaction in transactions) {
    if (!selectedAccountIds.contains(transaction.accountId)) {
      continue;
    }

    final DateTime date = transaction.date;
    final bool inToday = !date.isBefore(dayStart) && date.isBefore(dayEnd);
    final bool inMonth = !date.isBefore(monthStart) && date.isBefore(monthEnd);
    final double amount = transaction.amount.abs();
    final String? rootCategoryId = _resolveRootCategoryId(
      transaction.categoryId,
      hierarchy,
    );

    if (categoryIdsFilter != null &&
        (rootCategoryId == null ||
            !categoryIdsFilter.contains(rootCategoryId))) {
      continue;
    }

    if (transaction.type == TransactionType.income.storageValue) {
      if (inToday) {
        todayIncome += amount;
      }
      continue;
    }

    if (transaction.type == TransactionType.expense.storageValue) {
      if (inToday) {
        todayExpense += amount;
      }
      if (inMonth) {
        expenseByRoot[rootCategoryId] =
            (expenseByRoot[rootCategoryId] ?? 0) + amount;
      }
    }
  }

  HomeTopExpenseCategory? topExpenseCategory;
  if (expenseByRoot.isNotEmpty) {
    final List<MapEntry<String?, double>> entries =
        expenseByRoot.entries.toList(growable: false)..sort(
          (MapEntry<String?, double> a, MapEntry<String?, double> b) =>
              b.value.compareTo(a.value),
        );
    final MapEntry<String?, double> top = entries.first;
    if (top.value > 0) {
      topExpenseCategory = HomeTopExpenseCategory(
        categoryId: top.key,
        amount: top.value,
      );
    }
  }

  return HomeOverviewSummary(
    totalBalance: totalBalance,
    todayIncome: todayIncome,
    todayExpense: todayExpense,
    topExpenseCategory: topExpenseCategory,
  );
}

String? _resolveRootCategoryId(
  String? categoryId,
  CategoryHierarchy hierarchy,
) {
  if (categoryId == null) {
    return null;
  }
  String? current = categoryId;
  while (current != null) {
    final Category? category = hierarchy.byId[current];
    if (category == null) {
      return null;
    }
    final String? parentId = category.parentId;
    if (parentId == null ||
        parentId.isEmpty ||
        !hierarchy.byId.containsKey(parentId)) {
      return current;
    }
    current = parentId;
  }
  return null;
}

Stream<T> _combineLatest3<A, B, C, T>(
  Stream<A> first,
  Stream<B> second,
  Stream<C> third,
  T Function(A first, B second, C third) combiner,
) {
  late final StreamController<T> controller;
  A? latestFirst;
  B? latestSecond;
  C? latestThird;
  bool hasFirst = false;
  bool hasSecond = false;
  bool hasThird = false;
  late StreamSubscription<A> firstSub;
  late StreamSubscription<B> secondSub;
  late StreamSubscription<C> thirdSub;

  void emitIfReady() {
    if (hasFirst && hasSecond && hasThird) {
      controller.add(
        combiner(latestFirst as A, latestSecond as B, latestThird as C),
      );
    }
  }

  controller = StreamController<T>(
    onListen: () {
      firstSub = first.listen((A value) {
        latestFirst = value;
        hasFirst = true;
        emitIfReady();
      }, onError: controller.addError);
      secondSub = second.listen((B value) {
        latestSecond = value;
        hasSecond = true;
        emitIfReady();
      }, onError: controller.addError);
      thirdSub = third.listen((C value) {
        latestThird = value;
        hasThird = true;
        emitIfReady();
      }, onError: controller.addError);
    },
    onCancel: () async {
      await firstSub.cancel();
      await secondSub.cancel();
      await thirdSub.cancel();
    },
  );
  return controller.stream;
}
