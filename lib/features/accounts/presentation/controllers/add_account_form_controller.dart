import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/domain/icons/phosphor_icon_descriptor.dart';
import 'package:kopim/core/utils/helpers.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/use_cases/add_account_use_case.dart';
import 'package:kopim/features/accounts/domain/utils/account_type_utils.dart';
import 'package:kopim/features/accounts/presentation/controllers/account_balance_parser.dart';
import 'package:kopim/features/categories/presentation/utils/category_color_palette.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'add_account_form_controller.freezed.dart';
part 'add_account_form_controller.g.dart';

enum AddAccountFieldError { emptyName, invalidBalance, emptyType }

@freezed
abstract class AddAccountFormState with _$AddAccountFormState {
  const factory AddAccountFormState({
    @Default('') String name,
    @Default('') String balanceInput,
    @Default('RUB') String currency,
    @Default('cash') String type,
    @Default(false) bool useCustomType,
    @Default('') String customType,
    @Default(false) bool isSaving,
    @Default(false) bool submissionSuccess,
    @Default(false) bool isPrimary,
    AddAccountFieldError? nameError,
    AddAccountFieldError? balanceError,
    AddAccountFieldError? typeError,
    String? errorMessage,
    String? color,
    String? gradientId,
    String? iconName,
    String? iconStyle,
  }) = _AddAccountFormState;

  const AddAccountFormState._();

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
class AddAccountFormController extends _$AddAccountFormController {
  late final AddAccountUseCase _addAccountUseCase;
  late final Uuid _uuid;

  @override
  AddAccountFormState build() {
    _addAccountUseCase = ref.watch(addAccountUseCaseProvider);
    _uuid = ref.watch(uuidGeneratorProvider);
    final String defaultColor = colorToHex(
      kCategoryPastelPalette.first,
      includeAlpha: false,
    )!;
    return AddAccountFormState(color: defaultColor);
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
    state = state.copyWith(
      type: value,
      useCustomType: false,
      submissionSuccess: false,
      typeError: null,
    );
  }

  void enableCustomType() {
    state = state.copyWith(
      useCustomType: true,
      submissionSuccess: false,
      typeError: null,
    );
  }

  void updateCustomType(String value) {
    state = state.copyWith(
      customType: value,
      submissionSuccess: false,
      typeError: null,
    );
  }

  void resetForm() {
    state = const AddAccountFormState();
  }

  void clearSubmissionFlag() {
    if (state.submissionSuccess) {
      state = state.copyWith(submissionSuccess: false);
    }
  }

  void updateIsPrimary(bool value) {
    state = state.copyWith(isPrimary: value, submissionSuccess: false);
  }

  void updateColor(String? value) {
    state = state.copyWith(color: value, submissionSuccess: false);
  }

  void updateGradient(String? value) {
    state = state.copyWith(gradientId: value, submissionSuccess: false);
  }

  void updateIcon(PhosphorIconDescriptor? icon) {
    state = state.copyWith(
      iconName: icon?.name,
      iconStyle: icon?.style.name,
      submissionSuccess: false,
    );
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

    final double? balance = parseBalanceInput(state.balanceInput);
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
      typeError: null,
      submissionSuccess: false,
    );

    final DateTime now = DateTime.now().toUtc();
    final String? resolvedType = state.resolvedType;
    if (resolvedType == null) {
      state = state.copyWith(
        typeError: AddAccountFieldError.emptyType,
        isSaving: false,
        submissionSuccess: false,
      );
      return;
    }

    final AccountEntity account = AccountEntity(
      id: _uuid.v4(),
      name: trimmedName,
      balance: balance!,
      currency: state.currency,
      type: resolvedType,
      createdAt: now,
      updatedAt: now,
      color: state.color,
      gradientId: state.gradientId,
      iconName: state.iconName,
      iconStyle: state.iconStyle,
      isPrimary: state.isPrimary,
    );

    try {
      await _addAccountUseCase(account);
      state = state.copyWith(
        isSaving: false,
        name: '',
        balanceInput: '',
        type: 'cash',
        useCustomType: false,
        customType: '',
        submissionSuccess: true,
        isPrimary: state.isPrimary,
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
