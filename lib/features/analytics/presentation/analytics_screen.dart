import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kopim/core/config/theme_extensions.dart';
import 'package:kopim/core/widgets/phosphor_icon_utils.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/analytics/domain/models/analytics_category_breakdown.dart';
import 'package:kopim/features/analytics/domain/models/analytics_overview.dart';
import 'package:kopim/features/analytics/domain/models/monthly_balance_data.dart';
import 'package:kopim/features/analytics/presentation/controllers/analytics_filter_controller.dart';
import 'package:kopim/features/analytics/presentation/controllers/analytics_providers.dart';
import 'package:kopim/features/analytics/presentation/models/monthly_cashflow_data.dart';
import 'package:kopim/features/analytics/presentation/widgets/analytics_chart.dart';
import 'package:kopim/features/analytics/presentation/widgets/analytics_filter_chip.dart';
import 'package:kopim/features/analytics/presentation/widgets/monthly_cashflow_bar_chart_widget.dart';
import 'package:kopim/features/analytics/presentation/widgets/total_money_chart_widget.dart';
import 'package:kopim/features/app_shell/presentation/models/navigation_tab_content.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/categories/presentation/utils/category_gradients.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/presentation/widgets/transaction_list_tile.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

const String _othersCategoryKey = '_others';
const String _uncategorizedCategoryKey = '_uncategorized';
const String _transfersCategoryKey = '_transfers';
const String _creditPaymentsCategoryKey = '_credit_payments';
const Object _clearCategorySelection = Object();
const Object _customDateRangeSelection = Object();

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
  return NavigationTabContent(
    bodyBuilder: (BuildContext context, WidgetRef ref) =>
        const _AnalyticsBody(),
  );
}

class _AnalyticsBody extends ConsumerWidget {
  const _AnalyticsBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final AsyncValue<AnalyticsOverview> overviewAsync = ref.watch(
      analyticsFilteredStatsProvider(topCategoriesLimit: 5),
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
    final DateTime rangeAnchor =
        filterState.monthAnchor ?? filterState.dateRange.start;
    final DateTime statsAnchor =
        filterState.monthAnchor ?? filterState.dateRange.end;
    final DateTime currentMonthStart = DateTime(
      DateTime.now().year,
      DateTime.now().month,
    );
    final DateTime today = DateUtils.dateOnly(DateTime.now());
    final bool isMonthBased =
        filterState.period == AnalyticsPeriodPreset.thisMonth ||
        filterState.period == AnalyticsPeriodPreset.customMonth;
    final DateTime anchorForBounds = isMonthBased
        ? DateTime(rangeAnchor.year, rangeAnchor.month)
        : DateUtils.dateOnly(rangeAnchor);
    final bool canGoNextRange = isMonthBased
        ? anchorForBounds.isBefore(currentMonthStart)
        : filterState.dateRange.end.isBefore(today);
    final bool canGoPreviousRange = anchorForBounds.isAfter(DateTime(2000));

    final List<Category> categories =
        categoriesAsync.value ?? const <Category>[];
    final List<AccountEntity> accounts =
        accountsAsync.value ?? const <AccountEntity>[];
    final bool showFullScreenLoading =
        overviewAsync.isLoading && !overviewAsync.hasValue;

    final Object? error =
        overviewAsync.error ?? categoriesAsync.error ?? accountsAsync.error;
    final AnalyticsOverview? overview = overviewAsync.value;

    return SafeArea(
      bottom: false,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: <Widget>[
                Text(
                  strings.analyticsTitle,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: DefaultTabController(
              length: 4,
              child: NestedScrollView(
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                      final ThemeData theme = Theme.of(context);
                      return <Widget>[
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: _AnalyticsTabsHeaderDelegate(
                            backgroundColor: theme.scaffoldBackgroundColor,
                            tabBar: TabBar(
                              isScrollable: true,
                              tabAlignment: TabAlignment.start,
                              dividerColor: Colors.transparent,
                              indicatorColor: Colors.transparent,
                              labelColor: theme.colorScheme.primary,
                              unselectedLabelColor: theme.colorScheme.outline,
                              labelStyle: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              unselectedLabelStyle: theme.textTheme.labelLarge
                                  ?.copyWith(fontWeight: FontWeight.w500),
                              tabs: <Widget>[
                                Tab(
                                  text: strings.analyticsTabCategoriesSpending,
                                ),
                                Tab(text: strings.analyticsTabStatistics),
                                Tab(text: strings.creditsSegmentCredits),
                                Tab(text: strings.homeNavSavings),
                              ],
                            ),
                          ),
                        ),
                      ];
                    },
                body: TabBarView(
                  children: <Widget>[
                    _AnalyticsCategoriesTabView(
                      showFullScreenLoading: showFullScreenLoading,
                      error: error,
                      overview: overview,
                      categories: categories,
                      accounts: accounts,
                      filterState: filterState,
                      strings: strings,
                      activeAnchor: rangeAnchor,
                      canGoNextRange: canGoNextRange,
                      canGoPreviousRange: canGoPreviousRange,
                      onGoPreviousRange: () => ref
                          .read(analyticsFilterControllerProvider.notifier)
                          .goToPreviousRangeStep(),
                      onGoNextRange: () => ref
                          .read(analyticsFilterControllerProvider.notifier)
                          .goToNextRangeStep(),
                      onOpenMonthPicker: () => _openMonthPicker(
                        context: context,
                        ref: ref,
                        current:
                            filterState.monthAnchor ??
                            filterState.dateRange.start,
                        showMonthSelection:
                            filterState.period !=
                            AnalyticsPeriodPreset.customRange,
                      ),
                      onOpenAccountsPicker: () => _openAccountsPicker(
                        context: context,
                        ref: ref,
                        accounts: accounts,
                        selected: filterState.accountIds,
                        strings: strings,
                      ),
                      onOpenCategoryPicker: () => _openCategoryPicker(
                        context: context,
                        ref: ref,
                        categories: categories,
                        selectedId: filterState.categoryId,
                        strings: strings,
                      ),
                    ),
                    _AnalyticsStatsTabView(
                      showFullScreenLoading: showFullScreenLoading,
                      error: error,
                      overview: overview,
                      strings: strings,
                      activeAnchor: statsAnchor,
                      filterState: filterState,
                      accounts: accounts,
                      onOpenMonthPicker: () => _openMonthPicker(
                        context: context,
                        ref: ref,
                        current:
                            filterState.monthAnchor ??
                            filterState.dateRange.end,
                        showMonthSelection:
                            filterState.period !=
                            AnalyticsPeriodPreset.customRange,
                      ),
                      onOpenAccountsPicker: () => _openAccountsPicker(
                        context: context,
                        ref: ref,
                        accounts: accounts,
                        selected: filterState.accountIds,
                        strings: strings,
                      ),
                    ),
                    _AnalyticsCreditsTabView(strings: strings),
                    _AnalyticsPlaceholderTabView(
                      title: strings.homeNavSavings,
                      strings: strings,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsTabsHeaderDelegate extends SliverPersistentHeaderDelegate {
  _AnalyticsTabsHeaderDelegate({
    required this.tabBar,
    required this.backgroundColor,
  });

  final TabBar tabBar;
  final Color backgroundColor;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Align(alignment: Alignment.centerLeft, child: tabBar),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _AnalyticsTabsHeaderDelegate oldDelegate) {
    return oldDelegate.tabBar != tabBar ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}

class _AnalyticsCategoriesTabView extends StatelessWidget {
  const _AnalyticsCategoriesTabView({
    required this.showFullScreenLoading,
    required this.error,
    required this.overview,
    required this.categories,
    required this.accounts,
    required this.filterState,
    required this.strings,
    required this.activeAnchor,
    required this.canGoNextRange,
    required this.canGoPreviousRange,
    required this.onGoPreviousRange,
    required this.onGoNextRange,
    required this.onOpenMonthPicker,
    required this.onOpenAccountsPicker,
    required this.onOpenCategoryPicker,
  });

  final bool showFullScreenLoading;
  final Object? error;
  final AnalyticsOverview? overview;
  final List<Category> categories;
  final List<AccountEntity> accounts;
  final AnalyticsFilterState filterState;
  final AppLocalizations strings;
  final DateTime activeAnchor;
  final bool canGoNextRange;
  final bool canGoPreviousRange;
  final VoidCallback onGoPreviousRange;
  final VoidCallback onGoNextRange;
  final VoidCallback onOpenMonthPicker;
  final VoidCallback onOpenAccountsPicker;
  final VoidCallback onOpenCategoryPicker;

  @override
  Widget build(BuildContext context) {
    if (showFullScreenLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return _AnalyticsError(message: error.toString(), strings: strings);
    }
    if (overview == null) {
      return _AnalyticsEmpty(strings: strings);
    }

    final NumberFormat currencyFormat = NumberFormat.simpleCurrency(
      locale: strings.localeName,
    );
    final Map<String, Category> categoriesById = <String, Category>{
      for (final Category category in categories) category.id: category,
    };
    final Map<String, AccountEntity> accountsById = <String, AccountEntity>{
      for (final AccountEntity account in accounts) account.id: account,
    };

    return CustomScrollView(
      slivers: <Widget>[
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
          sliver: SliverToBoxAdapter(
            child: _TopCategoriesTabContent(
              overview: overview!,
              categoriesById: categoriesById,
              accountsById: accountsById,
              filterState: filterState,
              categories: categories,
              accounts: accounts,
              currencyFormat: currencyFormat,
              strings: strings,
              activeAnchor: activeAnchor,
              canGoNextRange: canGoNextRange,
              canGoPreviousRange: canGoPreviousRange,
              onGoPreviousRange: onGoPreviousRange,
              onGoNextRange: onGoNextRange,
              onOpenMonthPicker: onOpenMonthPicker,
              onOpenAccountsPicker: onOpenAccountsPicker,
              onOpenCategoryPicker: onOpenCategoryPicker,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }
}

class _AnalyticsStatsTabView extends StatelessWidget {
  const _AnalyticsStatsTabView({
    required this.showFullScreenLoading,
    required this.error,
    required this.overview,
    required this.strings,
    required this.activeAnchor,
    required this.filterState,
    required this.accounts,
    required this.onOpenMonthPicker,
    required this.onOpenAccountsPicker,
  });

  final bool showFullScreenLoading;
  final Object? error;
  final AnalyticsOverview? overview;
  final AppLocalizations strings;
  final DateTime activeAnchor;
  final AnalyticsFilterState filterState;
  final List<AccountEntity> accounts;
  final VoidCallback onOpenMonthPicker;
  final VoidCallback onOpenAccountsPicker;

  @override
  Widget build(BuildContext context) {
    if (showFullScreenLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return _AnalyticsError(message: error.toString(), strings: strings);
    }
    if (overview == null) {
      return _AnalyticsEmpty(strings: strings);
    }

    final NumberFormat currencyFormat = NumberFormat.simpleCurrency(
      locale: strings.localeName,
    );

    return CustomScrollView(
      slivers: <Widget>[
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
          sliver: SliverToBoxAdapter(
            child: _TotalMoneyTabContent(
              currencyFormat: currencyFormat,
              strings: strings,
              activeAnchor: activeAnchor,
              monthFilterLabel: _resolveDateChipLabel(
                state: filterState,
                strings: strings,
              ),
              accountFilterLabel: _resolveAccountsLabel(
                accounts: accounts,
                selectedIds: filterState.accountIds,
                strings: strings,
              ),
              isAccountFilterActive: filterState.accountIds.isNotEmpty,
              onMonthChipTap: onOpenMonthPicker,
              onAccountsChipTap: onOpenAccountsPicker,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }
}

class _AnalyticsCreditsTabView extends ConsumerWidget {
  const _AnalyticsCreditsTabView({required this.strings});

  final AppLocalizations strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<AnalyticsDebtOverview> debtAsync = ref.watch(
      analyticsDebtOverviewProvider,
    );

    return CustomScrollView(
      slivers: <Widget>[
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
          sliver: SliverToBoxAdapter(
            child: debtAsync.when(
              data: (AnalyticsDebtOverview overview) {
                return _CreditsDebtAnalyticsContent(
                  overview: overview,
                  strings: strings,
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.only(top: 32),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (Object error, StackTrace stackTrace) {
                return _AnalyticsError(
                  message: error.toString(),
                  strings: strings,
                );
              },
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }
}

class _CreditsDebtAnalyticsContent extends StatelessWidget {
  const _CreditsDebtAnalyticsContent({
    required this.overview,
    required this.strings,
  });

  final AnalyticsDebtOverview overview;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final NumberFormat amountFormat = NumberFormat.simpleCurrency(
      locale: strings.localeName,
      decimalDigits: 0,
    );
    final NumberFormat compactFormat = NumberFormat.compact(
      locale: strings.localeName,
    );
    final double totalDebt = overview.totalDebt.toDouble();
    final String amountText = amountFormat.format(totalDebt);
    final double? deltaPercent = overview.monthDeltaPercent;
    final bool isDecrease = deltaPercent != null && deltaPercent <= 0;
    final Color deltaColor = isDecrease
        ? const Color(0xFF34D399)
        : colors.error;
    final String deltaText = deltaPercent == null
        ? strings.analyticsCreditsDeltaUnavailable
        : strings.analyticsCreditsDeltaThisMonth(
            '${deltaPercent > 0 ? '+' : ''}${deltaPercent.toStringAsFixed(1)}%',
          );
    final List<AnalyticsDebtTrendPoint> trend = overview.trend;
    final double maxValue = trend
        .map((AnalyticsDebtTrendPoint point) => point.totalDebt.toDouble())
        .fold<double>(
          0,
          (double prev, double next) => next > prev ? next : prev,
        );
    final double yMax = maxValue <= 0 ? 1 : maxValue * 1.12;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colors.surfaceContainer,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                strings.analyticsCreditsTotalDebtTitle,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                amountText,
                style: theme.textTheme.displayMedium?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: deltaColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      isDecrease
                          ? Icons.trending_down_rounded
                          : Icons.trending_up_rounded,
                      size: 14,
                      color: deltaColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      deltaText,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: deltaColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colors.surfaceContainer,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      strings.analyticsCreditsDebtTrendTitle,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest.withValues(
                        alpha: 0.2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      strings.analyticsCreditsDebtTrendPeriod,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colors.outline,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 260,
                child: SfCartesianChart(
                  plotAreaBorderWidth: 0,
                  margin: EdgeInsets.zero,
                  primaryXAxis: CategoryAxis(
                    majorGridLines: const MajorGridLines(width: 0),
                    axisLine: AxisLine(
                      color: colors.outline.withValues(alpha: 0.25),
                      width: 1,
                    ),
                    labelStyle: theme.textTheme.labelSmall?.copyWith(
                      color: colors.outline,
                    ),
                  ),
                  primaryYAxis: NumericAxis(
                    minimum: 0,
                    maximum: yMax,
                    majorGridLines: MajorGridLines(
                      color: colors.outline.withValues(alpha: 0.2),
                      width: 1,
                    ),
                    axisLine: const AxisLine(width: 0),
                    majorTickLines: const MajorTickLines(size: 0),
                    numberFormat: compactFormat,
                    labelStyle: theme.textTheme.labelSmall?.copyWith(
                      color: colors.outline,
                    ),
                  ),
                  series: <CartesianSeries<AnalyticsDebtTrendPoint, String>>[
                    AreaSeries<AnalyticsDebtTrendPoint, String>(
                      dataSource: trend,
                      xValueMapper: (AnalyticsDebtTrendPoint point, _) =>
                          _formatMonthShort(point.month, strings.localeName),
                      yValueMapper: (AnalyticsDebtTrendPoint point, _) =>
                          point.totalDebt.toDouble(),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          colors.primary.withValues(alpha: 0.32),
                          colors.primary.withValues(alpha: 0.02),
                        ],
                      ),
                      borderWidth: 0,
                      animationDuration: 0,
                    ),
                    SplineSeries<AnalyticsDebtTrendPoint, String>(
                      dataSource: trend,
                      xValueMapper: (AnalyticsDebtTrendPoint point, _) =>
                          _formatMonthShort(point.month, strings.localeName),
                      yValueMapper: (AnalyticsDebtTrendPoint point, _) =>
                          point.totalDebt.toDouble(),
                      color: colors.primary,
                      width: 3,
                      markerSettings: MarkerSettings(
                        isVisible: true,
                        width: 6,
                        height: 6,
                        color: colors.primary,
                      ),
                      animationDuration: 0,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnalyticsPlaceholderTabView extends StatelessWidget {
  const _AnalyticsPlaceholderTabView({
    required this.title,
    required this.strings,
  });

  final String title;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          '$title: ${strings.analyticsTopCategoriesEmpty}',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _TopCategoriesTabContent extends StatelessWidget {
  const _TopCategoriesTabContent({
    required this.overview,
    required this.categoriesById,
    required this.accountsById,
    required this.filterState,
    required this.categories,
    required this.accounts,
    required this.currencyFormat,
    required this.strings,
    required this.activeAnchor,
    required this.canGoNextRange,
    required this.canGoPreviousRange,
    required this.onGoPreviousRange,
    required this.onGoNextRange,
    required this.onOpenMonthPicker,
    required this.onOpenAccountsPicker,
    required this.onOpenCategoryPicker,
  });

  final AnalyticsOverview overview;
  final Map<String, Category> categoriesById;
  final Map<String, AccountEntity> accountsById;
  final AnalyticsFilterState filterState;
  final List<Category> categories;
  final List<AccountEntity> accounts;
  final NumberFormat currencyFormat;
  final AppLocalizations strings;
  final DateTime activeAnchor;
  final bool canGoNextRange;
  final bool canGoPreviousRange;
  final VoidCallback onGoPreviousRange;
  final VoidCallback onGoNextRange;
  final VoidCallback onOpenMonthPicker;
  final VoidCallback onOpenAccountsPicker;
  final VoidCallback onOpenCategoryPicker;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (Widget child, Animation<double> animation) {
            final Animation<Offset> slide =
                Tween<Offset>(
                  begin: const Offset(0.04, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                );
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(position: slide, child: child),
            );
          },
          child: _TopCategoriesPager(
            expenseBreakdowns: overview.topExpenseCategories,
            incomeBreakdowns: overview.topIncomeCategories,
            categoriesById: categoriesById,
            accountsById: accountsById,
            totalExpense: overview.totalExpense.toDouble(),
            totalIncome: overview.totalIncome.toDouble(),
            currencyFormat: currencyFormat,
            strings: strings,
            activeAnchor: activeAnchor,
            accountsFilterLabel: _resolveAccountsLabel(
              accounts: accounts,
              selectedIds: filterState.accountIds,
              strings: strings,
            ),
            categoryFilterLabel: _resolveCategoryLabel(
              categories: categories,
              selectedId: filterState.categoryId,
              strings: strings,
            ),
            monthFilterLabel: _resolveDateChipLabel(
              state: filterState,
              strings: strings,
            ),
            isAccountsFilterActive: filterState.accountIds.isNotEmpty,
            isCategoryFilterActive: filterState.categoryId != null,
            onMonthChipTap: onOpenMonthPicker,
            onAccountsChipTap: onOpenAccountsPicker,
            onCategoryChipTap: onOpenCategoryPicker,
            canGoNextRange: canGoNextRange,
            canGoPreviousRange: canGoPreviousRange,
            onPreviousRange: onGoPreviousRange,
            onNextRange: onGoNextRange,
          ),
        ),
      ],
    );
  }
}

class _TotalMoneyTabContent extends StatelessWidget {
  const _TotalMoneyTabContent({
    required this.currencyFormat,
    required this.strings,
    required this.activeAnchor,
    required this.monthFilterLabel,
    required this.accountFilterLabel,
    required this.isAccountFilterActive,
    required this.onMonthChipTap,
    required this.onAccountsChipTap,
  });

  final NumberFormat currencyFormat;
  final AppLocalizations strings;
  final DateTime activeAnchor;
  final String monthFilterLabel;
  final String accountFilterLabel;
  final bool isAccountFilterActive;
  final VoidCallback onMonthChipTap;
  final VoidCallback onAccountsChipTap;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final AsyncValue<List<MonthlyCashflowData>> cashflowAsync = ref.watch(
          monthlyCashflowDataProvider,
        );
        final AsyncValue<List<MonthlyBalanceData>> monthlyDataAsync = ref.watch(
          monthlyBalanceDataProvider,
        );

        return Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: MonthlyCashflowBarChartWidget(
                data: cashflowAsync.value ?? const <MonthlyCashflowData>[],
                currencySymbol: currencyFormat.currencySymbol,
                selectedMonth: activeAnchor,
                localeName: strings.localeName,
                monthFilterLabel: monthFilterLabel,
                accountFilterLabel: accountFilterLabel,
                isAccountFilterActive: isAccountFilterActive,
                onMonthFilterTap: onMonthChipTap,
                onAccountsFilterTap: onAccountsChipTap,
                onMonthSelected: (DateTime month) {
                  ref
                      .read(analyticsFilterControllerProvider.notifier)
                      .selectMonth(month);
                },
              ),
            ),
            monthlyDataAsync.when(
              data: (List<MonthlyBalanceData> data) {
                if (data.isEmpty) {
                  return const SizedBox.shrink();
                }
                return TotalMoneyChartWidget(
                  data: data,
                  currencySymbol: currencyFormat.currencySymbol,
                  selectedMonth: activeAnchor,
                  localeName: strings.localeName,
                  monthFilterLabel: monthFilterLabel,
                  accountFilterLabel: accountFilterLabel,
                  isAccountFilterActive: isAccountFilterActive,
                  onMonthFilterTap: onMonthChipTap,
                  onAccountsFilterTap: onAccountsChipTap,
                  onMonthSelected: (DateTime month) {
                    ref
                        .read(analyticsFilterControllerProvider.notifier)
                        .selectMonth(month);
                  },
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (Object error, StackTrace stack) =>
                  const SizedBox.shrink(),
            ),
          ],
        );
      },
    );
  }
}

Future<void> _openMonthPicker({
  required BuildContext context,
  required WidgetRef ref,
  required DateTime current,
  required bool showMonthSelection,
}) async {
  final ThemeData theme = Theme.of(context);
  final AppLocalizations strings = AppLocalizations.of(context)!;
  final DateTime now = DateTime.now();
  final List<DateTime> months = List<DateTime>.generate(12, (int index) {
    final DateTime date = DateTime(now.year, now.month - index);
    return DateTime(date.year, date.month);
  });

  final Object? picked = await showModalBottomSheet<Object?>(
    context: context,
    showDragHandle: true,
    backgroundColor: theme.colorScheme.surface,
    builder: (BuildContext context) {
      return SafeArea(
        top: false,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: months.length + 1,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return ListTile(
                leading: const Icon(Icons.edit_calendar_outlined),
                title: Text(strings.analyticsFilterPresetPickDate),
                onTap: () =>
                    Navigator.of(context).pop(_customDateRangeSelection),
              );
            }
            final int monthIndex = index - 1;
            final DateTime month = months[monthIndex];
            final bool isSelected =
                showMonthSelection &&
                month.year == current.year &&
                month.month == current.month;
            return ListTile(
              title: Text(_formatMonthShort(month, strings.localeName)),
              subtitle: Text(
                strings.analyticsMonthPickerYearSubtitle(month.year),
              ),
              trailing: isSelected
                  ? Icon(Icons.check, color: theme.colorScheme.primary)
                  : null,
              onTap: () => Navigator.of(context).pop(month),
            );
          },
        ),
      );
    },
  );

  if (picked is DateTime) {
    ref.read(analyticsFilterControllerProvider.notifier).selectMonth(picked);
    return;
  }

  if (picked == _customDateRangeSelection) {
    if (!context.mounted) {
      return;
    }
    final DateTime initialStart = DateTime(current.year, current.month, 1);
    final DateTime initialEnd = DateTime(current.year, current.month + 1, 0);
    final DateTimeRange? range = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: initialStart, end: initialEnd),
      firstDate: DateTime(2000),
      lastDate: DateTime(DateTime.now().year + 10, 12, 31),
      locale: Locale(strings.localeName),
    );
    if (range != null) {
      ref
          .read(analyticsFilterControllerProvider.notifier)
          .updateDateRange(range);
    }
  }
}

Future<void> _openAccountsPicker({
  required BuildContext context,
  required WidgetRef ref,
  required List<AccountEntity> accounts,
  required Set<String> selected,
  required AppLocalizations strings,
}) async {
  final Set<String> tempSelection = <String>{...selected};
  final ThemeData theme = Theme.of(context);
  final ColorScheme colors = theme.colorScheme;

  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: colors.surface,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        strings.analyticsAccountsPickerTitle,
                        style: theme.textTheme.titleMedium,
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          setState(() => tempSelection.clear());
                        },
                        child: Text(strings.analyticsAccountsPickerReset),
                      ),
                    ],
                  ),
                  ...accounts.map((AccountEntity account) {
                    final bool checked = tempSelection.contains(account.id);
                    return CheckboxListTile(
                      value: checked,
                      dense: true,
                      onChanged: (_) {
                        setState(() {
                          if (checked) {
                            tempSelection.remove(account.id);
                          } else {
                            tempSelection.add(account.id);
                          }
                        });
                      },
                      title: Text(account.name),
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  }),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        ref
                            .read(analyticsFilterControllerProvider.notifier)
                            .setAccounts(tempSelection);
                        Navigator.of(context).pop();
                      },
                      child: Text(strings.analyticsAccountsPickerApply),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

String _formatMonthShort(DateTime date, String locale) {
  final String raw = DateFormat.MMM(locale).format(date);
  return raw.replaceAll('.', '').toLowerCase();
}

String _resolveDateChipLabel({
  required AnalyticsFilterState state,
  required AppLocalizations strings,
}) {
  if (state.period == AnalyticsPeriodPreset.customRange) {
    final DateFormat dateFormat = DateFormat.MMMd(strings.localeName);
    final String start = dateFormat.format(state.dateRange.start);
    final String end = dateFormat.format(state.dateRange.end);
    if (start == end) {
      return start;
    }
    return strings.analyticsFilterDateValue(start, end);
  }
  return _formatMonthShort(
    state.monthAnchor ?? state.dateRange.start,
    strings.localeName,
  );
}

String _resolveAccountsLabel({
  required List<AccountEntity> accounts,
  required Set<String> selectedIds,
  required AppLocalizations strings,
}) {
  if (selectedIds.isEmpty) {
    return strings.analyticsFilterAccountAll;
  }
  if (selectedIds.length == 1) {
    final AccountEntity? account = accounts.firstWhereOrNull(
      (AccountEntity item) => item.id == selectedIds.first,
    );
    return account?.name ?? strings.analyticsAccountsSelectedOneFallback;
  }
  return strings.analyticsAccountsSelectedMany(selectedIds.length);
}

String _resolveCategoryLabel({
  required List<Category> categories,
  required String? selectedId,
  required AppLocalizations strings,
}) {
  if (selectedId == null) {
    return strings.analyticsFilterCategoryAll;
  }
  final Category? category = categories.firstWhereOrNull(
    (Category item) => item.id == selectedId,
  );
  return category?.name ?? strings.analyticsCategorySelectedFallback;
}

Future<void> _openCategoryPicker({
  required BuildContext context,
  required WidgetRef ref,
  required List<Category> categories,
  required String? selectedId,
  required AppLocalizations strings,
}) async {
  final ThemeData theme = Theme.of(context);
  final ColorScheme colors = theme.colorScheme;
  final Object? picked = await showModalBottomSheet<Object?>(
    context: context,
    showDragHandle: true,
    backgroundColor: colors.surface,
    builder: (BuildContext context) {
      return SafeArea(
        top: false,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: categories.length + 1,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              final bool isSelected = selectedId == null;
              return ListTile(
                title: Text(strings.analyticsFilterCategoryAll),
                trailing: isSelected
                    ? Icon(Icons.check, color: colors.primary)
                    : null,
                onTap: () => Navigator.of(context).pop(_clearCategorySelection),
              );
            }
            final Category category = categories[index - 1];
            final bool isSelected = category.id == selectedId;
            return ListTile(
              leading: Icon(
                resolvePhosphorIconData(category.icon) ??
                    Icons.category_outlined,
              ),
              title: Text(category.name),
              trailing: isSelected
                  ? Icon(Icons.check, color: colors.primary)
                  : null,
              onTap: () => Navigator.of(context).pop(category.id),
            );
          },
        ),
      );
    },
  );

  final AnalyticsFilterController notifier = ref.read(
    analyticsFilterControllerProvider.notifier,
  );
  if (picked == null) {
    return;
  }
  if (picked == _clearCategorySelection) {
    notifier.clearCategory();
    return;
  }
  notifier.updateCategory(picked as String);
}

class _TopCategoriesPager extends StatefulWidget {
  const _TopCategoriesPager({
    required this.expenseBreakdowns,
    required this.incomeBreakdowns,
    required this.categoriesById,
    required this.accountsById,
    required this.totalExpense,
    required this.totalIncome,
    required this.currencyFormat,
    required this.strings,
    required this.activeAnchor,
    required this.accountsFilterLabel,
    required this.categoryFilterLabel,
    required this.monthFilterLabel,
    required this.isAccountsFilterActive,
    required this.isCategoryFilterActive,
    required this.onMonthChipTap,
    required this.onAccountsChipTap,
    required this.onCategoryChipTap,
    required this.canGoNextRange,
    required this.canGoPreviousRange,
    required this.onPreviousRange,
    required this.onNextRange,
  });

  final List<AnalyticsCategoryBreakdown> expenseBreakdowns;
  final List<AnalyticsCategoryBreakdown> incomeBreakdowns;
  final Map<String, Category> categoriesById;
  final Map<String, AccountEntity> accountsById;
  final double totalExpense;
  final double totalIncome;
  final NumberFormat currencyFormat;
  final AppLocalizations strings;
  final DateTime activeAnchor;
  final String accountsFilterLabel;
  final String categoryFilterLabel;
  final String monthFilterLabel;
  final bool isAccountsFilterActive;
  final bool isCategoryFilterActive;
  final VoidCallback onMonthChipTap;
  final VoidCallback onAccountsChipTap;
  final VoidCallback onCategoryChipTap;
  final bool canGoNextRange;
  final bool canGoPreviousRange;
  final VoidCallback onPreviousRange;
  final VoidCallback onNextRange;

  @override
  State<_TopCategoriesPager> createState() => _TopCategoriesPagerState();
}

class _TopCategoriesPagerState extends State<_TopCategoriesPager> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<AnalyticsChartItem> expenseItems = _mapBreakdowns(
      widget.expenseBreakdowns,
      widget.categoriesById,
      widget.strings,
      theme,
    );
    final List<AnalyticsChartItem> incomeItems = _mapBreakdowns(
      widget.incomeBreakdowns,
      widget.categoriesById,
      widget.strings,
      theme,
    );
    final _TopCategoriesPageData expenseData = _TopCategoriesPageData(
      label: widget.strings.analyticsTopCategoriesExpensesTab,
      items: expenseItems,
      total: widget.totalExpense,
      isIncome: false,
    );
    final _TopCategoriesPageData incomeData = _TopCategoriesPageData(
      label: widget.strings.analyticsTopCategoriesIncomeTab,
      items: incomeItems,
      total: widget.totalIncome,
      isIncome: true,
    );

    return Container(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            widget.strings.analyticsOperationsByCategoryTitle,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          AnimatedSize(
            alignment: Alignment.topCenter,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              child: _TopCategoriesPage(
                key: ValueKey<DateTime>(widget.activeAnchor),
                expenseData: expenseData,
                incomeData: incomeData,
                currencyFormat: widget.currencyFormat,
                strings: widget.strings,
                categoriesById: widget.categoriesById,
                accountsById: widget.accountsById,
                activeAnchor: widget.activeAnchor,
                canGoNextRange: widget.canGoNextRange,
                canGoPreviousRange: widget.canGoPreviousRange,
                onPreviousRange: widget.onPreviousRange,
                onNextRange: widget.onNextRange,
                totalIncome: widget.totalIncome,
                accountsFilterLabel: widget.accountsFilterLabel,
                categoryFilterLabel: widget.categoryFilterLabel,
                monthFilterLabel: widget.monthFilterLabel,
                isAccountsFilterActive: widget.isAccountsFilterActive,
                isCategoryFilterActive: widget.isCategoryFilterActive,
                onMonthChipTap: widget.onMonthChipTap,
                onAccountsChipTap: widget.onAccountsChipTap,
                onCategoryChipTap: widget.onCategoryChipTap,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<AnalyticsChartItem> _mapBreakdowns(
    List<AnalyticsCategoryBreakdown> breakdowns,
    Map<String, Category> categoriesById,
    AppLocalizations strings,
    ThemeData theme,
  ) {
    AnalyticsChartItem mapBreakdown(AnalyticsCategoryBreakdown breakdown) {
      final String? rawId = breakdown.categoryId;
      final bool isOthers = rawId == _othersCategoryKey;
      final bool isDirect =
          rawId != null && isAnalyticsDirectCategoryKey(rawId);
      final String? resolvedId = isDirect
          ? parseAnalyticsDirectCategoryParentId(rawId)
          : rawId;
      final Category? category = resolvedId == null || isOthers
          ? null
          : categoriesById[resolvedId];
      final Color baseColor =
          resolveCategoryColorStyle(category?.color).sampleColor ??
          theme.colorScheme.primary;
      final Color color = isOthers
          ? theme.colorScheme.outlineVariant
          : isDirect
          ? baseColor.withValues(alpha: 0.6)
          : baseColor;
      final String title = isOthers
          ? strings.analyticsTopCategoriesOthers
          : isDirect
          ? strings.analyticsCategoryDirectLabel
          : category?.name ?? strings.analyticsCategoryUncategorized;
      final IconData? iconData = isOthers
          ? Icons.more_horiz
          : resolvePhosphorIconData(category?.icon);
      final String key = rawId ?? _uncategorizedCategoryKey;
      final List<AnalyticsChartItem> children = breakdown.children
          .map(mapBreakdown)
          .toList(growable: false);

      return AnalyticsChartItem(
        key: key,
        title: title,
        amount: breakdown.amount.toDouble(),
        color: color,
        icon: iconData,
        children: children,
      );
    }

    return breakdowns.map(mapBreakdown).toList(growable: false);
  }
}

class _TopCategoriesPageData {
  const _TopCategoriesPageData({
    required this.label,
    required this.items,
    required this.total,
    required this.isIncome,
  });

  final String label;
  final List<AnalyticsChartItem> items;
  final double total;
  final bool isIncome;
}

class _TopCategoriesPage extends ConsumerStatefulWidget {
  const _TopCategoriesPage({
    super.key,
    required this.expenseData,
    required this.incomeData,
    required this.currencyFormat,
    required this.strings,
    required this.categoriesById,
    required this.accountsById,
    required this.activeAnchor,
    required this.canGoNextRange,
    required this.canGoPreviousRange,
    required this.onPreviousRange,
    required this.onNextRange,
    required this.totalIncome,
    required this.accountsFilterLabel,
    required this.categoryFilterLabel,
    required this.monthFilterLabel,
    required this.isAccountsFilterActive,
    required this.isCategoryFilterActive,
    required this.onMonthChipTap,
    required this.onAccountsChipTap,
    required this.onCategoryChipTap,
  });

  final _TopCategoriesPageData expenseData;
  final _TopCategoriesPageData incomeData;
  final NumberFormat currencyFormat;
  final AppLocalizations strings;
  final Map<String, Category> categoriesById;
  final Map<String, AccountEntity> accountsById;
  final DateTime activeAnchor;
  final bool canGoNextRange;
  final bool canGoPreviousRange;
  final VoidCallback onPreviousRange;
  final VoidCallback onNextRange;
  final double totalIncome;
  final String accountsFilterLabel;
  final String categoryFilterLabel;
  final String monthFilterLabel;
  final bool isAccountsFilterActive;
  final bool isCategoryFilterActive;
  final VoidCallback onMonthChipTap;
  final VoidCallback onAccountsChipTap;
  final VoidCallback onCategoryChipTap;

  @override
  ConsumerState<_TopCategoriesPage> createState() => _TopCategoriesPageState();
}

enum _CategoriesChartMode { donut, bar }

enum _OperationsBreakdownMode { expense, income }

class _TopCategoriesHeaderFilters extends StatelessWidget {
  const _TopCategoriesHeaderFilters({
    required this.strings,
    required this.highlightedItem,
    required this.onClearHighlight,
    required this.accountLabel,
    required this.categoryLabel,
    required this.monthLabel,
    required this.isAccountActive,
    required this.isCategoryActive,
    required this.isTransfersVisible,
    required this.onTransfersToggle,
    required this.onMonthTap,
    required this.onAccountsTap,
    required this.onCategoryTap,
  });

  final AppLocalizations strings;
  final AnalyticsChartItem? highlightedItem;
  final VoidCallback? onClearHighlight;
  final String accountLabel;
  final String categoryLabel;
  final String monthLabel;
  final bool isAccountActive;
  final bool isCategoryActive;
  final bool isTransfersVisible;
  final VoidCallback onTransfersToggle;
  final VoidCallback onMonthTap;
  final VoidCallback onAccountsTap;
  final VoidCallback onCategoryTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: <Widget>[
              if (highlightedItem != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: AnalyticsFilterChip(
                    label: highlightedItem!.title,
                    selected: true,
                    onTap: onClearHighlight,
                    trailingIcon: Icons.close,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: AnalyticsFilterChip(
                  label: accountLabel,
                  selected: isAccountActive,
                  onTap: onAccountsTap,
                ),
              ),
              if (highlightedItem == null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: AnalyticsFilterChip(
                    label: categoryLabel,
                    selected: isCategoryActive,
                    onTap: onCategoryTap,
                  ),
                ),
              AnalyticsFilterChip(
                label: monthLabel,
                selected: true,
                onTap: onMonthTap,
              ),
              const SizedBox(width: 8),
              AnalyticsFilterChip(
                label: strings.analyticsShowTransfersChip,
                selected: isTransfersVisible,
                onTap: onTransfersToggle,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TopCategoriesTotalsRow extends StatelessWidget {
  const _TopCategoriesTotalsRow({
    required this.currencyFormat,
    required this.expenseTotal,
    required this.incomeTotal,
  });

  final NumberFormat currencyFormat;
  final double expenseTotal;
  final double incomeTotal;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        _TotalBadge(
          label: AppLocalizations.of(context)!.analyticsSummaryExpenseLabel,
          amount: currencyFormat.format(expenseTotal),
        ),
        _TotalBadge(
          label: AppLocalizations.of(context)!.analyticsSummaryIncomeLabel,
          amount: currencyFormat.format(incomeTotal),
        ),
      ],
    );
  }
}

class _TotalBadge extends StatelessWidget {
  const _TotalBadge({required this.label, required this.amount});

  final String label;
  final String amount;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '$label: $amount',
        style: theme.textTheme.labelMedium?.copyWith(
          color: colors.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _ChartBottomControls extends StatelessWidget {
  const _ChartBottomControls({
    required this.mode,
    required this.breakdownMode,
    required this.strings,
    required this.canGoPreviousRange,
    required this.canGoNextRange,
    required this.onModeChanged,
    required this.onBreakdownModeChanged,
    required this.onPreviousRange,
    required this.onNextRange,
  });

  final _CategoriesChartMode mode;
  final _OperationsBreakdownMode breakdownMode;
  final AppLocalizations strings;
  final bool canGoPreviousRange;
  final bool canGoNextRange;
  final ValueChanged<_CategoriesChartMode> onModeChanged;
  final ValueChanged<_OperationsBreakdownMode> onBreakdownModeChanged;
  final VoidCallback? onPreviousRange;
  final VoidCallback? onNextRange;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Wrap(
          spacing: 8,
          children: <Widget>[
            _OperationsBreakdownIconToggle(
              mode: breakdownMode,
              strings: strings,
              onModeChanged: onBreakdownModeChanged,
            ),
            _CategoriesChartModeToggle(
              mode: mode,
              strings: strings,
              onModeChanged: onModeChanged,
            ),
          ],
        ),
        const Spacer(),
        _MonthArrowButton(
          icon: Icons.chevron_left_rounded,
          onTap: canGoPreviousRange ? onPreviousRange : null,
        ),
        const SizedBox(width: 8),
        _MonthArrowButton(
          icon: Icons.chevron_right_rounded,
          onTap: canGoNextRange ? onNextRange : null,
        ),
      ],
    );
  }
}

class _OperationsBreakdownIconToggle extends StatelessWidget {
  const _OperationsBreakdownIconToggle({
    required this.mode,
    required this.strings,
    required this.onModeChanged,
  });

  final _OperationsBreakdownMode mode;
  final AppLocalizations strings;
  final ValueChanged<_OperationsBreakdownMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _ChartModeButton(
            icon: Icons.arrow_downward_rounded,
            tooltip: strings.analyticsTopCategoriesExpensesTab,
            selected: mode == _OperationsBreakdownMode.expense,
            onTap: () => onModeChanged(_OperationsBreakdownMode.expense),
          ),
          _ChartModeButton(
            icon: Icons.arrow_upward_rounded,
            tooltip: strings.analyticsTopCategoriesIncomeTab,
            selected: mode == _OperationsBreakdownMode.income,
            onTap: () => onModeChanged(_OperationsBreakdownMode.income),
          ),
        ],
      ),
    );
  }
}

class _MonthArrowButton extends StatelessWidget {
  const _MonthArrowButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return IconButton.filledTonal(
      style: IconButton.styleFrom(
        minimumSize: const Size(40, 40),
        maximumSize: const Size(40, 40),
        padding: EdgeInsets.zero,
        backgroundColor: theme.colorScheme.surfaceContainerHigh,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      onPressed: onTap,
      icon: Icon(icon),
    );
  }
}

class _TopCategoriesPageState extends ConsumerState<_TopCategoriesPage> {
  String? _highlightKey;
  _CategoriesChartMode _chartMode = _CategoriesChartMode.donut;
  _OperationsBreakdownMode _breakdownMode = _OperationsBreakdownMode.expense;
  bool _showTransfers = true;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<TransactionEntity>> transfersAsync = ref.watch(
      analyticsTransferTransactionsProvider,
    );
    final AsyncValue<CreditDebtOperationsOverview> creditDebtAsync = ref.watch(
      analyticsCreditDebtOperationsProvider,
    );
    final double transfersTotal =
        transfersAsync.value?.fold<double>(
          0,
          (double sum, TransactionEntity transaction) =>
              sum + transaction.amountValue.toDouble(),
        ) ??
        0;
    final double creditPaymentsTotal =
        creditDebtAsync.value?.totalOutflow.toDouble() ?? 0;
    final _TopCategoriesPageData baseData =
        _breakdownMode == _OperationsBreakdownMode.expense
        ? widget.expenseData
        : widget.incomeData;
    final List<AnalyticsChartItem> chartItems = <AnalyticsChartItem>[
      ...baseData.items,
      if (_breakdownMode == _OperationsBreakdownMode.expense &&
          _showTransfers &&
          transfersTotal > 0)
        AnalyticsChartItem(
          key: _transfersCategoryKey,
          title: widget.strings.analyticsTransfersOperationLabel,
          amount: transfersTotal,
          color: Theme.of(context).colorScheme.secondary,
          icon: Icons.swap_horiz_rounded,
        ),
      if (_breakdownMode == _OperationsBreakdownMode.expense &&
          _showTransfers &&
          creditPaymentsTotal > 0)
        AnalyticsChartItem(
          key: _creditPaymentsCategoryKey,
          title: widget.strings.analyticsCreditPaymentsOperationLabel,
          amount: creditPaymentsTotal,
          color: Theme.of(context).colorScheme.tertiary,
          icon: Icons.credit_card_rounded,
        ),
    ];
    final double capturedTotal =
        baseData.total +
        (_breakdownMode == _OperationsBreakdownMode.expense && _showTransfers
            ? transfersTotal + creditPaymentsTotal
            : 0);
    final double expenseTotalForBadges =
        _breakdownMode == _OperationsBreakdownMode.expense
        ? capturedTotal
        : widget.expenseData.total;
    final double incomeTotalForBadges =
        _breakdownMode == _OperationsBreakdownMode.income
        ? capturedTotal
        : widget.incomeData.total;

    final Widget content;
    final bool isEmptyData = chartItems.isEmpty || capturedTotal <= 0;
    if (isEmptyData) {
      final ThemeData theme = Theme.of(context);
      final Color placeholderColor = theme.colorScheme.surfaceContainerHighest
          .withValues(alpha: 0.7);
      final List<AnalyticsChartItem> placeholderItems = <AnalyticsChartItem>[
        AnalyticsChartItem(
          key: '_placeholder',
          title: widget.strings.analyticsEmptyState,
          amount: 1,
          color: placeholderColor,
        ),
      ];
      content = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _TopCategoriesHeaderFilters(
            strings: widget.strings,
            highlightedItem: null,
            onClearHighlight: null,
            accountLabel: widget.accountsFilterLabel,
            categoryLabel: widget.categoryFilterLabel,
            monthLabel: widget.monthFilterLabel,
            isAccountActive: widget.isAccountsFilterActive,
            isCategoryActive: widget.isCategoryFilterActive,
            isTransfersVisible: _showTransfers,
            onTransfersToggle: () => setState(() {
              _showTransfers = !_showTransfers;
            }),
            onMonthTap: widget.onMonthChipTap,
            onAccountsTap: widget.onAccountsChipTap,
            onCategoryTap: widget.onCategoryChipTap,
          ),
          const SizedBox(height: 12),
          _TopCategoriesTotalsRow(
            currencyFormat: widget.currencyFormat,
            expenseTotal: expenseTotalForBadges,
            incomeTotal: incomeTotalForBadges,
          ),
          const SizedBox(height: 12),
          const SizedBox(height: 20),
          _EmptyMonthChart(items: placeholderItems, color: placeholderColor),
          SizedBox(height: _chartMode == _CategoriesChartMode.bar ? 8 : 16),
          _ChartBottomControls(
            mode: _chartMode,
            breakdownMode: _breakdownMode,
            strings: widget.strings,
            canGoPreviousRange: widget.canGoPreviousRange,
            canGoNextRange: widget.canGoNextRange,
            onModeChanged: (_CategoriesChartMode mode) {
              if (_chartMode == mode) {
                return;
              }
              setState(() {
                _chartMode = mode;
              });
            },
            onBreakdownModeChanged: (_OperationsBreakdownMode mode) {
              if (_breakdownMode == mode) {
                return;
              }
              setState(() {
                _breakdownMode = mode;
                _highlightKey = null;
              });
            },
            onPreviousRange: widget.canGoPreviousRange
                ? widget.onPreviousRange
                : null,
            onNextRange: widget.canGoNextRange ? widget.onNextRange : null,
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              widget.strings.analyticsEmptyState,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    } else {
      final ThemeData theme = Theme.of(context);
      final Color backgroundColor = theme.colorScheme.surfaceContainerHighest
          .withValues(alpha: 0.32);

      AnalyticsChartItem? focusedItem;
      if (_highlightKey != null) {
        final _FocusedItemResult? result = _findFocusedItem(
          chartItems,
          _highlightKey!,
        );
        if (result != null) {
          focusedItem = result.item;
        }
      }

      final _DisplayItemsResult display = _resolveDisplayItems(
        items: chartItems,
        total: capturedTotal,
        focusedItem: focusedItem,
      );
      final List<AnalyticsChartItem> displayItems = display.items;
      final double displayTotal = display.total;

      int? selectedIndex;
      if (_highlightKey != null) {
        final int candidateIndex = displayItems.indexWhere(
          (AnalyticsChartItem item) => item.key == _highlightKey,
        );
        if (candidateIndex >= 0) {
          selectedIndex = candidateIndex;
        }
      }
      final _CategoryTransactionsSelection? selection =
          _resolveTransactionsSelection(focusedItem);

      content = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _TopCategoriesHeaderFilters(
            strings: widget.strings,
            highlightedItem: focusedItem,
            onClearHighlight: _highlightKey == null
                ? null
                : () => setState(() => _highlightKey = null),
            accountLabel: widget.accountsFilterLabel,
            categoryLabel: widget.categoryFilterLabel,
            monthLabel: widget.monthFilterLabel,
            isAccountActive: widget.isAccountsFilterActive,
            isCategoryActive: widget.isCategoryFilterActive,
            isTransfersVisible: _showTransfers,
            onTransfersToggle: () => setState(() {
              _showTransfers = !_showTransfers;
              _highlightKey = null;
            }),
            onMonthTap: widget.onMonthChipTap,
            onAccountsTap: widget.onAccountsChipTap,
            onCategoryTap: widget.onCategoryChipTap,
          ),
          const SizedBox(height: 12),
          _TopCategoriesTotalsRow(
            currencyFormat: widget.currencyFormat,
            expenseTotal: expenseTotalForBadges,
            incomeTotal: incomeTotalForBadges,
          ),
          const SizedBox(height: 12),
          SizedBox(height: _chartMode == _CategoriesChartMode.donut ? 20 : 16),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final Size screenSize = MediaQuery.sizeOf(context);
              final double availableWidth =
                  constraints.hasBoundedWidth &&
                      constraints.maxWidth.isFinite &&
                      constraints.maxWidth > 0
                  ? constraints.maxWidth
                  : screenSize.width;
              final double baseExtent = availableWidth * 0.7;
              final double donutExtent = baseExtent
                  .clamp(220.0, 360.0)
                  .toDouble();
              final double barExtent = (displayItems.length * 56.0 + 40.0)
                  .clamp(220.0, 640.0)
                  .toDouble();
              final double chartExtent = _chartMode == _CategoriesChartMode.bar
                  ? barExtent
                  : donutExtent;
              final double targetWidth = availableWidth
                  .clamp(240.0, screenSize.width)
                  .toDouble();

              final Widget chartWidget =
                  _chartMode == _CategoriesChartMode.donut
                  ? AnalyticsDonutChart(
                      items: displayItems,
                      backgroundColor: backgroundColor,
                      totalAmount: displayTotal,
                      selectedIndex: selectedIndex,
                      animate: false,
                      onSegmentSelected: (int index) {
                        if (index >= 0 && index < displayItems.length) {
                          setState(() {
                            final String key = displayItems[index].key;
                            _highlightKey = _highlightKey == key ? null : key;
                          });
                        }
                      },
                    )
                  : AnalyticsBarChart(
                      items: displayItems,
                      backgroundColor: backgroundColor,
                      totalAmount: displayTotal,
                      amountFormatter: widget.currencyFormat.format,
                      selectedIndex: selectedIndex,
                      animate: false,
                      onBarSelected: (int index) {
                        if (index >= 0 && index < displayItems.length) {
                          setState(() {
                            final String key = displayItems[index].key;
                            _highlightKey = _highlightKey == key ? null : key;
                          });
                        }
                      },
                    );

              final Widget chart = RepaintBoundary(
                child: SizedBox(height: chartExtent, child: chartWidget),
              );

              return Align(
                alignment: Alignment.center,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: targetWidth),
                  child: chart,
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _ChartBottomControls(
            mode: _chartMode,
            breakdownMode: _breakdownMode,
            strings: widget.strings,
            canGoPreviousRange: widget.canGoPreviousRange,
            canGoNextRange: widget.canGoNextRange,
            onModeChanged: (_CategoriesChartMode mode) {
              if (_chartMode == mode) {
                return;
              }
              setState(() {
                _chartMode = mode;
              });
            },
            onBreakdownModeChanged: (_OperationsBreakdownMode mode) {
              if (_breakdownMode == mode) {
                return;
              }
              setState(() {
                _breakdownMode = mode;
                _highlightKey = null;
              });
            },
            onPreviousRange: widget.canGoPreviousRange
                ? widget.onPreviousRange
                : null,
            onNextRange: widget.canGoNextRange ? widget.onNextRange : null,
          ),
          const SizedBox(height: 20),
          _TopCategoriesLegend(
            items: displayItems,
            currencyFormat: widget.currencyFormat,
            total: displayTotal,
            highlightedKey: _highlightKey,
            onToggle: _handleToggle,
          ),
          AnimatedSize(
            alignment: Alignment.topCenter,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            child: selection == null
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: _CategoryTransactionsSection(
                      selection: selection,
                      type: baseData.isIncome
                          ? TransactionType.income
                          : TransactionType.expense,
                      categoriesById: widget.categoriesById,
                      accountsById: widget.accountsById,
                      strings: widget.strings,
                    ),
                  ),
          ),
        ],
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      child: KeyedSubtree(
        key: ValueKey<DateTime>(widget.activeAnchor),
        child: content,
      ),
    );
  }

  void _handleToggle(AnalyticsChartItem item) {
    setState(() {
      _highlightKey = _highlightKey == item.key ? null : item.key;
    });
  }

  _CategoryTransactionsSelection? _resolveTransactionsSelection(
    AnalyticsChartItem? focusedItem,
  ) {
    if (focusedItem == null) {
      return null;
    }
    if (focusedItem.key == _transfersCategoryKey ||
        focusedItem.key == _creditPaymentsCategoryKey) {
      return null;
    }
    final _SelectionPayload payload = _collectSelectionPayload(focusedItem);
    if (payload.categoryIds.isEmpty && !payload.includeUncategorized) {
      return null;
    }
    final String title = _resolveSelectionTitle(focusedItem);
    return _CategoryTransactionsSelection(
      title: title,
      categoryIds: payload.categoryIds.toList()..sort(),
      includeUncategorized: payload.includeUncategorized,
    );
  }

  String _resolveSelectionTitle(AnalyticsChartItem item) {
    final String? parentId = parseAnalyticsDirectCategoryParentId(item.key);
    if (parentId == null) {
      return item.title;
    }
    final Category? parent = widget.categoriesById[parentId];
    if (parent == null) {
      return item.title;
    }
    return '${parent.name} · ${widget.strings.analyticsCategoryDirectLabel}';
  }

  _SelectionPayload _collectSelectionPayload(AnalyticsChartItem item) {
    bool includeUncategorized = false;
    final Set<String> categoryIds = <String>{};

    void visit(AnalyticsChartItem node) {
      final String key = node.key;
      if (key == _othersCategoryKey) {
        for (final AnalyticsChartItem child in node.children) {
          visit(child);
        }
        return;
      }
      if (key == _uncategorizedCategoryKey) {
        includeUncategorized = true;
        return;
      }
      final String? directParentId = parseAnalyticsDirectCategoryParentId(key);
      if (directParentId != null) {
        categoryIds.add(directParentId);
        return;
      }
      categoryIds.add(key);
      for (final AnalyticsChartItem child in node.children) {
        visit(child);
      }
    }

    visit(item);
    return _SelectionPayload(
      categoryIds: categoryIds,
      includeUncategorized: includeUncategorized,
    );
  }

  _DisplayItemsResult _resolveDisplayItems({
    required List<AnalyticsChartItem> items,
    required double total,
    AnalyticsChartItem? focusedItem,
  }) {
    if (focusedItem == null) {
      return _DisplayItemsResult(items: items, total: total);
    }
    if (focusedItem.children.isEmpty) {
      return _DisplayItemsResult(
        items: <AnalyticsChartItem>[focusedItem],
        total: focusedItem.absoluteAmount,
      );
    }

    final AnalyticsChartItem? directChild = focusedItem.children
        .firstWhereOrNull((AnalyticsChartItem item) {
          return isAnalyticsDirectCategoryKey(item.key);
        });
    final double directAmount = directChild?.amount ?? 0;
    final List<AnalyticsChartItem> displayItems = <AnalyticsChartItem>[];
    if (directAmount > 0) {
      displayItems.add(
        AnalyticsChartItem(
          key: focusedItem.key,
          title: focusedItem.title,
          amount: directAmount,
          color: focusedItem.color,
          icon: focusedItem.icon,
        ),
      );
    }
    displayItems.addAll(
      focusedItem.children.where(
        (AnalyticsChartItem item) => item.key != directChild?.key,
      ),
    );

    return _DisplayItemsResult(
      items: displayItems,
      total: focusedItem.absoluteAmount,
    );
  }
}

class _SelectionPayload {
  const _SelectionPayload({
    required this.categoryIds,
    required this.includeUncategorized,
  });

  final Set<String> categoryIds;
  final bool includeUncategorized;
}

class _DisplayItemsResult {
  const _DisplayItemsResult({required this.items, required this.total});

  final List<AnalyticsChartItem> items;
  final double total;
}

class _FocusedItemResult {
  const _FocusedItemResult({required this.item, required this.topLevelItem});

  final AnalyticsChartItem item;
  final AnalyticsChartItem topLevelItem;
}

_FocusedItemResult? _findFocusedItem(
  List<AnalyticsChartItem> items,
  String key,
) {
  for (final AnalyticsChartItem item in items) {
    final AnalyticsChartItem? found = _findItemInTree(item, key);
    if (found != null) {
      return _FocusedItemResult(item: found, topLevelItem: item);
    }
  }
  return null;
}

AnalyticsChartItem? _findItemInTree(AnalyticsChartItem item, String key) {
  if (item.key == key) {
    return item;
  }
  for (final AnalyticsChartItem child in item.children) {
    final AnalyticsChartItem? found = _findItemInTree(child, key);
    if (found != null) {
      return found;
    }
  }
  return null;
}

class _CategoryTransactionsSelection {
  const _CategoryTransactionsSelection({
    required this.title,
    required this.categoryIds,
    required this.includeUncategorized,
  });

  final String title;
  final List<String> categoryIds;
  final bool includeUncategorized;
}

class _CategoryTransactionsSection extends ConsumerWidget {
  const _CategoryTransactionsSection({
    required this.selection,
    required this.type,
    required this.categoriesById,
    required this.accountsById,
    required this.strings,
  });

  final _CategoryTransactionsSelection selection;
  final TransactionType type;
  final Map<String, Category> categoriesById;
  final Map<String, AccountEntity> accountsById;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AnalyticsCategoryTransactionsFilter filter =
        AnalyticsCategoryTransactionsFilter(
          categoryIds: selection.categoryIds,
          includeUncategorized: selection.includeUncategorized,
          type: type,
        );
    final AsyncValue<List<TransactionEntity>> transactionsAsync = ref.watch(
      analyticsCategoryTransactionsProvider(filter),
    );
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            strings.analyticsCategoryTransactionsTitle(selection.title),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          transactionsAsync.when(
            data: (List<TransactionEntity> transactions) {
              if (transactions.isEmpty) {
                return Text(
                  strings.analyticsCategoryTransactionsEmpty,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length,
                separatorBuilder: (BuildContext context, int index) =>
                    const SizedBox(height: 4),
                itemBuilder: (BuildContext context, int index) {
                  final TransactionEntity transaction = transactions[index];
                  final AccountEntity? account =
                      accountsById[transaction.accountId];
                  final Category? category = transaction.categoryId == null
                      ? null
                      : categoriesById[transaction.categoryId!];
                  return TransactionListTile(
                    transaction: transaction,
                    category: category,
                    currency: account?.currency ?? '',
                    accountName: account?.name,
                    strings: strings,
                  );
                },
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (Object error, StackTrace stackTrace) => Text(
              error.toString(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyMonthChart extends StatelessWidget {
  const _EmptyMonthChart({required this.items, required this.color});

  final List<AnalyticsChartItem> items;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final Size screenSize = MediaQuery.sizeOf(context);
        final double availableWidth =
            constraints.hasBoundedWidth &&
                constraints.maxWidth.isFinite &&
                constraints.maxWidth > 0
            ? constraints.maxWidth
            : screenSize.width;
        final double baseExtent = availableWidth * 0.7;
        final double chartExtent = baseExtent.clamp(220.0, 360.0).toDouble();
        final double targetWidth = availableWidth
            .clamp(240.0, screenSize.width)
            .toDouble();

        return Align(
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: targetWidth),
            child: RepaintBoundary(
              child: SizedBox(
                height: chartExtent,
                child: AnalyticsDonutChart(
                  items: items,
                  backgroundColor: color.withValues(alpha: 0.2),
                  totalAmount: 1,
                  selectedIndex: null,
                  onSegmentSelected: null,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TopCategoriesLegend extends StatelessWidget {
  const _TopCategoriesLegend({
    required this.items,
    required this.currencyFormat,
    required this.total,
    required this.highlightedKey,
    required this.onToggle,
  });

  final List<AnalyticsChartItem> items;
  final NumberFormat currencyFormat;
  final double total;
  final String? highlightedKey;
  final ValueChanged<AnalyticsChartItem> onToggle;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty || total <= 0) {
      return const SizedBox.shrink();
    }
    final _FocusedItemResult? focused = highlightedKey == null
        ? null
        : _findFocusedItem(items, highlightedKey!);
    final AnalyticsChartItem? expandedItem = focused?.topLevelItem;
    final bool showExpandedChildren =
        expandedItem != null && expandedItem.children.isNotEmpty;
    final List<Widget> legendItems = List<Widget>.generate(items.length, (
      int index,
    ) {
      final AnalyticsChartItem item = items[index];
      final String amountText = currencyFormat.format(item.absoluteAmount);
      final bool isSelected = highlightedKey == item.key;
      return SizedBox(
        width: 168,
        child: _TopCategoryLegendItem(
          item: item,
          amountText: amountText,
          isSelected: isSelected,
          onTap: () => onToggle(item),
        ),
      );
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Wrap(spacing: 8, runSpacing: 8, children: legendItems),
        if (showExpandedChildren) ...<Widget>[
          const SizedBox(height: 8),
          _CategoryBreakdownList(
            items: expandedItem.children,
            currencyFormat: currencyFormat,
            highlightedKey: highlightedKey,
            onToggle: onToggle,
          ),
        ],
      ],
    );
  }
}

class _TopCategoryLegendItem extends StatelessWidget {
  const _TopCategoryLegendItem({
    required this.item,
    required this.amountText,
    required this.isSelected,
    this.onTap,
    this.compact = false,
  });

  final AnalyticsChartItem item;
  final String amountText;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final KopimLayout layout = context.kopimLayout;
    final double height = compact ? 32 : 40;

    final TextStyle titleStyle =
        theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: colors.onSurfaceVariant,
        ) ??
        TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: colors.onSurfaceVariant,
        );
    final TextStyle amountStyle =
        theme.textTheme.labelMedium?.copyWith(
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          letterSpacing: 0.1,
          color: colors.onSurface,
        ) ??
        TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          letterSpacing: 0.1,
          color: colors.onSurface,
        );

    return Tooltip(
      message: amountText,
      waitDuration: const Duration(milliseconds: 400),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(32),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            height: height,
            padding: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: isSelected ? colors.primary : Colors.transparent,
                width: isSelected ? 1.1 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: item.color,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    item.icon ?? Icons.pie_chart_outline,
                    size: layout.iconSizes.sm,
                    color: colors.surface,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Row(
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: titleStyle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(amountText, maxLines: 1, style: amountStyle),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryBreakdownList extends StatelessWidget {
  const _CategoryBreakdownList({
    required this.items,
    required this.currencyFormat,
    required this.highlightedKey,
    required this.onToggle,
  });

  final List<AnalyticsChartItem> items;
  final NumberFormat currencyFormat;
  final String? highlightedKey;
  final ValueChanged<AnalyticsChartItem> onToggle;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items
          .map((AnalyticsChartItem item) {
            final bool isSelected = highlightedKey == item.key;
            return SizedBox(
              width: 160,
              child: _TopCategoryLegendItem(
                item: item,
                amountText: currencyFormat.format(item.absoluteAmount),
                isSelected: isSelected,
                onTap: () => onToggle(item),
                compact: true,
              ),
            );
          })
          .toList(growable: false),
    );
  }
}

class _CategoriesChartModeToggle extends StatelessWidget {
  const _CategoriesChartModeToggle({
    required this.mode,
    required this.strings,
    required this.onModeChanged,
  });

  final _CategoriesChartMode mode;
  final AppLocalizations strings;
  final ValueChanged<_CategoriesChartMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _ChartModeButton(
            icon: Icons.donut_large,
            tooltip: strings.analyticsChartTypeDonut,
            selected: mode == _CategoriesChartMode.donut,
            onTap: () => onModeChanged(_CategoriesChartMode.donut),
          ),
          _ChartModeButton(
            icon: Icons.bar_chart_rounded,
            tooltip: strings.analyticsChartTypeBar,
            selected: mode == _CategoriesChartMode.bar,
            onTap: () => onModeChanged(_CategoriesChartMode.bar),
          ),
        ],
      ),
    );
  }
}

class _ChartModeButton extends StatelessWidget {
  const _ChartModeButton({
    required this.icon,
    required this.tooltip,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: selected ? colors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Icon(
              icon,
              size: 18,
              color: selected ? colors.onPrimary : colors.onSurfaceVariant,
            ),
          ),
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
