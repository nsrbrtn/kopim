import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/use_cases/watch_accounts_use_case.dart';
import 'package:kopim/features/accounts/domain/utils/account_type_utils.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/savings/domain/use_cases/create_saving_goal_use_case.dart';
import 'package:kopim/features/savings/domain/use_cases/update_saving_goal_use_case.dart';
import 'package:kopim/features/savings/domain/value_objects/money.dart';

import 'edit_goal_state.dart';

part 'edit_goal_controller.g.dart';

@riverpod
class EditGoalController extends _$EditGoalController {
  StreamSubscription<List<AccountEntity>>? _subscription;

  @override
  EditGoalState build(SavingGoal? goal) {
    ref.onDispose(() async {
      await _subscription?.cancel();
    });

    final EditGoalState initialState;
    if (goal == null) {
      initialState = const EditGoalState();
    } else {
      final double target = goal.targetAmount / 100;
      initialState = EditGoalState(
        original: goal,
        selectedStorageAccountIds: goal.effectiveStorageAccountIds,
        name: goal.name,
        targetInput: target.toStringAsFixed(2),
        note: goal.note,
        targetDate: goal.targetDate,
      );
    }

    _subscribeAccounts(
      goal,
      initialSelectedStorageAccountIds: initialState.selectedStorageAccountIds,
    );
    return initialState;
  }

  void updateName(String value) {
    state = state.copyWith(name: value, nameError: null);
  }

  void updateTarget(String value) {
    state = state.copyWith(targetInput: value, targetError: null);
  }

  void toggleStorageAccount(String accountId, bool selected) {
    final Set<String> updated = state.selectedStorageAccountIds.toSet();
    if (selected) {
      updated.add(accountId);
    } else {
      updated.remove(accountId);
    }
    state = state.copyWith(
      selectedStorageAccountIds: updated.toList(growable: false),
      storageAccountsError: null,
    );
  }

  void updateNote(String value) {
    state = state.copyWith(note: value);
  }

  void updateTargetDate(DateTime? value) {
    state = state.copyWith(targetDate: value);
  }

  Future<void> submit() async {
    final String trimmedName = state.name.trim();
    if (trimmedName.isEmpty) {
      state = state.copyWith(nameError: 'Введите название цели');
      return;
    }
    final String normalizedTarget = state.targetInput.replaceAll(',', '.');
    final double? parsedTarget = double.tryParse(normalizedTarget);
    if (parsedTarget == null || parsedTarget <= 0) {
      state = state.copyWith(targetError: 'Введите сумму больше нуля');
      return;
    }
    final Money targetMoney = Money.fromDouble(parsedTarget);
    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      final String? trimmedNote = state.note?.trim().isNotEmpty ?? false
          ? state.note!.trim()
          : null;
      if (state.original == null) {
        final CreateSavingGoalUseCase create = ref.read(
          createSavingGoalUseCaseProvider,
        );
        await create(
          name: trimmedName,
          target: targetMoney,
          storageAccountIds: state.selectedStorageAccountIds,
          note: trimmedNote,
          targetDate: state.targetDate,
        );
      } else {
        final UpdateSavingGoalUseCase update = ref.read(
          updateSavingGoalUseCaseProvider,
        );
        await update(
          goal: state.original!,
          name: trimmedName,
          target: targetMoney,
          storageAccountIds: state.selectedStorageAccountIds,
          note: trimmedNote,
          targetDate: state.targetDate,
        );
      }
      state = state.copyWith(
        isSaving: false,
        submissionSuccess: true,
        nameError: null,
        targetError: null,
      );
    } catch (error) {
      state = state.copyWith(isSaving: false, errorMessage: error.toString());
    }
  }

  void _subscribeAccounts(
    SavingGoal? goal, {
    required List<String> initialSelectedStorageAccountIds,
  }) {
    _subscription?.cancel();
    final WatchAccountsUseCase watchAccounts = ref.watch(
      watchAccountsUseCaseProvider,
    );
    _subscription = watchAccounts().listen((List<AccountEntity> accounts) {
      final Set<String> preselectedIds = <String>{
        ...?goal?.effectiveStorageAccountIds,
        ...initialSelectedStorageAccountIds,
        ...state.selectedStorageAccountIds,
      };
      final List<AccountEntity> allowed = accounts
          .where((AccountEntity account) {
            if (account.isDeleted) {
              return false;
            }
            if (preselectedIds.contains(account.id)) {
              return true;
            }
            if (account.isHidden) {
              return false;
            }
            if (isLiabilityAccountType(account.type)) {
              return false;
            }
            return isCashAccountType(account.type) ||
                isInvestmentAccountType(account.type);
          })
          .toList(growable: false);

      final Set<String> allowedIds = allowed
          .map((AccountEntity account) => account.id)
          .toSet();
      List<String> selected = <String>[
        ...initialSelectedStorageAccountIds,
        ...state.selectedStorageAccountIds,
      ].where(allowedIds.contains).toSet().toList(growable: false);
      if (selected.isEmpty && goal != null) {
        selected = goal.effectiveStorageAccountIds
            .where(allowedIds.contains)
            .toList(growable: false);
      }
      state = state.copyWith(
        availableStorageAccounts: allowed,
        selectedStorageAccountIds: selected,
      );
    });
  }
}
