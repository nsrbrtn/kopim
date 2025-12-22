import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kopim/features/analytics/presentation/models/monthly_cashflow_data.dart';
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
  });

  final List<MonthlyCashflowData> data;
  final String currencySymbol;
  final DateTime selectedMonth;
  final ValueChanged<DateTime> onMonthSelected;
  final String localeName;

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
    _windowStart = _initialWindowStart(dataLength);
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

    final List<MonthlyCashflowData> effectiveData = widget.data.isEmpty
        ? _placeholderData()
        : widget.data;

    final List<MonthlyCashflowData> visibleData = _sliceWindow(
      effectiveData,
      start: _windowStart,
      count: _kVisibleMonths,
    );

    final MonthlyCashflowData? selectedData = effectiveData.firstWhereOrNull(
      (MonthlyCashflowData d) =>
          d.month.year == widget.selectedMonth.year &&
          d.month.month == widget.selectedMonth.month,
    );
    final MonthlyCashflowData displayData = selectedData ?? effectiveData.last;

    double maxPositive = 0;
    for (final MonthlyCashflowData d in effectiveData) {
      if (d.income > maxPositive) {
        maxPositive = d.income;
      }
      if (d.expense > maxPositive) {
        maxPositive = d.expense;
      }
    }

    final double yMax = maxPositive <= 0 ? 100 : maxPositive * 1.15;
    const double yMin = 0;

    final NumberFormat compact = NumberFormat.compact(
      locale: widget.localeName,
    );
    final String monthName = DateFormat(
      'LLLL',
      widget.localeName,
    ).format(displayData.month);

    final Color incomeColor = colors.primary;
    final Color expenseColor = colors.error;
    final Color netPositiveColor = colors.tertiary;

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
              Text(
                'Остаток денег',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  Icons.help_outline,
                  size: 20,
                  color: colors.onSurfaceVariant,
                ),
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('О виджете'),
                        content: const Text(
                          'Доходы и расходы считаются по месяцам. Остаток — это доходы минус расходы за выбранный месяц. Для текущего месяца учитываются данные на сегодня.',
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Понятно'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _capitalize(monthName),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              height: 20 / 14,
              fontWeight: FontWeight.w500,
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: _LegendMetric(
                  label: 'Доход',
                  value:
                      '${compact.format(displayData.income)} ${widget.currencySymbol}',
                  valueColor: incomeColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _LegendMetric(
                  label: 'Расход',
                  value:
                      '${compact.format(displayData.expense)} ${widget.currencySymbol}',
                  valueColor: expenseColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _LegendMetric(
                  label: 'Остаток',
                  value:
                      '${compact.format(displayData.net)} ${widget.currencySymbol}',
                  valueColor: displayData.net >= 0
                      ? colors.tertiary
                      : colors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragEnd: (DragEndDetails details) {
                const double threshold = 150;
                final double velocityX = details.velocity.pixelsPerSecond.dx;
                if (velocityX.abs() < threshold) {
                  return;
                }
                final bool goOlder = velocityX > 0;
                _shiftWindow(
                  goOlder: goOlder,
                  dataLength: effectiveData.length,
                );
              },
              child: SfCartesianChart(
                plotAreaBorderWidth: 0,
                margin: EdgeInsets.zero,
                primaryXAxis: CategoryAxis(
                  majorGridLines: const MajorGridLines(width: 0),
                  axisLine: const AxisLine(width: 0),
                  labelIntersectAction: AxisLabelIntersectAction.hide,
                  labelStyle: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    height: 16 / 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                primaryYAxis: NumericAxis(
                  isVisible: false,
                  minimum: yMin,
                  maximum: yMax,
                ),
                series: <CartesianSeries<MonthlyCashflowData, String>>[
                  ColumnSeries<MonthlyCashflowData, String>(
                    dataSource: visibleData,
                    xValueMapper: (MonthlyCashflowData d, _) => d.monthLabel,
                    yValueMapper: (MonthlyCashflowData d, _) => d.income,
                    color: incomeColor,
                    width: 0.44,
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
                    xValueMapper: (MonthlyCashflowData d, _) => d.monthLabel,
                    yValueMapper: (MonthlyCashflowData d, _) => d.expense,
                    color: expenseColor.withValues(alpha: 0.85),
                    width: 0.44,
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
                    xValueMapper: (MonthlyCashflowData d, _) => d.monthLabel,
                    yValueMapper: (MonthlyCashflowData d, _) =>
                        d.net > 0 ? d.net : null,
                    pointColorMapper: (MonthlyCashflowData d, _) => d.net >= 0
                        ? netPositiveColor.withValues(alpha: 0.85)
                        : colors.error.withValues(alpha: 0.85),
                    width: 0.44,
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
                  // Прозрачная серия для увеличения зоны нажатия по месяцу.
                  ScatterSeries<MonthlyCashflowData, String>(
                    dataSource: visibleData,
                    xValueMapper: (MonthlyCashflowData d, _) => d.monthLabel,
                    yValueMapper: (MonthlyCashflowData d, _) => yMax / 2,
                    color: Colors.transparent,
                    markerSettings: const MarkerSettings(
                      isVisible: true,
                      height: 50,
                      width: 40,
                      shape: DataMarkerType.rectangle,
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
          ),
        ],
      ),
    );
  }

  void _shiftWindow({required bool goOlder, required int dataLength}) {
    if (dataLength <= _kVisibleMonths) {
      return;
    }
    final int maxStart = _maxWindowStart(dataLength);
    final int nextStart = goOlder
        ? (_windowStart - 1).clamp(0, maxStart)
        : (_windowStart + 1).clamp(0, maxStart);
    if (nextStart == _windowStart) {
      return;
    }
    setState(() {
      _windowStart = nextStart;
    });
  }
}

class _LegendMetric extends StatelessWidget {
  const _LegendMetric({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

String _capitalize(String value) {
  if (value.isEmpty) {
    return value;
  }
  return '${value[0].toUpperCase()}${value.substring(1)}';
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

int _initialWindowStart(int dataLength) {
  return _maxWindowStart(dataLength);
}

int _maxWindowStart(int dataLength) {
  if (dataLength <= _kVisibleMonths) {
    return 0;
  }
  return dataLength - _kVisibleMonths;
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
