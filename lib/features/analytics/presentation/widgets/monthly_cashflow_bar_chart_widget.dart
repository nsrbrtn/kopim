import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kopim/features/analytics/presentation/models/monthly_cashflow_data.dart';
import 'package:kopim/features/analytics/presentation/widgets/analytics_filter_chip.dart';
import 'package:kopim/features/analytics/presentation/widgets/analytics_info_button.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

const int _kVisibleMonths = 6;

class MonthlyCashflowBarChartWidget extends StatefulWidget {
  const MonthlyCashflowBarChartWidget({
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

  final List<MonthlyCashflowData> data;
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
  State<MonthlyCashflowBarChartWidget> createState() =>
      _MonthlyCashflowBarChartWidgetState();
}

class _MonthlyCashflowBarChartWidgetState
    extends State<MonthlyCashflowBarChartWidget> {
  int _windowStart = 0;

  @override
  void initState() {
    super.initState();
    final int dataLength = widget.data.isEmpty ? 12 : widget.data.length;
    _windowStart = _maxWindowStart(dataLength);
  }

  @override
  void didUpdateWidget(covariant MonthlyCashflowBarChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final int dataLength = widget.data.isEmpty ? 12 : widget.data.length;
    final int maxStart = _maxWindowStart(dataLength);
    if (_windowStart > maxStart) {
      _windowStart = maxStart;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final AppLocalizations strings = AppLocalizations.of(context)!;

    final List<MonthlyCashflowData> effectiveData = widget.data.isEmpty
        ? _placeholderData()
        : widget.data;
    final int maxStart = _maxWindowStart(effectiveData.length);
    final int selectedMonthIndex = effectiveData.indexWhere(
      (MonthlyCashflowData item) =>
          item.month.year == widget.selectedMonth.year &&
          item.month.month == widget.selectedMonth.month,
    );
    final int windowStart = _resolveWindowStartForSelection(
      currentStart: _windowStart.clamp(0, maxStart),
      selectedIndex: selectedMonthIndex,
      maxStart: maxStart,
    );

    final List<MonthlyCashflowData> visibleData = _sliceWindow(
      effectiveData,
      start: windowStart,
      count: _kVisibleMonths,
    );

    final MonthlyCashflowData displayData = _findClosestMonthData(
      data: effectiveData,
      selectedMonth: widget.selectedMonth,
    );

    final NumberFormat compact = NumberFormat.compact(
      locale: widget.localeName,
    );

    double maxPositive = 0;
    for (final MonthlyCashflowData d in visibleData) {
      if (d.income > maxPositive) {
        maxPositive = d.income;
      }
      if (d.expense > maxPositive) {
        maxPositive = d.expense;
      }
      if (d.net > maxPositive) {
        maxPositive = d.net;
      }
    }
    final double yMax = maxPositive <= 0 ? 100 : maxPositive * 1.2;
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
                  strings.analyticsCashflowWidgetTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colors.onSurface,
                  ),
                ),
              ),
              const AnalyticsInfoButton(
                title: 'Остаток денег',
                description:
                    'График показывает траты, доходы и итоговый остаток по месяцам. '
                    'Чипы сверху позволяют менять период и набор счетов.',
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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _MetricChip(
                label: strings.analyticsSummaryExpenseLabel,
                value:
                    '${compact.format(displayData.expense)} ${widget.currencySymbol}',
                background: colors.onErrorContainer,
                foreground: colors.surface,
              ),
              _MetricChip(
                label: strings.analyticsSummaryIncomeLabel,
                value:
                    '${compact.format(displayData.income)} ${widget.currencySymbol}',
                background: colors.onPrimaryContainer,
                foreground: colors.onSurface,
              ),
              _MetricChip(
                label: strings.analyticsSummaryNetLabel,
                value:
                    '${compact.format(displayData.net)} ${widget.currencySymbol}',
                background: colors.onTertiaryContainer,
                foreground: colors.onSurface,
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 210,
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
                minimum: 0,
                maximum: yMax,
                majorGridLines: MajorGridLines(
                  width: 1,
                  color: colors.outline.withValues(alpha: 0.2),
                ),
                axisLine: const AxisLine(width: 0),
                majorTickLines: const MajorTickLines(size: 0),
                numberFormat: NumberFormat.compact(locale: widget.localeName),
                labelStyle: theme.textTheme.labelSmall?.copyWith(
                  color: colors.surfaceContainerHighest,
                  letterSpacing: 0.5,
                ),
              ),
              series: <CartesianSeries<MonthlyCashflowData, String>>[
                ColumnSeries<MonthlyCashflowData, String>(
                  dataSource: visibleData,
                  xValueMapper: (MonthlyCashflowData d, _) =>
                      _monthLabelUpper(d.month, widget.localeName),
                  yValueMapper: (MonthlyCashflowData d, _) => d.expense,
                  color: colors.onErrorContainer,
                  width: 1,
                  spacing: 0.45,
                  borderRadius: const BorderRadius.all(Radius.circular(6)),
                  animationDuration: 0,
                  onPointTap: (ChartPointDetails details) {
                    final int? i = details.pointIndex;
                    if (i == null || i >= visibleData.length) {
                      return;
                    }
                    widget.onMonthSelected(visibleData[i].month);
                  },
                ),
                ColumnSeries<MonthlyCashflowData, String>(
                  dataSource: visibleData,
                  xValueMapper: (MonthlyCashflowData d, _) =>
                      _monthLabelUpper(d.month, widget.localeName),
                  yValueMapper: (MonthlyCashflowData d, _) => d.income,
                  color: colors.onPrimaryContainer,
                  width: 1,
                  spacing: 0.45,
                  borderRadius: const BorderRadius.all(Radius.circular(6)),
                  animationDuration: 0,
                  onPointTap: (ChartPointDetails details) {
                    final int? i = details.pointIndex;
                    if (i == null || i >= visibleData.length) {
                      return;
                    }
                    widget.onMonthSelected(visibleData[i].month);
                  },
                ),
                ColumnSeries<MonthlyCashflowData, String>(
                  dataSource: visibleData,
                  xValueMapper: (MonthlyCashflowData d, _) =>
                      _monthLabelUpper(d.month, widget.localeName),
                  yValueMapper: (MonthlyCashflowData d, _) => d.net,
                  color: colors.onTertiaryContainer,
                  width: 1,
                  spacing: 0.45,
                  borderRadius: const BorderRadius.all(Radius.circular(6)),
                  animationDuration: 0,
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

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.value,
    required this.background,
    required this.foreground,
  });

  final String label;
  final String value;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '$label: $value',
        style: theme.textTheme.labelMedium?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

List<MonthlyCashflowData> _placeholderData() {
  final DateTime now = DateTime.now();
  final DateTime month = DateTime(now.year, now.month);
  return List<MonthlyCashflowData>.generate(
    12,
    (int index) => MonthlyCashflowData(
      month: DateTime(month.year, month.month - (11 - index)),
      income: 0,
      expense: 0,
    ),
    growable: false,
  );
}

int _maxWindowStart(int dataLength) {
  if (dataLength <= _kVisibleMonths) {
    return 0;
  }
  return dataLength - _kVisibleMonths;
}

int _resolveWindowStartForSelection({
  required int currentStart,
  required int selectedIndex,
  required int maxStart,
}) {
  if (selectedIndex < 0) {
    return currentStart.clamp(0, maxStart);
  }
  final int currentEnd = currentStart + _kVisibleMonths - 1;
  if (selectedIndex >= currentStart && selectedIndex <= currentEnd) {
    return currentStart.clamp(0, maxStart);
  }
  return (selectedIndex - (_kVisibleMonths - 1)).clamp(0, maxStart);
}

List<MonthlyCashflowData> _sliceWindow(
  List<MonthlyCashflowData> data, {
  required int start,
  required int count,
}) {
  if (data.isEmpty) {
    return const <MonthlyCashflowData>[];
  }
  final int safeStart = start.clamp(0, data.length - 1);
  final int safeEnd = (safeStart + count).clamp(0, data.length);
  return data.sublist(safeStart, safeEnd);
}

MonthlyCashflowData _findClosestMonthData({
  required List<MonthlyCashflowData> data,
  required DateTime selectedMonth,
}) {
  final int selectedOrdinal = _monthOrdinal(selectedMonth);
  MonthlyCashflowData closest = data.first;
  int minDistance = (_monthOrdinal(closest.month) - selectedOrdinal).abs();

  for (int i = 1; i < data.length; i++) {
    final MonthlyCashflowData candidate = data[i];
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
