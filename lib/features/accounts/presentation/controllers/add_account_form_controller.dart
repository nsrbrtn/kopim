import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/domain/icons/phosphor_icon_descriptor.dart';
import 'package:kopim/core/money/currency_scale.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/core/utils/helpers.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/use_cases/add_account_use_case.dart';
import 'package:kopim/features/accounts/domain/utils/account_type_utils.dart';
import 'package:kopim/features/accounts/presentation/controllers/account_balance_parser.dart';
import 'package:kopim/features/categories/presentation/utils/category_color_palette.dart';
import 'package:kopim/features/credits/domain/entities/credit_card_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'add_account_form_controller.freezed.dart';
part 'add_account_form_controller.g.dart';

enum AddAccountFieldError { emptyName, invalidBalance, emptyType }

enum CreditCardFieldError {
  invalidLimit,
  invalidStatementDay,
  invalidPaymentDueDays,
  invalidInterestRate,
}

@freezed
abstract class AddAccountFormState with _$AddAccountFormState {
  const factory AddAccountFormState({
    @Default('') String name,
    @Default('') String balanceInput,
    @Default('RUB') String currency,
    @Default('') String type,
    @Default(false) bool useCustomType,
    @Default('') String customType,
    @Default(false) bool isSaving,
    @Default(false) bool submissionSuccess,
    @Default(false) bool isPrimary,
    @Default('') String creditLimitInput,
    @Default('') String statementDayInput,
    @Default('') String paymentDueDaysInput,
    @Default('') String interestRateInput,
    AddAccountFieldError? nameError,
    AddAccountFieldError? balanceError,
    AddAccountFieldError? typeError,
    CreditCardFieldError? creditLimitError,
    CreditCardFieldError? statementDayError,
    CreditCardFieldError? paymentDueDaysError,
    CreditCardFieldError? interestRateError,
    String? errorMessage,
    String? color,
    String? gradientId,
    String? iconName,
    String? iconStyle,
  }) = _AddAccountFormState;

  const AddAccountFormState._();

  MoneyAmount? parseBalance() =>
      parseBalanceInput(balanceInput, scale: resolveCurrencyScale(currency));

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
      creditLimitError == null &&
      statementDayError == null &&
      paymentDueDaysError == null &&
      interestRateError == null &&
      name.trim().isNotEmpty &&
      (resolvedType == 'credit_card' || parseBalance() != null) &&
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
      creditLimitError: null,
      statementDayError: null,
      paymentDueDaysError: null,
      interestRateError: null,
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

  void updateCreditLimit(String value) {
    state = state.copyWith(
      creditLimitInput: value,
      creditLimitError: null,
      submissionSuccess: false,
    );
  }

  void updateStatementDay(String value) {
    state = state.copyWith(
      statementDayInput: value,
      statementDayError: null,
      submissionSuccess: false,
    );
  }

  void updatePaymentDueDays(String value) {
    state = state.copyWith(
      paymentDueDaysInput: value,
      paymentDueDaysError: null,
      submissionSuccess: false,
    );
  }

  void updateInterestRate(String value) {
    state = state.copyWith(
      interestRateInput: value,
      interestRateError: null,
      submissionSuccess: false,
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

    final String? resolvedType = state.resolvedType;
    final bool isCreditCard = resolvedType == 'credit_card';
    final int currencyScale = resolveCurrencyScale(state.currency);
    MoneyAmount? balance = parseBalanceInput(
      state.balanceInput,
      scale: currencyScale,
    );
    AddAccountFieldError? balanceError;
    if (!isCreditCard && balance == null) {
      balanceError = AddAccountFieldError.invalidBalance;
    }
    balance ??= isCreditCard
        ? MoneyAmount(minor: BigInt.zero, scale: currencyScale)
        : null;

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
      creditLimitError: null,
      statementDayError: null,
      paymentDueDaysError: null,
      interestRateError: null,
      submissionSuccess: false,
    );

    final DateTime now = DateTime.now().toUtc();
    if (resolvedType == null) {
      state = state.copyWith(
        typeError: AddAccountFieldError.emptyType,
        isSaving: false,
        submissionSuccess: false,
      );
      return;
    }

    CreditCardFieldError? creditLimitError;
    CreditCardFieldError? statementDayError;
    CreditCardFieldError? paymentDueDaysError;
    CreditCardFieldError? interestRateError;
    MoneyAmount? creditLimit;
    int? statementDay;
    int? paymentDueDays;
    double? interestRateAnnual;

    if (isCreditCard) {
      creditLimit = parseBalanceInput(
        state.creditLimitInput,
        scale: currencyScale,
      );
      statementDay = int.tryParse(state.statementDayInput);
      paymentDueDays = int.tryParse(state.paymentDueDaysInput);
      interestRateAnnual = _parseRate(state.interestRateInput);

      if (creditLimit == null || creditLimit.minor <= BigInt.zero) {
        creditLimitError = CreditCardFieldError.invalidLimit;
      }
      if (statementDay == null || statementDay < 1 || statementDay > 31) {
        statementDayError = CreditCardFieldError.invalidStatementDay;
      }
      if (paymentDueDays == null || paymentDueDays < 0) {
        paymentDueDaysError = CreditCardFieldError.invalidPaymentDueDays;
      }
      if (interestRateAnnual == null || interestRateAnnual < 0) {
        interestRateError = CreditCardFieldError.invalidInterestRate;
      }
      if (creditLimitError != null ||
          statementDayError != null ||
          paymentDueDaysError != null ||
          interestRateError != null) {
        state = state.copyWith(
          isSaving: false,
          creditLimitError: creditLimitError,
          statementDayError: statementDayError,
          paymentDueDaysError: paymentDueDaysError,
          interestRateError: interestRateError,
          submissionSuccess: false,
        );
        return;
      }
    }

    final MoneyAmount resolvedBalance =
        balance ?? MoneyAmount(minor: BigInt.zero, scale: currencyScale);
    final AccountEntity account = AccountEntity(
      id: _uuid.v4(),
      name: trimmedName,
      balanceMinor: resolvedBalance.minor,
      openingBalanceMinor: resolvedBalance.minor,
      currency: state.currency,
      currencyScale: currencyScale,
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
      if (isCreditCard) {
        await ref
            .read(addCreditCardUseCaseProvider)
            .call(
              CreditCardEntity(
                id: account.id,
                accountId: account.id,
                creditLimitMinor: creditLimit!.minor,
                creditLimitScale: creditLimit.scale,
                statementDay: statementDay!,
                paymentDueDays: paymentDueDays!,
                interestRateAnnual: interestRateAnnual!,
                createdAt: now,
                updatedAt: now,
              ),
            );
      }
      state = state.copyWith(
        isSaving: false,
        name: '',
        balanceInput: '',
        type: '',
        useCustomType: false,
        customType: '',
        creditLimitInput: '',
        statementDayInput: '',
        paymentDueDaysInput: '',
        interestRateInput: '',
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

  double? _parseRate(String input) {
    final String trimmed = input.trim();
    if (trimmed.isEmpty) {
      return 0;
    }
    final String normalized = trimmed.replaceAll(',', '.');
    return double.tryParse(normalized);
  }
}
