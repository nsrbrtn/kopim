import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kopim/core/utils/helpers.dart';
import 'package:kopim/features/analytics/domain/models/analytics_category_breakdown.dart';
import 'package:kopim/features/analytics/domain/models/analytics_overview.dart';
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

      if (overviewAsync.isLoading || categoriesAsync.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      final Object? overviewError = overviewAsync.error;
      final Object? categoriesError = categoriesAsync.error;
      if (overviewError != null || categoriesError != null) {
        final Object? error = overviewError ?? categoriesError;
        return _AnalyticsError(message: error.toString(), strings: strings);
      }

      final AnalyticsOverview? overview = overviewAsync.value;
      final List<Category> categories =
          categoriesAsync.value ?? const <Category>[];

      if (overview == null ||
          (overview.totalIncome == 0 && overview.totalExpense == 0)) {
        return _AnalyticsEmpty(strings: strings);
      }

      return _AnalyticsContent(
        overview: overview,
        categories: categories,
        strings: strings,
      );
    },
  );
}

class _AnalyticsContent extends StatelessWidget {
  const _AnalyticsContent({
    required this.overview,
    required this.categories,
    required this.strings,
  });

  final AnalyticsOverview overview;
  final List<Category> categories;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final NumberFormat currencyFormat = NumberFormat.simpleCurrency(
      locale: strings.localeName,
    );
    final Map<String, Category> categoriesById = <String, Category>{
      for (final Category category in categories) category.id: category,
    };
    final double totalExpense = overview.totalExpense;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            strings.analyticsCurrentMonthTitle,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              _AnalyticsSummaryCard(
                label: strings.analyticsSummaryIncomeLabel,
                value: overview.totalIncome,
                currencyFormat: currencyFormat,
                valueColor: theme.colorScheme.primary,
              ),
              _AnalyticsSummaryCard(
                label: strings.analyticsSummaryExpenseLabel,
                value: overview.totalExpense,
                currencyFormat: currencyFormat,
                valueColor: theme.colorScheme.error,
              ),
              _AnalyticsSummaryCard(
                label: strings.analyticsSummaryNetLabel,
                value: overview.netBalance,
                currencyFormat: currencyFormat,
                valueColor: overview.netBalance >= 0
                    ? theme.colorScheme.primary
                    : theme.colorScheme.error,
              ),
            ],
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
            Column(
              children: overview.topExpenseCategories
                  .map((AnalyticsCategoryBreakdown breakdown) {
                    final Category? category = breakdown.categoryId == null
                        ? null
                        : categoriesById[breakdown.categoryId!];
                    final Color? categoryColor = parseHexColor(category?.color);
                    final double percentage =
                        (breakdown.amount / totalExpense) * 100;
                    final String title =
                        category?.name ??
                        strings.analyticsCategoryUncategorized;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _CategoryBreakdownTile(
                        title: title,
                        amount: breakdown.amount,
                        percentage: percentage,
                        currencyFormat: currencyFormat,
                        color: categoryColor,
                      ),
                    );
                  })
                  .toList(growable: false),
            ),
        ],
      ),
    );
  }
}

class _AnalyticsSummaryCard extends StatelessWidget {
  const _AnalyticsSummaryCard({
    required this.label,
    required this.value,
    required this.currencyFormat,
    required this.valueColor,
  });

  final String label;
  final double value;
  final NumberFormat currencyFormat;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 200, maxWidth: 320),
      child: Card(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(label, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 8),
              Text(
                currencyFormat.format(value),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: valueColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryBreakdownTile extends StatelessWidget {
  const _CategoryBreakdownTile({
    required this.title,
    required this.amount,
    required this.percentage,
    required this.currencyFormat,
    this.color,
  });

  final String title;
  final double amount;
  final double percentage;
  final NumberFormat currencyFormat;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color resolvedColor = color ?? theme.colorScheme.primary;
    final double normalizedValue = (percentage / 100).clamp(0, 1);

    return Card(
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 18,
                  backgroundColor: color ?? theme.colorScheme.surfaceVariant,
                  child: color == null
                      ? Icon(
                          Icons.category_outlined,
                          color: theme.colorScheme.onSurfaceVariant,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(title, style: theme.textTheme.bodyMedium)),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: normalizedValue,
              backgroundColor: theme.colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(resolvedColor),
            ),
            const SizedBox(height: 12),
            Text(
              currencyFormat.format(amount),
              style: theme.textTheme.titleMedium?.copyWith(
                color: resolvedColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
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
