import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kopim/core/utils/helpers.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/analytics/domain/models/analytics_category_breakdown.dart';
import 'package:kopim/features/analytics/domain/models/analytics_overview.dart';
import 'package:kopim/features/analytics/presentation/controllers/analytics_filter_controller.dart';
import 'package:kopim/features/analytics/presentation/controllers/analytics_providers.dart';
import 'package:kopim/features/app_shell/presentation/models/navigation_tab_content.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/l10n/app_localizations.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  static const String routeName = '/analytics';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final NavigationTabContent content = buildAnalyticsTabContent(context, ref);
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

NavigationTabContent buildAnalyticsTabContent(
  BuildContext context,
  WidgetRef ref,
) {
  final AppLocalizations strings = AppLocalizations.of(context)!;
  return NavigationTabContent(
    appBarBuilder: (BuildContext context, WidgetRef ref) =>
        AppBar(title: Text(strings.analyticsTitle)),
    bodyBuilder: (BuildContext context, WidgetRef ref) {
      final AsyncValue<AnalyticsOverview> overviewAsync = ref.watch(
        analyticsOverviewProvider(topCategoriesLimit: 6),
      );
      final AsyncValue<List<Category>> categoriesAsync = ref.watch(
        analyticsCategoriesProvider,
      );
      final AsyncValue<List<AccountEntity>> accountsAsync = ref.watch(
        analyticsAccountsProvider,
      );
      final AnalyticsFilterState filterState = ref.watch(
        analyticsFilterControllerProvider,
      );

      if (overviewAsync.isLoading ||
          categoriesAsync.isLoading ||
          accountsAsync.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      final Object? overviewError = overviewAsync.error;
      final Object? categoriesError = categoriesAsync.error;
      final Object? accountsError = accountsAsync.error;
      if (overviewError != null ||
          categoriesError != null ||
          accountsError != null) {
        final Object? error = overviewError ?? categoriesError ?? accountsError;
        return _AnalyticsError(message: error.toString(), strings: strings);
      }

      final AnalyticsOverview? overview = overviewAsync.value;
      final List<Category> categories =
          categoriesAsync.value ?? const <Category>[];
      final List<AccountEntity> accounts =
          accountsAsync.value ?? const <AccountEntity>[];

      if (overview == null ||
          (overview.totalIncome == 0 && overview.totalExpense == 0)) {
        return _AnalyticsEmpty(strings: strings);
      }

      return _AnalyticsContent(
        overview: overview,
        categories: categories,
        accounts: accounts,
        filterState: filterState,
        strings: strings,
      );
    },
  );
}

class _AnalyticsContent extends ConsumerWidget {
  const _AnalyticsContent({
    required this.overview,
    required this.categories,
    required this.accounts,
    required this.filterState,
    required this.strings,
  });

  final AnalyticsOverview overview;
  final List<Category> categories;
  final List<AccountEntity> accounts;
  final AnalyticsFilterState filterState;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final NumberFormat currencyFormat = NumberFormat.simpleCurrency(
      locale: strings.localeName,
    );
    final Map<String, Category> categoriesById = <String, Category>{
      for (final Category category in categories) category.id: category,
    };
    final double totalExpense = overview.totalExpense;
    final DateFormat dateRangeFormat = DateFormat.yMMMMd(strings.localeName);
    final String startLabel = dateRangeFormat.format(
      filterState.dateRange.start,
    );
    final String endLabel = dateRangeFormat.format(filterState.dateRange.end);
    final String rangeLabel = startLabel == endLabel
        ? startLabel
        : strings.analyticsFilterDateValue(startLabel, endLabel);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            strings.analyticsOverviewRangeTitle(rangeLabel),
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _AnalyticsFilterBar(
            filterState: filterState,
            accounts: accounts,
            categories: categories,
            strings: strings,
          ),
          const SizedBox(height: 24),
          _AnalyticsSummaryFrame(
            overview: overview,
            currencyFormat: currencyFormat,
            strings: strings,
          ),
          const SizedBox(height: 24),
          Text(
            strings.analyticsTopCategoriesTitle,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          if (overview.topExpenseCategories.isEmpty || totalExpense == 0)
            Text(
              strings.analyticsTopCategoriesEmpty,
              style: theme.textTheme.bodyMedium,
            )
          else
            _TopCategoriesSection(
              breakdowns: overview.topExpenseCategories,
              categoriesById: categoriesById,
              totalExpense: totalExpense,
              currencyFormat: currencyFormat,
              strings: strings,
            ),
        ],
      ),
    );
  }
}

class _AnalyticsSummaryFrame extends StatelessWidget {
  const _AnalyticsSummaryFrame({
    required this.overview,
    required this.currencyFormat,
    required this.strings,
  });

  final AnalyticsOverview overview;
  final NumberFormat currencyFormat;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<_SummaryEntry> entries = <_SummaryEntry>[
      _SummaryEntry(
        label: strings.analyticsSummaryIncomeLabel,
        value: overview.totalIncome,
        color: theme.colorScheme.primary,
      ),
      _SummaryEntry(
        label: strings.analyticsSummaryExpenseLabel,
        value: overview.totalExpense,
        color: theme.colorScheme.error,
      ),
      _SummaryEntry(
        label: strings.analyticsSummaryNetLabel,
        value: overview.netBalance,
        color: overview.netBalance >= 0
            ? theme.colorScheme.primary
            : theme.colorScheme.error,
      ),
    ];

    return Card(
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool isCompact = constraints.maxWidth < 520;
            if (isCompact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  for (
                    int index = 0;
                    index < entries.length;
                    index++
                  ) ...<Widget>[
                    _SummaryValue(
                      entry: entries[index],
                      currencyFormat: currencyFormat,
                      textAlign: TextAlign.start,
                    ),
                    if (index < entries.length - 1)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(height: 1),
                      ),
                  ],
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                for (
                  int index = 0;
                  index < entries.length;
                  index++
                ) ...<Widget>[
                  Expanded(
                    child: _SummaryValue(
                      entry: entries[index],
                      currencyFormat: currencyFormat,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (index < entries.length - 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        height: 64,
                        child: VerticalDivider(
                          width: 1,
                          color: theme.colorScheme.outlineVariant,
                        ),
                      ),
                    ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SummaryEntry {
  const _SummaryEntry({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;
}

class _SummaryValue extends StatelessWidget {
  const _SummaryValue({
    required this.entry,
    required this.currencyFormat,
    required this.textAlign,
  });

  final _SummaryEntry entry;
  final NumberFormat currencyFormat;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: textAlign == TextAlign.center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: <Widget>[
        Text(entry.label, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 8),
        Text(
          currencyFormat.format(entry.value),
          textAlign: textAlign,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: entry.color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _AnalyticsFilterBar extends ConsumerWidget {
  const _AnalyticsFilterBar({
    required this.filterState,
    required this.accounts,
    required this.categories,
    required this.strings,
  });

  final AnalyticsFilterState filterState;
  final List<AccountEntity> accounts;
  final List<Category> categories;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DateFormat dateFormat = DateFormat.yMMMd(strings.localeName);
    final String startText = dateFormat.format(filterState.dateRange.start);
    final String endText = dateFormat.format(filterState.dateRange.end);
    final String dateValue = startText == endText
        ? startText
        : strings.analyticsFilterDateValue(startText, endText);

    return Card(
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            FilledButton.tonal(
              onPressed: () async {
                final DateTimeRange? result = await showDateRangePicker(
                  context: context,
                  initialDateRange: filterState.dateRange,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(DateTime.now().year + 10, 12, 31),
                  locale: Locale(strings.localeName),
                );
                if (result == null) {
                  return;
                }
                ref
                    .read(analyticsFilterControllerProvider.notifier)
                    .updateDateRange(result);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(Icons.calendar_today_outlined, size: 18),
                  const SizedBox(width: 8),
                  Text('${strings.analyticsFilterDateLabel}: $dateValue'),
                ],
              ),
            ),
            SizedBox(
              width: 240,
              child: DropdownMenu<String?>(
                initialSelection: filterState.accountId,
                label: Text(strings.analyticsFilterAccountLabel),
                inputDecorationTheme: const InputDecorationTheme(
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                dropdownMenuEntries: <DropdownMenuEntry<String?>>[
                  DropdownMenuEntry<String?>(
                    value: null,
                    label: strings.analyticsFilterAccountAll,
                  ),
                  ...accounts.map((AccountEntity account) {
                    return DropdownMenuEntry<String?>(
                      value: account.id,
                      label: account.name,
                    );
                  }),
                ],
                onSelected: (String? value) {
                  ref
                      .read(analyticsFilterControllerProvider.notifier)
                      .updateAccount(value);
                },
              ),
            ),
            SizedBox(
              width: 240,
              child: DropdownMenu<String?>(
                initialSelection: filterState.categoryId,
                label: Text(strings.analyticsFilterCategoryLabel),
                inputDecorationTheme: const InputDecorationTheme(
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                dropdownMenuEntries: <DropdownMenuEntry<String?>>[
                  DropdownMenuEntry<String?>(
                    value: null,
                    label: strings.analyticsFilterCategoryAll,
                  ),
                  ...categories.map((Category category) {
                    return DropdownMenuEntry<String?>(
                      value: category.id,
                      label: category.name,
                    );
                  }),
                ],
                onSelected: (String? value) {
                  ref
                      .read(analyticsFilterControllerProvider.notifier)
                      .updateCategory(value);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopCategoriesSection extends StatelessWidget {
  const _TopCategoriesSection({
    required this.breakdowns,
    required this.categoriesById,
    required this.totalExpense,
    required this.currencyFormat,
    required this.strings,
  });

  final List<AnalyticsCategoryBreakdown> breakdowns;
  final Map<String, Category> categoriesById;
  final double totalExpense;
  final NumberFormat currencyFormat;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<_CategoryChartItem> items = breakdowns
        .map((AnalyticsCategoryBreakdown breakdown) {
          final Category? category = breakdown.categoryId == null
              ? null
              : categoriesById[breakdown.categoryId!];
          final Color color =
              parseHexColor(category?.color) ?? theme.colorScheme.primary;
          final String title =
              category?.name ?? strings.analyticsCategoryUncategorized;
          return _CategoryChartItem(
            title: title,
            amount: breakdown.amount,
            color: color,
          );
        })
        .toList(growable: false);

    final double maxAmount = items.fold<double>(
      0,
      (double previousValue, _CategoryChartItem item) =>
          math.max(previousValue, item.amount.abs()),
    );

    return Card(
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 220,
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final double chartHeight = math.max(
                    constraints.maxHeight - 48,
                    80,
                  );
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      for (final _CategoryChartItem item in items)
                        Expanded(
                          child: _BarColumn(
                            item: item,
                            maxAmount: maxAmount,
                            totalExpense: totalExpense,
                            currencyFormat: currencyFormat,
                            chartHeight: chartHeight,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items
                  .map(
                    (_CategoryChartItem item) => _CategoryLegendChip(
                      label: item.title,
                      color: item.color,
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarColumn extends StatelessWidget {
  const _BarColumn({
    required this.item,
    required this.maxAmount,
    required this.totalExpense,
    required this.currencyFormat,
    required this.chartHeight,
  });

  final _CategoryChartItem item;
  final double maxAmount;
  final double totalExpense;
  final NumberFormat currencyFormat;
  final double chartHeight;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double normalized = maxAmount == 0
        ? 0
        : (item.amount.abs() / maxAmount).clamp(0, 1);
    final double barHeight = chartHeight * normalized;
    final double percentage = totalExpense == 0
        ? 0
        : (item.amount / totalExpense * 100).clamp(0, 100);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Text(
          '${percentage.toStringAsFixed(0)}%',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        Container(
          height: barHeight,
          decoration: BoxDecoration(
            color: item.color,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          currencyFormat.format(item.amount),
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _CategoryChartItem {
  const _CategoryChartItem({
    required this.title,
    required this.amount,
    required this.color,
  });

  final String title;
  final double amount;
  final Color color;
}

class _CategoryLegendChip extends StatelessWidget {
  const _CategoryLegendChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Brightness brightness = ThemeData.estimateBrightnessForColor(color);
    final Color textColor = brightness == Brightness.dark
        ? Colors.white
        : Colors.black.withValues(alpha: 0.87);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _AnalyticsEmpty extends StatelessWidget {
  const _AnalyticsEmpty({required this.strings});

  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(strings.analyticsEmptyState, textAlign: TextAlign.center),
      ),
    );
  }
}

class _AnalyticsError extends StatelessWidget {
  const _AnalyticsError({required this.message, required this.strings});

  final String message;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          strings.analyticsLoadError(message),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.error,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
