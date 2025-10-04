import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/budgets/domain/entities/budget.dart';
import 'package:kopim/features/budgets/domain/entities/budget_period.dart';
import 'package:kopim/features/budgets/domain/entities/budget_scope.dart';
import 'package:kopim/features/budgets/domain/use_cases/save_budget_use_case.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'budget_form_controller.freezed.dart';
part 'budget_form_controller.g.dart';

@immutable
class BudgetFormParams {
  const BudgetFormParams({this.initial});

  final Budget? initial;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is BudgetFormParams && other.initial == initial;
  }

  @override
  int get hashCode => initial.hashCode;
}

@freezed
abstract class BudgetFormState with _$BudgetFormState {
  const factory BudgetFormState({
    required String title,
    required String amountText,
    required BudgetPeriod period,
    required BudgetScope scope,
    required DateTime startDate,
    DateTime? endDate,
    @Default(<String>[]) List<String> categoryIds,
    @Default(<String>[]) List<String> accountIds,
    Budget? initialBudget,
    @Default(false) bool isSubmitting,
    String? errorMessage,
  }) = _BudgetFormState;
}

@riverpod
class BudgetFormController extends _$BudgetFormController {
  @override
  BudgetFormState build({BudgetFormParams params = const BudgetFormParams()}) {
    final Budget? initial = params.initial;
    if (initial != null) {
      return BudgetFormState(
        title: initial.title,
        amountText: initial.amount.toStringAsFixed(2),
        period: initial.period,
        scope: initial.scope,
        startDate: initial.startDate,
        endDate: initial.endDate,
        categoryIds: initial.categories,
        accountIds: initial.accounts,
        initialBudget: initial,
      );
    }
    final DateTime now = DateTime.now();
    return BudgetFormState(
      title: '',
      amountText: '0',
      period: BudgetPeriod.monthly,
      scope: BudgetScope.all,
      startDate: DateTime(now.year, now.month, now.day, 0, 1),
      endDate: null,
      categoryIds: const <String>[],
      accountIds: const <String>[],
      initialBudget: null,
    );
  }

  void setTitle(String value) {
    state = state.copyWith(title: value);
  }

  void setAmountText(String value) {
    state = state.copyWith(amountText: value);
  }

  void setPeriod(BudgetPeriod period) {
    state = state.copyWith(period: period);
  }

  void setScope(BudgetScope scope) {
    state = state.copyWith(scope: scope);
  }

  void setStartDate(DateTime date) {
    state = state.copyWith(startDate: _normalizeStart(date));
  }

  void setEndDate(DateTime? date) {
    state = state.copyWith(
      endDate: date != null ? _normalizeStart(date) : null,
    );
  }

  void toggleCategory(String categoryId) {
    final List<String> categories = List<String>.from(state.categoryIds);
    if (categories.contains(categoryId)) {
      categories.remove(categoryId);
    } else {
      categories.add(categoryId);
    }
    state = state.copyWith(categoryIds: categories);
  }

  void toggleAccount(String accountId) {
    final List<String> accounts = List<String>.from(state.accountIds);
    if (accounts.contains(accountId)) {
      accounts.remove(accountId);
    } else {
      accounts.add(accountId);
    }
    state = state.copyWith(accountIds: accounts);
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
  }

  Future<bool> submit() async {
    final double? amount = double.tryParse(
      state.amountText.replaceAll(',', '.').trim(),
    );
    if (amount == null || amount <= 0) {
      state = state.copyWith(errorMessage: 'invalid_amount');
      return false;
    }
    if (state.title.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'missing_title');
      return false;
    }

    state = state.copyWith(isSubmitting: true, errorMessage: null);
    final SaveBudgetUseCase saveUseCase = ref.read(saveBudgetUseCaseProvider);
    final Uuid uuid = ref.read(uuidGeneratorProvider);
    final DateTime now = DateTime.now();

    final List<String> categories = state.scope == BudgetScope.byCategory
        ? state.categoryIds
        : const <String>[];
    final List<String> accounts = state.scope == BudgetScope.byAccount
        ? state.accountIds
        : const <String>[];

    final Budget budget = state.initialBudget != null
        ? state.initialBudget!.copyWith(
            title: state.title.trim(),
            period: state.period,
            scope: state.scope,
            startDate: _normalizeStart(state.startDate),
            endDate: state.endDate != null
                ? _normalizeStart(state.endDate!)
                : null,
            amount: amount,
            categories: categories,
            accounts: accounts,
            updatedAt: now,
          )
        : Budget(
            id: uuid.v4(),
            title: state.title.trim(),
            period: state.period,
            startDate: _normalizeStart(state.startDate),
            endDate: state.endDate != null
                ? _normalizeStart(state.endDate!)
                : null,
            amount: amount,
            scope: state.scope,
            categories: categories,
            accounts: accounts,
            createdAt: now,
            updatedAt: now,
          );

    try {
      await saveUseCase(budget);
      state = state.copyWith(isSubmitting: false, initialBudget: budget);
      return true;
    } catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: error.toString(),
      );
      return false;
    }
  }

  DateTime _normalizeStart(DateTime date) {
    return DateTime(date.year, date.month, date.day, 0, 1);
  }
}
