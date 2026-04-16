import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kopim/core/formatting/currency_symbols.dart';
import 'package:kopim/core/config/theme_extensions.dart';
import 'package:kopim/core/widgets/phosphor_icon_utils.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/home/domain/models/home_overview_summary.dart';
import 'package:kopim/features/home/presentation/controllers/home_providers.dart';
import 'package:kopim/features/profile/presentation/controllers/active_currency_code_provider.dart';
import 'package:kopim/features/transactions/presentation/widgets/transaction_tile_formatters.dart';
import 'package:kopim/l10n/app_localizations.dart';

const Color _overviewHighlightSurface = Color(0xFFD7FFD0);
const Color _overviewCategoryIconSurface = Color(0xFFE8FF94);

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

    const BorderRadius outerRadius = BorderRadius.all(Radius.circular(28));
    final Color cardBackground = theme.brightness == Brightness.dark
        ? theme.colorScheme.surfaceContainer
        : theme.colorScheme.secondaryContainer;

    return Material(
      color: cardBackground,
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
    final bool isDarkTheme = theme.brightness == Brightness.dark;
    final String currencyCode = ref.watch(activeCurrencyCodeProvider);
    final String currencySymbol = resolveCurrencySymbol(
      currencyCode,
      locale: strings.localeName,
    );
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
    final Color amountForeground = isDarkTheme
        ? theme.colorScheme.scrim
        : theme.colorScheme.onSurface;
    final Color cornerArrowColor = isDarkTheme
        ? _overviewHighlightSurface
        : theme.colorScheme.tertiary;
    final TextStyle balanceLabelStyle =
        theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
        ) ??
        TextStyle(color: theme.colorScheme.onPrimaryContainer);
    final TextStyle amountStyle =
        theme.textTheme.titleSmall?.copyWith(color: amountForeground) ??
        TextStyle(color: amountForeground);
    final TextStyle cardTitleStyle =
        theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
        ) ??
        TextStyle(color: theme.colorScheme.onPrimaryContainer);
    final TextStyle categoryLabelStyle =
        theme.textTheme.labelSmall?.copyWith(color: amountForeground) ??
        TextStyle(color: amountForeground);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double cardWidth = constraints.maxWidth;
        final double minHeroWidth = cardWidth < 220 ? cardWidth : 220;
        final double heroWidth = (cardWidth * 0.75).clamp(
          minHeroWidth,
          cardWidth,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(
              height: 104,
              child: Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: heroWidth,
                      child: _OverviewSurface(
                        backgroundColor: _overviewHighlightSurface,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              strings.homeOverviewTotalBalanceLabel,
                              style: balanceLabelStyle,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  balanceLabel,
                                  style: theme.textTheme.displayMedium
                                      ?.copyWith(color: amountForeground),
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    top: 4,
                    end: 4,
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: Center(
                        child: Icon(
                          Icons.arrow_outward,
                          color: cornerArrowColor,
                          size: layout.iconSizes.xl,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: layout.spacing.between),
            SizedBox(
              height: 100,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: _OverviewSurface(
                      backgroundColor: _overviewHighlightSurface,
                      borderRadius: const BorderRadius.all(Radius.circular(24)),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            strings.homeTransactionsTodayLabel,
                            style: cardTitleStyle,
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  incomeLabel,
                                  style: amountStyle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  expenseLabel,
                                  style: amountStyle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: layout.spacing.between),
                  Expanded(
                    flex: 3,
                    child: _OverviewSurface(
                      backgroundColor: _overviewHighlightSurface,
                      borderRadius: const BorderRadius.all(Radius.circular(24)),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            strings.homeOverviewTopExpensesLabel,
                            style: cardTitleStyle,
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: topExpense == null
                                ? Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      strings.homeOverviewTopExpensesEmpty,
                                      style: amountStyle,
                                    ),
                                  )
                                : Row(
                                    children: <Widget>[
                                      DecoratedBox(
                                        decoration: BoxDecoration(
                                          color: _overviewCategoryIconSurface,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: SizedBox(
                                          width: 48,
                                          height: 48,
                                          child: Center(
                                            child: Icon(
                                              resolvePhosphorIconData(
                                                    topCategory?.icon,
                                                  ) ??
                                                  Icons.category_outlined,
                                              color: amountForeground,
                                              size: layout.iconSizes.md,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              topCategoryName,
                                              style: categoryLabelStyle,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              topCategoryAmount,
                                              style: amountStyle,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _OverviewSurface extends StatelessWidget {
  const _OverviewSurface({
    required this.child,
    required this.backgroundColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.padding,
  });

  final Widget child;
  final Color backgroundColor;
  final BorderRadius borderRadius;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}
