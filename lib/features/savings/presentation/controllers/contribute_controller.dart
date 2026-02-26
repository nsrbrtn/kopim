import 'dart:async';

import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/utils/account_type_utils.dart';
import 'package:kopim/features/accounts/domain/use_cases/watch_accounts_use_case.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/savings/domain/use_cases/add_contribution_use_case.dart';
import 'package:kopim/features/savings/domain/value_objects/money.dart';

import 'contribute_state.dart';

part 'contribute_controller.g.dart';

@riverpod
class ContributeController extends _$ContributeController {
  StreamSubscription<List<AccountEntity>>? _subscription;

  @override
  ContributeState build(SavingGoal goal) {
    ref.onDispose(() async {
      await _subscription?.cancel();
    });
    final ContributeState initial = ContributeState(goal: goal);
    state = initial;
    _subscribeAccounts();
    return initial;
  }

  void updateAmount(String value) {
    state = state.copyWith(
      amountInput: value,
      amountError: null,
      sourceAccountError: null,
      success: false,
    );
  }

  void updateNote(String value) {
    state = state.copyWith(note: value, success: false);
  }

  void selectAccount(String? accountId) {
    state = state.copyWith(
      selectedAccountId: accountId,
      sourceAccountError: null,
      success: false,
    );
  }

  Future<void> submit() async {
    final String? sourceAccountId = state.selectedAccountId;
    if (sourceAccountId == null || sourceAccountId.isEmpty) {
      state = state.copyWith(
        sourceAccountError: 'Выберите счет списания',
        success: false,
      );
      return;
    }
    final String normalized = state.amountInput.replaceAll(',', '.');
    final double? parsed = double.tryParse(normalized);
    if (parsed == null || parsed <= 0) {
      state = state.copyWith(amountError: 'Введите сумму больше нуля');
      return;
    }
    final AccountEntity? sourceAccount = state.accounts
        .where((AccountEntity account) => account.id == sourceAccountId)
        .firstOrNull;
    if (sourceAccount == null) {
      state = state.copyWith(
        sourceAccountError: 'Счет списания недоступен',
        success: false,
      );
      return;
    }
    final String? goalCurrency = state.goalAccountCurrency;
    if (goalCurrency == null || goalCurrency.isEmpty) {
      state = state.copyWith(
        sourceAccountError: 'Счет копилки недоступен',
        success: false,
      );
      return;
    }
    if (sourceAccount.currency != goalCurrency) {
      state = state.copyWith(
        sourceAccountError: 'Валюты счетов не совпадают',
        success: false,
      );
      return;
    }
    final Money amount = Money.fromDouble(parsed);
    final BigInt sourceBalance = sourceAccount.balanceMinor ?? BigInt.zero;
    if (sourceBalance < BigInt.from(amount.minorUnits)) {
      state = state.copyWith(
        sourceAccountError: 'Недостаточно средств на счете',
        success: false,
      );
      return;
    }
    state = state.copyWith(
      isSubmitting: true,
      amountError: null,
      sourceAccountError: null,
      errorMessage: null,
    );
    try {
      final AddContributionUseCase addContribution = ref.read(
        addContributionUseCaseProvider,
      );
      await addContribution(
        goalId: state.goal.id,
        amount: amount,
        sourceAccountId: sourceAccountId,
        note: state.note,
      );
      state = state.copyWith(
        isSubmitting: false,
        success: true,
        errorMessage: null,
      );
    } catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: error.toString(),
      );
      ref
          .read(loggerServiceProvider)
          .logError('Failed to add contribution', error);
    }
  }

  void _subscribeAccounts() {
    _subscription?.cancel();
    final WatchAccountsUseCase watchAccounts = ref.watch(
      watchAccountsUseCaseProvider,
    );
    _subscription = watchAccounts().listen((List<AccountEntity> accounts) {
      final AccountEntity? goalAccount =
          (state.goal.accountId == null || state.goal.accountId!.isEmpty)
          ? null
          : accounts.where((AccountEntity account) {
              return account.id == state.goal.accountId;
            }).firstOrNull;
      final List<AccountEntity> filtered = accounts
          .where(
            (AccountEntity account) =>
                isCashAccountType(account.type) &&
                !account.isHidden &&
                account.id != state.goal.accountId,
          )
          .toList(growable: false);
      final String? previousSelected = state.selectedAccountId;
      String? nextSelected = previousSelected;
      final bool selectionRemoved =
          previousSelected != null &&
          !filtered.any(
            (AccountEntity account) => account.id == previousSelected,
          );
      if (selectionRemoved) {
        nextSelected = null;
      }
      final bool shouldDefaultToPrimary =
          selectionRemoved ||
          (previousSelected == null && state.accounts.isEmpty);
      if (nextSelected == null && shouldDefaultToPrimary) {
        bool assigned = false;
        for (final AccountEntity account in filtered) {
          if (account.isPrimary) {
            nextSelected = account.id;
            assigned = true;
            break;
          }
        }
        if (!assigned && filtered.isNotEmpty) {
          nextSelected = filtered.first.id;
        }
      }
      state = state.copyWith(
        accounts: filtered,
        selectedAccountId: nextSelected,
        goalAccountCurrency: goalAccount?.currency,
      );
    });
  }
}
