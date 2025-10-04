import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/recurring_transactions/domain/entities/recurring_rule.dart';
import 'package:kopim/features/recurring_transactions/domain/use_cases/save_recurring_rule_use_case.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'recurring_rule_form_controller.freezed.dart';
part 'recurring_rule_form_controller.g.dart';

enum RecurringRuleTitleError { empty }

enum RecurringRuleAmountError { invalid }

enum RecurringRuleAccountError { missing }

enum RecurringRuleCategoryError { missing }

@freezed
abstract class RecurringRuleFormState with _$RecurringRuleFormState {
  const factory RecurringRuleFormState({
    @Default('') String title,
    @Default('') String amountInput,
    AccountEntity? account,
    String? accountId,
    Category? category,
    String? categoryId,
    @Default(TransactionType.expense) TransactionType type,
    required DateTime startDate,
    @Default(0) int applyHour,
    @Default(0) int applyMinute,
    @Default(false) bool autoPost,
    @Default(false) bool isSubmitting,
    @Default(false) bool submissionSuccess,
    @Default(false) bool isEditing,
    RecurringRule? initialRule,
    RecurringRuleTitleError? titleError,
    RecurringRuleAmountError? amountError,
    RecurringRuleAccountError? accountError,
    RecurringRuleCategoryError? categoryError,
    String? generalErrorMessage,
  }) = _RecurringRuleFormState;

  const RecurringRuleFormState._();

  DateTime get startDateTime => DateTime(
    startDate.year,
    startDate.month,
    startDate.day,
    applyHour,
    applyMinute,
  );
}

@riverpod
class RecurringRuleFormController extends _$RecurringRuleFormController {
  late final SaveRecurringRuleUseCase _saveRecurringRuleUseCase;
  late final Uuid _uuid;

  @override
  RecurringRuleFormState build({RecurringRule? initialRule}) {
    _saveRecurringRuleUseCase = ref.watch(saveRecurringRuleUseCaseProvider);
    _uuid = ref.watch(uuidGeneratorProvider);
    if (initialRule != null) {
      final DateTime referenceLocalDateTime =
          (initialRule.nextDueLocalDate ?? initialRule.startAt).toLocal();
      final double absoluteAmount = initialRule.amount.abs();
      final TransactionType initialType = initialRule.amount >= 0
          ? TransactionType.expense
          : TransactionType.income;
      return RecurringRuleFormState(
        title: initialRule.title,
        amountInput: _formatAmountInput(absoluteAmount),
        accountId: initialRule.accountId,
        categoryId: initialRule.categoryId,
        type: initialType,
        startDate: DateTime(
          referenceLocalDateTime.year,
          referenceLocalDateTime.month,
          referenceLocalDateTime.day,
        ),
        applyHour: initialRule.applyAtLocalHour,
        applyMinute: initialRule.applyAtLocalMinute,
        autoPost: initialRule.autoPost,
        isEditing: true,
        initialRule: initialRule,
      );
    }
    final DateTime now = DateTime.now();
    return RecurringRuleFormState(
      startDate: DateTime(now.year, now.month, now.day),
      applyHour: 0,
      applyMinute: 1,
      categoryId: null,
    );
  }

  void updateTitle(String value) {
    state = state.copyWith(
      title: value,
      titleError: null,
      submissionSuccess: false,
      generalErrorMessage: null,
    );
  }

  void updateAmount(String value) {
    state = state.copyWith(
      amountInput: value,
      amountError: null,
      submissionSuccess: false,
      generalErrorMessage: null,
    );
  }

  void updateAccount(AccountEntity? account) {
    state = state.copyWith(
      account: account,
      accountId: account?.id,
      accountError: null,
      submissionSuccess: false,
      generalErrorMessage: null,
    );
  }

  void updateCategory(Category? category) {
    state = state.copyWith(
      category: category,
      categoryId: category?.id,
      categoryError: null,
      submissionSuccess: false,
      generalErrorMessage: null,
    );
  }

  void updateType(TransactionType type) {
    state = state.copyWith(
      type: type,
      submissionSuccess: false,
      category: null,
      categoryId: null,
      categoryError: null,
    );
  }

  void updateStartDate(DateTime date) {
    state = state.copyWith(
      startDate: DateTime(date.year, date.month, date.day),
      submissionSuccess: false,
    );
  }

  void updateTime({required int hour, required int minute}) {
    state = state.copyWith(
      applyHour: hour,
      applyMinute: minute,
      submissionSuccess: false,
    );
  }

  void updateAutoPost(bool value) {
    state = state.copyWith(autoPost: value, submissionSuccess: false);
  }

  void acknowledgeSuccess() {
    if (state.submissionSuccess) {
      state = state.copyWith(submissionSuccess: false);
    }
  }

  Future<void> submit() async {
    if (state.isSubmitting) {
      return;
    }

    final String trimmedTitle = state.title.trim();
    RecurringRuleTitleError? titleError;
    if (trimmedTitle.isEmpty) {
      titleError = RecurringRuleTitleError.empty;
    }

    final double? parsedAmount = _parseAmount(state.amountInput);
    RecurringRuleAmountError? amountError;
    if (parsedAmount == null) {
      amountError = RecurringRuleAmountError.invalid;
    }

    final AccountEntity? account = state.account;
    RecurringRuleAccountError? accountError;
    if (account == null) {
      accountError = RecurringRuleAccountError.missing;
    }

    final Category? category = state.category;
    RecurringRuleCategoryError? categoryError;
    if (category == null) {
      categoryError = RecurringRuleCategoryError.missing;
    }

    if (titleError != null ||
        amountError != null ||
        accountError != null ||
        categoryError != null) {
      state = state.copyWith(
        titleError: titleError,
        amountError: amountError,
        accountError: accountError,
        categoryError: categoryError,
        submissionSuccess: false,
      );
      return;
    }

    state = state.copyWith(
      isSubmitting: true,
      submissionSuccess: false,
      titleError: null,
      amountError: null,
      accountError: null,
      generalErrorMessage: null,
    );

    final DateTime startDate = state.startDate;
    final DateTime startDateTimeLocal = state.startDateTime;
    final DateTime startAtUtc = DateTime.utc(
      startDate.year,
      startDate.month,
      startDate.day,
      state.applyHour,
      state.applyMinute,
    );
    final double amount = state.type == TransactionType.expense
        ? parsedAmount!
        : -parsedAmount!;
    final DateTime now = DateTime.now().toUtc();
    final RecurringRule? existingRule = state.initialRule;
    final RecurringRule rule;
    if (existingRule == null) {
      rule = RecurringRule(
        id: _uuid.v4(),
        title: trimmedTitle,
        accountId: account!.id,
        categoryId: category!.id,
        amount: amount,
        currency: account.currency,
        startAt: startAtUtc,
        timezone: 'Europe/Helsinki',
        rrule: 'FREQ=MONTHLY;INTERVAL=1;BYMONTHDAY=${startDate.day}',
        notes: null,
        dayOfMonth: startDate.day,
        applyAtLocalHour: state.applyHour,
        applyAtLocalMinute: state.applyMinute,
        lastRunAt: null,
        nextDueLocalDate: startDateTimeLocal,
        isActive: true,
        autoPost: state.autoPost,
        reminderMinutesBefore: null,
        shortMonthPolicy: RecurringRuleShortMonthPolicy.clipToLastDay,
        createdAt: now,
        updatedAt: now,
      );
    } else {
      rule = existingRule.copyWith(
        title: trimmedTitle,
        accountId: account!.id,
        categoryId: category!.id,
        amount: amount,
        currency: account.currency,
        startAt: startAtUtc,
        rrule: 'FREQ=MONTHLY;INTERVAL=1;BYMONTHDAY=${startDate.day}',
        timezone: 'Europe/Helsinki',
        dayOfMonth: startDate.day,
        applyAtLocalHour: state.applyHour,
        applyAtLocalMinute: state.applyMinute,
        nextDueLocalDate: startDateTimeLocal,
        autoPost: state.autoPost,
        updatedAt: now,
      );
    }

    try {
      await _saveRecurringRuleUseCase(rule);
      state = state.copyWith(
        isSubmitting: false,
        submissionSuccess: true,
        initialRule: rule,
        isEditing: existingRule != null,
      );
    } catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        generalErrorMessage: error.toString(),
        submissionSuccess: false,
      );
    }
  }

  double? _parseAmount(String input) {
    final String normalized = input.replaceAll(',', '.');
    final double? value = double.tryParse(normalized);
    if (value == null || value <= 0) {
      return null;
    }
    return value;
  }

  String _formatAmountInput(double value) {
    final String formatted = value.toStringAsFixed(2);
    if (!formatted.contains('.')) {
      return formatted;
    }
    String trimmed = formatted;
    while (trimmed.endsWith('0')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    if (trimmed.endsWith('.')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }
}

final StreamProvider<List<AccountEntity>> recurringRuleAccountsProvider =
    StreamProvider.autoDispose<List<AccountEntity>>((Ref ref) {
      return ref.watch(watchAccountsUseCaseProvider).call();
    });

final StreamProvider<List<Category>> recurringRuleCategoriesProvider =
    StreamProvider.autoDispose<List<Category>>((Ref ref) {
      return ref.watch(watchCategoriesUseCaseProvider).call();
    });
