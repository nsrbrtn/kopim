import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kopim/features/analytics/domain/models/monthly_balance_data.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class TotalMoneyChartWidget extends StatefulWidget {
  const TotalMoneyChartWidget({
    super.key,
    required this.data,
    required this.currencySymbol,
    required this.selectedMonth,
    required this.onMonthSelected,
    required this.localeName,
  });

  final List<MonthlyBalanceData> data;
  final String currencySymbol;
  final DateTime selectedMonth;
  final ValueChanged<DateTime> onMonthSelected;
  final String localeName;

  @override
  State<TotalMoneyChartWidget> createState() => _TotalMoneyChartWidgetState();
}

class _TotalMoneyChartWidgetState extends State<TotalMoneyChartWidget> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final AppLocalizations strings = AppLocalizations.of(context)!;

    if (widget.data.isEmpty) {
      return const SizedBox.shrink();
    }

    // Найти данные для выбранного месяца
    final MonthlyBalanceData? selectedData = widget.data.firstWhereOrNull(
      (MonthlyBalanceData d) =>
          d.month.year == widget.selectedMonth.year &&
          d.month.month == widget.selectedMonth.month,
    );

    // Если выбранный месяц вне диапазона, показываем ближайший доступный.
    final MonthlyBalanceData displayData =
        selectedData ??
        _findClosestMonthData(
          data: widget.data,
          selectedMonth: widget.selectedMonth,
        );

    // Найти минимальное и максимальное значение для настройки осей
    final double minBalance = widget.data
        .map((MonthlyBalanceData d) => d.totalBalance.toDouble())
        .reduce((double a, double b) => a < b ? a : b);
    final double maxBalance = widget.data
        .map((MonthlyBalanceData d) => d.totalBalance.toDouble())
        .reduce((double a, double b) => a > b ? a : b);

    // Настройка отступов в пикселях
    const double chartHeight = 160;
    const double topPadding = 32;
    const double bottomPadding = 16;
    const double availableHeight = chartHeight - topPadding - bottomPadding;

    final double range = maxBalance - minBalance;
    // Если диапазон 0, задаем дефолтный
    final double effectiveRange = range == 0
        ? (maxBalance == 0 ? 100 : maxBalance * 0.2)
        : range;

    // Рассчитываем диапазон оси Y так, чтобы данные занимали availableHeight
    // R = (max - min) * H / (H - Top - Bottom)
    final double axisRange = effectiveRange * chartHeight / availableHeight;

    // axisMax = max + (Top / H) * R
    final double yMax = maxBalance + (topPadding / chartHeight) * axisRange;
    final double yMin = yMax - axisRange;

    final NumberFormat formatter = NumberFormat.compact(
      locale: widget.localeName,
    );
    final String monthName = DateFormat(
      'LLLL',
      widget.localeName,
    ).format(displayData.month);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Title and Help
          Row(
            children: <Widget>[
              Text(
                strings.analyticsTotalMoneyWidgetTitle,
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
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(strings.analyticsTotalMoneyWidgetInfoTitle),
                        content: Text(
                          strings.analyticsTotalMoneyWidgetInfoBody,
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(strings.analyticsDialogClose),
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
          // Selected Month Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                monthName.capitalize(),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  height: 20 / 14,
                  fontWeight: FontWeight.w500,
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${formatter.format(displayData.totalBalance.toDouble())} ${widget.currencySymbol}',
                style: TextStyle(
                  fontFamily: 'Onest',
                  fontSize: 32,
                  height: 40 / 32,
                  fontWeight: FontWeight.w400,
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: chartHeight,
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              margin: EdgeInsets.zero,
              primaryXAxis: CategoryAxis(
                majorGridLines: const MajorGridLines(width: 0),
                axisLine: const AxisLine(width: 0),
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
              annotations: <CartesianChartAnnotation>[
                CartesianChartAnnotation(
                  widget: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: colors.primary.withValues(alpha: 0.5),
                          blurRadius: 10,
                          spreadRadius: 2.5,
                        ),
                      ],
                    ),
                  ),
                  coordinateUnit: CoordinateUnit.point,
                  x: _monthLabel(displayData.month, widget.localeName),
                  y: displayData.totalBalance.toDouble(),
                ),
              ],
              series: <CartesianSeries<MonthlyBalanceData, String>>[
                SplineSeries<MonthlyBalanceData, String>(
                  dataSource: widget.data,
                  xValueMapper: (MonthlyBalanceData d, _) =>
                      _monthLabel(d.month, widget.localeName),
                  yValueMapper: (MonthlyBalanceData d, _) =>
                      d.totalBalance.toDouble(),
                  color: colors.primary,
                  width: 2,
                  animationDuration: 0,
                  markerSettings: MarkerSettings(
                    isVisible: true,
                    height: 8,
                    width: 8,
                    shape: DataMarkerType.circle,
                    borderWidth: 2,
                    borderColor: colors.surfaceContainer,
                    color: colors.primary,
                  ),
                  selectionBehavior: SelectionBehavior(
                    enable: false,
                    selectedColor: colors.primary,
                    unselectedColor: colors.primary.withValues(alpha: 0.5),
                    selectedBorderColor: colors.surfaceContainer,
                    selectedBorderWidth: 2,
                    unselectedBorderColor: colors.surfaceContainer,
                    unselectedBorderWidth: 2,
                  ),
                ),
                // Прозрачная серия для увеличения зоны нажатия
                ScatterSeries<MonthlyBalanceData, String>(
                  dataSource: widget.data,
                  xValueMapper: (MonthlyBalanceData d, _) =>
                      _monthLabel(d.month, widget.localeName),
                  yValueMapper: (MonthlyBalanceData d, _) =>
                      d.totalBalance.toDouble(),
                  color: Colors.transparent,
                  markerSettings: const MarkerSettings(
                    isVisible: true,
                    height: 40, // Большая зона клика
                    width: 40,
                    shape: DataMarkerType.circle,
                    borderWidth: 0,
                    color: Colors.transparent,
                    borderColor: Colors.transparent,
                  ),
                  onPointTap: (ChartPointDetails details) {
                    if (details.pointIndex != null &&
                        details.pointIndex! < widget.data.length) {
                      widget.onMonthSelected(
                        widget.data[details.pointIndex!].month,
                      );
                    }
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

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
