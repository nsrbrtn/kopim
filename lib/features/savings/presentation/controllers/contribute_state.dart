import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';

part 'contribute_state.freezed.dart';

@freezed
abstract class ContributeState with _$ContributeState {
  const factory ContributeState({
    required SavingGoal goal,
    @Default(<AccountEntity>[]) List<AccountEntity> accounts,
    String? selectedAccountId,
    @Default('') String amountInput,
    String? amountError,
    String? note,
    @Default(false) bool isSubmitting,
    @Default(false) bool success,
    String? errorMessage,
  }) = _ContributeState;
}
