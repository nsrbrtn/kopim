import 'package:kopim/core/money/money.dart';
import 'package:kopim/features/credits/domain/entities/credit_payment_schedule.dart';

class CreditPaymentScheduleValidator {
  const CreditPaymentScheduleValidator();

  void validate(CreditPaymentScheduleEntity item) {
    _ensureSameMoneyContext(item.principalAmount, item.interestAmount);
    _ensureSameMoneyContext(item.principalAmount, item.totalAmount);
    _ensureSameMoneyContext(item.principalAmount, item.principalPaid);
    _ensureSameMoneyContext(item.principalAmount, item.interestPaid);

    if (item.totalAmount.minor !=
        item.principalAmount.minor + item.interestAmount.minor) {
      throw ArgumentError(
        'totalAmount должен быть равен principalAmount + interestAmount',
      );
    }
    if (item.principalPaid.minor < BigInt.zero ||
        item.interestPaid.minor < BigInt.zero) {
      throw ArgumentError('Оплаченные суммы не могут быть отрицательными');
    }
    if (item.principalPaid.minor > item.principalAmount.minor) {
      throw ArgumentError('principalPaid не может превышать principalAmount');
    }
    if (item.interestPaid.minor > item.interestAmount.minor) {
      throw ArgumentError('interestPaid не может превышать interestAmount');
    }

    final bool hasAnyPaid =
        item.principalPaid.minor > BigInt.zero ||
        item.interestPaid.minor > BigInt.zero;
    final bool fullyPaid =
        item.principalPaid.minor == item.principalAmount.minor &&
        item.interestPaid.minor == item.interestAmount.minor;
    switch (item.status) {
      case CreditPaymentStatus.paid:
        if (!fullyPaid) {
          throw ArgumentError(
            'status=paid требует полного погашения principal и interest',
          );
        }
        if (item.paidAt == null) {
          throw ArgumentError('status=paid требует заполненного paidAt');
        }
        break;
      case CreditPaymentStatus.partiallyPaid:
        if (!hasAnyPaid || fullyPaid) {
          throw ArgumentError(
            'status=partiallyPaid требует частичной оплаты без полного погашения',
          );
        }
        break;
      case CreditPaymentStatus.planned:
      case CreditPaymentStatus.skipped:
        if (hasAnyPaid) {
          throw ArgumentError(
            'status=planned/skipped не допускает оплаченные суммы',
          );
        }
        if (item.paidAt != null) {
          throw ArgumentError('status=planned/skipped не допускает paidAt');
        }
        break;
    }
  }

  void _ensureSameMoneyContext(Money reference, Money value) {
    if (reference.currency != value.currency ||
        reference.scale != value.scale) {
      throw ArgumentError(
        'Money поля графика должны иметь одинаковые currency/scale',
      );
    }
  }
}
