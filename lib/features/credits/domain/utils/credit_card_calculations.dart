import 'dart:math' as math;

import 'package:kopim/core/money/money_utils.dart';

MoneyAmount calculateCreditCardAvailableLimit({
  required MoneyAmount creditLimit,
  required MoneyAmount balance,
}) {
  final int targetScale = math.max(creditLimit.scale, balance.scale);
  final MoneyAmount normalizedLimit = rescaleMoneyAmount(
    creditLimit,
    targetScale,
  );
  final MoneyAmount normalizedBalance = rescaleMoneyAmount(
    balance,
    targetScale,
  );
  return MoneyAmount(
    minor: normalizedLimit.minor + normalizedBalance.minor,
    scale: targetScale,
  );
}

MoneyAmount calculateCreditCardDebt(MoneyAmount balance) {
  if (balance.minor >= BigInt.zero) {
    return MoneyAmount(minor: BigInt.zero, scale: balance.scale);
  }
  return MoneyAmount(minor: -balance.minor, scale: balance.scale);
}
