import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/credits/domain/utils/credit_schedule_dates.dart';

void main() {
  group('resolveFirstCreditPaymentDate', () {
    test('берет текущий месяц если день платежа еще не наступил', () {
      final DateTime result = resolveFirstCreditPaymentDate(
        from: DateTime(2026, 6, 11, 14, 30),
        paymentDay: 15,
      );

      expect(result, DateTime(2026, 6, 15));
    });

    test('берет текущий день если кредит создан в день платежа', () {
      final DateTime result = resolveFirstCreditPaymentDate(
        from: DateTime(2026, 6, 15, 9, 0),
        paymentDay: 15,
      );

      expect(result, DateTime(2026, 6, 15));
    });

    test('переносит на следующий месяц если день платежа уже прошел', () {
      final DateTime result = resolveFirstCreditPaymentDate(
        from: DateTime(2026, 6, 20, 8, 15),
        paymentDay: 15,
      );

      expect(result, DateTime(2026, 7, 15));
    });

    test('клампит день к последнему дню месяца', () {
      final DateTime result = resolveFirstCreditPaymentDate(
        from: DateTime(2026, 4, 10, 12, 0),
        paymentDay: 31,
      );

      expect(result, DateTime(2026, 4, 30));
    });
  });
}
