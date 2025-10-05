import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';

part 'edit_goal_state.freezed.dart';

@freezed
abstract class EditGoalState with _$EditGoalState {
  const factory EditGoalState({
    SavingGoal? original,
    @Default('') String name,
    @Default('') String targetInput,
    String? nameError,
    String? targetError,
    String? note,
    @Default(false) bool isSaving,
    @Default(false) bool submissionSuccess,
    String? errorMessage,
  }) = _EditGoalState;
}
