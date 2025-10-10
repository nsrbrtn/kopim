import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/upcoming_payments/domain/validators/payment_reminder_validator.dart';

import '../../test_utils/fakes.dart';

void main() {
  final FixedTimeService timeService = FixedTimeService(
    DateTime(2024, 1, 1, 12),
  );
  final PaymentReminderValidator validator = PaymentReminderValidator(
    timeService: timeService,
  );

  test('успешная валидация', () {
    expect(
      () => validator.validate(
        title: 'Разовый платёж',
        amount: 500,
        whenLocal: DateTime(2024, 1, 1, 12),
      ),
      returnsNormally,
    );
  });

  test('падает при пустом заголовке', () {
    expect(
      () => validator.validate(
        title: '',
        amount: 100,
        whenLocal: DateTime(2024, 1, 1, 12),
      ),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('падает при неположительной сумме', () {
    expect(
      () => validator.validate(
        title: 'Разовый платёж',
        amount: -1,
        whenLocal: DateTime(2024, 1, 1, 12),
      ),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('падает, если дата в прошлом', () {
    expect(
      () => validator.validate(
        title: 'Разовый платёж',
        amount: 500,
        whenLocal: DateTime(2023, 12, 31, 23, 59),
      ),
      throwsA(isA<ArgumentError>()),
    );
  });
}
