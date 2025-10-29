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
    final NumberFormat percentFormat = NumberFormat.percentPattern(localeName)
      ..minimumFractionDigits = 0
      ..maximumFractionDigits = 0;

    final List<BudgetCategorySpend> chartItems = data
        .take(_maxCategoriesToShow)
        .toList(growable: false);
    final double maxReference = _resolveMaxReference(chartItems);
    final List<_CategoryChartMetrics> metrics = <_CategoryChartMetrics>[
      for (final BudgetCategorySpend item in chartItems)
        _CategoryChartMetrics.from(item, maxReference),
    ];

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
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
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double chartHeight =
                    _resolveChartHeight(constraints.maxWidth);
                final double maxBarHeight = math.max(
                  0,
                  chartHeight - _BudgetCategoryBar.extraHeight,
                );

                return SizedBox(
                  height: chartHeight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      for (final _CategoryChartMetrics item in metrics)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: _BudgetCategoryBar(
                              metrics: item,
                              maxBarHeight: maxBarHeight,
                              percentFormat: percentFormat,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _BudgetCategoryBreakdown(
              data: data,
              currencyFormat: currencyFormat,
              percentFormat: percentFormat,
              strings: strings,
            ),
          ],
        ),
      ),
    );
  }
}

double _resolveChartHeight(double maxWidth) {
  if (!maxWidth.isFinite || maxWidth <= 0) {
    return 260;
  }
  final double baseHeight = maxWidth * 0.72;
  return math.max(220, math.min(360, baseHeight));
}

double _resolveMaxReference(List<BudgetCategorySpend> items) {
  double reference = 0;
  for (final BudgetCategorySpend item in items) {
    final double candidate =
        (item.limit != null && item.limit! > 0) ? item.limit! : item.spent;
    reference = math.max(reference, candidate);
  }
  if (reference <= 0) {
    for (final BudgetCategorySpend item in items) {
      reference = math.max(reference, item.spent);
    }
  }
  return reference > 0 ? reference : 1;
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

class _CategoryChartMetrics {
  const _CategoryChartMetrics({
    required this.data,
    required this.limitFraction,
    required this.spentFractionWithinLimit,
    required this.utilization,
  });

  factory _CategoryChartMetrics.from(
    BudgetCategorySpend item,
    double maxReference,
  ) {
    final double safeReference = maxReference > 0 ? maxReference : 1;
    final double rawLimit =
        (item.limit != null && item.limit! > 0) ? item.limit! : item.spent;
    final double limitFraction = rawLimit > 0
        ? (rawLimit / safeReference).clamp(0, 1)
        : 0;

    double utilization = 0;
    double spentFractionWithinLimit = 0;
    if (item.limit != null && item.limit! > 0) {
      utilization = item.limit! == 0 ? 0 : item.spent / item.limit!;
      spentFractionWithinLimit =
          (item.limit! == 0) ? 0 : (item.spent / item.limit!).clamp(0, 1);
    } else if (rawLimit > 0) {
      utilization = rawLimit == 0 ? 0 : item.spent / rawLimit;
      spentFractionWithinLimit =
          rawLimit == 0 ? 0 : (item.spent / rawLimit).clamp(0, 1);
    }

    return _CategoryChartMetrics(
      data: item,
      limitFraction: limitFraction,
      spentFractionWithinLimit: spentFractionWithinLimit,
      utilization: utilization,
    );
  }

  final BudgetCategorySpend data;
  final double limitFraction;
  final double spentFractionWithinLimit;
  final double utilization;

  bool get hasLimit => data.limit != null && data.limit! > 0;
  bool get isExceeded => hasLimit && utilization > 1;
}

class _BudgetCategoryBreakdown extends StatelessWidget {
  const _BudgetCategoryBreakdown({
    required this.data,
    required this.currencyFormat,
    required this.percentFormat,
    required this.strings,
  });

  final List<BudgetCategorySpend> data;
  final NumberFormat currencyFormat;
  final NumberFormat percentFormat;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox.shrink();
    }

    final ThemeData theme = Theme.of(context);

    return Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        collapsedShape: const RoundedRectangleBorder(),
        shape: const RoundedRectangleBorder(),
        title: Text(
          strings.budgetsCategoryBreakdownTitle,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        children: <Widget>[
          const SizedBox(height: 8),
          for (int index = 0; index < data.length; index++) ...<Widget>[
            if (index > 0) const SizedBox(height: 14),
            _BudgetCategoryBreakdownTile(
              item: data[index],
              currencyFormat: currencyFormat,
              percentFormat: percentFormat,
              strings: strings,
            ),
          ],
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _BudgetCategoryBreakdownTile extends StatelessWidget {
  const _BudgetCategoryBreakdownTile({
    required this.item,
    required this.currencyFormat,
    required this.percentFormat,
    required this.strings,
  });

  final BudgetCategorySpend item;
  final NumberFormat currencyFormat;
  final NumberFormat percentFormat;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color categoryColor =
        parseHexColor(item.category.color) ?? theme.colorScheme.primary;
    final PhosphorIconData? iconData = resolvePhosphorIconData(
      item.category.icon,
    );
    final double limit = item.limit ?? 0;
    final bool hasLimit = limit > 0;
    final double utilization =
        hasLimit && limit != 0 ? item.spent / limit : 0;
    final bool exceeded = hasLimit && utilization > 1;
    final double progressWidthFactor =
        hasLimit && limit > 0 ? (item.spent / limit).clamp(0, 1) : 0;
    final String percentLabel = percentFormat.format(
      hasLimit
          ? (utilization.isFinite ? utilization.clamp(0, 9.99) : 0)
          : 0,
    );
    final TextStyle? baseAmountStyle = theme.textTheme.bodySmall;
    final TextStyle? spentStyle = exceeded
        ? baseAmountStyle?.copyWith(
            color: theme.colorScheme.error,
            fontWeight: FontWeight.w600,
          )
        : baseAmountStyle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            DecoratedBox(
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  iconData ?? PhosphorIconsRegular.squaresFour,
                  color: categoryColor,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.category.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: <Widget>[
                      Text(
                        '${strings.budgetsSpentLabel}: ${currencyFormat.format(item.spent)}',
                        style: spentStyle,
                      ),
                      if (hasLimit)
                        Text(
                          '${strings.budgetsLimitLabel}: ${currencyFormat.format(limit)}',
                          style: baseAmountStyle,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              percentLabel,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: exceeded
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            height: 8,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: <Widget>[
                Container(color: theme.colorScheme.surfaceContainerHighest),
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progressWidthFactor,
                  child: Container(color: categoryColor),
                ),
                if (exceeded)
                  Positioned(
                    right: 0,
                    child: Container(
                      width: 6,
                      height: 8,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error,
                        borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(999),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BudgetCategoryBar extends StatelessWidget {
  const _BudgetCategoryBar({
    required this.metrics,
    required this.maxBarHeight,
    required this.percentFormat,
  });

  final _CategoryChartMetrics metrics;
  final double maxBarHeight;
  final NumberFormat percentFormat;

  static const double extraHeight = 120;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color categoryColor =
        parseHexColor(metrics.data.category.color) ?? theme.colorScheme.primary;
    final PhosphorIconData? iconData = resolvePhosphorIconData(
      metrics.data.category.icon,
    );
    final double safeMaxBarHeight = math.max(0, maxBarHeight);
    final double backgroundHeight =
        safeMaxBarHeight * metrics.limitFraction.clamp(0, 1);
    final double foregroundHeight =
        backgroundHeight * metrics.spentFractionWithinLimit.clamp(0, 1);
    final String percentLabel = percentFormat.format(
      metrics.hasLimit
          ? metrics.utilization.isFinite
              ? metrics.utilization.clamp(0, 9.99)
              : 0
          : 0,
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Text(
          percentLabel,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: metrics.isExceeded
                ? theme.colorScheme.error
                : theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: safeMaxBarHeight,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: backgroundHeight,
              width: 40,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: <Widget>[
                    Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                    ),
                    FractionallySizedBox(
                      alignment: Alignment.bottomCenter,
                      heightFactor: backgroundHeight <= 0
                          ? 0
                          : metrics.spentFractionWithinLimit.clamp(0, 1),
                      child: Container(color: categoryColor),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              iconData ?? PhosphorIconsRegular.squaresFour,
              color: categoryColor,
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          metrics.data.category.name,
          style: theme.textTheme.labelMedium,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
