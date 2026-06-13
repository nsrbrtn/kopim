import 'dart:async';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/utils/liability_account_links.dart';
import 'package:kopim/features/accounts/domain/repositories/account_repository.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/categories/domain/repositories/category_repository.dart';
import 'package:kopim/features/categories/domain/services/category_hierarchy.dart';
import 'package:kopim/features/credits/domain/entities/credit_card_entity.dart';
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/features/credits/domain/entities/debt_entity.dart';
import 'package:kopim/features/credits/domain/repositories/credit_card_repository.dart';
import 'package:kopim/features/credits/domain/repositories/credit_repository.dart';
import 'package:kopim/features/credits/domain/repositories/debt_repository.dart';
import 'package:kopim/features/home/domain/models/home_overview_summary.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';

class WatchHomeOverviewSummaryUseCase {
  WatchHomeOverviewSummaryUseCase({
    required AccountRepository accountRepository,
    required TransactionRepository transactionRepository,
    required CategoryRepository categoryRepository,
    required CreditRepository creditRepository,
    required CreditCardRepository creditCardRepository,
    required DebtRepository debtRepository,
  }) : _accountRepository = accountRepository,
       _transactionRepository = transactionRepository,
       _categoryRepository = categoryRepository,
       _creditRepository = creditRepository,
       _creditCardRepository = creditCardRepository,
       _debtRepository = debtRepository;

  final AccountRepository _accountRepository;
  final TransactionRepository _transactionRepository;
  final CategoryRepository _categoryRepository;
  final CreditRepository _creditRepository;
  final CreditCardRepository _creditCardRepository;
  final DebtRepository _debtRepository;

  Stream<HomeOverviewSummary> call({
    DateTime? reference,
    Set<String>? accountIdsFilter,
    Set<String>? categoryIdsFilter,
  }) {
    return _combineLatest6(
      _accountRepository.watchAccounts(),
      _transactionRepository.watchTransactions(),
      _categoryRepository.watchCategories(),
      _creditRepository.watchCredits(),
      _creditCardRepository.watchCreditCards(),
      _debtRepository.watchDebts(),
      (
        List<AccountEntity> accounts,
        List<TransactionEntity> transactions,
        List<Category> categories,
        List<CreditEntity> credits,
        List<CreditCardEntity> creditCards,
        List<DebtEntity> debts,
      ) {
        return computeHomeOverviewSummary(
          accounts: accounts,
          transactions: transactions,
          categories: categories,
          activeLiabilityAccountIds: collectActiveLiabilityAccountIds(
            credits: credits,
            creditCards: creditCards,
            debts: debts,
          ),
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
  Set<String>? activeLiabilityAccountIds,
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
  final Iterable<AccountEntity> liabilityFilteredAccounts =
      activeLiabilityAccountIds == null
      ? accounts
      : excludeOrphanedLiabilityAccounts(
          accounts: accounts,
          activeLiabilityAccountIds: activeLiabilityAccountIds,
        );
  final List<AccountEntity> selectedAccounts = allowedAccountIds == null
      ? liabilityFilteredAccounts.toList(growable: false)
      : liabilityFilteredAccounts
            .where(
              (AccountEntity account) => allowedAccountIds.contains(account.id),
            )
            .toList(growable: false);
  final Set<String> selectedAccountIds = selectedAccounts
      .map((AccountEntity account) => account.id)
      .toSet();

  final MoneyAccumulator totalBalance = MoneyAccumulator();
  for (final AccountEntity account in selectedAccounts) {
    totalBalance.add(account.balanceAmount);
  }

  final MoneyAccumulator todayIncome = MoneyAccumulator();
  final MoneyAccumulator todayExpense = MoneyAccumulator();
  final CategoryHierarchy hierarchy = CategoryHierarchy(categories);
  final Map<String?, MoneyAccumulator> expenseByRoot =
      <String?, MoneyAccumulator>{};

  for (final TransactionEntity transaction in transactions) {
    if (!selectedAccountIds.contains(transaction.accountId)) {
      continue;
    }

    final DateTime date = transaction.date;
    final bool inToday = !date.isBefore(dayStart) && date.isBefore(dayEnd);
    final bool inMonth = !date.isBefore(monthStart) && date.isBefore(monthEnd);
    final MoneyAmount amount = transaction.amountValue.abs();
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
        todayIncome.add(amount);
      }
      continue;
    }

    if (transaction.type == TransactionType.expense.storageValue) {
      if (inToday) {
        todayExpense.add(amount);
      }
      if (inMonth) {
        expenseByRoot
            .putIfAbsent(rootCategoryId, MoneyAccumulator.new)
            .add(amount);
      }
    }
  }

  HomeTopExpenseCategory? topExpenseCategory;
  if (expenseByRoot.isNotEmpty) {
    final List<MapEntry<String?, MoneyAccumulator>> entries =
        expenseByRoot.entries.toList(growable: false)..sort(
          (
            MapEntry<String?, MoneyAccumulator> a,
            MapEntry<String?, MoneyAccumulator> b,
          ) => b.value.toDouble().compareTo(a.value.toDouble()),
        );
    final MapEntry<String?, MoneyAccumulator> top = entries.first;
    if (top.value.minor > BigInt.zero) {
      topExpenseCategory = HomeTopExpenseCategory(
        categoryId: top.key,
        amount: _toMoneyAmount(top.value),
      );
    }
  }

  return HomeOverviewSummary(
    totalBalance: _toMoneyAmount(totalBalance),
    todayIncome: _toMoneyAmount(todayIncome),
    todayExpense: _toMoneyAmount(todayExpense),
    topExpenseCategory: topExpenseCategory,
  );
}

MoneyAmount _toMoneyAmount(MoneyAccumulator accumulator) {
  return MoneyAmount(minor: accumulator.minor, scale: accumulator.scale);
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

Stream<T> _combineLatest6<A, B, C, D, E, F, T>(
  Stream<A> first,
  Stream<B> second,
  Stream<C> third,
  Stream<D> fourth,
  Stream<E> fifth,
  Stream<F> sixth,
  T Function(A first, B second, C third, D fourth, E fifth, F sixth) combiner,
) {
  late final StreamController<T> controller;
  A? latestFirst;
  B? latestSecond;
  C? latestThird;
  D? latestFourth;
  E? latestFifth;
  F? latestSixth;
  bool hasFirst = false;
  bool hasSecond = false;
  bool hasThird = false;
  bool hasFourth = false;
  bool hasFifth = false;
  bool hasSixth = false;
  late StreamSubscription<A> firstSub;
  late StreamSubscription<B> secondSub;
  late StreamSubscription<C> thirdSub;
  late StreamSubscription<D> fourthSub;
  late StreamSubscription<E> fifthSub;
  late StreamSubscription<F> sixthSub;

  void emitIfReady() {
    if (hasFirst &&
        hasSecond &&
        hasThird &&
        hasFourth &&
        hasFifth &&
        hasSixth) {
      controller.add(
        combiner(
          latestFirst as A,
          latestSecond as B,
          latestThird as C,
          latestFourth as D,
          latestFifth as E,
          latestSixth as F,
        ),
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
      fourthSub = fourth.listen((D value) {
        latestFourth = value;
        hasFourth = true;
        emitIfReady();
      }, onError: controller.addError);
      fifthSub = fifth.listen((E value) {
        latestFifth = value;
        hasFifth = true;
        emitIfReady();
      }, onError: controller.addError);
      sixthSub = sixth.listen((F value) {
        latestSixth = value;
        hasSixth = true;
        emitIfReady();
      }, onError: controller.addError);
    },
    onCancel: () async {
      await firstSub.cancel();
      await secondSub.cancel();
      await thirdSub.cancel();
      await fourthSub.cancel();
      await fifthSub.cancel();
      await sixthSub.cancel();
    },
  );

  return controller.stream;
}
