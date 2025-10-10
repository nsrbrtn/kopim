import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/upcoming_payments/domain/services/time_service.dart';
import 'package:kopim/features/upcoming_payments/domain/validators/upcoming_payment_validator.dart';

import '../../test_utils/fakes.dart';

void main() {
  final TimeService timeService = FixedTimeService(DateTime(2024, 1, 1));
  final UpcomingPaymentValidator validator = UpcomingPaymentValidator(
    timeService: timeService,
  );

  test('валидация успешна для корректных данных', () {
    expect(
      () => validator.validate(
        title: 'Коммуналка',
        amount: 1000,
        dayOfMonth: 15,
        notifyDaysBefore: 3,
        notifyTimeHhmm: '10:00',
        accountId: 'acc',
        categoryId: 'cat',
      ),
      returnsNormally,
    );
  });

  test('падает, если заголовок пустой', () {
    expect(
      () => validator.validate(
        title: '  ',
        amount: 1000,
        dayOfMonth: 15,
        notifyDaysBefore: 3,
        notifyTimeHhmm: '10:00',
        accountId: 'acc',
        categoryId: 'cat',
      ),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('падает, если сумма отрицательная', () {
    expect(
      () => validator.validate(
        title: 'Коммуналка',
        amount: 0,
        dayOfMonth: 15,
        notifyDaysBefore: 3,
        notifyTimeHhmm: '10:00',
        accountId: 'acc',
        categoryId: 'cat',
      ),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('падает, если день вне диапазона', () {
    expect(
      () => validator.validate(
        title: 'Коммуналка',
        amount: 1000,
        dayOfMonth: 0,
        notifyDaysBefore: 3,
        notifyTimeHhmm: '10:00',
        accountId: 'acc',
        categoryId: 'cat',
      ),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('падает, если notifyDaysBefore отрицателен', () {
    expect(
      () => validator.validate(
        title: 'Коммуналка',
        amount: 1000,
        dayOfMonth: 15,
        notifyDaysBefore: -1,
        notifyTimeHhmm: '10:00',
        accountId: 'acc',
        categoryId: 'cat',
      ),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('падает, если notifyTimeHhmm некорректен', () {
    expect(
      () => validator.validate(
        title: 'Коммуналка',
        amount: 1000,
        dayOfMonth: 15,
        notifyDaysBefore: 1,
        notifyTimeHhmm: '99:00',
        accountId: 'acc',
        categoryId: 'cat',
      ),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('падает, если accountId пустой', () {
    expect(
      () => validator.validate(
        title: 'Коммуналка',
        amount: 1000,
        dayOfMonth: 15,
        notifyDaysBefore: 1,
        notifyTimeHhmm: '09:00',
        accountId: '',
        categoryId: 'cat',
      ),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('падает, если categoryId пустой', () {
    expect(
      () => validator.validate(
        title: 'Коммуналка',
        amount: 1000,
        dayOfMonth: 15,
        notifyDaysBefore: 1,
        notifyTimeHhmm: '09:00',
        accountId: 'acc',
        categoryId: ' ',
      ),
      throwsA(isA<ArgumentError>()),
    );
  });
}
