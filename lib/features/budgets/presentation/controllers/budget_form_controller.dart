import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/budgets/domain/entities/budget.dart';
import 'package:kopim/features/budgets/domain/entities/budget_category_allocation.dart';
import 'package:kopim/features/budgets/domain/entities/budget_period.dart';
import 'package:kopim/features/budgets/domain/entities/budget_scope.dart';
import 'package:kopim/features/budgets/domain/services/budget_category_scope.dart';
import 'package:kopim/features/budgets/domain/use_cases/save_budget_use_case.dart';
import 'package:kopim/features/categories/domain/entities/category.dart'
    as budget_category;
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
      final Set<String> categoryIds = <String>{
        ...initial.categories,
        ...initial.categoryAllocations.map(
          (BudgetCategoryAllocation allocation) => allocation.categoryId,
        ),
      };
      return BudgetFormState(
        title: initial.title,
        amountText: initial.amountValue.toDouble().toStringAsFixed(
          initial.amountScale ?? 2,
        ),
        period: initial.period,
        scope: initial.scope,
        startDate: initial.startDate,
        endDate: initial.endDate,
        categoryIds: categoryIds.toList(growable: false),
        accountIds: initial.accounts,
        categoryAmounts: <String, String>{
          for (final BudgetCategoryAllocation allocation
              in initial.categoryAllocations)
            allocation.categoryId: allocation.limitValue
                .toDouble()
                .toStringAsFixed(allocation.limitScale),
        },
        initialBudget: initial,
      );
    }
    final DateTime now = DateTime.now();
    return BudgetFormState(
      title: '',
      amountText: '',
      period: BudgetPeriod.monthly,
      scope: BudgetScope.byCategory,
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
    state = state.copyWith(
      scope: scope,
      categoryAmounts: scope == BudgetScope.byCategory
          ? state.categoryAmounts
          : const <String, String>{},
    );
  }

  void setStartDate(DateTime date) {
    state = state.copyWith(startDate: _normalizeStart(date));
  }

  void setEndDate(DateTime? date) {
    state = state.copyWith(
      endDate: date != null ? _normalizeStart(date) : null,
    );
  }

  void syncCategoryHierarchy(List<budget_category.Category> categories) {
    final Set<String> normalized = expandBudgetCategoryIds(
      categoryIds: state.categoryIds,
      categories: categories,
    );
    if (setEquals(normalized, state.categoryIds.toSet())) {
      return;
    }
    final Map<String, String> normalizedAmounts = <String, String>{
      for (final String categoryId in normalized)
        if (state.categoryAmounts.containsKey(categoryId))
          categoryId: state.categoryAmounts[categoryId]!,
    };
    state = state.copyWith(
      categoryIds: normalized.toList(growable: false),
      categoryAmounts: normalizedAmounts,
    );
  }

  void toggleCategory(
    budget_category.Category category,
    List<budget_category.Category> categories,
  ) {
    final Set<String> descendants = expandBudgetCategoryIds(
      categoryIds: <String>[category.id],
      categories: categories,
    );
    final Set<String> selected = state.categoryIds.toSet();
    if (selected.contains(category.id)) {
      selected.removeAll(descendants);
    } else {
      selected.addAll(descendants);
    }
    final Map<String, String> categoryAmounts = <String, String>{
      for (final String categoryId in selected)
        categoryId: state.categoryAmounts[categoryId] ?? '',
    };
    state = state.copyWith(
      categoryIds: selected.toList(growable: false),
      categoryAmounts: categoryAmounts,
    );
  }

  void setCategoryAmount(String categoryId, String value) {
    final Map<String, String> categoryAmounts = <String, String>{
      ...state.categoryAmounts,
      categoryId: value,
    };
    state = state.copyWith(categoryAmounts: categoryAmounts);
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

  Future<bool> submit(
    List<budget_category.Category> availableCategories,
  ) async {
    final int scale = _resolveScale();
    if (state.scope == BudgetScope.byCategory) {
      if (state.categoryIds.isEmpty) {
        state = state.copyWith(errorMessage: 'invalid_category_amount');
        return false;
      }
    }
    if (state.title.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'missing_title');
      return false;
    }

    final List<BudgetCategoryAllocation> categoryAllocations =
        state.scope == BudgetScope.byCategory
        ? _buildCategoryAllocations(scale)
        : const <BudgetCategoryAllocation>[];

    if (state.scope == BudgetScope.byCategory &&
        !_isCategoryAllocationTreeValid(
          categories: availableCategories,
          allocations: categoryAllocations,
        )) {
      state = state.copyWith(errorMessage: 'invalid_category_amount');
      return false;
    }

    final MoneyAmount? amount = state.scope == BudgetScope.byCategory
        ? null
        : _parseAmount(state.amountText, scale);
    if (state.scope != BudgetScope.byCategory &&
        (amount == null || amount.minor <= BigInt.zero)) {
      state = state.copyWith(errorMessage: 'invalid_amount');
      return false;
    }

    state = state.copyWith(isSubmitting: true, errorMessage: null);
    final SaveBudgetUseCase saveUseCase = ref.read(saveBudgetUseCaseProvider);
    final Uuid uuid = ref.read(uuidGeneratorProvider);
    final DateTime now = DateTime.now();

    final List<String> selectedCategoryIds =
        state.scope == BudgetScope.byCategory
        ? state.categoryIds
        : const <String>[];
    final List<String> accounts = state.scope == BudgetScope.byAccount
        ? state.accountIds
        : const <String>[];

    final Budget categoryBudget = Budget(
      id: state.initialBudget?.id ?? '',
      title: state.title.trim(),
      period: state.period,
      startDate: _normalizeStart(state.startDate),
      endDate: state.endDate != null ? _normalizeStart(state.endDate!) : null,
      amountMinor: BigInt.zero,
      amountScale: scale,
      scope: state.scope,
      categories: state.categoryIds,
      accounts: accounts,
      categoryAllocations: categoryAllocations,
      createdAt: state.initialBudget?.createdAt ?? now,
      updatedAt: now,
    );
    final BigInt totalCategoryMinor =
        resolveBudgetAllocationRootIds(
          budget: categoryBudget,
          categories: availableCategories,
        ).fold<BigInt>(BigInt.zero, (BigInt sum, String categoryId) {
          final BudgetCategoryAllocation? allocation = categoryAllocations
              .where(
                (BudgetCategoryAllocation item) =>
                    item.categoryId == categoryId,
              )
              .firstOrNull;
          return sum + (allocation?.limitMinor ?? BigInt.zero);
        });
    final MoneyAmount effectiveAmount = state.scope == BudgetScope.byCategory
        ? MoneyAmount(minor: totalCategoryMinor, scale: scale)
        : amount!;

    final Budget budget = state.initialBudget != null
        ? state.initialBudget!.copyWith(
            title: state.title.trim(),
            period: state.period,
            scope: state.scope,
            startDate: _normalizeStart(state.startDate),
            endDate: state.endDate != null
                ? _normalizeStart(state.endDate!)
                : null,
            amountMinor: effectiveAmount.minor,
            amountScale: effectiveAmount.scale,
            categories: selectedCategoryIds,
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
            amountMinor: effectiveAmount.minor,
            amountScale: effectiveAmount.scale,
            scope: state.scope,
            categories: selectedCategoryIds,
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

  MoneyAmount? _parseAmount(String raw, int scale) {
    final String sanitized = raw
        .trim()
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll(',', '.');
    if (sanitized.isEmpty) {
      return null;
    }
    return tryParseMoneyAmount(input: sanitized, scale: scale);
  }

  int _resolveScale() {
    return state.initialBudget?.amountScale ?? 2;
  }

  List<BudgetCategoryAllocation> _buildCategoryAllocations(int scale) {
    final List<BudgetCategoryAllocation> allocations =
        <BudgetCategoryAllocation>[];
    for (final String categoryId in state.categoryIds) {
      final String raw = state.categoryAmounts[categoryId] ?? '';
      final MoneyAmount? parsed = _parseAmount(raw, scale);
      if (parsed == null || parsed.minor <= BigInt.zero) {
        continue;
      }
      allocations.add(
        BudgetCategoryAllocation(
          categoryId: categoryId,
          limitMinor: parsed.minor,
          limitScale: parsed.scale,
        ),
      );
    }
    return allocations;
  }

  bool _isCategoryAllocationTreeValid({
    required List<budget_category.Category> categories,
    required List<BudgetCategoryAllocation> allocations,
  }) {
    if (state.scope != BudgetScope.byCategory) {
      return true;
    }
    if (allocations.isEmpty) {
      return false;
    }

    final Budget draft = Budget(
      id: state.initialBudget?.id ?? '',
      title: state.title.trim(),
      period: state.period,
      startDate: _normalizeStart(state.startDate),
      endDate: state.endDate != null ? _normalizeStart(state.endDate!) : null,
      amountMinor: BigInt.zero,
      amountScale: _resolveScale(),
      scope: state.scope,
      categories: state.categoryIds,
      accounts: state.accountIds,
      categoryAllocations: allocations,
      createdAt: state.initialBudget?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final Set<String> selectedIds = state.categoryIds.toSet();
    final Set<String> explicitIds = allocations
        .map((BudgetCategoryAllocation allocation) => allocation.categoryId)
        .toSet();

    for (final String categoryId in selectedIds) {
      if (explicitIds.contains(categoryId)) {
        continue;
      }
      final String? explicitParentId = resolveBudgetExplicitParentCategoryId(
        budget: draft,
        categories: categories,
        categoryId: categoryId,
      );
      if (explicitParentId == null) {
        return false;
      }
    }

    for (final BudgetCategoryAllocation allocation in allocations) {
      final List<String> childAllocationIds =
          resolveBudgetExplicitChildCategoryIds(
            budget: draft,
            categories: categories,
            parentCategoryId: allocation.categoryId,
          );
      final BigInt allocatedToChildren = childAllocationIds.fold<BigInt>(
        BigInt.zero,
        (BigInt sum, String childId) {
          final BudgetCategoryAllocation childAllocation = allocations
              .firstWhere(
                (BudgetCategoryAllocation item) => item.categoryId == childId,
              );
          return sum + childAllocation.limitMinor;
        },
      );
      if (allocatedToChildren > allocation.limitMinor) {
        return false;
      }
    }

    return true;
  }
}
