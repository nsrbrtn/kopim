import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/use_cases/add_account_use_case.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'add_account_form_controller.freezed.dart';
part 'add_account_form_controller.g.dart';

enum AddAccountFieldError { emptyName, invalidBalance }

@freezed
abstract class AddAccountFormState with _$AddAccountFormState {
  const factory AddAccountFormState({
    @Default('') String name,
    @Default('') String balanceInput,
    @Default('USD') String currency,
    @Default('cash') String type,
    @Default(false) bool isSaving,
    @Default(false) bool submissionSuccess,
    AddAccountFieldError? nameError,
    AddAccountFieldError? balanceError,
    String? errorMessage,
  }) = _AddAccountFormState;

  const AddAccountFormState._();

  double? get parsedBalance => _parseBalanceInput(balanceInput);

  bool get canSubmit =>
      !isSaving &&
      nameError == null &&
      balanceError == null &&
      name.trim().isNotEmpty &&
      parsedBalance != null;
}

@riverpod
class AddAccountFormController extends _$AddAccountFormController {
  late final AddAccountUseCase _addAccountUseCase;
  late final Uuid _uuid;

  @override
  AddAccountFormState build() {
    _addAccountUseCase = ref.watch(addAccountUseCaseProvider);
    _uuid = ref.watch(uuidGeneratorProvider);
    return const AddAccountFormState();
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
    state = state.copyWith(currency: value, submissionSuccess: false);
  }

  void updateType(String value) {
    state = state.copyWith(type: value, submissionSuccess: false);
  }

  void resetForm() {
    state = const AddAccountFormState();
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
    AddAccountFieldError? nameError;
    if (trimmedName.isEmpty) {
      nameError = AddAccountFieldError.emptyName;
    }

    final double? balance = _parseBalanceInput(state.balanceInput);
    AddAccountFieldError? balanceError;
    if (balance == null) {
      balanceError = AddAccountFieldError.invalidBalance;
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
      errorMessage: null,
      nameError: null,
      balanceError: null,
      submissionSuccess: false,
    );

    final DateTime now = DateTime.now().toUtc();
    final AccountEntity account = AccountEntity(
      id: _uuid.v4(),
      name: trimmedName,
      balance: balance!,
      currency: state.currency,
      type: state.type,
      createdAt: now,
      updatedAt: now,
    );

    try {
      await _addAccountUseCase(account);
      state = state.copyWith(
        isSaving: false,
        name: '',
        balanceInput: '',
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

double? _parseBalanceInput(String input) {
  final String trimmed = input.trim();
  if (trimmed.isEmpty) {
    return 0;
  }

  final String normalized = trimmed.replaceAll(',', '.');
  return double.tryParse(normalized);
}
