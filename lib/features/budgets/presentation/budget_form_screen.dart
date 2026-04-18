import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/widgets/kopim_dropdown_field.dart';
import 'package:kopim/core/widgets/kopim_text_field.dart';
import 'package:kopim/core/widgets/phosphor_icon_utils.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/budgets/domain/entities/budget.dart';
import 'package:kopim/features/budgets/domain/entities/budget_period.dart';
import 'package:kopim/features/budgets/domain/entities/budget_scope.dart';
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
    final List<Category> categories =
        categoriesAsync.value ?? const <Category>[];
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
                  data: (List<Category> items) => _BudgetCategoryTreeSelector(
                    title: strings.budgetCategoriesLabel,
                    categories: items,
                    selectedCategoryIds: state.categoryIds,
                    onToggle: (Category category) =>
                        controller.toggleCategory(category, items),
                  ),
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
              if (state.scope == BudgetScope.byCategory) ...<Widget>[
                const SizedBox(height: 16),
                _BudgetCategoryAllocationSection(
                  categories: categories,
                  selectedCategoryIds: state.categoryIds,
                  controllers: _categoryAmountControllers,
                  placeholder: strings.budgetAmountPlaceholder,
                  onChanged: controller.setCategoryAmount,
                ),
              ],
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
                  child: Text(
                    _mapError(strings, state.errorMessage!),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
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

class _BudgetCategoryTreeSelector extends StatelessWidget {
  const _BudgetCategoryTreeSelector({
    required this.title,
    required this.categories,
    required this.selectedCategoryIds,
    required this.onToggle,
  });

  final String title;
  final List<Category> categories;
  final List<String> selectedCategoryIds;
  final void Function(Category category) onToggle;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<_BudgetCategoryTreeItem> items = _buildBudgetCategoryTreeItems(
      categories,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        for (final _BudgetCategoryTreeItem item in items) ...<Widget>[
          _BudgetCategoryTreeTile(
            item: item,
            selected: selectedCategoryIds.contains(item.category.id),
            onTap: () => onToggle(item.category),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _BudgetCategoryAllocationSection extends StatelessWidget {
  const _BudgetCategoryAllocationSection({
    required this.categories,
    required this.selectedCategoryIds,
    required this.controllers,
    required this.placeholder,
    required this.onChanged,
  });

  final List<Category> categories;
  final List<String> selectedCategoryIds;
  final Map<String, TextEditingController> controllers;
  final String placeholder;
  final void Function(String categoryId, String value) onChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<_BudgetCategoryTreeItem> selectedItems =
        _buildBudgetCategoryTreeItems(categories)
            .where(
              (_BudgetCategoryTreeItem item) =>
                  selectedCategoryIds.contains(item.category.id),
            )
            .toList(growable: false);
    if (selectedItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Лимиты по категориям', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        for (final _BudgetCategoryTreeItem item in selectedItems) ...<Widget>[
          Padding(
            padding: EdgeInsets.only(left: item.depth * 16),
            child: Text(item.category.name, style: theme.textTheme.labelMedium),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.only(left: item.depth * 16),
            child: _BudgetAmountField(
              controller: controllers[item.category.id]!,
              placeholder: placeholder,
              onChanged: (String value) => onChanged(item.category.id, value),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
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

class _BudgetCategoryTreeTile extends StatelessWidget {
  const _BudgetCategoryTreeTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _BudgetCategoryTreeItem item;
  final bool selected;
  final VoidCallback onTap;

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
          child: Row(
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
        ),
      ),
    );
  }
}
