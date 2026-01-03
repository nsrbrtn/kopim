import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/budgets/domain/entities/budget.dart';
import 'package:kopim/features/budgets/domain/entities/budget_category_allocation.dart';
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
    @Default(<String, String>{}) Map<String, String> categoryAmounts,
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
      final Map<String, String> initialCategoryAmounts = <String, String>{
        for (final BudgetCategoryAllocation allocation
            in initial.categoryAllocations)
          allocation.categoryId: allocation.limit.toStringAsFixed(2),
      };
      final Set<String> categoryIds = <String>{
        ...initial.categories,
        ...initialCategoryAmounts.keys,
      };
      return BudgetFormState(
        title: initial.title,
        amountText: initial.amount.toStringAsFixed(2),
        period: initial.period,
        scope: initial.scope,
        startDate: initial.startDate,
        endDate: initial.endDate,
        categoryIds: categoryIds.toList(growable: false),
        accountIds: initial.accounts,
        categoryAmounts: initialCategoryAmounts,
        initialBudget: initial,
      );
    }
    final DateTime now = DateTime.now();
    return BudgetFormState(
      title: '',
      amountText: '',
      period: BudgetPeriod.monthly,
      scope: BudgetScope.all,
      startDate: DateTime(now.year, now.month, now.day),
      endDate: null,
      categoryIds: const <String>[],
      accountIds: const <String>[],
      categoryAmounts: const <String, String>{},
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
    final Map<String, String> categoryAmounts = state.categoryAmounts;
    if (scope == BudgetScope.byCategory) {
      state = state.copyWith(
        scope: scope,
        amountText: _formatCategoryTotal(categoryAmounts),
      );
    } else {
      state = state.copyWith(scope: scope);
    }
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
    final Map<String, String> categoryAmounts = Map<String, String>.from(
      state.categoryAmounts,
    );
    if (categories.contains(categoryId)) {
      categories.remove(categoryId);
      categoryAmounts.remove(categoryId);
    } else {
      categories.add(categoryId);
      categoryAmounts.putIfAbsent(categoryId, () => '');
    }
    state = state.copyWith(
      categoryIds: categories,
      categoryAmounts: categoryAmounts,
      amountText: state.scope == BudgetScope.byCategory
          ? _formatCategoryTotal(categoryAmounts)
          : state.amountText,
    );
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

  void updateCategoryAmount(String categoryId, String value) {
    final Map<String, String> categoryAmounts = Map<String, String>.from(
      state.categoryAmounts,
    );
    categoryAmounts[categoryId] = value;
    state = state.copyWith(
      categoryAmounts: categoryAmounts,
      amountText: state.scope == BudgetScope.byCategory
          ? _formatCategoryTotal(categoryAmounts)
          : state.amountText,
    );
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
  }

  Future<bool> submit() async {
    double? amount = double.tryParse(
      state.amountText.replaceAll(',', '.').trim(),
    );
    List<BudgetCategoryAllocation> categoryAllocations =
        const <BudgetCategoryAllocation>[];
    if (state.scope == BudgetScope.byCategory) {
      if (state.categoryIds.isEmpty) {
        state = state.copyWith(errorMessage: 'invalid_category_amount');
        return false;
      }
      final List<BudgetCategoryAllocation> allocations =
          <BudgetCategoryAllocation>[];
      for (final String categoryId in state.categoryIds) {
        final String raw = state.categoryAmounts[categoryId] ?? '';
        final double? limit = double.tryParse(raw.replaceAll(',', '.').trim());
        if (limit == null || limit <= 0) {
          state = state.copyWith(errorMessage: 'invalid_category_amount');
          return false;
        }
        allocations.add(
          BudgetCategoryAllocation(categoryId: categoryId, limit: limit),
        );
      }
      categoryAllocations = allocations;
      amount = allocations.fold<double>(
        0,
        (double previousValue, BudgetCategoryAllocation allocation) =>
            previousValue + allocation.limit,
      );
    }
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
            categoryAllocations: categoryAllocations,
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
            categoryAllocations: categoryAllocations,
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
    return DateTime(date.year, date.month, date.day);
  }

  String _formatCategoryTotal(Map<String, String> categoryAmounts) {
    if (categoryAmounts.isEmpty) {
      return '';
    }
    double total = 0;
    bool hasValue = false;
    for (final String value in categoryAmounts.values) {
      final String trimmed = value.replaceAll(',', '.').trim();
      if (trimmed.isEmpty) {
        continue;
      }
      final double? parsed = double.tryParse(trimmed);
      if (parsed != null && parsed >= 0) {
        total += parsed;
        hasValue = true;
      }
    }
    if (!hasValue) {
      return '';
    }
    return total.toStringAsFixed(2);
  }
}
