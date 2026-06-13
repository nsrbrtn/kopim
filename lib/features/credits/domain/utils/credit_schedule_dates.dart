import 'package:flutter/material.dart';

DateTime resolveFirstCreditPaymentDate({
  required DateTime from,
  required int paymentDay,
}) {
  final DateTime currentMonthCandidate = _resolvePaymentDateInMonth(
    year: from.year,
    month: from.month,
    paymentDay: paymentDay,
  );
  final DateTime currentDate = DateUtils.dateOnly(from);
  if (!currentMonthCandidate.isBefore(currentDate)) {
    return currentMonthCandidate;
  }

  final DateTime nextMonth = DateTime(from.year, from.month + 1, 1);
  return _resolvePaymentDateInMonth(
    year: nextMonth.year,
    month: nextMonth.month,
    paymentDay: paymentDay,
  );
}

DateTime _resolvePaymentDateInMonth({
  required int year,
  required int month,
  required int paymentDay,
}) {
  final int maxDay = DateUtils.getDaysInMonth(year, month);
  final int safeDay = paymentDay.clamp(1, maxDay);
  return DateTime(year, month, safeDay);
}
