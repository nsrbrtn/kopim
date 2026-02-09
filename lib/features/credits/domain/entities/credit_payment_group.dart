import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kopim/core/money/money.dart';

part 'credit_payment_group.freezed.dart';

@freezed
abstract class CreditPaymentGroupEntity with _$CreditPaymentGroupEntity {
  const factory CreditPaymentGroupEntity({
    required String id,
    required String creditId,
    required String sourceAccountId,
    String? scheduleItemId,
    required DateTime paidAt,
    required Money totalOutflow,
    required Money principalPaid,
    required Money interestPaid,
    required Money feesPaid,
    String? note,
    String? idempotencyKey,
  }) = _CreditPaymentGroupEntity;
}
