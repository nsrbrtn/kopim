import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kopim/core/config/theme_extensions.dart';
import 'package:kopim/core/widgets/phosphor_icon_utils.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/categories/presentation/utils/category_gradients.dart';
import 'package:kopim/features/home/domain/models/home_overview_summary.dart';
import 'package:kopim/features/home/presentation/controllers/home_providers.dart';
import 'package:kopim/features/transactions/presentation/widgets/transaction_tile_formatters.dart';
import 'package:kopim/l10n/app_localizations.dart';

class HomeOverviewSummaryCard extends ConsumerWidget {
  const HomeOverviewSummaryCard({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final KopimLayout layout = context.kopimLayout;
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final AsyncValue<HomeOverviewSummary> summaryAsync = ref.watch(
      homeOverviewSummaryProvider,
    );

    final BorderRadius outerRadius = BorderRadius.circular(layout.radius.xxl);

    return Material(
      color: theme.colorScheme.surfaceContainer,
      borderRadius: outerRadius,
      child: InkWell(
        borderRadius: outerRadius,
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(layout.spacing.between),
          child: summaryAsync.when(
            data: (HomeOverviewSummary summary) => _HomeOverviewSummaryContent(
              summary: summary,
              strings: strings,
              theme: theme,
              layout: layout,
            ),
            loading: () => SizedBox(
              height: 220,
              child: Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            error: (Object error, _) => SizedBox(
              height: 220,
              child: Center(
                child: Text(
                  strings.homeOverviewSummaryError(error.toString()),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeOverviewSummaryContent extends ConsumerWidget {
  const _HomeOverviewSummaryContent({
    required this.summary,
    required this.strings,
    required this.theme,
    required this.layout,
  });

  final HomeOverviewSummary summary;
  final AppLocalizations strings;
  final ThemeData theme;
  final KopimLayout layout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String currencySymbol = NumberFormat.simpleCurrency(
      locale: strings.localeName,
    ).currencySymbol;
    final NumberFormat currencyFormat = TransactionTileFormatters.currency(
      strings.localeName,
      currencySymbol,
      decimalDigits: 0,
    );
    final String balanceLabel = currencyFormat.format(
      summary.totalBalance.toDouble(),
    );

    final String incomeLabel = strings.homeOverviewIncomeValue(
      currencyFormat.format(summary.todayIncome.toDouble()),
    );
    final String expenseLabel = strings.homeOverviewExpenseValue(
      currencyFormat.format(summary.todayExpense.toDouble()),
    );

    final HomeTopExpenseCategory? topExpense = summary.topExpenseCategory;
    final String? topCategoryId = topExpense?.categoryId;
    final Category? topCategory = topCategoryId == null
        ? null
        : ref.watch(homeCategoryByIdProvider(topCategoryId));
    final String topCategoryName =
        topCategory?.name ?? strings.homeTransactionsUncategorized;
    final String topCategoryAmount = topExpense == null
        ? ''
        : strings.homeOverviewExpenseValue(
            currencyFormat.format(topExpense.amount.toDouble()),
          );
    final CategoryColorStyle categoryStyle = resolveCategoryColorStyle(
      topCategory?.color,
    );
    final Color iconForeground =
        categoryStyle.sampleColor ?? theme.colorScheme.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _OverviewSurface(
          layout: layout,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                strings.homeOverviewTotalBalanceLabel,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                balanceLabel,
                style: theme.textTheme.displayMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: layout.spacing.between),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: _OverviewSurface(
                padding: const EdgeInsets.all(16),
                layout: layout,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        strings.homeTransactionsTodayLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(incomeLabel, style: theme.textTheme.titleSmall),
                    const SizedBox(height: 8),
                    Text(expenseLabel, style: theme.textTheme.titleSmall),
                  ],
                ),
              ),
            ),
            SizedBox(width: layout.spacing.between),
            Expanded(
              child: _OverviewSurface(
                padding: const EdgeInsets.all(16),
                layout: layout,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        strings.homeOverviewTopExpensesLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (topExpense == null)
                      Text(
                        strings.homeOverviewTopExpensesEmpty,
                        style: theme.textTheme.titleSmall,
                      )
                    else
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Icon(
                                      resolvePhosphorIconData(
                                            topCategory?.icon,
                                          ) ??
                                          Icons.category_outlined,
                                      color: iconForeground,
                                      size: layout.iconSizes.md,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        topCategoryName,
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              color:
                                                  theme.colorScheme.onSurface,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  topCategoryAmount,
                                  style: theme.textTheme.titleSmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _OverviewSurface extends StatelessWidget {
  const _OverviewSurface({
    required this.child,
    required this.layout,
    this.padding,
  });

  final Widget child;
  final KopimLayout layout;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(layout.radius.card),
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.all(layout.spacing.between),
        child: child,
      ),
    );
  }
}
