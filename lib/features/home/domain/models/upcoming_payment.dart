import 'package:freezed_annotation/freezed_annotation.dart';

part 'upcoming_payment.freezed.dart';

@freezed
abstract class UpcomingPayment with _$UpcomingPayment {
  const factory UpcomingPayment({
    required String occurrenceId,
    required String ruleId,
    required String title,
    required double amount,
    required String currency,
    required DateTime dueDate,
    required String accountId,
    required String categoryId,
  }) = _UpcomingPayment;

  const UpcomingPayment._();

  bool get isExpense => amount >= 0;

  double get absoluteAmount => amount.abs();
}
