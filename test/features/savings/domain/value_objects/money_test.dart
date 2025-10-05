import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/savings/domain/value_objects/money.dart';

void main() {
  group('Money', () {
    test('fromMinorUnits clamps negative values to zero', () {
      final Money money = Money.fromMinorUnits(-250);
      expect(money.minorUnits, 0);
    });

    test('fromDouble converts value using fraction digits', () {
      final Money money = Money.fromDouble(12.345, fractionDigits: 2);
      expect(money.minorUnits, 1235);
    });

    test('toDouble returns normalized value', () {
      final Money money = Money.fromMinorUnits(990);
      expect(money.toDouble(), 9.9);
    });

    test('addition and subtraction operate on minor units', () {
      final Money left = Money.fromMinorUnits(500);
      final Money right = Money.fromMinorUnits(125);

      expect((left + right).minorUnits, 625);
      expect((left - right).minorUnits, 375);
    });
  });
}
