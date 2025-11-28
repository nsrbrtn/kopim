import 'package:freezed_annotation/freezed_annotation.dart';

part 'monthly_balance_data.freezed.dart';

@freezed
abstract class MonthlyBalanceData with _$MonthlyBalanceData {
  const MonthlyBalanceData._();

  const factory MonthlyBalanceData({
    required DateTime month,
    required double totalBalance,
  }) = _MonthlyBalanceData;

  String get monthLabel {
    final List<String> monthNames = [
      'Янв',
      'Фев',
      'Мар',
      'Апр',
      'Май',
      'Июн',
      'Июл',
      'Авг',
      'Сен',
      'Окт',
      'Ноя',
      'Дек',
    ];
    return monthNames[month.month - 1];
  }
}
