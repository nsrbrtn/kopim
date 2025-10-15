import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kopim/core/utils/helpers.dart';
import 'package:kopim/core/widgets/phosphor_icon_utils.dart';
import 'package:kopim/features/budgets/presentation/models/budget_category_spend.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class BudgetCategorySpendingChartCard extends StatelessWidget {
  const BudgetCategorySpendingChartCard({
    super.key,
    required this.data,
    required this.localeName,
    required this.strings,
  });

  final List<BudgetCategorySpend> data;
  final String localeName;
  final AppLocalizations strings;

  static const int _maxCategoriesToShow = 6;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                strings.budgetsCategoryChartTitle,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Text(
                strings.homeBudgetWidgetCategoriesEmpty,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    final ThemeData theme = Theme.of(context);
    final NumberFormat currencyFormat = NumberFormat.simpleCurrency(
      locale: localeName,
    );
    final double maxSpent = data
        .map((BudgetCategorySpend item) => item.spent)
        .fold<double>(0, math.max);
    final List<BudgetCategorySpend> items = data
        .take(_maxCategoriesToShow)
        .toList(growable: false);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              strings.budgetsCategoryChartTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 240,
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final double maxBarHeight = math.max(
                    0,
                    constraints.maxHeight - 88,
                  );
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      for (final BudgetCategorySpend item in items)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: _BudgetCategoryBar(
                              item: item,
                              currencyFormat: currencyFormat,
                              maxBarHeight: maxBarHeight,
                              maxSpent: maxSpent,
                              strings: strings,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BudgetCategorySpendingChartSkeleton extends StatelessWidget {
  const BudgetCategorySpendingChartSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              AppLocalizations.of(context)!.budgetsCategoryChartTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 32),
            const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class BudgetCategorySpendingChartError extends StatelessWidget {
  const BudgetCategorySpendingChartError({
    super.key,
    required this.message,
    required this.strings,
  });

  final String message;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              strings.budgetsCategoryChartTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              strings.budgetsErrorTitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetCategoryBar extends StatelessWidget {
  const _BudgetCategoryBar({
    required this.item,
    required this.currencyFormat,
    required this.maxBarHeight,
    required this.maxSpent,
    required this.strings,
  });

  final BudgetCategorySpend item;
  final NumberFormat currencyFormat;
  final double maxBarHeight;
  final double maxSpent;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color baseColor =
        parseHexColor(item.category.color) ?? theme.colorScheme.primary;
    final PhosphorIconData? iconData = resolvePhosphorIconData(
      item.category.icon,
    );
    final double barHeight = maxSpent <= 0
        ? 0
        : (item.spent / maxSpent).clamp(0, 1) * maxBarHeight;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Text(
          currencyFormat.format(item.spent),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        if (item.limit != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${strings.budgetsLimitLabel}: ${currencyFormat.format(item.limit!)}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: 12),
        SizedBox(
          height: maxBarHeight,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              height: math.max(0, barHeight),
              width: 36,
              decoration: BoxDecoration(
                color: baseColor.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(12),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: baseColor.withValues(alpha: 0.24),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        DecoratedBox(
          decoration: BoxDecoration(
            color: baseColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              iconData ?? PhosphorIconsRegular.squaresFour,
              color: baseColor,
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          item.category.name,
          style: theme.textTheme.labelMedium,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
