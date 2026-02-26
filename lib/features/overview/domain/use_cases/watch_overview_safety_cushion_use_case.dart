import 'dart:async';

import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/repositories/account_repository.dart';
import 'package:kopim/features/overview/domain/models/overview_safety_cushion.dart';
import 'package:kopim/features/overview/domain/services/safety_cushion_calculator.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/savings/domain/repositories/saving_goal_repository.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';

class WatchOverviewSafetyCushionUseCase {
  WatchOverviewSafetyCushionUseCase({
    required AccountRepository accountRepository,
    required TransactionRepository transactionRepository,
    required SavingGoalRepository savingGoalRepository,
  }) : _accountRepository = accountRepository,
       _transactionRepository = transactionRepository,
       _savingGoalRepository = savingGoalRepository;

  final AccountRepository _accountRepository;
  final TransactionRepository _transactionRepository;
  final SavingGoalRepository _savingGoalRepository;

  Stream<OverviewSafetyCushion> call({
    Set<String>? accountIdsFilter,
    DateTime? reference,
  }) {
    return _combineLatest3(
      _accountRepository.watchAccounts(),
      _transactionRepository.watchTransactions(),
      _savingGoalRepository.watchGoals(includeArchived: false),
      (
        List<AccountEntity> accounts,
        List<TransactionEntity> transactions,
        List<SavingGoal> goals,
      ) {
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
            .where((TransactionEntity tx) {
              if (tx.isDeleted) {
                return false;
              }
              return scopedAccountIds.contains(tx.accountId);
            })
            .toList(growable: false);

        return SafetyCushionCalculator.calculate(
          accounts: scopedAccounts,
          transactions: scopedTransactions,
          savingGoals: goals,
          reference: reference ?? DateTime.now(),
        );
      },
    );
  }
}

Stream<R> _combineLatest3<A, B, C, R>(
  Stream<A> a,
  Stream<B> b,
  Stream<C> c,
  R Function(A a, B b, C c) combiner,
) {
  return Stream<R>.multi((StreamController<R> controller) {
    A? latestA;
    B? latestB;
    C? latestC;
    bool hasA = false;
    bool hasB = false;
    bool hasC = false;

    void emit() {
      if (!hasA || !hasB || !hasC) {
        return;
      }
      try {
        controller.add(combiner(latestA as A, latestB as B, latestC as C));
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

    final StreamSubscription<C> subC = c.listen((C value) {
      latestC = value;
      hasC = true;
      emit();
    }, onError: controller.addError);

    controller.onCancel = () async {
      await subA.cancel();
      await subB.cancel();
      await subC.cancel();
    };
  });
}
