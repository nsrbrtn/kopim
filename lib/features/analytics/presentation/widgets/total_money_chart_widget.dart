import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kopim/features/analytics/domain/models/monthly_balance_data.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class TotalMoneyChartWidget extends StatelessWidget {
  const TotalMoneyChartWidget({
    super.key,
    required this.data,
    required this.currencySymbol,
  });

  final List<MonthlyBalanceData> data;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    if (data.isEmpty) {
      return const SizedBox.shrink();
    }

    // Найти минимальное и максимальное значение для настройки осей
    final double minBalance = data
        .map((MonthlyBalanceData d) => d.totalBalance)
        .reduce((double a, double b) => a < b ? a : b);
    final double maxBalance = data
        .map((MonthlyBalanceData d) => d.totalBalance)
        .reduce((double a, double b) => a > b ? a : b);

    // Добавить отступы для лучшей визуализации
    final double range = maxBalance - minBalance;
    final double yMin = minBalance - range * 0.1;
    final double yMax = maxBalance + range * 0.1;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Денег всего',
            style: TextStyle(
              fontFamily: 'Onest',
              fontSize: 28,
              height: 36 / 28,
              fontWeight: FontWeight.w400,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 137,
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              margin: const EdgeInsets.all(0),
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
              series: <CartesianSeries<MonthlyBalanceData, String>>[
                SplineSeries<MonthlyBalanceData, String>(
                  dataSource: data,
                  xValueMapper: (MonthlyBalanceData d, _) => d.monthLabel,
                  yValueMapper: (MonthlyBalanceData d, _) => d.totalBalance,
                  color: colors.primary,
                  width: 2,
                  markerSettings: MarkerSettings(
                    isVisible: true,
                    height: 6,
                    width: 6,
                    shape: DataMarkerType.circle,
                    borderWidth: 2,
                    borderColor: colors.primary,
                  ),
                  dataLabelSettings: DataLabelSettings(
                    isVisible: true,
                    labelAlignment: ChartDataLabelAlignment.top,
                    textStyle: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      height: 16 / 12,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.4,
                      color: colors.onSurfaceVariant,
                    ),
                    builder:
                        (
                          dynamic data,
                          dynamic point,
                          dynamic series,
                          int pointIndex,
                          int seriesIndex,
                        ) {
                          final MonthlyBalanceData balanceData =
                              data as MonthlyBalanceData;
                          final NumberFormat formatter = NumberFormat.compact();
                          return Text(
                            '${formatter.format(balanceData.totalBalance)} $currencySymbol',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              height: 16 / 12,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.4,
                              color: colors.onSurfaceVariant,
                            ),
                          );
                        },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
