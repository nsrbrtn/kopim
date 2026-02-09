import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kopim/core/money/money.dart';

part 'credit_payment_schedule.freezed.dart';

@freezed
abstract class CreditPaymentScheduleEntity with _$CreditPaymentScheduleEntity {
  const factory CreditPaymentScheduleEntity({
    required String id,
    required String creditId,
    required String periodKey,
    required DateTime dueDate,
    required CreditPaymentStatus status,
    required Money principalAmount,
    required Money interestAmount,
    required Money totalAmount,
    required Money principalPaid,
    required Money interestPaid,
    DateTime? paidAt,
  }) = _CreditPaymentScheduleEntity;
}

enum CreditPaymentStatus {
  planned,
  partiallyPaid,
  paid,
  skipped; // Overdue is calculated
  
  bool get isPaid => this == CreditPaymentStatus.paid;
}
