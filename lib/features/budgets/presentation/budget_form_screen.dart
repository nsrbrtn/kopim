import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/formatting/currency_symbols.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/core/widgets/kopim_dropdown_field.dart';
import 'package:kopim/core/widgets/kopim_text_field.dart';
import 'package:kopim/core/widgets/phosphor_icon_utils.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/budgets/domain/entities/budget.dart';
import 'package:kopim/features/budgets/domain/entities/budget_category_allocation.dart';
import 'package:kopim/features/budgets/domain/entities/budget_period.dart';
import 'package:kopim/features/budgets/domain/entities/budget_scope.dart';
import 'package:kopim/features/budgets/domain/services/budget_category_scope.dart';
import 'package:kopim/features/budgets/presentation/controllers/budget_form_controller.dart';
import 'package:kopim/features/budgets/presentation/controllers/budgets_providers.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/categories/domain/services/category_hierarchy.dart';
import 'package:kopim/features/categories/presentation/utils/category_gradients.dart';
import 'package:kopim/l10n/app_localizations.dart';

enum BudgetFormResult { saved, deleted }

class BudgetFormScreen extends ConsumerStatefulWidget {
  const BudgetFormScreen({this.initialBudget, super.key});

  final Budget? initialBudget;

  @override
  ConsumerState<BudgetFormScreen> createState() => _BudgetFormScreenState();
}

class _BudgetFormScreenState extends ConsumerState<BudgetFormScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  final Map<String, TextEditingController> _categoryAmountControllers =
      <String, TextEditingController>{};

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _amountController = TextEditingController();
    final BudgetFormParams params = BudgetFormParams(
      initial: widget.initialBudget,
    );
    final BudgetFormState state = ref.read(
      budgetFormControllerProvider(params: params),
    );
    _titleController.text = state.title;
    _amountController.text = state.amountText;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    for (final TextEditingController controller
        in _categoryAmountControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final BudgetFormParams params = BudgetFormParams(
      initial: widget.initialBudget,
    );
    final BudgetFormState state = ref.watch(
      budgetFormControllerProvider(params: params),
    );
    final BudgetFormController controller = ref.watch(
      budgetFormControllerProvider(params: params).notifier,
    );
    final AppLocalizations strings = AppLocalizations.of(context)!;

    ref.listen<BudgetFormState>(budgetFormControllerProvider(params: params), (
      BudgetFormState? previous,
      BudgetFormState next,
    ) {
      if (previous?.initialBudget != next.initialBudget) {
        _titleController.text = next.title;
        _amountController.text = next.amountText;
      }
      if (previous?.amountText != next.amountText &&
          _amountController.text != next.amountText) {
        _amountController.value = _amountController.value.copyWith(
          text: next.amountText,
          selection: TextSelection.collapsed(offset: next.amountText.length),
        );
      }
    });

    final AsyncValue<List<Category>> categoriesAsync = ref.watch(
      budgetCategoriesStreamProvider,
    );
    final AsyncValue<List<AccountEntity>> accountsAsync = ref.watch(
      budgetAccountsStreamProvider,
    );
    final List<Category> categories = _expenseCategories(
      categoriesAsync.value ?? const <Category>[],
    );
    _syncCategoryAmountControllers(state);

    if (state.scope == BudgetScope.byCategory && categories.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          controller.syncCategoryHierarchy(categories);
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          state.initialBudget == null
              ? strings.budgetCreateTitle
              : strings.budgetEditTitle,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _SectionLabel(strings.budgetTitleLabel),
              const SizedBox(height: 8),
              KopimTextField(
                controller: _titleController,
                placeholder: strings.budgetTitlePlaceholder,
                onChanged: controller.setTitle,
              ),
              const SizedBox(height: 16),
              _SectionLabel(strings.budgetPeriodLabelShort),
              const SizedBox(height: 8),
              KopimDropdownField<BudgetPeriod>(
                value: state.period,
                items: BudgetPeriod.values
                    .map(
                      (BudgetPeriod period) => DropdownMenuItem<BudgetPeriod>(
                        value: period,
                        child: Text(_periodLabel(strings, period)),
                      ),
                    )
                    .toList(growable: false),
                valueLabelBuilder: (BudgetPeriod? period) => period == null
                    ? strings.budgetPeriodLabelShort
                    : _periodLabel(strings, period),
                onChanged: controller.setPeriod,
              ),
              if (state.period == BudgetPeriod.custom) ...<Widget>[
                const SizedBox(height: 16),
                _DatePickerTile(
                  label: strings.budgetStartDateLabel,
                  value: state.startDate,
                  onSelected: (DateTime? date) {
                    if (date != null) {
                      controller.setStartDate(date);
                    }
                  },
                ),
                _DatePickerTile(
                  label: strings.budgetEndDateLabel,
                  value: state.endDate,
                  onSelected: controller.setEndDate,
                ),
              ],
              const SizedBox(height: 16),
              _SectionLabel(strings.budgetScopeLabel),
              const SizedBox(height: 8),
              KopimDropdownField<BudgetScope>(
                value: state.scope,
                items: BudgetScope.values
                    .map(
                      (BudgetScope scope) => DropdownMenuItem<BudgetScope>(
                        value: scope,
                        child: Text(_scopeLabel(strings, scope)),
                      ),
                    )
                    .toList(growable: false),
                valueLabelBuilder: (BudgetScope? scope) => scope == null
                    ? strings.budgetScopeLabel
                    : _scopeLabel(strings, scope),
                onChanged: controller.setScope,
              ),
              const SizedBox(height: 16),
              if (state.scope == BudgetScope.byCategory)
                categoriesAsync.when(
                  data: (List<Category> items) {
                    final List<Category> expenseItems = _expenseCategories(
                      items,
                    );
                    return _BudgetCategoryBudgetSection(
                      state: state,
                      categories: expenseItems,
                      controllers: _categoryAmountControllers,
                      placeholder: strings.budgetAmountPlaceholder,
                      localeName: strings.localeName,
                      onToggle: (Category category) =>
                          controller.toggleCategory(category, expenseItems),
                      onChanged: controller.setCategoryAmount,
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (Object error, StackTrace stackTrace) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(error.toString()),
                  ),
                ),
              if (state.scope == BudgetScope.byAccount)
                accountsAsync.when(
                  data: (List<AccountEntity> accounts) {
                    return _SelectionChips<AccountEntity>(
                      title: strings.budgetAccountsLabel,
                      values: accounts,
                      selectedValues: state.accountIds,
                      labelBuilder: (AccountEntity account) => account.name,
                      onToggle: (AccountEntity account) =>
                          controller.toggleAccount(account.id),
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (Object error, StackTrace stackTrace) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(error.toString()),
                  ),
                ),
              if (state.scope != BudgetScope.byCategory) ...<Widget>[
                _SectionLabel(strings.budgetAmountLabel),
                const SizedBox(height: 8),
                _BudgetAmountField(
                  controller: _amountController,
                  placeholder: strings.budgetAmountPlaceholder,
                  onChanged: controller.setAmountText,
                ),
              ],
              if (state.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: state.categoryLimitConflict != null
                      ? _BudgetCategoryConflictCard(
                          strings: strings,
                          categories: categories,
                          conflict: state.categoryLimitConflict!,
                          onIncreaseParent: () =>
                              controller.increaseParentLimitToChildSum(
                                state.categoryLimitConflict!.parentCategoryId,
                              ),
                          onRebalanceChildren: () =>
                              controller.rebalanceChildLimitsToParent(
                                state.categoryLimitConflict!.parentCategoryId,
                              ),
                        )
                      : Text(
                          _mapError(strings, state.errorMessage!),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                ),
              if (state.errorMessage != null &&
                  state.categoryLimitConflict != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    strings.budgetCategoryConflictDirectHint,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              const SizedBox(height: 24),
              if (state.initialBudget != null) ...<Widget>[
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: state.isSubmitting
                        ? null
                        : () => _deleteBudget(
                            context,
                            budgetId: state.initialBudget!.id,
                            strings: strings,
                          ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                    child: Text(strings.deleteButtonLabel),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: state.isSubmitting
                      ? null
                      : () async {
                          final bool success = await controller.submit(
                            categories,
                          );
                          if (success && context.mounted) {
                            Navigator.of(context).pop(BudgetFormResult.saved);
                          }
                        },
                  child: state.isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(strings.saveButtonLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _syncCategoryAmountControllers(BudgetFormState state) {
    final Set<String> selectedIds = state.categoryIds.toSet();
    final List<String> staleIds = _categoryAmountControllers.keys
        .where((String id) => !selectedIds.contains(id))
        .toList(growable: false);
    for (final String staleId in staleIds) {
      _categoryAmountControllers.remove(staleId)?.dispose();
    }
    for (final String categoryId in state.categoryIds) {
      final String text = state.categoryAmounts[categoryId] ?? '';
      final TextEditingController controller = _categoryAmountControllers
          .putIfAbsent(categoryId, () => TextEditingController(text: text));
      if (controller.text != text) {
        controller.value = controller.value.copyWith(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      }
    }
  }

  Future<void> _deleteBudget(
    BuildContext context, {
    required String budgetId,
    required AppLocalizations strings,
  }) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(strings.budgetDeleteTitle),
          content: Text(strings.budgetDeleteMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(strings.cancelButtonLabel),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(strings.deleteButtonLabel),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !context.mounted) {
      return;
    }
    await ref.read(deleteBudgetUseCaseProvider).call(budgetId);
    if (context.mounted) {
      Navigator.of(context).pop(BudgetFormResult.deleted);
    }
  }

  String _periodLabel(AppLocalizations strings, BudgetPeriod period) {
    switch (period) {
      case BudgetPeriod.monthly:
        return strings.budgetPeriodMonthly;
      case BudgetPeriod.weekly:
        return strings.budgetPeriodWeekly;
      case BudgetPeriod.custom:
        return strings.budgetPeriodCustom;
    }
  }

  String _scopeLabel(AppLocalizations strings, BudgetScope scope) {
    switch (scope) {
      case BudgetScope.all:
        return strings.budgetScopeAll;
      case BudgetScope.byCategory:
        return strings.budgetScopeByCategory;
      case BudgetScope.byAccount:
        return strings.budgetScopeByAccount;
    }
  }

  String _mapError(AppLocalizations strings, String code) {
    switch (code) {
      case 'invalid_amount':
        return strings.budgetErrorInvalidAmount;
      case 'missing_title':
        return strings.budgetErrorMissingTitle;
      case 'budget_subcategory_sum_exceeds_parent':
        return strings.budgetErrorCategoryChildrenExceedParent;
      case 'invalid_category_amount':
        return strings.budgetErrorInvalidCategoryAmount;
      default:
        return strings.genericErrorMessage;
    }
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.labelLarge);
  }
}

class _BudgetAmountField extends StatelessWidget {
  const _BudgetAmountField({
    required this.controller,
    required this.placeholder,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String placeholder;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return KopimTextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      placeholder: placeholder,
      onChanged: onChanged,
    );
  }
}

class _DatePickerTile extends StatelessWidget {
  const _DatePickerTile({
    required this.label,
    required this.value,
    required this.onSelected,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onSelected;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final DateFormat formatter = DateFormat.yMMMd(strings.localeName);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(
        value != null ? formatter.format(value!) : strings.budgetNoEndDateLabel,
      ),
      trailing: const Icon(Icons.calendar_today),
      onTap: () async {
        final DateTime initial = value ?? DateTime.now();
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: initial,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        onSelected(picked);
      },
    );
  }
}

class _SelectionChips<T> extends StatelessWidget {
  const _SelectionChips({
    required this.title,
    required this.values,
    required this.selectedValues,
    required this.labelBuilder,
    required this.onToggle,
  });

  final String title;
  final List<T> values;
  final List<String> selectedValues;
  final String Function(T value) labelBuilder;
  final void Function(T value) onToggle;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            for (final T value in values)
              FilterChip(
                label: Text(labelBuilder(value)),
                selected: selectedValues.contains(_extractId(value)),
                onSelected: (_) => onToggle(value),
              ),
          ],
        ),
      ],
    );
  }

  String _extractId(T value) {
    if (value is Category) {
      return value.id;
    }
    if (value is AccountEntity) {
      return value.id;
    }
    throw ArgumentError('Unsupported type $value');
  }
}

class _BudgetCategoryBudgetSection extends StatelessWidget {
  const _BudgetCategoryBudgetSection({
    required this.state,
    required this.categories,
    required this.controllers,
    required this.placeholder,
    required this.localeName,
    required this.onToggle,
    required this.onChanged,
  });

  final BudgetFormState state;
  final List<Category> categories;
  final Map<String, TextEditingController> controllers;
  final String placeholder;
  final String localeName;
  final void Function(Category category) onToggle;
  final void Function(String categoryId, String value) onChanged;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    final int scale = state.initialBudget?.amountScale ?? 2;
    final List<_BudgetCategoryTreeItem> items = _buildBudgetCategoryTreeItems(
      categories,
    );
    final Budget draftBudget = _buildDraftBudget(
      state: state,
      categories: categories,
      scale: scale,
    );
    final NumberFormat currencyFormat = resolveCurrencyFormat(
      locale: localeName,
      decimalDigits: scale,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          strings.budgetCategoryAllocationsTitle,
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        _BudgetCategoryGuidance(strings: strings),
        const SizedBox(height: 12),
        for (final _BudgetCategoryTreeItem item in items) ...<Widget>[
          _BudgetCategoryBudgetTile(
            item: item,
            selected: state.categoryIds.contains(item.category.id),
            controller: controllers[item.category.id],
            placeholder: placeholder,
            amountLabel: strings.budgetCategoryLimitLabel(item.category.name),
            summary: _buildCategorySummary(
              strings: strings,
              budget: draftBudget,
              categories: categories,
              categoryId: item.category.id,
              currencyFormat: currencyFormat,
            ),
            onTap: () => onToggle(item.category),
            onChanged: (String value) => onChanged(item.category.id, value),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Budget _buildDraftBudget({
    required BudgetFormState state,
    required List<Category> categories,
    required int scale,
  }) {
    final Set<String> normalizedIds = expandBudgetCategoryIds(
      categoryIds: state.categoryIds,
      categories: categories,
    );
    final List<BudgetCategoryAllocation> allocations =
        <BudgetCategoryAllocation>[];
    for (final String categoryId in state.categoryIds) {
      final MoneyAmount? amount = _parseDraftAmount(
        state.categoryAmounts[categoryId],
        scale,
      );
      if (amount == null || amount.minor <= BigInt.zero) {
        continue;
      }
      allocations.add(
        BudgetCategoryAllocation(
          categoryId: categoryId,
          limitMinor: amount.minor,
          limitScale: amount.scale,
        ),
      );
    }
    return Budget(
      id: state.initialBudget?.id ?? '',
      title: state.title,
      period: state.period,
      startDate: state.startDate,
      endDate: state.endDate,
      amountMinor: BigInt.zero,
      amountScale: scale,
      scope: BudgetScope.byCategory,
      categories: normalizedIds.toList(growable: false),
      accounts: state.accountIds,
      categoryAllocations: allocations,
      createdAt: state.initialBudget?.createdAt ?? state.startDate,
      updatedAt: state.initialBudget?.updatedAt ?? state.startDate,
    );
  }

  String? _buildCategorySummary({
    required AppLocalizations strings,
    required Budget budget,
    required List<Category> categories,
    required String categoryId,
    required NumberFormat currencyFormat,
  }) {
    final Map<String, BudgetCategoryAllocation> allocations =
        resolveBudgetAllocationMap(budget);
    final BudgetCategoryAllocation? allocation = allocations[categoryId];
    if (allocation == null) {
      return null;
    }
    final List<String> childAllocationIds =
        resolveBudgetExplicitChildCategoryIds(
          budget: budget,
          categories: categories,
          parentCategoryId: categoryId,
        );
    final BigInt childLimitMinor = childAllocationIds.fold<BigInt>(
      BigInt.zero,
      (BigInt sum, String childId) =>
          sum + (allocations[childId]?.limitMinor ?? BigInt.zero),
    );
    final BigInt remainingMinor = allocation.limitMinor - childLimitMinor;
    final bool hasVisibleChildren = categories.any(
      (Category item) => item.parentId == categoryId,
    );
    if (!hasVisibleChildren) {
      return null;
    }
    return '${strings.budgetCategoryNoSubcategoryLabel}: '
        '${currencyFormat.format(MoneyAmount(minor: remainingMinor > BigInt.zero ? remainingMinor : BigInt.zero, scale: allocation.limitScale).toDouble())}';
  }

  MoneyAmount? _parseDraftAmount(String? raw, int scale) {
    if (raw == null) {
      return null;
    }
    final String sanitized = raw
        .trim()
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll(',', '.');
    if (sanitized.isEmpty) {
      return null;
    }
    return tryParseMoneyAmount(input: sanitized, scale: scale);
  }
}

class _BudgetCategoryGuidance extends StatelessWidget {
  const _BudgetCategoryGuidance({required this.strings});

  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            strings.budgetCategoryExpensesOnlyHint,
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          Text(
            strings.budgetCategoryEnvelopeInfo,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 6),
          Text(
            strings.budgetCategorySubcategoryInfo,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 6),
          Text(
            strings.budgetCategoryNoSubcategoryInfo,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _BudgetCategoryBudgetTile extends StatelessWidget {
  const _BudgetCategoryBudgetTile({
    required this.item,
    required this.selected,
    required this.placeholder,
    required this.amountLabel,
    required this.onTap,
    required this.onChanged,
    this.controller,
    this.summary,
  });

  final _BudgetCategoryTreeItem item;
  final bool selected;
  final TextEditingController? controller;
  final String placeholder;
  final String amountLabel;
  final VoidCallback onTap;
  final ValueChanged<String> onChanged;
  final String? summary;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Category category = item.category;
    final bool isChild = item.depth > 0;
    final CategoryColorStyle colorStyle = resolveCategoryColorStyle(
      category.color,
    );
    final IconData iconData =
        resolvePhosphorIconData(category.icon) ?? Icons.category_outlined;
    final double leftPadding = 12 + (item.depth * 18);

    return Material(
      color: selected
          ? theme.colorScheme.primary.withValues(alpha: 0.08)
          : theme.colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: EdgeInsets.fromLTRB(leftPadding, 12, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: isChild ? 40 : 46,
                    height: isChild ? 40 : 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorStyle.backgroundGradient == null
                          ? colorStyle.sampleColor ??
                                theme.colorScheme.surfaceContainerHighest
                          : null,
                      gradient: colorStyle.backgroundGradient,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      iconData,
                      color: theme.colorScheme.onPrimary,
                      size: isChild ? 18 : 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      category.name,
                      style:
                          (isChild
                                  ? theme.textTheme.labelMedium
                                  : theme.textTheme.labelLarge)
                              ?.copyWith(color: theme.colorScheme.onSurface),
                    ),
                  ),
                  Icon(
                    selected
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: selected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline,
                  ),
                ],
              ),
              if (selected) ...<Widget>[
                const SizedBox(height: 12),
                Text(amountLabel, style: theme.textTheme.labelMedium),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: _BudgetAmountField(
                    controller: controller!,
                    placeholder: placeholder,
                    onChanged: onChanged,
                  ),
                ),
                if (summary != null) ...<Widget>[
                  const SizedBox(height: 8),
                  Text(summary!, style: theme.textTheme.bodySmall),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _BudgetCategoryConflictCard extends StatelessWidget {
  const _BudgetCategoryConflictCard({
    required this.strings,
    required this.categories,
    required this.conflict,
    required this.onIncreaseParent,
    required this.onRebalanceChildren,
  });

  final AppLocalizations strings;
  final List<Category> categories;
  final BudgetCategoryLimitConflict conflict;
  final VoidCallback onIncreaseParent;
  final VoidCallback onRebalanceChildren;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final NumberFormat currencyFormat = resolveCurrencyFormat(
      locale: strings.localeName,
      decimalDigits: conflict.scale,
    );
    final Category? parent = categories.firstWhereOrNull(
      (Category item) => item.id == conflict.parentCategoryId,
    );
    final String parentName = parent?.name ?? strings.budgetCategoriesLabel;
    final String parentAmount = currencyFormat.format(
      MoneyAmount(
        minor: conflict.parentLimitMinor,
        scale: conflict.scale,
      ).toDouble(),
    );
    final String childSumAmount = currencyFormat.format(
      MoneyAmount(
        minor: conflict.childLimitSumMinor,
        scale: conflict.scale,
      ).toDouble(),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            strings.budgetCategoryConflictTitle,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onErrorContainer,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            strings.budgetCategoryConflictMessage(
              parentName,
              parentAmount,
              childSumAmount,
            ),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onErrorContainer,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              FilledButton.tonal(
                onPressed: onIncreaseParent,
                child: Text(strings.budgetCategoryConflictIncreaseAction),
              ),
              OutlinedButton(
                onPressed: onRebalanceChildren,
                child: Text(strings.budgetCategoryConflictReduceChildrenAction),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BudgetCategoryTreeItem {
  const _BudgetCategoryTreeItem({required this.category, required this.depth});

  final Category category;
  final int depth;
}

List<_BudgetCategoryTreeItem> _buildBudgetCategoryTreeItems(
  List<Category> categories,
) {
  final CategoryHierarchy hierarchy = CategoryHierarchy(categories);
  final Map<String, Category> categoriesById = <String, Category>{
    for (final Category category in categories) category.id: category,
  };
  final Map<String, int> orderById = <String, int>{
    for (int index = 0; index < categories.length; index += 1)
      categories[index].id: index,
  };
  final List<_BudgetCategoryTreeItem> items = <_BudgetCategoryTreeItem>[];

  void visit(String categoryId, int depth) {
    final Category? category = categoriesById[categoryId];
    if (category == null) {
      return;
    }
    items.add(_BudgetCategoryTreeItem(category: category, depth: depth));
    final List<String> children = hierarchy.childrenOf(categoryId).toList()
      ..sort(
        (String a, String b) =>
            (orderById[a] ?? 0).compareTo(orderById[b] ?? 0),
      );
    for (final String childId in children) {
      visit(childId, depth + 1);
    }
  }

  final List<String> rootIds = hierarchy.rootIds.toList()
    ..sort(
      (String a, String b) => (orderById[a] ?? 0).compareTo(orderById[b] ?? 0),
    );
  for (final String rootId in rootIds) {
    visit(rootId, 0);
  }
  return items;
}

List<Category> _expenseCategories(List<Category> categories) {
  return categories
      .where(
        (Category category) => category.type.trim().toLowerCase() == 'expense',
      )
      .toList(growable: false);
}
