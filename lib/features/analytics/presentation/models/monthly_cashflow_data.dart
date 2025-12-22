import 'package:flutter/foundation.dart';

@immutable
class MonthlyCashflowData {
  const MonthlyCashflowData({
    required this.month,
    required this.income,
    required this.expense,
  });

  final DateTime month;
  final double income;
  final double expense;

  double get net => income - expense;

  String get monthLabel {
    const List<String> monthNames = <String>[
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
