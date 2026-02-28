import 'package:kopim/core/money/money.dart';
import 'package:kopim/features/credits/domain/entities/credit_payment_schedule.dart';

BigInt _remainingMinor({
  required BigInt plannedMinor,
  required BigInt paidMinor,
}) {
  final BigInt remaining = plannedMinor - paidMinor;
  return remaining > BigInt.zero ? remaining : BigInt.zero;
}

Money remainingPrincipalAmount(CreditPaymentScheduleEntity item) {
  final BigInt minor = _remainingMinor(
    plannedMinor: item.principalAmount.minor,
    paidMinor: item.principalPaid.minor,
  );
  return Money.fromMinor(
    minor,
    currency: item.principalAmount.currency,
    scale: item.principalAmount.scale,
  );
}

Money remainingInterestAmount(CreditPaymentScheduleEntity item) {
  final BigInt minor = _remainingMinor(
    plannedMinor: item.interestAmount.minor,
    paidMinor: item.interestPaid.minor,
  );
  return Money.fromMinor(
    minor,
    currency: item.interestAmount.currency,
    scale: item.interestAmount.scale,
  );
}

Money remainingTotalAmount(CreditPaymentScheduleEntity item) {
  final Money principal = remainingPrincipalAmount(item);
  final Money interest = remainingInterestAmount(item);
  return Money.fromMinor(
    principal.minor + interest.minor,
    currency: item.totalAmount.currency,
    scale: item.totalAmount.scale,
  );
}
