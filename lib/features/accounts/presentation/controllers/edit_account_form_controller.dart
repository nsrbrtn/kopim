import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/domain/icons/phosphor_icon_descriptor.dart';
import 'package:kopim/core/money/currency_scale.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/use_cases/add_account_use_case.dart';
import 'package:kopim/features/accounts/domain/utils/account_type_utils.dart';
import 'package:kopim/features/accounts/presentation/controllers/account_balance_parser.dart';
import 'package:kopim/features/credits/domain/entities/credit_card_entity.dart';
import 'package:kopim/features/credits/domain/use_cases/add_credit_card_use_case.dart';
import 'package:kopim/features/credits/domain/use_cases/delete_credit_card_use_case.dart';
import 'package:kopim/features/credits/domain/use_cases/get_credit_card_by_account_id_use_case.dart';
import 'package:kopim/features/credits/domain/use_cases/update_credit_card_use_case.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'edit_account_form_controller.freezed.dart';
part 'edit_account_form_controller.g.dart';

enum EditAccountFieldError { emptyName, invalidBalance, emptyType }

enum CreditCardFieldError {
  invalidLimit,
  invalidStatementDay,
  invalidPaymentDueDays,
  invalidInterestRate,
}

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
    @Default(false) bool isPrimary,
    @Default('') String creditLimitInput,
    @Default('') String statementDayInput,
    @Default('') String paymentDueDaysInput,
    @Default('') String interestRateInput,
    @Default(false) bool creditCardLoaded,
    String? creditCardId,
    DateTime? creditCardCreatedAt,
    String? color,
    String? gradientId,
    String? iconName,
    String? iconStyle,
    EditAccountFieldError? nameError,
    EditAccountFieldError? balanceError,
    EditAccountFieldError? typeError,
    CreditCardFieldError? creditLimitError,
    CreditCardFieldError? statementDayError,
    CreditCardFieldError? paymentDueDaysError,
    CreditCardFieldError? interestRateError,
    String? errorMessage,
  }) = _EditAccountFormState;

  const EditAccountFormState._();

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
      parseBalance() != null &&
      resolvedType != null;
}

@riverpod
class EditAccountFormController extends _$EditAccountFormController {
  late final AddAccountUseCase _addAccountUseCase;
  late final TransactionRepository _transactionRepository;
  static const Set<String> _defaultTypes = <String>{
    'cash',
    'card',
    'bank',
    'credit_card',
  };
  late final GetCreditCardByAccountIdUseCase _getCreditCardByAccountIdUseCase;
  late final AddCreditCardUseCase _addCreditCardUseCase;
  late final UpdateCreditCardUseCase _updateCreditCardUseCase;
  late final DeleteCreditCardUseCase _deleteCreditCardUseCase;

  @override
  EditAccountFormState build(AccountEntity account) {
    _addAccountUseCase = ref.watch(addAccountUseCaseProvider);
    _transactionRepository = ref.watch(transactionRepositoryProvider);
    _getCreditCardByAccountIdUseCase = ref.watch(
      getCreditCardByAccountIdUseCaseProvider,
    );
    _addCreditCardUseCase = ref.watch(addCreditCardUseCaseProvider);
    _updateCreditCardUseCase = ref.watch(updateCreditCardUseCaseProvider);
    _deleteCreditCardUseCase = ref.watch(deleteCreditCardUseCaseProvider);
    final bool useCustomType = !_defaultTypes.contains(
      account.type.toLowerCase(),
    );
    final String customType = useCustomType
        ? stripCustomAccountPrefix(account.type)
        : '';
    final MoneyAmount balanceAmount = account.balanceAmount;
    return EditAccountFormState(
      original: account,
      name: account.name,
      balanceInput: balanceAmount.toDouble().toStringAsFixed(
        balanceAmount.scale,
      ),
      currency: account.currency,
      type: useCustomType ? 'cash' : account.type,
      useCustomType: useCustomType,
      customType: customType,
      isPrimary: account.isPrimary,
      color: account.color,
      gradientId: account.gradientId,
      iconName: account.iconName,
      iconStyle: account.iconStyle,
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

  void updateCreditLimit(String value) {
    state = state.copyWith(
      creditLimitInput: value,
      creditLimitError: null,
      submissionSuccess: false,
      errorMessage: null,
    );
  }

  void updateStatementDay(String value) {
    state = state.copyWith(
      statementDayInput: value,
      statementDayError: null,
      submissionSuccess: false,
      errorMessage: null,
    );
  }

  void updatePaymentDueDays(String value) {
    state = state.copyWith(
      paymentDueDaysInput: value,
      paymentDueDaysError: null,
      submissionSuccess: false,
      errorMessage: null,
    );
  }

  void updateInterestRate(String value) {
    state = state.copyWith(
      interestRateInput: value,
      interestRateError: null,
      submissionSuccess: false,
      errorMessage: null,
    );
  }

  void updateIsPrimary(bool value) {
    state = state.copyWith(
      isPrimary: value,
      submissionSuccess: false,
      errorMessage: null,
    );
  }

  void updateColor(String? value) {
    state = state.copyWith(
      color: value,
      submissionSuccess: false,
      errorMessage: null,
    );
  }

  void updateGradient(String? value) {
    state = state.copyWith(
      gradientId: value,
      submissionSuccess: false,
      errorMessage: null,
    );
  }

  void updateIcon(PhosphorIconDescriptor? icon) {
    state = state.copyWith(
      iconName: icon?.name,
      iconStyle: icon?.style.name,
      submissionSuccess: false,
      errorMessage: null,
    );
  }

  void clearSubmissionFlag() {
    if (state.submissionSuccess) {
      state = state.copyWith(submissionSuccess: false);
    }
  }

  Future<void> loadCreditCard() async {
    if (state.creditCardLoaded || state.original.type != 'credit_card') {
      return;
    }
    state = state.copyWith(creditCardLoaded: true);
    final CreditCardEntity? creditCard = await _getCreditCardByAccountIdUseCase
        .call(state.original.id);
    if (creditCard == null) {
      return;
    }
    final MoneyAmount creditLimit = creditCard.creditLimitValue;
    state = state.copyWith(
      creditCardId: creditCard.id,
      creditCardCreatedAt: creditCard.createdAt,
      creditLimitInput: creditLimit.toDouble().toStringAsFixed(
        creditLimit.scale,
      ),
      statementDayInput: creditCard.statementDay.toString(),
      paymentDueDaysInput: creditCard.paymentDueDays.toString(),
      interestRateInput: creditCard.interestRateAnnual.toStringAsFixed(2),
    );
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

    final int currencyScale = resolveCurrencyScale(state.currency);
    final MoneyAmount? balance = parseBalanceInput(
      state.balanceInput,
      scale: currencyScale,
    );
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
      creditLimitError: null,
      statementDayError: null,
      paymentDueDaysError: null,
      interestRateError: null,
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

    final bool isCreditCard = resolvedType == 'credit_card';
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

    final MoneyAmount transactionDelta = await _calculateTransactionDelta(
      state.original.id,
    );
    final MoneyAmount resolvedBalance =
        balance ?? MoneyAmount(minor: BigInt.zero, scale: currencyScale);
    final String resolvedTypeValue = resolvedType ?? state.original.type;
    final MoneyAmount openingBalance = MoneyAmount(
      minor: resolvedBalance.minor - transactionDelta.minor,
      scale: resolvedBalance.scale,
    );
    final AccountEntity updatedAccount = state.original.copyWith(
      name: trimmedName,
      balanceMinor: resolvedBalance.minor,
      openingBalanceMinor: openingBalance.minor,
      currency: state.currency,
      currencyScale: currencyScale,
      type: resolvedTypeValue,
      updatedAt: updatedAt,
      isPrimary: state.isPrimary,
      color: state.color,
      gradientId: state.gradientId,
      iconName: state.iconName,
      iconStyle: state.iconStyle,
    );

    try {
      await _addAccountUseCase(updatedAccount);
      await _syncCreditCard(
        updatedAccount: updatedAccount,
        creditLimit: creditLimit,
        statementDay: statementDay,
        paymentDueDays: paymentDueDays,
        interestRateAnnual: interestRateAnnual,
      );
      final bool updatedIsCustom = !_defaultTypes.contains(
        updatedAccount.type.toLowerCase(),
      );
      final String normalizedCustom = stripCustomAccountPrefix(
        updatedAccount.type,
      );
      state = state.copyWith(
        isSaving: false,
        original: updatedAccount,
        balanceInput: resolvedBalance.toDouble().toStringAsFixed(
          resolvedBalance.scale,
        ),
        type: updatedIsCustom ? state.type : updatedAccount.type,
        useCustomType: updatedIsCustom,
        customType: updatedIsCustom ? normalizedCustom : '',
        submissionSuccess: true,
        isPrimary: updatedAccount.isPrimary,
      );
    } catch (error) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: error.toString(),
        submissionSuccess: false,
      );
    }
  }

  Future<MoneyAmount> _calculateTransactionDelta(String accountId) async {
    final List<TransactionEntity> transactions = await _transactionRepository
        .loadTransactions();
    final MoneyAccumulator accumulator = MoneyAccumulator();
    for (final TransactionEntity transaction in transactions) {
      if (transaction.isDeleted) continue;
      final MoneyAmount amount = transaction.amountValue.abs();
      final TransactionType type = parseTransactionType(transaction.type);
      switch (type) {
        case TransactionType.income:
          if (transaction.accountId == accountId) {
            accumulator.add(amount);
          }
          break;
        case TransactionType.expense:
          if (transaction.accountId == accountId) {
            accumulator.subtract(amount);
          }
          break;
        case TransactionType.transfer:
          if (transaction.accountId == accountId) {
            accumulator.subtract(amount);
          }
          if (transaction.transferAccountId == accountId) {
            accumulator.add(amount);
          }
          break;
      }
    }
    return MoneyAmount(minor: accumulator.minor, scale: accumulator.scale);
  }

  Future<void> _syncCreditCard({
    required AccountEntity updatedAccount,
    required MoneyAmount? creditLimit,
    required int? statementDay,
    required int? paymentDueDays,
    required double? interestRateAnnual,
  }) async {
    final bool wasCreditCard = state.original.type == 'credit_card';
    final bool isCreditCard = updatedAccount.type == 'credit_card';
    final String? creditCardId = state.creditCardId;

    if (!isCreditCard && wasCreditCard && creditCardId != null) {
      await _deleteCreditCardUseCase.call(creditCardId);
      return;
    }

    if (!isCreditCard) {
      return;
    }

    final DateTime now = DateTime.now().toUtc();
    final DateTime createdAt = state.creditCardCreatedAt ?? now;
    final MoneyAmount resolvedLimit =
        creditLimit ?? MoneyAmount(minor: BigInt.zero, scale: 2);
    final CreditCardEntity creditCard = CreditCardEntity(
      id: creditCardId ?? updatedAccount.id,
      accountId: updatedAccount.id,
      creditLimitMinor: resolvedLimit.minor,
      creditLimitScale: resolvedLimit.scale,
      statementDay: statementDay ?? 1,
      paymentDueDays: paymentDueDays ?? 0,
      interestRateAnnual: interestRateAnnual ?? 0,
      createdAt: createdAt,
      updatedAt: now,
    );

    if (creditCardId == null && !wasCreditCard) {
      await _addCreditCardUseCase.call(creditCard);
      state = state.copyWith(creditCardId: creditCard.id);
      return;
    }

    await _updateCreditCardUseCase.call(creditCard);
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
