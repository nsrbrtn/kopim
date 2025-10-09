import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:kopim/core/utils/helpers.dart';
import 'package:kopim/core/widgets/phosphor_icon_utils.dart';
import 'package:kopim/features/budgets/domain/entities/budget_progress.dart';
import 'package:kopim/features/budgets/presentation/budget_detail_screen.dart';
import 'package:kopim/features/budgets/presentation/controllers/budgets_providers.dart';
import 'package:kopim/features/budgets/presentation/widgets/budget_progress_indicator.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/categories/presentation/widgets/category_chip.dart';
import 'package:kopim/features/home/domain/entities/home_dashboard_preferences.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class HomeBudgetProgressCard extends ConsumerWidget {
  const HomeBudgetProgressCard({
    required this.preferences,
    required this.onConfigure,
    super.key,
  });

  final HomeDashboardPreferences preferences;
  final VoidCallback onConfigure;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations strings = AppLocalizations.of(context)!;

    final String? budgetId = preferences.budgetId;
    if (budgetId == null) {
      return Card(
        color: theme.colorScheme.surfaceContainerHigh,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                strings.homeBudgetWidgetTitle,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                strings.homeBudgetWidgetEmpty,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.tonalIcon(
                onPressed: onConfigure,
                icon: const Icon(Icons.settings_outlined),
                label: Text(strings.homeBudgetWidgetConfigureCta),
              ),
            ],
          ),
        ),
      );
    }

    final AsyncValue<BudgetProgress> progressAsync = ref.watch(
      budgetProgressByIdProvider(budgetId),
    );
    final AsyncValue<List<Category>> categoriesAsync = ref.watch(
      budgetCategoriesStreamProvider,
    );
    final AsyncValue<List<TransactionEntity>> transactionsAsync = ref.watch(
      budgetTransactionsByIdProvider(budgetId),
    );

    return Card(
      color: theme.colorScheme.surfaceContainerHigh,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: progressAsync.maybeWhen(
          data: (BudgetProgress progress) => () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    BudgetDetailScreen(budgetId: progress.budget.id),
              ),
            );
          },
          orElse: () => null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                strings.homeBudgetWidgetTitle,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              progressAsync.when(
                data: (BudgetProgress progress) {
                  final NumberFormat currencyFormat =
                      NumberFormat.simpleCurrency(locale: strings.localeName);
                  final double limit = progress.budget.amount;
                  final double spent = progress.spent;
                  final double remaining = progress.remaining;
                  final double ratio = progress.utilization.isFinite
                      ? progress.utilization.clamp(0, 2)
                      : 1.0;
                  final bool exceeded = progress.isExceeded;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        progress.budget.title,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      BudgetProgressIndicator(value: ratio, exceeded: exceeded),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          _BudgetStat(
                            label: strings.budgetsSpentLabel,
                            value: currencyFormat.format(spent),
                          ),
                          _BudgetStat(
                            label: strings.budgetsLimitLabel,
                            value: currencyFormat.format(limit),
                          ),
                          _BudgetStat(
                            label: exceeded
                                ? strings.budgetsExceededLabel
                                : strings.budgetsRemainingLabel,
                            value: currencyFormat.format(
                              exceeded ? (spent - limit) : remaining,
                            ),
                            valueStyle: exceeded
                                ? theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.error,
                                    fontWeight: FontWeight.w600,
                                  )
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _BudgetCategoriesBreakdown(
                        progress: progress,
                        categoriesAsync: categoriesAsync,
                        transactionsAsync: transactionsAsync,
                      ),
                    ],
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: LinearProgressIndicator(),
                ),
                error: (Object error, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      strings.homeBudgetWidgetMissing,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FilledButton.tonalIcon(
                      onPressed: onConfigure,
                      icon: const Icon(Icons.settings_outlined),
                      label: Text(strings.homeBudgetWidgetConfigureCta),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BudgetStat extends StatelessWidget {
  const _BudgetStat({
    required this.label,
    required this.value,
    this.valueStyle,
  });

  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(value, style: valueStyle ?? theme.textTheme.bodyMedium),
      ],
    );
  }
}

class _BudgetCategoriesBreakdown extends ConsumerWidget {
  const _BudgetCategoriesBreakdown({
    required this.progress,
    required this.categoriesAsync,
    required this.transactionsAsync,
  });

  final BudgetProgress progress;
  final AsyncValue<List<Category>> categoriesAsync;
  final AsyncValue<List<TransactionEntity>> transactionsAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations strings = AppLocalizations.of(context)!;

    return categoriesAsync.when(
      data: (List<Category> categories) {
        return transactionsAsync.when(
          data: (List<TransactionEntity> transactions) {
            final Map<String, Category> categoryMap = <String, Category>{
              for (final Category category in categories) category.id: category,
            };
            final Map<String, double> spentByCategory = <String, double>{};
            for (final TransactionEntity tx in transactions) {
              final String? categoryId = tx.categoryId;
              if (categoryId == null) continue;
              spentByCategory.update(
                categoryId,
                (double value) => value + tx.amount.abs(),
                ifAbsent: () => tx.amount.abs(),
              );
            }
            final Iterable<String> ids = progress.budget.categories.isNotEmpty
                ? progress.budget.categories
                : spentByCategory.keys;
            final List<_CategoryBreakdown> breakdowns = <_CategoryBreakdown>[];
            double denominator = progress.budget.amount > 0
                ? progress.budget.amount
                : spentByCategory.values.fold<double>(
                    0,
                    (double sum, double value) => sum + value,
                  );
            if (denominator <= 0) {
              denominator = 0;
            }
            for (final String id in ids) {
              final Category? category = categoryMap[id];
              if (category == null) {
                continue;
              }
              final double rawValue = spentByCategory[id] ?? 0;
              final double percent = denominator <= 0
                  ? 0
                  : (rawValue / denominator * 100).clamp(0, 100);
              breakdowns.add(
                _CategoryBreakdown(
                  category: category,
                  percent: percent.isFinite ? percent : 0,
                ),
              );
            }
            breakdowns.sort(
              (_CategoryBreakdown a, _CategoryBreakdown b) =>
                  b.percent.compareTo(a.percent),
            );
            if (breakdowns.isEmpty) {
              return Text(
                strings.homeBudgetWidgetCategoriesEmpty,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
                ),
              );
            }
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: breakdowns
                  .map(
                    (_CategoryBreakdown breakdown) =>
                        _BudgetCategoryChip(breakdown: breakdown),
                  )
                  .toList(growable: false),
            );
          },
          loading: () => const _BudgetChipsSkeleton(),
          error: (Object error, _) => Text(
            strings.genericErrorMessage,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        );
      },
      loading: () => const _BudgetChipsSkeleton(),
      error: (Object error, _) => Text(
        strings.genericErrorMessage,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.error,
        ),
      ),
    );
  }
}

class _BudgetChipsSkeleton extends StatelessWidget {
  const _BudgetChipsSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 32,
      child: Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

class _CategoryBreakdown {
  const _CategoryBreakdown({required this.category, required this.percent});

  final Category category;
  final double percent;
}

class _BudgetCategoryChip extends StatelessWidget {
  const _BudgetCategoryChip({required this.breakdown});

  final _CategoryBreakdown breakdown;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Category category = breakdown.category;
    final Color? baseColor = parseHexColor(category.color);
    final Color backgroundColor =
        baseColor ?? theme.colorScheme.surfaceContainerHighest;
    final Brightness brightness = ThemeData.estimateBrightnessForColor(
      backgroundColor,
    );
    final Color foregroundColor = brightness == Brightness.dark
        ? Colors.white
        : Colors.black87;
    final PhosphorIconData? iconData = resolvePhosphorIconData(category.icon);
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final NumberFormat percentFormat = NumberFormat.decimalPattern(
      strings.localeName,
    );
    final int roundedPercent = breakdown.percent.round();
    final String percentText = '${percentFormat.format(roundedPercent)}%';

    return CategoryChip(
      label: category.name,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      leading: Icon(iconData ?? PhosphorIconsLight.tag, size: 16),
      trailing: Text(
        percentText,
        style:
            theme.textTheme.labelSmall?.copyWith(
              color: foregroundColor.withValues(alpha: 0.88),
              fontWeight: FontWeight.w600,
            ) ??
            TextStyle(
              color: foregroundColor.withValues(alpha: 0.88),
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
      ),
    );
  }
}
