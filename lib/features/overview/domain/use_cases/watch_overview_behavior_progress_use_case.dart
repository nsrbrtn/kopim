import 'dart:async';

import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/repositories/account_repository.dart';
import 'package:kopim/features/overview/domain/models/overview_behavior_progress.dart';
import 'package:kopim/features/overview/domain/services/behavior_discipline_calculator.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';

class WatchOverviewBehaviorProgressUseCase {
  WatchOverviewBehaviorProgressUseCase({
    required AccountRepository accountRepository,
    required TransactionRepository transactionRepository,
  }) : _accountRepository = accountRepository,
       _transactionRepository = transactionRepository;

  final AccountRepository _accountRepository;
  final TransactionRepository _transactionRepository;

  Stream<OverviewBehaviorProgress> call({
    Set<String>? accountIdsFilter,
    Set<String>? categoryIdsFilter,
    DateTime? reference,
  }) {
    return _combineLatest2(
      _accountRepository.watchAccounts(),
      _transactionRepository.watchTransactions(),
      (List<AccountEntity> accounts, List<TransactionEntity> transactions) {
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

        final Set<String> scopedAccountIds = scopedAccounts
            .map((AccountEntity account) => account.id)
            .toSet();

        final List<TransactionEntity> scopedTransactions = transactions
            .where((TransactionEntity transaction) {
              if (transaction.isDeleted) {
                return false;
              }
              if (!scopedAccountIds.contains(transaction.accountId)) {
                return false;
              }
              if (categoryIdsFilter == null || categoryIdsFilter.isEmpty) {
                return true;
              }
              final String? categoryId = transaction.categoryId;
              return categoryId != null &&
                  categoryIdsFilter.contains(categoryId);
            })
            .toList(growable: false);

        return BehaviorDisciplineCalculator.calculate(
          transactions: scopedTransactions,
          reference: reference ?? DateTime.now(),
        );
      },
    );
  }
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
