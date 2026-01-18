import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/money/money_utils.dart';

void main() {
  group('MoneyAccumulator', () {
    test('sums amounts with different scales', () {
      final MoneyAccumulator accumulator = MoneyAccumulator();
      accumulator.add(
        MoneyAmount(minor: BigInt.from(123), scale: 2),
      ); // 1.23
      accumulator.add(
        MoneyAmount(minor: BigInt.from(45), scale: 4),
      ); // 0.0045

      expect(accumulator.scale, 4);
      expect(accumulator.minor, BigInt.from(12345));
      expect(accumulator.toDouble(), closeTo(1.2345, 1e-9));
    });

    test('subtracts amounts', () {
      final MoneyAccumulator accumulator = MoneyAccumulator();
      accumulator.add(
        MoneyAmount(minor: BigInt.from(1000), scale: 2),
      ); // 10.00
      accumulator.subtract(
        MoneyAmount(minor: BigInt.from(250), scale: 2),
      ); // 2.50

      expect(accumulator.minor, BigInt.from(750));
      expect(accumulator.toDouble(), closeTo(7.5, 1e-9));
    });
  });

  group('resolveMoneyAmount', () {
    test('uses minor when provided', () {
      final MoneyAmount amount = resolveMoneyAmount(
        amount: 1.0,
        minor: BigInt.from(250),
        scale: 2,
      );

      expect(amount.toDouble(), closeTo(2.5, 1e-9));
    });
  });
}
