import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_account_monthly_summary.freezed.dart';

@freezed
abstract class HomeAccountMonthlySummary with _$HomeAccountMonthlySummary {
  const factory HomeAccountMonthlySummary({
    required double income,
    required double expense,
  }) = _HomeAccountMonthlySummary;

  const HomeAccountMonthlySummary._();

  double get net => income - expense;
}
