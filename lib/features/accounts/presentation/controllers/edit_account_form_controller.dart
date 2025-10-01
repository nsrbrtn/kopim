import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/use_cases/add_account_use_case.dart';
import 'package:kopim/features/accounts/presentation/controllers/account_balance_parser.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'edit_account_form_controller.freezed.dart';
part 'edit_account_form_controller.g.dart';

enum EditAccountFieldError { emptyName, invalidBalance }

@freezed
abstract class EditAccountFormState with _$EditAccountFormState {
  const factory EditAccountFormState({
    required AccountEntity original,
    required String name,
    required String balanceInput,
    required String currency,
    @Default(false) bool isSaving,
    @Default(false) bool submissionSuccess,
    EditAccountFieldError? nameError,
    EditAccountFieldError? balanceError,
    String? errorMessage,
  }) = _EditAccountFormState;

  const EditAccountFormState._();

  double? get parsedBalance => parseBalanceInput(balanceInput);

  bool get canSubmit =>
      !isSaving &&
      nameError == null &&
      balanceError == null &&
      name.trim().isNotEmpty &&
      parsedBalance != null;
}

@riverpod
class EditAccountFormController extends _$EditAccountFormController {
  late final AddAccountUseCase _addAccountUseCase;

  @override
  EditAccountFormState build(AccountEntity account) {
    _addAccountUseCase = ref.watch(addAccountUseCaseProvider);
    return EditAccountFormState(
      original: account,
      name: account.name,
      balanceInput: account.balance.toStringAsFixed(2),
      currency: account.currency,
    );
  }

  void updateName(String value) {
    state = state.copyWith(
      name: value,
      nameError: null,
      submissionSuccess: false,
      errorMessage: null,
    );
  }

  void updateBalance(String value) {
    state = state.copyWith(
      balanceInput: value,
      balanceError: null,
      submissionSuccess: false,
      errorMessage: null,
    );
  }

  void updateCurrency(String value) {
    state = state.copyWith(
      currency: value,
      submissionSuccess: false,
      errorMessage: null,
    );
  }

  void clearSubmissionFlag() {
    if (state.submissionSuccess) {
      state = state.copyWith(submissionSuccess: false);
    }
  }

  Future<void> submit() async {
    if (state.isSaving) {
      return;
    }

    final String trimmedName = state.name.trim();
    EditAccountFieldError? nameError;
    if (trimmedName.isEmpty) {
      nameError = EditAccountFieldError.emptyName;
    }

    final double? balance = parseBalanceInput(state.balanceInput);
    EditAccountFieldError? balanceError;
    if (balance == null) {
      balanceError = EditAccountFieldError.invalidBalance;
    }

    if (nameError != null || balanceError != null) {
      state = state.copyWith(
        nameError: nameError,
        balanceError: balanceError,
        submissionSuccess: false,
      );
      return;
    }

    state = state.copyWith(
      isSaving: true,
      nameError: null,
      balanceError: null,
      errorMessage: null,
      submissionSuccess: false,
    );

    final DateTime updatedAt = DateTime.now().toUtc();
    final AccountEntity updatedAccount = state.original.copyWith(
      name: trimmedName,
      balance: balance!,
      currency: state.currency,
      updatedAt: updatedAt,
    );

    try {
      await _addAccountUseCase(updatedAccount);
      state = state.copyWith(
        isSaving: false,
        original: updatedAccount,
        balanceInput: balance.toStringAsFixed(2),
        submissionSuccess: true,
      );
    } catch (error) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: error.toString(),
        submissionSuccess: false,
      );
    }
  }
}
