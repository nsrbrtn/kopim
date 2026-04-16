import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';

part 'edit_goal_state.freezed.dart';

@freezed
abstract class EditGoalState with _$EditGoalState {
  const factory EditGoalState({
    SavingGoal? original,
    @Default(<AccountEntity>[]) List<AccountEntity> availableStorageAccounts,
    @Default(<String>[]) List<String> selectedStorageAccountIds,
    @Default('') String name,
    @Default('') String targetInput,
    String? nameError,
    String? targetError,
    String? storageAccountsError,
    String? note,
    DateTime? targetDate,
    @Default(false) bool isSaving,
    @Default(false) bool submissionSuccess,
    String? errorMessage,
  }) = _EditGoalState;
}
