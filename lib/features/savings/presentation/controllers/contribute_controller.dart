import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
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
      success: false,
    );
  }

  void updateNote(String value) {
    state = state.copyWith(note: value, success: false);
  }

  void selectAccount(String? accountId) {
    state = state.copyWith(selectedAccountId: accountId, success: false);
  }

  Future<void> submit() async {
    final String normalized = state.amountInput.replaceAll(',', '.');
    final double? parsed = double.tryParse(normalized);
    if (parsed == null || parsed <= 0) {
      state = state.copyWith(amountError: 'Введите сумму больше нуля');
      return;
    }
    final Money amount = Money.fromDouble(parsed);
    state = state.copyWith(
      isSubmitting: true,
      amountError: null,
      errorMessage: null,
    );
    try {
      final AddContributionUseCase addContribution = ref.read(
        addContributionUseCaseProvider,
      );
      await addContribution(
        goalId: state.goal.id,
        amount: amount,
        sourceAccountId: state.selectedAccountId,
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
      final String? selected = state.selectedAccountId;
      final bool stillExists = selected == null
          ? true
          : accounts.any((AccountEntity account) => account.id == selected);
      state = state.copyWith(
        accounts: accounts,
        selectedAccountId: stillExists ? selected : null,
      );
    });
  }
}
