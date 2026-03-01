import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/money/money.dart';
import 'package:kopim/features/credits/domain/entities/credit_payment_schedule.dart';
import 'package:kopim/features/credits/domain/validators/credit_payment_schedule_validator.dart';

void main() {
  const CreditPaymentScheduleValidator validator =
      CreditPaymentScheduleValidator();
  final DateTime now = DateTime.utc(2026, 3, 1, 12);

  Money rub(int minor) =>
      Money.fromMinor(BigInt.from(minor), currency: 'RUB', scale: 2);

  CreditPaymentScheduleEntity base({
    CreditPaymentStatus status = CreditPaymentStatus.planned,
    int principalAmount = 10_000,
    int interestAmount = 1_000,
    int principalPaid = 0,
    int interestPaid = 0,
    DateTime? paidAt,
  }) {
    return CreditPaymentScheduleEntity(
      id: 'sched-1',
      creditId: 'credit-1',
      periodKey: '2026-03',
      dueDate: now.add(const Duration(days: 14)),
      status: status,
      principalAmount: rub(principalAmount),
      interestAmount: rub(interestAmount),
      totalAmount: rub(principalAmount + interestAmount),
      principalPaid: rub(principalPaid),
      interestPaid: rub(interestPaid),
      paidAt: paidAt,
    );
  }

  test('принимает planned без оплат и paidAt', () {
    final CreditPaymentScheduleEntity item = base();
    expect(() => validator.validate(item), returnsNormally);
  });

  test('принимает skipped без оплат и paidAt', () {
    final CreditPaymentScheduleEntity item = base(
      status: CreditPaymentStatus.skipped,
    );
    expect(() => validator.validate(item), returnsNormally);
  });

  test('принимает partiallyPaid с частичной оплатой', () {
    final CreditPaymentScheduleEntity item = base(
      status: CreditPaymentStatus.partiallyPaid,
      principalPaid: 2_000,
      interestPaid: 100,
    );
    expect(() => validator.validate(item), returnsNormally);
  });

  test('принимает paid при полном погашении и paidAt', () {
    final CreditPaymentScheduleEntity item = base(
      status: CreditPaymentStatus.paid,
      principalPaid: 10_000,
      interestPaid: 1_000,
      paidAt: now,
    );
    expect(() => validator.validate(item), returnsNormally);
  });

  test('отклоняет totalAmount != principal + interest', () {
    final CreditPaymentScheduleEntity item = base().copyWith(
      totalAmount: rub(10_500),
    );
    expect(() => validator.validate(item), throwsA(isA<ArgumentError>()));
  });

  test('отклоняет разные currency/scale у money полей', () {
    final CreditPaymentScheduleEntity item = base().copyWith(
      interestAmount: Money.fromMinor(
        BigInt.from(1_000),
        currency: 'USD',
        scale: 2,
      ),
    );
    expect(() => validator.validate(item), throwsA(isA<ArgumentError>()));
  });

  test('отклоняет отрицательные principalPaid/interestPaid', () {
    final CreditPaymentScheduleEntity item = base().copyWith(
      principalPaid: rub(-1),
    );
    expect(() => validator.validate(item), throwsA(isA<ArgumentError>()));
  });

  test('отклоняет principalPaid > principalAmount', () {
    final CreditPaymentScheduleEntity item = base().copyWith(
      principalPaid: rub(10_001),
    );
    expect(() => validator.validate(item), throwsA(isA<ArgumentError>()));
  });

  test('отклоняет interestPaid > interestAmount', () {
    final CreditPaymentScheduleEntity item = base().copyWith(
      interestPaid: rub(1_001),
    );
    expect(() => validator.validate(item), throwsA(isA<ArgumentError>()));
  });

  test('отклоняет paid без полного погашения', () {
    final CreditPaymentScheduleEntity item = base(
      status: CreditPaymentStatus.paid,
      principalPaid: 10_000,
      interestPaid: 999,
      paidAt: now,
    );
    expect(() => validator.validate(item), throwsA(isA<ArgumentError>()));
  });

  test('отклоняет paid без paidAt', () {
    final CreditPaymentScheduleEntity item = base(
      status: CreditPaymentStatus.paid,
      principalPaid: 10_000,
      interestPaid: 1_000,
      paidAt: null,
    );
    expect(() => validator.validate(item), throwsA(isA<ArgumentError>()));
  });

  test('отклоняет partiallyPaid без оплат', () {
    final CreditPaymentScheduleEntity item = base(
      status: CreditPaymentStatus.partiallyPaid,
      principalPaid: 0,
      interestPaid: 0,
    );
    expect(() => validator.validate(item), throwsA(isA<ArgumentError>()));
  });

  test('отклоняет partiallyPaid при полном погашении', () {
    final CreditPaymentScheduleEntity item = base(
      status: CreditPaymentStatus.partiallyPaid,
      principalPaid: 10_000,
      interestPaid: 1_000,
    );
    expect(() => validator.validate(item), throwsA(isA<ArgumentError>()));
  });

  test('отклоняет planned/skipped с paidAt', () {
    final CreditPaymentScheduleEntity planned = base(paidAt: now);
    final CreditPaymentScheduleEntity skipped = base(
      status: CreditPaymentStatus.skipped,
      paidAt: now,
    );

    expect(() => validator.validate(planned), throwsA(isA<ArgumentError>()));
    expect(() => validator.validate(skipped), throwsA(isA<ArgumentError>()));
  });

  test('отклоняет planned/skipped с оплаченной суммой', () {
    final CreditPaymentScheduleEntity planned = base(principalPaid: 1);
    final CreditPaymentScheduleEntity skipped = base(
      status: CreditPaymentStatus.skipped,
      interestPaid: 1,
    );

    expect(() => validator.validate(planned), throwsA(isA<ArgumentError>()));
    expect(() => validator.validate(skipped), throwsA(isA<ArgumentError>()));
  });
}
