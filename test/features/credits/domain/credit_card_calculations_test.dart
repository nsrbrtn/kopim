import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/credits/domain/utils/credit_card_calculations.dart';

void main() {
  test('calculateCreditCardAvailableLimit учитывает текущий баланс', () {
    final double available = calculateCreditCardAvailableLimit(
      creditLimit: 10000,
      balance: -5000,
    );

    expect(available, 5000);
  });

  test('calculateCreditCardDebt возвращает ноль при положительном балансе', () {
    final double debt = calculateCreditCardDebt(1200);

    expect(debt, 0);
  });
}
