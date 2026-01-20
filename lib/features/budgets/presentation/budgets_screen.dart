import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kopim/core/config/theme_extensions.dart';
import 'package:kopim/core/widgets/animated_fab.dart';
import 'package:kopim/core/widgets/kopim_glass_fab.dart';
import 'package:kopim/features/app_shell/presentation/models/navigation_tab_content.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/budgets/domain/entities/budget.dart';
import 'package:kopim/features/budgets/domain/entities/budget_category_allocation.dart';
import 'package:kopim/features/budgets/domain/entities/budget_progress.dart';
import 'package:kopim/features/budgets/domain/use_cases/compute_budget_progress_use_case.dart';
import 'package:kopim/features/budgets/presentation/controllers/budgets_providers.dart';
import 'package:kopim/features/budgets/presentation/models/budget_category_spend.dart';
import 'package:kopim/features/budgets/presentation/widgets/budget_card.dart';
import 'package:kopim/features/budgets/presentation/budget_detail_screen.dart';
import 'package:kopim/features/budgets/presentation/budget_form_screen.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/l10n/app_localizations.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  static const String routeName = '/budgets';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final NavigationTabContent content = buildBudgetsTabContent(context, ref);
    return Scaffold(
      appBar: content.appBarBuilder?.call(context, ref),
      body: content.bodyBuilder(context, ref),
      floatingActionButton: content.floatingActionButtonBuilder?.call(
        context,
        ref,
      ),
    );
  }
}

List<BudgetCategorySpend> _computeBudgetCategorySpend({
  required Budget budget,
  required List<TransactionEntity> transactions,
  required List<Category> categories,
  required ComputeBudgetProgressUseCase compute,
}) {
  final List<TransactionEntity> scopedTransactions = compute.filterTransactions(
    budget: budget,
    transactions: transactions,
  );

  final Map<String, double> spentByCategory = <String, double>{};
  for (final TransactionEntity transaction in scopedTransactions) {
    if (transaction.type == TransactionType.income.storageValue) {
      continue;
    }
    final String? categoryId = transaction.categoryId;
    if (categoryId == null) {
      continue;
    }
    spentByCategory[categoryId] =
        (spentByCategory[categoryId] ?? 0) +
        transaction.amountValue.abs().toDouble();
  }

  final Set<String> categoryIds = <String>{
    ...spentByCategory.keys,
    ...budget.categories,
    ...budget.categoryAllocations.map(
      (BudgetCategoryAllocation allocation) => allocation.categoryId,
    ),
  };
  if (categoryIds.isEmpty) {
    return const <BudgetCategorySpend>[];
  }

  final List<BudgetCategorySpend> items = <BudgetCategorySpend>[];
  for (final String categoryId in categoryIds) {
    final Category? category = categories.firstWhereOrNull(
      (Category item) => item.id == categoryId,
    );
    if (category == null) {
      continue;
    }
    items.add(
      BudgetCategorySpend(
        category: category,
        spent: spentByCategory[categoryId] ?? 0,
        limit: resolveBudgetCategoryLimit(budget, categoryId),
      ),
    );
  }

  items.sort((BudgetCategorySpend a, BudgetCategorySpend b) {
    final int spentComparison = b.spent.compareTo(a.spent);
    if (spentComparison != 0) return spentComparison;
    return a.category.name.compareTo(b.category.name);
  });
  return items;
}

NavigationTabContent buildBudgetsTabContent(
  BuildContext context,
  WidgetRef ref,
) {
  final AppLocalizations strings = AppLocalizations.of(context)!;
  return NavigationTabContent(
    floatingActionButtonBuilder: (BuildContext context, WidgetRef ref) {
      final ColorScheme colorScheme = Theme.of(context).colorScheme;
      return AnimatedFab(
        child: KopimGlassFab(
          enableGradientHighlight: false,
          icon: Icon(Icons.add, color: colorScheme.primary),
          foregroundColor: colorScheme.primary,
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const BudgetFormScreen(),
              ),
            );
          },
        ),
      );
    },
    bodyBuilder: (BuildContext context, WidgetRef ref) {
      final KopimLayout layout = context.kopimLayout;
      final KopimSpacingScale spacing = layout.spacing;
      final AsyncValue<List<BudgetProgress>> budgetsAsync = ref.watch(
        budgetsWithProgressProvider,
      );
      final AsyncValue<List<TransactionEntity>> transactionsAsync = ref.watch(
        budgetTransactionsStreamProvider,
      );
      final AsyncValue<List<Category>> categoriesAsync = ref.watch(
        budgetCategoriesStreamProvider,
      );
      final ComputeBudgetProgressUseCase compute = ref.watch(
        computeBudgetProgressUseCaseProvider,
      );

      final bool isLoading =
          budgetsAsync.isLoading ||
          transactionsAsync.isLoading ||
          categoriesAsync.isLoading;
      final Object? error =
          budgetsAsync.error ??
          transactionsAsync.error ??
          categoriesAsync.error;

      final Widget content;
      if (isLoading) {
        content = const Center(child: CircularProgressIndicator());
      } else if (error != null) {
        content = _BudgetsErrorState(
          message: error.toString(),
          strings: strings,
        );
      } else {
        final List<BudgetProgress> items =
            budgetsAsync.value ?? const <BudgetProgress>[];
        if (items.isEmpty) {
          content = _BudgetsEmptyState(strings: strings);
        } else {
          final List<TransactionEntity> transactions =
              transactionsAsync.value ?? const <TransactionEntity>[];
          final List<Category> categories =
              categoriesAsync.value ?? const <Category>[];
          final List<Widget> budgetCards = <Widget>[];
          for (int index = 0; index < items.length; index++) {
            if (index > 0) {
              budgetCards.add(SizedBox(height: spacing.section));
            }
            final BudgetProgress progress = items[index];
            final List<BudgetCategorySpend> spendByCategory =
                _computeBudgetCategorySpend(
                  budget: progress.budget,
                  transactions: transactions,
                  categories: categories,
                  compute: compute,
                );
            budgetCards.add(
              BudgetCard(
                progress: progress,
                categorySpend: spendByCategory,
                onOpenDetails: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) =>
                          BudgetDetailScreen(budgetId: progress.budget.id),
                    ),
                  );
                },
                onEdit: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) =>
                          BudgetFormScreen(initialBudget: progress.budget),
                    ),
                  );
                },
                onDelete: () async {
                  final bool? confirmed = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(strings.budgetDeleteTitle),
                        content: Text(strings.budgetDeleteMessage),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text(strings.cancelButtonLabel),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text(strings.deleteButtonLabel),
                          ),
                        ],
                      );
                    },
                  );
                  if (confirmed != true) return;
                  await ref
                      .read(deleteBudgetUseCaseProvider)
                      .call(progress.budget.id);
                },
              ),
            );
          }
          final List<Widget> children = <Widget>[...budgetCards];
          content = ListView(
            padding: const EdgeInsets.only(top: 16, bottom: 16),
            children: children,
          );
        }
      }
      return SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(
                spacing.screen,
                spacing.section,
                spacing.screen,
                spacing.between,
              ),
              child: Text(
                strings.budgetsTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeBottom: true,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 80),
                  child: content,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _BudgetsEmptyState extends StatelessWidget {
  const _BudgetsEmptyState({required this.strings});

  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final KopimLayout layout = context.kopimLayout;
    final KopimSpacingScale spacing = layout.spacing;
    final KopimIconSizes iconSizes = layout.iconSizes;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: spacing.screen),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.pie_chart_outline,
              size: iconSizes.xl,
              color: theme.colorScheme.primary,
            ),
            SizedBox(height: spacing.section),
            Text(
              strings.budgetsEmptyTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacing.between),
            Text(
              strings.budgetsEmptyMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetsErrorState extends StatelessWidget {
  const _BudgetsErrorState({required this.message, required this.strings});

  final String message;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final KopimLayout layout = context.kopimLayout;
    final KopimSpacingScale spacing = layout.spacing;
    final KopimIconSizes iconSizes = layout.iconSizes;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: spacing.sectionLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.warning_amber_rounded,
              size: iconSizes.lg,
              color: theme.colorScheme.error,
            ),
            SizedBox(height: spacing.section),
            Text(
              strings.budgetsErrorTitle,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacing.between),
            Text(
              message,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
