import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:kopim/core/utils/helpers.dart';
import 'package:kopim/core/widgets/kopim_text_field.dart';
import 'package:kopim/core/widgets/phosphor_icon_utils.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/budgets/domain/entities/budget.dart';
import 'package:kopim/features/budgets/domain/entities/budget_period.dart';
import 'package:kopim/features/budgets/domain/entities/budget_scope.dart';
import 'package:kopim/features/budgets/presentation/controllers/budget_form_controller.dart';
import 'package:kopim/features/budgets/presentation/controllers/budgets_providers.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/l10n/app_localizations.dart';

class BudgetFormScreen extends ConsumerStatefulWidget {
  const BudgetFormScreen({this.initialBudget, super.key});

  final Budget? initialBudget;

  @override
  ConsumerState<BudgetFormScreen> createState() => _BudgetFormScreenState();
}

class _BudgetFormScreenState extends ConsumerState<BudgetFormScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  final Map<String, TextEditingController> _categoryControllers =
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
        in _categoryControllers.values) {
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
    _syncCategoryControllers(state);
    final NumberFormat currencyFormat = NumberFormat.simpleCurrency(
      locale: strings.localeName,
    );

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
              Text(
                strings.budgetTitleLabel,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              KopimTextField(
                controller: _titleController,
                placeholder: strings.budgetTitleLabel,
                onChanged: controller.setTitle,
              ),
              const SizedBox(height: 16),
              Text(
                strings.budgetAmountLabel,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              KopimTextField(
                controller: _amountController,
                readOnly: state.scope == BudgetScope.byCategory,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                placeholder: strings.budgetAmountLabel,
                supportingText: state.scope == BudgetScope.byCategory
                    ? strings.budgetAmountAutoHelper
                    : currencyFormat.currencySymbol,
                onChanged: state.scope == BudgetScope.byCategory
                    ? null
                    : controller.setAmountText,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<BudgetPeriod>(
                initialValue: state.period,
                items: BudgetPeriod.values
                    .map(
                      (BudgetPeriod period) => DropdownMenuItem<BudgetPeriod>(
                        value: period,
                        child: Text(_periodLabel(strings, period)),
                      ),
                    )
                    .toList(),
                onChanged: (BudgetPeriod? value) {
                  if (value != null) {
                    controller.setPeriod(value);
                  }
                },
                decoration: InputDecoration(
                  labelText: strings.budgetPeriodLabelShort,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<BudgetScope>(
                initialValue: state.scope,
                items: BudgetScope.values
                    .map(
                      (BudgetScope scope) => DropdownMenuItem<BudgetScope>(
                        value: scope,
                        child: Text(_scopeLabel(strings, scope)),
                      ),
                    )
                    .toList(),
                onChanged: (BudgetScope? value) {
                  if (value != null) {
                    controller.setScope(value);
                  }
                },
                decoration: InputDecoration(
                  labelText: strings.budgetScopeLabel,
                ),
              ),
              const SizedBox(height: 16),
              if (state.period == BudgetPeriod.custom)
                _DatePickerTile(
                  label: strings.budgetStartDateLabel,
                  value: state.startDate,
                  onSelected: (DateTime? date) {
                    if (date != null) {
                      controller.setStartDate(date);
                    }
                  },
                ),
              if (state.period == BudgetPeriod.custom)
                _DatePickerTile(
                  label: strings.budgetEndDateLabel,
                  value: state.endDate,
                  onSelected: controller.setEndDate,
                ),
              const SizedBox(height: 16),
              if (state.scope == BudgetScope.byCategory)
                categoriesAsync.when(
                  data: (List<Category> categories) {
                    final Map<String, Category> categoriesById =
                        <String, Category>{
                          for (final Category category in categories)
                            category.id: category,
                        };
                    final List<Category> selectedCategories = state.categoryIds
                        .map((String id) => categoriesById[id])
                        .whereType<Category>()
                        .toList(growable: false);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _SelectionChips<Category>(
                          title: strings.budgetCategoriesLabel,
                          values: categories,
                          selectedValues: state.categoryIds,
                          labelBuilder: (Category category) => category.name,
                          onToggle: (Category category) =>
                              controller.toggleCategory(category.id),
                        ),
                        if (selectedCategories.isNotEmpty) ...<Widget>[
                          const SizedBox(height: 16),
                          _CategoryAllocationsEditor(
                            title: strings.budgetCategoryAllocationsTitle,
                            categories: selectedCategories,
                            controllers: _categoryControllers,
                            onChanged: controller.updateCategoryAmount,
                            strings: strings,
                          ),
                        ],
                      ],
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
              if (state.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    _mapError(strings, state.errorMessage!),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: state.isSubmitting
                      ? null
                      : () async {
                          final bool success = await controller.submit();
                          if (success && context.mounted) {
                            Navigator.of(context).pop();
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

  void _syncCategoryControllers(BudgetFormState state) {
    final Set<String> ids = state.categoryIds.toSet();
    final List<String> toRemove = _categoryControllers.keys
        .where((String key) => !ids.contains(key))
        .toList(growable: false);
    for (final String key in toRemove) {
      _categoryControllers.remove(key)?.dispose();
    }
    for (final String id in ids) {
      final String value = state.categoryAmounts[id] ?? '';
      final TextEditingController controller =
          _categoryControllers[id] ?? TextEditingController();
      if (!_categoryControllers.containsKey(id)) {
        _categoryControllers[id] = controller;
      }
      if (controller.text != value) {
        controller.value = controller.value.copyWith(
          text: value,
          selection: TextSelection.collapsed(offset: value.length),
        );
      }
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
      case 'invalid_category_amount':
        return strings.budgetErrorInvalidCategoryAmount;
      default:
        return strings.genericErrorMessage;
    }
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
        final DateTime firstDate = DateTime(2000);
        final DateTime lastDate = DateTime(2100);
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: initial,
          firstDate: firstDate,
          lastDate: lastDate,
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

class _CategoryAllocationsEditor extends StatelessWidget {
  const _CategoryAllocationsEditor({
    required this.title,
    required this.categories,
    required this.controllers,
    required this.onChanged,
    required this.strings,
  });

  final String title;
  final List<Category> categories;
  final Map<String, TextEditingController> controllers;
  final void Function(String categoryId, String value) onChanged;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Column(
          children: categories
              .map((Category category) {
                final TextEditingController controller =
                    controllers[category.id]!;
                final Color? background = parseHexColor(category.color);
                final Color foreground = background != null
                    ? (ThemeData.estimateBrightnessForColor(background) ==
                              Brightness.dark
                          ? Colors.white
                          : Colors.black87)
                    : theme.colorScheme.onSurfaceVariant;
                final IconData? iconData = resolvePhosphorIconData(
                  category.icon,
                );
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      CircleAvatar(
                        backgroundColor:
                            background ??
                            theme.colorScheme.surfaceContainerHighest,
                        foregroundColor: foreground,
                        child: iconData != null
                            ? Icon(iconData, size: 20)
                            : const Icon(Icons.category_outlined, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: controller,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: strings.budgetCategoryLimitLabel(
                              category.name,
                            ),
                          ),
                          onChanged: (String value) =>
                              onChanged(category.id, value),
                        ),
                      ),
                    ],
                  ),
                );
              })
              .toList(growable: false),
        ),
      ],
    );
  }
}
