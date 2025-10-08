import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/use_cases/add_account_use_case.dart';
import 'package:kopim/features/accounts/domain/utils/account_type_utils.dart';
import 'package:kopim/features/accounts/presentation/controllers/account_balance_parser.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'edit_account_form_controller.freezed.dart';
part 'edit_account_form_controller.g.dart';

enum EditAccountFieldError { emptyName, invalidBalance, emptyType }

@freezed
abstract class EditAccountFormState with _$EditAccountFormState {
  const factory EditAccountFormState({
    required AccountEntity original,
    required String name,
    required String balanceInput,
    required String currency,
    required String type,
    @Default(false) bool useCustomType,
    @Default('') String customType,
    @Default(false) bool isSaving,
    @Default(false) bool submissionSuccess,
    EditAccountFieldError? nameError,
    EditAccountFieldError? balanceError,
    EditAccountFieldError? typeError,
    String? errorMessage,
  }) = _EditAccountFormState;

  const EditAccountFormState._();

  double? get parsedBalance => parseBalanceInput(balanceInput);

  String? get resolvedType {
    final String value = useCustomType ? customType.trim() : type.trim();
    if (value.isEmpty) {
      return null;
    }
    final String normalized = normalizeAccountType(value);
    if (normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  bool get canSubmit =>
      !isSaving &&
      nameError == null &&
      balanceError == null &&
      typeError == null &&
      name.trim().isNotEmpty &&
      parsedBalance != null &&
      resolvedType != null;
}

@riverpod
class EditAccountFormController extends _$EditAccountFormController {
  late final AddAccountUseCase _addAccountUseCase;
  static const Set<String> _defaultTypes = <String>{'cash', 'card', 'bank'};

  @override
  EditAccountFormState build(AccountEntity account) {
    _addAccountUseCase = ref.watch(addAccountUseCaseProvider);
    final bool useCustomType = !_defaultTypes.contains(
      account.type.toLowerCase(),
    );
    final String customType = useCustomType
        ? stripCustomAccountPrefix(account.type)
        : '';
    return EditAccountFormState(
      original: account,
      name: account.name,
      balanceInput: account.balance.toStringAsFixed(2),
      currency: account.currency,
      type: useCustomType ? 'cash' : account.type,
      useCustomType: useCustomType,
      customType: customType,
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

  void updateType(String value) {
    state = state.copyWith(
      type: value,
      useCustomType: false,
      submissionSuccess: false,
      errorMessage: null,
      typeError: null,
    );
  }

  void enableCustomType() {
    state = state.copyWith(
      useCustomType: true,
      submissionSuccess: false,
      errorMessage: null,
      typeError: null,
    );
  }

  void updateCustomType(String value) {
    state = state.copyWith(
      customType: value,
      submissionSuccess: false,
      errorMessage: null,
      typeError: null,
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
      typeError: null,
      errorMessage: null,
      submissionSuccess: false,
    );

    final DateTime updatedAt = DateTime.now().toUtc();
    final String? resolvedType = state.resolvedType;
    EditAccountFieldError? typeError;
    if (resolvedType == null) {
      typeError = EditAccountFieldError.emptyType;
    }

    if (typeError != null) {
      state = state.copyWith(
        isSaving: false,
        typeError: typeError,
        submissionSuccess: false,
      );
      return;
    }

    final AccountEntity updatedAccount = state.original.copyWith(
      name: trimmedName,
      balance: balance!,
      currency: state.currency,
      type: resolvedType!,
      updatedAt: updatedAt,
    );

    try {
      await _addAccountUseCase(updatedAccount);
      final bool updatedIsCustom = !_defaultTypes.contains(
        updatedAccount.type.toLowerCase(),
      );
      final String normalizedCustom = stripCustomAccountPrefix(
        updatedAccount.type,
      );
      state = state.copyWith(
        isSaving: false,
        original: updatedAccount,
        balanceInput: balance.toStringAsFixed(2),
        type: updatedIsCustom ? state.type : updatedAccount.type,
        useCustomType: updatedIsCustom,
        customType: updatedIsCustom ? normalizedCustom : '',
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
