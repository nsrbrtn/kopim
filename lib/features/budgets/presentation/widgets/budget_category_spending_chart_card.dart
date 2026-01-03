import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kopim/core/config/theme_extensions.dart';
import 'package:kopim/core/widgets/phosphor_icon_utils.dart';
import 'package:kopim/features/budgets/presentation/models/budget_category_spend.dart';
import 'package:kopim/features/categories/presentation/utils/category_gradients.dart';
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

  @override
  Widget build(BuildContext context) {
    final KopimLayout layout = context.kopimLayout;
    final KopimSpacingScale spacing = layout.spacing;
    return BudgetCategorySpendingView(
      data: data,
      localeName: localeName,
      strings: strings,
      wrapWithContainers: true,
      padding: EdgeInsets.symmetric(horizontal: spacing.screen),
    );
  }
}

class BudgetCategorySpendingView extends StatelessWidget {
  const BudgetCategorySpendingView({
    super.key,
    required this.data,
    required this.localeName,
    required this.strings,
    this.wrapWithContainers = false,
    this.padding,
    this.showSectionTitles = true,
  });

  final List<BudgetCategorySpend> data;
  final String localeName;
  final AppLocalizations strings;
  final bool wrapWithContainers;
  final EdgeInsetsGeometry? padding;
  final bool showSectionTitles;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final KopimSpacingScale spacing = context.kopimLayout.spacing;
    final EdgeInsetsGeometry resolvedPadding = padding ?? EdgeInsets.zero;

    if (data.isEmpty) {
      final Widget empty = Text(
        strings.homeBudgetWidgetCategoriesEmpty,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
      if (wrapWithContainers) {
        return Padding(
          padding: resolvedPadding,
          child: _budgetSectionContainer(
            context: context,
            title: strings.budgetsCategoryChartTitle,
            child: empty,
          ),
        );
      }
      return Padding(padding: resolvedPadding, child: empty);
    }

    final NumberFormat currencyFormat = NumberFormat.simpleCurrency(
      locale: localeName,
    );
    final NumberFormat percentFormat = NumberFormat.percentPattern(localeName)
      ..minimumFractionDigits = 0
      ..maximumFractionDigits = 0;

    final List<BudgetCategorySpend> chartItems = data;
    final double maxReference = _resolveMaxReference(chartItems);
    final List<_CategoryChartMetrics> metrics = <_CategoryChartMetrics>[
      for (final BudgetCategorySpend item in chartItems)
        _CategoryChartMetrics.from(item, maxReference),
    ];

    final Widget chart = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double chartHeight = _resolveChartHeight(constraints.maxWidth);
        final double maxBarHeight = math.max(
          0,
          chartHeight - _BudgetCategoryBar.extraHeight,
        );

        return SizedBox(
          height: chartHeight,
          child: ScrollConfiguration(
            behavior: const ScrollBehavior().copyWith(overscroll: false),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: spacing.between),
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      for (
                        int index = 0;
                        index < metrics.length;
                        index++
                      ) ...<Widget>[
                        if (index > 0) SizedBox(width: spacing.section),
                        SizedBox(
                          width: 28,
                          child: _BudgetCategoryBar(
                            metrics: metrics[index],
                            maxBarHeight: maxBarHeight,
                            percentFormat: percentFormat,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    final Widget breakdown = _BudgetCategoryBreakdown(
      data: data,
      currencyFormat: currencyFormat,
      percentFormat: percentFormat,
      strings: strings,
    );

    final List<Widget> content = wrapWithContainers
        ? <Widget>[
            _budgetSectionContainer(
              context: context,
              title: strings.budgetsCategoryChartTitle,
              child: chart,
            ),
            SizedBox(height: spacing.between),
            _budgetSectionContainer(context: context, child: breakdown),
          ]
        : <Widget>[
            if (showSectionTitles)
              Text(
                strings.budgetsCategoryChartTitle,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            SizedBox(height: spacing.between),
            chart,
            SizedBox(height: spacing.sectionLarge),
            breakdown,
          ];

    return Padding(
      padding: resolvedPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: content,
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
    final double candidate = (item.limit != null && item.limit! > 0)
        ? item.limit!
        : item.spent;
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
    final KopimSpacingScale spacing = context.kopimLayout.spacing;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing.screen),
      child: _budgetSectionContainer(
        context: context,
        title: AppLocalizations.of(context)!.budgetsCategoryChartTitle,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: spacing.sectionLarge + spacing.section),
            const Center(child: CircularProgressIndicator()),
            SizedBox(height: spacing.sectionLarge),
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
    final KopimSpacingScale spacing = context.kopimLayout.spacing;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing.screen),
      child: _budgetSectionContainer(
        context: context,
        title: strings.budgetsCategoryChartTitle,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              strings.budgetsErrorTitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.error,
              ),
            ),
            SizedBox(height: spacing.between),
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

Widget _budgetSectionContainer({
  required BuildContext context,
  required Widget child,
  String? title,
}) {
  final ThemeData theme = Theme.of(context);
  final KopimLayout layout = context.kopimLayout;
  final KopimSpacingScale spacing = layout.spacing;

  return DecoratedBox(
    decoration: BoxDecoration(
      color: theme.colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(layout.radius.xxl),
      border: Border.all(
        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.28),
      ),
    ),
    child: Padding(
      padding: EdgeInsets.all(spacing.sectionLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (title != null) ...<Widget>[
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: spacing.between),
          ],
          child,
        ],
      ),
    ),
  );
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
    final double rawLimit = (item.limit != null && item.limit! > 0)
        ? item.limit!
        : item.spent;
    final double limitFraction = rawLimit > 0
        ? (rawLimit / safeReference).clamp(0, 1)
        : 0;

    double utilization = 0;
    double spentFractionWithinLimit = 0;
    if (item.limit != null && item.limit! > 0) {
      utilization = item.limit! == 0 ? 0 : item.spent / item.limit!;
      spentFractionWithinLimit = (item.limit! == 0)
          ? 0
          : (item.spent / item.limit!).clamp(0, 1);
    } else if (rawLimit > 0) {
      utilization = rawLimit == 0 ? 0 : item.spent / rawLimit;
      spentFractionWithinLimit = rawLimit == 0
          ? 0
          : (item.spent / rawLimit).clamp(0, 1);
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
    final KopimSpacingScale spacing = context.kopimLayout.spacing;

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
          SizedBox(height: spacing.between),
          for (int index = 0; index < data.length; index++) ...<Widget>[
            if (index > 0) SizedBox(height: spacing.section),
            _BudgetCategoryBreakdownTile(
              item: data[index],
              currencyFormat: currencyFormat,
              percentFormat: percentFormat,
              strings: strings,
            ),
          ],
          SizedBox(height: spacing.between / 2),
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
    final KopimSpacingScale spacing = context.kopimLayout.spacing;
    final Color categoryColor =
        resolveCategoryColorStyle(item.category.color).sampleColor ??
        theme.colorScheme.primary;
    final PhosphorIconData? iconData = resolvePhosphorIconData(
      item.category.icon,
    );
    final double limit = item.limit ?? 0;
    final bool hasLimit = limit > 0;
    final double utilization = hasLimit && limit != 0 ? item.spent / limit : 0;
    final bool exceeded = hasLimit && utilization > 1;
    final double progressWidthFactor = hasLimit && limit > 0
        ? (item.spent / limit).clamp(0, 1)
        : 0;
    final String percentLabel = percentFormat.format(
      hasLimit ? (utilization.isFinite ? utilization.clamp(0, 9.99) : 0) : 0,
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
                color: categoryColor,
                borderRadius: BorderRadius.circular(spacing.section),
              ),
              child: Padding(
                padding: EdgeInsets.all(spacing.between),
                child: Icon(
                  iconData ?? PhosphorIconsRegular.squaresFour,
                  color: theme.colorScheme.surface,
                  size: 22,
                ),
              ),
            ),
            SizedBox(width: spacing.between * 1.5),
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
                  SizedBox(height: spacing.between / 2),
                  Wrap(
                    spacing: spacing.between * 1.5,
                    runSpacing: spacing.between / 2,
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
            SizedBox(width: spacing.section),
            Text(
              percentLabel,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: exceeded
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        SizedBox(height: spacing.between),
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

  static const double extraHeight = 70;
  static const double _barWidth = 28;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final KopimLayout layout = context.kopimLayout;
    final KopimSpacingScale spacing = layout.spacing;
    final Color categoryColor =
        resolveCategoryColorStyle(metrics.data.category.color).sampleColor ??
        theme.colorScheme.primary;
    final PhosphorIconData? iconData = resolvePhosphorIconData(
      metrics.data.category.icon,
    );
    final double safeMaxBarHeight = math.max(0, maxBarHeight);
    final bool isExceeded = metrics.isExceeded && metrics.utilization.isFinite;
    final double baseFillFraction = metrics.spentFractionWithinLimit.clamp(
      0,
      1,
    );
    final double baseFillHeight = safeMaxBarHeight * baseFillFraction;
    final String percentLabel = percentFormat.format(
      metrics.hasLimit
          ? metrics.utilization.isFinite
                ? metrics.utilization.clamp(0, 9.99)
                : 0
          : 0,
    );
    final BorderRadiusGeometry barRadius = BorderRadius.circular(
      layout.radius.card,
    );
    final Color fillColor = isExceeded
        ? theme.colorScheme.error
        : categoryColor;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Text(
          percentLabel,
          style: (theme.textTheme.labelLarge ?? const TextStyle(fontSize: 14))
              .copyWith(
                fontSize: (theme.textTheme.labelLarge?.fontSize ?? 14) / 1.5,
                fontWeight: FontWeight.w700,
                color: isExceeded
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurface,
              ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: spacing.between),
        SizedBox(
          height: safeMaxBarHeight,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              Container(
                width: _barWidth,
                height: safeMaxBarHeight,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.18,
                    ),
                  ),
                  borderRadius: barRadius,
                ),
              ),
              if (baseFillHeight > 0)
                Positioned(
                  bottom: 0,
                  child: Container(
                    width: _barWidth,
                    height: baseFillHeight,
                    decoration: BoxDecoration(
                      color: fillColor,
                      borderRadius: barRadius,
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: spacing.section),
        DecoratedBox(
          decoration: BoxDecoration(
            color: categoryColor,
            borderRadius: BorderRadius.circular(layout.radius.card),
          ),
          child: Padding(
            padding: EdgeInsets.all(spacing.between / 2),
            child: Icon(
              iconData ?? PhosphorIconsRegular.squaresFour,
              color: theme.colorScheme.surface,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}
