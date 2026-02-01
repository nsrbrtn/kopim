import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:kopim/core/config/theme_extensions.dart';
import 'package:kopim/core/formatting/currency_symbols.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/core/widgets/phosphor_icon_utils.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/budgets/domain/entities/budget.dart';
import 'package:kopim/features/budgets/domain/entities/budget_category_allocation.dart';
import 'package:kopim/features/budgets/domain/entities/budget_progress.dart';
import 'package:kopim/features/budgets/domain/entities/budget_scope.dart';
import 'package:kopim/features/budgets/domain/services/budget_schedule.dart';
import 'package:kopim/features/budgets/presentation/budget_form_screen.dart';
import 'package:kopim/features/budgets/presentation/controllers/budgets_providers.dart';
import 'package:kopim/features/budgets/presentation/models/budget_category_spend.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/categories/presentation/utils/category_gradients.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/presentation/widgets/transaction_list_tile.dart';
import 'package:kopim/features/upcoming_payments/domain/models/upcoming_item.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';
import 'package:kopim/features/upcoming_payments/domain/providers/upcoming_payments_providers.dart';
import 'package:kopim/features/upcoming_payments/domain/services/time_service.dart';
import 'package:kopim/features/upcoming_payments/presentation/providers/upcoming_payment_selection_providers.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class BudgetOverviewScreen extends ConsumerStatefulWidget {
  const BudgetOverviewScreen({required this.budgetId, super.key});

  final String budgetId;

  @override
  ConsumerState<BudgetOverviewScreen> createState() =>
      _BudgetOverviewScreenState();
}

enum _BudgetOverviewRange { month, week }

class _BudgetOverviewScreenState extends ConsumerState<BudgetOverviewScreen> {
  _BudgetOverviewRange _range = _BudgetOverviewRange.month;
  final Set<String> _expandedCategoryIds = <String>{};

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    final KopimLayout layout = context.kopimLayout;
    final KopimSpacingScale spacing = layout.spacing;

    final AsyncValue<BudgetProgress> progressAsync = ref.watch(
      budgetProgressByIdProvider(widget.budgetId),
    );
    final AsyncValue<List<TransactionEntity>> transactionsAsync = ref.watch(
      budgetTransactionsStreamProvider,
    );
    final AsyncValue<List<Category>> categoriesAsync = ref.watch(
      budgetCategoriesStreamProvider,
    );
    final AsyncValue<List<AccountEntity>> accountsAsync = ref.watch(
      budgetAccountsStreamProvider,
    );
    final AsyncValue<List<UpcomingItem>> upcomingItemsAsync = ref.watch(
      homeUpcomingItemsProvider(limit: 12),
    );
    final AsyncValue<List<UpcomingPayment>> upcomingPaymentsAsync = ref.watch(
      watchUpcomingPaymentsProvider,
    );
    final AsyncValue<List<AccountEntity>> upcomingAccountsAsync = ref.watch(
      upcomingPaymentAccountsProvider,
    );
    final AsyncValue<List<Category>> upcomingCategoriesAsync = ref.watch(
      upcomingPaymentCategoriesProvider,
    );
    final TimeService timeService = ref.watch(timeServiceProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.budgetDetailTitle),
        actions: <Widget>[
          progressAsync.maybeWhen(
            data: (BudgetProgress progress) => TextButton(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) =>
                        BudgetFormScreen(initialBudget: progress.budget),
                  ),
                );
              },
              child: Text(strings.editButtonLabel),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: progressAsync.when(
        data: (BudgetProgress progress) {
          final Budget budget = progress.budget;
          final DateTime now = timeService.nowLocal();
          final DateTimeRange selectedRange = _resolveRange(now);
          const BudgetSchedule budgetSchedule = BudgetSchedule();
          final ({DateTime start, DateTime end}) budgetPeriod = budgetSchedule
              .periodFor(budget: budget, reference: now);
          final DateTimeRange cumulativeRange = DateTimeRange(
            start: budgetPeriod.start,
            end: selectedRange.end.isBefore(budgetPeriod.end)
                ? selectedRange.end
                : budgetPeriod.end,
          );
          final DateFormat dateFormat = DateFormat.MMMd(strings.localeName);
          final String periodLabel = strings.budgetPeriodLabel(
            dateFormat.format(selectedRange.start),
            dateFormat.format(
              selectedRange.end.subtract(const Duration(days: 1)),
            ),
          );

          final List<TransactionEntity> transactions =
              transactionsAsync.value ?? const <TransactionEntity>[];
          final List<Category> categories =
              categoriesAsync.value ?? const <Category>[];
          final List<AccountEntity> accounts =
              accountsAsync.value ?? const <AccountEntity>[];
          final List<TransactionEntity> scopedTransactions =
              _filterTransactions(
                budget: budget,
                transactions: transactions,
                range: selectedRange,
              );
          final List<TransactionEntity> cumulativeTransactions =
              _filterTransactions(
                budget: budget,
                transactions: transactions,
                range: cumulativeRange,
              );
          final List<TransactionEntity> expenseTransactions = scopedTransactions
              .where(
                (TransactionEntity tx) =>
                    tx.type == TransactionType.expense.storageValue,
              )
              .toList(growable: false);
          final List<TransactionEntity> cumulativeExpenses =
              cumulativeTransactions
                  .where(
                    (TransactionEntity tx) =>
                        tx.type == TransactionType.expense.storageValue,
                  )
                  .toList(growable: false);

          final _BudgetSummary summary = _buildSummary(
            budget: budget,
            transactions: _range == _BudgetOverviewRange.week
                ? cumulativeExpenses
                : expenseTransactions,
          );
          final List<_TrendPoint> trend = _buildTrendSeries(
            range: selectedRange,
            transactions: expenseTransactions,
            localeName: strings.localeName,
          );
          final _TrendDelta? trendDelta = _buildTrendDelta(
            budget: budget,
            transactions: transactions,
            range: selectedRange,
          );

          final List<BudgetCategorySpend> categorySpend = _computeCategorySpend(
            budget: budget,
            transactions: expenseTransactions,
            categories: categories,
          );

          final Map<String, Category> categoriesById = <String, Category>{
            for (final Category category in categories) category.id: category,
          };
          final Map<String, AccountEntity> accountsById =
              <String, AccountEntity>{
                for (final AccountEntity account in accounts)
                  account.id: account,
              };

          final List<UpcomingItem> upcomingItems =
              upcomingItemsAsync.value ?? const <UpcomingItem>[];
          final List<UpcomingPayment> upcomingPayments =
              upcomingPaymentsAsync.value ?? const <UpcomingPayment>[];
          final List<AccountEntity> upcomingAccounts =
              upcomingAccountsAsync.value ?? const <AccountEntity>[];
          final List<Category> upcomingCategories =
              upcomingCategoriesAsync.value ?? const <Category>[];
          final Map<String, AccountEntity> upcomingAccountsById =
              <String, AccountEntity>{
                for (final AccountEntity account in upcomingAccounts)
                  account.id: account,
              };
          final Map<String, Category> upcomingCategoriesById =
              <String, Category>{
                for (final Category category in upcomingCategories)
                  category.id: category,
              };
          final List<_UpcomingPaymentView> upcomingViews =
              _buildUpcomingPayments(
                items: upcomingItems,
                payments: upcomingPayments,
                range: selectedRange,
                timeService: timeService,
              );
          final bool categoriesLoading =
              transactionsAsync.isLoading || categoriesAsync.isLoading;
          final Object? categoriesError =
              transactionsAsync.error ?? categoriesAsync.error;
          final bool upcomingLoading =
              upcomingItemsAsync.isLoading ||
              upcomingPaymentsAsync.isLoading ||
              upcomingAccountsAsync.isLoading ||
              upcomingCategoriesAsync.isLoading;
          final Object? upcomingError =
              upcomingItemsAsync.error ??
              upcomingPaymentsAsync.error ??
              upcomingAccountsAsync.error ??
              upcomingCategoriesAsync.error;

          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                spacing.screen,
                spacing.section,
                spacing.screen,
                spacing.section,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _BudgetRangeToggle(
                    value: _range,
                    onChanged: (_BudgetOverviewRange value) {
                      setState(() => _range = value);
                    },
                    strings: strings,
                  ),
                  const SizedBox(height: 8),
                  _SummaryCard(
                    title: budget.title,
                    subtitle: periodLabel,
                    summary: summary,
                  ),
                  const SizedBox(height: 8),
                  _TrendCard(
                    title: strings.analyticsSummaryExpenseLabel,
                    periodLabel: periodLabel,
                    trend: trend,
                    delta: trendDelta,
                  ),
                  const SizedBox(height: 8),
                  _CategoriesSection(
                    title: strings.budgetsCategoryBreakdownTitle,
                    categorySpend: categorySpend,
                    transactions: expenseTransactions,
                    accountsById: accountsById,
                    categoriesById: categoriesById,
                    strings: strings,
                    expandedCategoryIds: _expandedCategoryIds,
                    onToggleCategory: (String id) {
                      setState(() {
                        if (_expandedCategoryIds.contains(id)) {
                          _expandedCategoryIds.remove(id);
                        } else {
                          _expandedCategoryIds.add(id);
                        }
                      });
                    },
                    isLoading: categoriesLoading,
                    errorMessage: categoriesError?.toString(),
                  ),
                  const SizedBox(height: 8),
                  _UpcomingPaymentsSection(
                    title: strings.homeUpcomingPaymentsTitle,
                    items: upcomingViews,
                    accountsById: upcomingAccountsById,
                    categoriesById: upcomingCategoriesById,
                    strings: strings,
                    isLoading: upcomingLoading,
                    errorMessage: upcomingError?.toString(),
                  ),
                  SizedBox(height: spacing.sectionLarge),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              error.toString(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ),
      ),
    );
  }

  DateTimeRange _resolveRange(DateTime now) {
    final DateTime today = DateUtils.dateOnly(now);
    switch (_range) {
      case _BudgetOverviewRange.week:
        final int delta = today.weekday - DateTime.monday;
        final DateTime start = today.subtract(Duration(days: delta));
        final DateTime end = start.add(const Duration(days: 7));
        return DateTimeRange(start: start, end: end);
      case _BudgetOverviewRange.month:
        final DateTime start = DateTime(today.year, today.month);
        final DateTime end = DateTime(today.year, today.month + 1);
        return DateTimeRange(start: start, end: end);
    }
  }
}

class _BudgetRangeToggle extends StatelessWidget {
  const _BudgetRangeToggle({
    required this.value,
    required this.onChanged,
    required this.strings,
  });

  final _BudgetOverviewRange value;
  final ValueChanged<_BudgetOverviewRange> onChanged;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    const Duration duration = Duration(milliseconds: 220);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        final double segmentWidth = width / 2;
        final int selectedIndex = value == _BudgetOverviewRange.month ? 0 : 1;

        return SizedBox(
          height: 48,
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: duration,
                curve: Curves.easeOutBack,
                left: selectedIndex * segmentWidth,
                top: 0,
                bottom: 0,
                width: segmentWidth,
                child: AnimatedContainer(
                  duration: duration,
                  curve: Curves.easeOutBack,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: colors.primary,
                    boxShadow: const <BoxShadow>[],
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _RangeSegmentItem(
                      label: strings.budgetPeriodMonthly,
                      selected: value == _BudgetOverviewRange.month,
                      onTap: () => onChanged(_BudgetOverviewRange.month),
                      selectedTextColor: colors.onPrimary,
                    ),
                  ),
                  Expanded(
                    child: _RangeSegmentItem(
                      label: strings.budgetPeriodWeekly,
                      selected: value == _BudgetOverviewRange.week,
                      onTap: () => onChanged(_BudgetOverviewRange.week),
                      selectedTextColor: colors.onPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RangeSegmentItem extends StatelessWidget {
  const _RangeSegmentItem({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.selectedTextColor,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color selectedTextColor;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle baseStyle =
        theme.textTheme.labelLarge ?? const TextStyle(fontSize: 16);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Center(
        child: AnimatedScale(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          scale: selected ? 1.0 : 0.95,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            style: baseStyle.copyWith(
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              color: selected
                  ? selectedTextColor
                  : theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.subtitle,
    required this.summary,
  });

  final String title;
  final String subtitle;
  final _BudgetSummary summary;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final NumberFormat formatter = NumberFormat.simpleCurrency(
      locale: AppLocalizations.of(context)!.localeName,
    );
    final double ratio = summary.limit <= 0
        ? 0
        : (summary.spent / summary.limit).clamp(0, 1);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: ratio.isFinite ? ratio : 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: _SummaryMetric(
                  label: AppLocalizations.of(context)!.budgetsSpentLabel,
                  value: formatter.format(summary.spent),
                  align: TextAlign.left,
                ),
              ),
              Expanded(
                child: _SummaryMetric(
                  label: AppLocalizations.of(context)!.budgetsLimitLabel,
                  value: formatter.format(summary.limit),
                  align: TextAlign.center,
                ),
              ),
              Expanded(
                child: _SummaryMetric(
                  label: summary.isExceeded
                      ? AppLocalizations.of(context)!.budgetsExceededLabel
                      : AppLocalizations.of(context)!.budgetsRemainingLabel,
                  value: formatter.format(summary.remaining.abs()),
                  valueColor: summary.isExceeded
                      ? colors.error
                      : colors.primary,
                  align: TextAlign.right,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.value,
    required this.align,
    this.valueColor,
  });

  final String label;
  final String value;
  final TextAlign align;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          label.toUpperCase(),
          textAlign: align,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colors.onSurfaceVariant,
            letterSpacing: 0.6,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: align,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: valueColor ?? colors.onSurface,
          ),
        ),
      ],
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({
    required this.title,
    required this.periodLabel,
    required this.trend,
    required this.delta,
  });

  final String title;
  final String periodLabel;
  final List<_TrendPoint> trend;
  final _TrendDelta? delta;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (delta != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    delta!.label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            periodLabel,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          _TrendChart(points: trend),
          const SizedBox(height: 8),
          _TrendLabels(points: trend),
        ],
      ),
    );
  }
}

class _TrendChart extends StatelessWidget {
  const _TrendChart({required this.points});

  final List<_TrendPoint> points;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return SizedBox(
      height: 120,
      child: CustomPaint(
        painter: _TrendChartPainter(
          points: points,
          lineColor: colors.primary,
          fillColor: colors.primary.withValues(alpha: 0.18),
          gridColor: colors.onSurfaceVariant.withValues(alpha: 0.2),
        ),
      ),
    );
  }
}

class _TrendLabels extends StatelessWidget {
  const _TrendLabels({required this.points});

  final List<_TrendPoint> points;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color textColor = theme.colorScheme.onSurfaceVariant;

    if (points.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<int> indices = <int>{
      0,
      (points.length * 0.25).floor(),
      (points.length * 0.5).floor(),
      (points.length * 0.75).floor(),
      points.length - 1,
    }.toList()..sort();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: indices.map((int index) {
        final String label = points[index].label;
        return Expanded(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(color: textColor),
          ),
        );
      }).toList(),
    );
  }
}

class _TrendChartPainter extends CustomPainter {
  _TrendChartPainter({
    required this.points,
    required this.lineColor,
    required this.fillColor,
    required this.gridColor,
  });

  final List<_TrendPoint> points;
  final Color lineColor;
  final Color fillColor;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    for (int i = 1; i <= 3; i++) {
      final double y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (points.length < 2) {
      return;
    }

    final double maxValue = points
        .map((_TrendPoint point) => point.value)
        .fold<double>(0, (double prev, double v) => math.max(prev, v));
    final double minValue = points
        .map((_TrendPoint point) => point.value)
        .fold<double>(
          double.infinity,
          (double prev, double v) => math.min(prev, v),
        );
    final double range = math.max(maxValue - minValue, 1);

    Offset pointOffset(int index) {
      final double x = size.width * index / (points.length - 1);
      final double normalized = (points[index].value - minValue) / range;
      final double y = size.height - normalized * size.height;
      return Offset(x, y);
    }

    final Path linePath = Path();
    final Path fillPath = Path();
    final Offset first = pointOffset(0);
    linePath.moveTo(first.dx, first.dy);
    fillPath.moveTo(first.dx, size.height);
    fillPath.lineTo(first.dx, first.dy);

    for (int i = 1; i < points.length; i++) {
      final Offset current = pointOffset(i);
      linePath.lineTo(current.dx, current.dy);
      fillPath.lineTo(current.dx, current.dy);
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    final Paint fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final Paint linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant _TrendChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.gridColor != gridColor;
  }
}

class _CategoriesSection extends StatefulWidget {
  const _CategoriesSection({
    required this.title,
    required this.categorySpend,
    required this.transactions,
    required this.accountsById,
    required this.categoriesById,
    required this.strings,
    required this.expandedCategoryIds,
    required this.onToggleCategory,
    required this.isLoading,
    required this.errorMessage,
  });

  final String title;
  final List<BudgetCategorySpend> categorySpend;
  final List<TransactionEntity> transactions;
  final Map<String, AccountEntity> accountsById;
  final Map<String, Category> categoriesById;
  final AppLocalizations strings;
  final Set<String> expandedCategoryIds;
  final ValueChanged<String> onToggleCategory;
  final bool isLoading;
  final String? errorMessage;

  @override
  State<_CategoriesSection> createState() => _CategoriesSectionState();
}

class _CategoriesSectionState extends State<_CategoriesSection> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    final List<BudgetCategorySpend> items = widget.categorySpend;
    final List<BudgetCategorySpend> topItems = items.take(3).toList();
    final List<BudgetCategorySpend> remainingItems = items.length > 3
        ? items.sublist(3)
        : const <BudgetCategorySpend>[];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  widget.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (remainingItems.isNotEmpty)
                TextButton(
                  onPressed: () => setState(() => _showAll = !_showAll),
                  child: Text(
                    _showAll
                        ? widget.strings.homeUpcomingPaymentsCollapse
                        : widget.strings.homeTransactionsFilterAll,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (widget.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (widget.errorMessage != null)
            Text(
              widget.errorMessage!,
              style: theme.textTheme.bodySmall?.copyWith(color: colors.error),
            )
          else if (items.isEmpty)
            Text(
              widget.strings.homeBudgetWidgetCategoriesEmpty,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            )
          else
            Column(
              children: <Widget>[
                for (final BudgetCategorySpend item in topItems)
                  _CategoryTile(
                    item: item,
                    transactions: widget.transactions,
                    accountsById: widget.accountsById,
                    categoriesById: widget.categoriesById,
                    strings: widget.strings,
                    isExpanded: widget.expandedCategoryIds.contains(
                      item.category.id,
                    ),
                    onToggle: widget.onToggleCategory,
                  ),
                if (_showAll)
                  for (final BudgetCategorySpend item in remainingItems)
                    _CategoryTile(
                      item: item,
                      transactions: widget.transactions,
                      accountsById: widget.accountsById,
                      categoriesById: widget.categoriesById,
                      strings: widget.strings,
                      isExpanded: widget.expandedCategoryIds.contains(
                        item.category.id,
                      ),
                      onToggle: widget.onToggleCategory,
                    ),
              ].separatedBy(const SizedBox(height: 8)).toList(),
            ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.item,
    required this.transactions,
    required this.accountsById,
    required this.categoriesById,
    required this.strings,
    required this.isExpanded,
    required this.onToggle,
  });

  final BudgetCategorySpend item;
  final List<TransactionEntity> transactions;
  final Map<String, AccountEntity> accountsById;
  final Map<String, Category> categoriesById;
  final AppLocalizations strings;
  final bool isExpanded;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final CategoryColorStyle colorStyle = resolveCategoryColorStyle(
      item.category.color,
    );
    final Color categoryColor =
        colorStyle.sampleColor ?? theme.colorScheme.primary;
    final PhosphorIconData? iconData = resolvePhosphorIconData(
      item.category.icon,
    );

    final List<TransactionEntity> categoryTransactions = transactions
        .where((TransactionEntity tx) => tx.categoryId == item.category.id)
        .toList(growable: false);

    final double limit = item.limit ?? 0;
    final double spent = item.spent;
    final double ratio = limit > 0 ? (spent / limit).clamp(0, 1) : 0;
    final NumberFormat currencyFormat = NumberFormat.simpleCurrency(
      locale: strings.localeName,
    );

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        collapsedShape: const RoundedRectangleBorder(),
        shape: const RoundedRectangleBorder(),
        onExpansionChanged: (_) => onToggle(item.category.id),
        initiallyExpanded: isExpanded,
        title: Row(
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: categoryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  iconData ?? PhosphorIconsRegular.squaresFour,
                  color: Colors.black87,
                  size: 20,
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
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: <Widget>[
                      Text(
                        currencyFormat.format(spent),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      if (limit > 0) ...<Widget>[
                        const SizedBox(width: 6),
                        Text(
                          '/ ${currencyFormat.format(limit)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: ratio,
                        child: Container(
                          decoration: BoxDecoration(
                            color: categoryColor,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        children: <Widget>[
          if (categoryTransactions.isEmpty)
            Text(
              strings.analyticsCategoryTransactionsEmpty,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            )
          else
            Column(
              children: categoryTransactions.map((
                TransactionEntity transaction,
              ) {
                final AccountEntity? account =
                    accountsById[transaction.accountId];
                final Category? category =
                    categoriesById[transaction.categoryId ?? item.category.id];
                return TransactionListTile(
                  transaction: transaction,
                  category: category,
                  currency: account?.currency ?? '',
                  accountName: account?.name,
                  strings: strings,
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _UpcomingPaymentsSection extends StatelessWidget {
  const _UpcomingPaymentsSection({
    required this.title,
    required this.items,
    required this.accountsById,
    required this.categoriesById,
    required this.strings,
    required this.isLoading,
    required this.errorMessage,
  });

  final String title;
  final List<_UpcomingPaymentView> items;
  final Map<String, AccountEntity> accountsById;
  final Map<String, Category> categoriesById;
  final AppLocalizations strings;
  final bool isLoading;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (errorMessage != null)
            Text(
              errorMessage!,
              style: theme.textTheme.bodySmall?.copyWith(color: colors.error),
            )
          else if (items.isEmpty)
            Text(
              strings.homeUpcomingPaymentsEmpty,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            )
          else
            SizedBox(
              height: 132,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int index) {
                  final _UpcomingPaymentView view = items[index];
                  return _UpcomingPaymentCard(
                    view: view,
                    account: view.accountId == null
                        ? null
                        : accountsById[view.accountId],
                    category: view.categoryId == null
                        ? null
                        : categoriesById[view.categoryId],
                    strings: strings,
                  );
                },
                separatorBuilder: (BuildContext context, int index) =>
                    const SizedBox(width: 8),
                itemCount: items.length,
              ),
            ),
        ],
      ),
    );
  }
}

class _UpcomingPaymentCard extends StatelessWidget {
  const _UpcomingPaymentCard({
    required this.view,
    required this.account,
    required this.category,
    required this.strings,
  });

  final _UpcomingPaymentView view;
  final AccountEntity? account;
  final Category? category;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final CategoryColorStyle colorStyle = resolveCategoryColorStyle(
      category?.color,
    );
    final PhosphorIconData? iconData = resolvePhosphorIconData(category?.icon);
    final String currencySymbol = account?.currency.isNotEmpty == true
        ? resolveCurrencySymbol(account!.currency, locale: strings.localeName)
        : NumberFormat.simpleCurrency(
            locale: strings.localeName,
          ).currencySymbol;
    final NumberFormat formatter = NumberFormat.currency(
      locale: strings.localeName,
      symbol: currencySymbol,
    );
    final DateFormat dateFormat = DateFormat.MMMd(strings.localeName);
    final Color backgroundColor =
        colorStyle.sampleColor ?? colors.surfaceContainerHighest;

    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                iconData ?? PhosphorIconsRegular.creditCard,
                size: 18,
                color: Colors.black87,
              ),
            ),
          ),
          const Spacer(),
          Text(
            dateFormat.format(view.date),
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            view.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formatter.format(view.amount.toDouble()),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetSummary {
  const _BudgetSummary({
    required this.spent,
    required this.limit,
    required this.remaining,
    required this.isExceeded,
  });

  final double spent;
  final double limit;
  final double remaining;
  final bool isExceeded;
}

_BudgetSummary _buildSummary({
  required Budget budget,
  required List<TransactionEntity> transactions,
}) {
  final MoneyAccumulator accumulator = MoneyAccumulator();
  for (final TransactionEntity tx in transactions) {
    accumulator.add(tx.amountValue.abs());
  }
  final double spent = accumulator.toDouble();
  final double limit = budget.amountValue.toDouble();
  final double remaining = limit - spent;
  return _BudgetSummary(
    spent: spent,
    limit: limit,
    remaining: remaining,
    isExceeded: spent > limit,
  );
}

List<TransactionEntity> _filterTransactions({
  required Budget budget,
  required List<TransactionEntity> transactions,
  required DateTimeRange range,
}) {
  final DateTime start = DateUtils.dateOnly(range.start);
  final DateTime end = DateUtils.dateOnly(range.end);
  return transactions
      .where((TransactionEntity tx) => _matchesScope(budget, tx))
      .where(
        (TransactionEntity tx) =>
            !tx.date.isBefore(start) && tx.date.isBefore(end),
      )
      .toList(growable: false);
}

bool _matchesScope(Budget budget, TransactionEntity transaction) {
  switch (budget.scope) {
    case BudgetScope.all:
      return true;
    case BudgetScope.byCategory:
      if (budget.categories.isEmpty) {
        return false;
      }
      final String? categoryId = transaction.categoryId;
      return categoryId != null && budget.categories.contains(categoryId);
    case BudgetScope.byAccount:
      if (budget.accounts.isEmpty) {
        return false;
      }
      return budget.accounts.contains(transaction.accountId);
  }
}

List<BudgetCategorySpend> _computeCategorySpend({
  required Budget budget,
  required List<TransactionEntity> transactions,
  required List<Category> categories,
}) {
  final Map<String, double> spentByCategory = <String, double>{};
  for (final TransactionEntity transaction in transactions) {
    if (transaction.type != TransactionType.expense.storageValue) {
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

class _TrendPoint {
  const _TrendPoint({
    required this.date,
    required this.value,
    required this.label,
  });

  final DateTime date;
  final double value;
  final String label;
}

List<_TrendPoint> _buildTrendSeries({
  required DateTimeRange range,
  required List<TransactionEntity> transactions,
  required String localeName,
}) {
  final DateTime start = DateUtils.dateOnly(range.start);
  final DateTime end = DateUtils.dateOnly(range.end);
  final int days = end.difference(start).inDays;
  final Map<DateTime, double> totalsByDay = <DateTime, double>{};

  for (final TransactionEntity tx in transactions) {
    if (tx.type != TransactionType.expense.storageValue) {
      continue;
    }
    final DateTime day = DateUtils.dateOnly(tx.date);
    totalsByDay[day] =
        (totalsByDay[day] ?? 0) + tx.amountValue.abs().toDouble();
  }

  final DateFormat labelFormat = DateFormat.MMMd(localeName);
  return List<_TrendPoint>.generate(days, (int index) {
    final DateTime day = start.add(Duration(days: index));
    return _TrendPoint(
      date: day,
      value: totalsByDay[day] ?? 0,
      label: labelFormat.format(day),
    );
  });
}

class _TrendDelta {
  const _TrendDelta({required this.percent});

  final double percent;

  String get label {
    final String sign = percent >= 0 ? '+' : '';
    return '$sign${percent.toStringAsFixed(0)}%';
  }
}

_TrendDelta? _buildTrendDelta({
  required Budget budget,
  required List<TransactionEntity> transactions,
  required DateTimeRange range,
}) {
  final bool isMonthRange =
      range.start.day == 1 &&
      range.end.day == 1 &&
      range.duration.inDays >= 28 &&
      range.duration.inDays <= 31;
  final DateTime previousStart = isMonthRange
      ? DateTime(range.start.year, range.start.month - 1)
      : range.start.subtract(range.duration);
  final DateTimeRange previousRange = DateTimeRange(
    start: previousStart,
    end: range.start,
  );
  final List<TransactionEntity> current = _filterTransactions(
    budget: budget,
    transactions: transactions,
    range: range,
  );
  final List<TransactionEntity> previous = _filterTransactions(
    budget: budget,
    transactions: transactions,
    range: previousRange,
  );
  double sumTransactions(List<TransactionEntity> list) {
    double total = 0;
    for (final TransactionEntity tx in list) {
      if (tx.type == TransactionType.expense.storageValue) {
        total += tx.amountValue.abs().toDouble();
      }
    }
    return total;
  }

  final double currentSpent = sumTransactions(current);
  final double previousSpent = sumTransactions(previous);
  if (previousSpent <= 0) {
    return null;
  }
  final double percent = ((currentSpent - previousSpent) / previousSpent) * 100;
  if (!percent.isFinite) {
    return null;
  }
  return _TrendDelta(percent: percent);
}

class _UpcomingPaymentView {
  const _UpcomingPaymentView({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.accountId,
    required this.categoryId,
  });

  final String id;
  final String title;
  final MoneyAmount amount;
  final DateTime date;
  final String? accountId;
  final String? categoryId;
}

List<_UpcomingPaymentView> _buildUpcomingPayments({
  required List<UpcomingItem> items,
  required List<UpcomingPayment> payments,
  required DateTimeRange range,
  required TimeService timeService,
}) {
  final DateTime start = DateUtils.dateOnly(range.start);
  final DateTime end = DateUtils.dateOnly(range.end);
  final Map<String, UpcomingPayment> paymentsById = <String, UpcomingPayment>{
    for (final UpcomingPayment payment in payments) payment.id: payment,
  };
  final List<_UpcomingPaymentView> views = <_UpcomingPaymentView>[];
  for (final UpcomingItem item in items) {
    final DateTime date = timeService.toLocal(item.whenMs);
    final DateTime dateOnly = DateUtils.dateOnly(date);
    if (dateOnly.isBefore(start) || !dateOnly.isBefore(end)) {
      continue;
    }
    final UpcomingPayment? payment = item.type == UpcomingItemType.paymentRule
        ? paymentsById[item.id]
        : null;
    if (payment != null && !payment.isActive) {
      continue;
    }
    views.add(
      _UpcomingPaymentView(
        id: item.id,
        title: item.title,
        amount: item.amount.abs(),
        date: date,
        accountId: payment?.accountId,
        categoryId: payment?.categoryId,
      ),
    );
  }

  views.sort(
    (_UpcomingPaymentView a, _UpcomingPaymentView b) =>
        a.date.compareTo(b.date),
  );
  return views;
}

extension on Iterable<Widget> {
  Iterable<Widget> separatedBy(Widget separator) sync* {
    bool first = true;
    for (final Widget child in this) {
      if (!first) {
        yield separator;
      }
      first = false;
      yield child;
    }
  }
}
