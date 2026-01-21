import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/credits/domain/utils/credit_card_calculations.dart';

void main() {
  test('calculateCreditCardAvailableLimit учитывает текущий баланс', () {
    final MoneyAmount available = calculateCreditCardAvailableLimit(
      creditLimit: MoneyAmount(minor: BigInt.from(1000000), scale: 2),
      balance: MoneyAmount(minor: BigInt.from(-500000), scale: 2),
    );

    expect(available.minor, BigInt.from(500000));
    expect(available.scale, 2);
  });

  test('calculateCreditCardDebt возвращает ноль при положительном балансе', () {
    final MoneyAmount debt = calculateCreditCardDebt(
      MoneyAmount(minor: BigInt.from(120000), scale: 2),
    );

    expect(debt.minor, BigInt.zero);
    expect(debt.scale, 2);
  });
}
