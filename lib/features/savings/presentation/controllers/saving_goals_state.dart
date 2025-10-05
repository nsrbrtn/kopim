import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';

part 'saving_goals_state.freezed.dart';

@freezed
abstract class SavingGoalsState with _$SavingGoalsState {
  const factory SavingGoalsState({
    @Default(<SavingGoal>[]) List<SavingGoal> goals,
    @Default(false) bool showArchived,
    @Default(true) bool isLoading,
    String? error,
  }) = _SavingGoalsState;
}
