import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/savings/domain/use_cases/create_saving_goal_use_case.dart';
import 'package:kopim/features/savings/domain/use_cases/update_saving_goal_use_case.dart';
import 'package:kopim/features/savings/domain/value_objects/money.dart';

import 'edit_goal_state.dart';

part 'edit_goal_controller.g.dart';

@riverpod
class EditGoalController extends _$EditGoalController {
  @override
  EditGoalState build(SavingGoal? goal) {
    if (goal == null) {
      return const EditGoalState();
    }
    final double target = goal.targetAmount / 100;
    return EditGoalState(
      original: goal,
      name: goal.name,
      targetInput: target.toStringAsFixed(2),
      note: goal.note,
    );
  }

  void updateName(String value) {
    state = state.copyWith(name: value, nameError: null);
  }

  void updateTarget(String value) {
    state = state.copyWith(targetInput: value, targetError: null);
  }

  void updateNote(String value) {
    state = state.copyWith(note: value);
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
        await create(name: trimmedName, target: targetMoney, note: trimmedNote);
      } else {
        final UpdateSavingGoalUseCase update = ref.read(
          updateSavingGoalUseCaseProvider,
        );
        await update(
          goal: state.original!,
          name: trimmedName,
          target: targetMoney,
          note: trimmedNote,
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
}
