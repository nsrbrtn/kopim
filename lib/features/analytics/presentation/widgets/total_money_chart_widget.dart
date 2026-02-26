import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/analytics/domain/models/monthly_balance_data.dart';
import 'package:kopim/features/analytics/presentation/widgets/analytics_filter_chip.dart';
import 'package:kopim/features/analytics/presentation/widgets/analytics_info_button.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

const int _kVisibleTotalMonths = 6;

class TotalMoneyChartWidget extends StatefulWidget {
  const TotalMoneyChartWidget({
    super.key,
    required this.data,
    required this.currencySymbol,
    required this.selectedMonth,
    required this.onMonthSelected,
    required this.localeName,
    required this.monthFilterLabel,
    required this.accountFilterLabel,
    required this.isAccountFilterActive,
    required this.onMonthFilterTap,
    required this.onAccountsFilterTap,
  });

  final List<MonthlyBalanceData> data;
  final String currencySymbol;
  final DateTime selectedMonth;
  final ValueChanged<DateTime> onMonthSelected;
  final String localeName;
  final String monthFilterLabel;
  final String accountFilterLabel;
  final bool isAccountFilterActive;
  final VoidCallback onMonthFilterTap;
  final VoidCallback onAccountsFilterTap;

  @override
  State<TotalMoneyChartWidget> createState() => _TotalMoneyChartWidgetState();
}

class _TotalMoneyChartWidgetState extends State<TotalMoneyChartWidget> {
  int _windowStart = 0;

  @override
  void initState() {
    super.initState();
    _windowStart = _maxWindowStart(widget.data.length);
  }

  @override
  void didUpdateWidget(covariant TotalMoneyChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final int maxStart = _maxWindowStart(widget.data.length);
    if (_windowStart > maxStart) {
      _windowStart = maxStart;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final AppLocalizations strings = AppLocalizations.of(context)!;

    final List<MonthlyBalanceData> effectiveData = widget.data.isEmpty
        ? _placeholderBalanceData()
        : widget.data;

    final int maxStart = _maxWindowStart(effectiveData.length);
    final int selectedMonthIndex = effectiveData.indexWhere(
      (MonthlyBalanceData d) =>
          d.month.year == widget.selectedMonth.year &&
          d.month.month == widget.selectedMonth.month,
    );
    final int windowStart = _resolveWindowStartForSelection(
      currentStart: _windowStart.clamp(0, maxStart),
      selectedIndex: selectedMonthIndex,
      maxStart: maxStart,
    );
    final List<MonthlyBalanceData> visibleData = _sliceWindow(
      effectiveData,
      start: windowStart,
      count: _kVisibleTotalMonths,
    );

    final MonthlyBalanceData? selectedData = effectiveData.firstWhereOrNull(
      (MonthlyBalanceData d) =>
          d.month.year == widget.selectedMonth.year &&
          d.month.month == widget.selectedMonth.month,
    );

    final MonthlyBalanceData displayData =
        selectedData ??
        _findClosestMonthData(
          data: effectiveData,
          selectedMonth: widget.selectedMonth,
        );

    final NumberFormat compact = NumberFormat.compact(
      locale: widget.localeName,
    );
    final String amountText =
        '${compact.format(displayData.totalBalance.toDouble())} ${widget.currencySymbol}';
    final double minBalance = visibleData
        .map((MonthlyBalanceData d) => d.totalBalance.toDouble())
        .reduce((double a, double b) => a < b ? a : b);
    final double maxBalance = visibleData
        .map((MonthlyBalanceData d) => d.totalBalance.toDouble())
        .reduce((double a, double b) => a > b ? a : b);
    final double range = (maxBalance - minBalance).abs();
    final double yPadding = range == 0
        ? (maxBalance.abs() * 0.2 + 1)
        : range * 0.25;
    final double yMin = minBalance - yPadding;
    final double yMax = maxBalance + yPadding;

    return Container(
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
                  strings.analyticsTotalMoneyWidgetTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colors.onSurface,
                  ),
                ),
              ),
              const AnalyticsInfoButton(
                title: 'Денег всего',
                description:
                    'График показывает динамику общей суммы денег по месяцам. '
                    'Нажмите на точку, чтобы выбрать месяц для просмотра значения.',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              AnalyticsFilterChip(
                label: widget.monthFilterLabel,
                selected: true,
                onTap: widget.onMonthFilterTap,
              ),
              const SizedBox(width: 8),
              AnalyticsFilterChip(
                label: widget.accountFilterLabel,
                selected: widget.isAccountFilterActive,
                onTap: widget.onAccountsFilterTap,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            amountText,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                strings.analyticsSummaryNetLabel,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.outline,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest.withValues(alpha: 0.2),
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
          const SizedBox(height: 8),
          SizedBox(
            height: 200,
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              margin: EdgeInsets.zero,
              primaryXAxis: CategoryAxis(
                majorGridLines: const MajorGridLines(width: 0),
                axisLine: AxisLine(
                  color: colors.outline.withValues(alpha: 0.6),
                  width: 1,
                ),
                labelStyle: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurface,
                  letterSpacing: 0.5,
                ),
              ),
              primaryYAxis: NumericAxis(
                minimum: yMin,
                maximum: yMax,
                majorGridLines: MajorGridLines(
                  width: 1,
                  color: colors.outline.withValues(alpha: 0.2),
                ),
                axisLine: const AxisLine(width: 0),
                majorTickLines: const MajorTickLines(size: 0),
                numberFormat: NumberFormat.compact(locale: widget.localeName),
                labelStyle: theme.textTheme.labelSmall?.copyWith(
                  color: colors.outline,
                  letterSpacing: 0.5,
                ),
              ),
              series: <CartesianSeries<MonthlyBalanceData, String>>[
                AreaSeries<MonthlyBalanceData, String>(
                  dataSource: visibleData,
                  xValueMapper: (MonthlyBalanceData d, _) =>
                      _monthLabelUpper(d.month, widget.localeName),
                  yValueMapper: (MonthlyBalanceData d, _) =>
                      d.totalBalance.toDouble(),
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
                SplineSeries<MonthlyBalanceData, String>(
                  dataSource: visibleData,
                  xValueMapper: (MonthlyBalanceData d, _) =>
                      _monthLabelUpper(d.month, widget.localeName),
                  yValueMapper: (MonthlyBalanceData d, _) =>
                      d.totalBalance.toDouble(),
                  color: colors.primary,
                  width: 2,
                  markerSettings: MarkerSettings(
                    isVisible: true,
                    height: 6,
                    width: 6,
                    shape: DataMarkerType.circle,
                    borderWidth: 0,
                    color: colors.primary,
                  ),
                  animationDuration: 0,
                  onPointTap: (ChartPointDetails details) {
                    final int? i = details.pointIndex;
                    if (i == null || i >= visibleData.length) {
                      return;
                    }
                    widget.onMonthSelected(visibleData[i].month);
                  },
                ),
                ScatterSeries<MonthlyBalanceData, String>(
                  dataSource: visibleData,
                  xValueMapper: (MonthlyBalanceData d, _) =>
                      _monthLabelUpper(d.month, widget.localeName),
                  yValueMapper: (MonthlyBalanceData d, _) =>
                      d.totalBalance.toDouble(),
                  color: Colors.transparent,
                  markerSettings: const MarkerSettings(
                    isVisible: true,
                    height: 40,
                    width: 40,
                    shape: DataMarkerType.circle,
                    borderWidth: 0,
                    color: Colors.transparent,
                    borderColor: Colors.transparent,
                  ),
                  onPointTap: (ChartPointDetails details) {
                    final int? i = details.pointIndex;
                    if (i == null || i >= visibleData.length) {
                      return;
                    }
                    widget.onMonthSelected(visibleData[i].month);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

int _maxWindowStart(int dataLength) {
  if (dataLength <= _kVisibleTotalMonths) {
    return 0;
  }
  return dataLength - _kVisibleTotalMonths;
}

List<MonthlyBalanceData> _placeholderBalanceData() {
  final DateTime now = DateTime.now();
  final DateTime month = DateTime(now.year, now.month);
  return List<MonthlyBalanceData>.generate(
    _kVisibleTotalMonths,
    (int index) => MonthlyBalanceData(
      month: DateTime(
        month.year,
        month.month - (_kVisibleTotalMonths - 1 - index),
      ),
      totalBalance: MoneyAmount(minor: BigInt.zero, scale: 2),
    ),
    growable: false,
  );
}

int _resolveWindowStartForSelection({
  required int currentStart,
  required int selectedIndex,
  required int maxStart,
}) {
  if (selectedIndex < 0) {
    return currentStart.clamp(0, maxStart);
  }
  final int currentEnd = currentStart + _kVisibleTotalMonths - 1;
  if (selectedIndex >= currentStart && selectedIndex <= currentEnd) {
    return currentStart.clamp(0, maxStart);
  }
  return (selectedIndex - (_kVisibleTotalMonths - 1)).clamp(0, maxStart);
}

List<MonthlyBalanceData> _sliceWindow(
  List<MonthlyBalanceData> data, {
  required int start,
  required int count,
}) {
  if (data.isEmpty) {
    return const <MonthlyBalanceData>[];
  }
  final int safeStart = start.clamp(0, data.length - 1);
  final int safeEnd = (safeStart + count).clamp(0, data.length);
  return data.sublist(safeStart, safeEnd);
}

MonthlyBalanceData _findClosestMonthData({
  required List<MonthlyBalanceData> data,
  required DateTime selectedMonth,
}) {
  final int selectedOrdinal = _monthOrdinal(selectedMonth);
  MonthlyBalanceData closest = data.first;
  int minDistance = (_monthOrdinal(closest.month) - selectedOrdinal).abs();

  for (int i = 1; i < data.length; i++) {
    final MonthlyBalanceData candidate = data[i];
    final int distance = (_monthOrdinal(candidate.month) - selectedOrdinal)
        .abs();
    if (distance < minDistance) {
      closest = candidate;
      minDistance = distance;
    }
  }

  return closest;
}

int _monthOrdinal(DateTime month) => month.year * 12 + month.month;

String _monthLabel(DateTime month, String locale) {
  final String raw = DateFormat.MMM(locale).format(month);
  return raw.replaceAll('.', '');
}

String _monthLabelUpper(DateTime month, String locale) {
  return _monthLabel(month, locale).toUpperCase();
}
