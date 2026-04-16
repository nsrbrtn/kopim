import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/money/money.dart';
import 'package:kopim/features/credits/domain/entities/credit_payment_schedule.dart';
import 'package:kopim/features/credits/domain/utils/credit_payment_amounts.dart';

void main() {
  group('credit payment amounts', () {
    CreditPaymentScheduleEntity buildItem({
      required int principalPlanned,
      required int principalPaid,
      required int interestPlanned,
      required int interestPaid,
    }) {
      return CreditPaymentScheduleEntity(
        id: 's1',
        creditId: 'c1',
        periodKey: '2026-03',
        dueDate: DateTime.utc(2026, 3, 15),
        status: CreditPaymentStatus.partiallyPaid,
        principalAmount: Money.fromMinor(
          BigInt.from(principalPlanned),
          currency: 'RUB',
          scale: 2,
        ),
        interestAmount: Money.fromMinor(
          BigInt.from(interestPlanned),
          currency: 'RUB',
          scale: 2,
        ),
        totalAmount: Money.fromMinor(
          BigInt.from(principalPlanned + interestPlanned),
          currency: 'RUB',
          scale: 2,
        ),
        principalPaid: Money.fromMinor(
          BigInt.from(principalPaid),
          currency: 'RUB',
          scale: 2,
        ),
        interestPaid: Money.fromMinor(
          BigInt.from(interestPaid),
          currency: 'RUB',
          scale: 2,
        ),
      );
    }

    test('remaining amounts use planned minus paid', () {
      final CreditPaymentScheduleEntity item = buildItem(
        principalPlanned: 10000,
        principalPaid: 2500,
        interestPlanned: 2000,
        interestPaid: 500,
      );

      expect(remainingPrincipalAmount(item).minor, BigInt.from(7500));
      expect(remainingInterestAmount(item).minor, BigInt.from(1500));
      expect(remainingTotalAmount(item).minor, BigInt.from(9000));
    });

    test('remaining amounts are clamped to zero', () {
      final CreditPaymentScheduleEntity item = buildItem(
        principalPlanned: 10000,
        principalPaid: 12000,
        interestPlanned: 2000,
        interestPaid: 3000,
      );

      expect(remainingPrincipalAmount(item).minor, BigInt.zero);
      expect(remainingInterestAmount(item).minor, BigInt.zero);
      expect(remainingTotalAmount(item).minor, BigInt.zero);
    });

    test(
      'remainingTotalAmount всегда равен сумме remaining principal + interest',
      () {
        final List<CreditPaymentScheduleEntity> cases =
            <CreditPaymentScheduleEntity>[
              buildItem(
                principalPlanned: 10000,
                principalPaid: 0,
                interestPlanned: 2000,
                interestPaid: 0,
              ),
              buildItem(
                principalPlanned: 10000,
                principalPaid: 2500,
                interestPlanned: 2000,
                interestPaid: 500,
              ),
              buildItem(
                principalPlanned: 10000,
                principalPaid: 12000,
                interestPlanned: 2000,
                interestPaid: 1000,
              ),
              buildItem(
                principalPlanned: 10000,
                principalPaid: 10000,
                interestPlanned: 2000,
                interestPaid: 2500,
              ),
            ];

        for (final CreditPaymentScheduleEntity item in cases) {
          final Money remainingPrincipal = remainingPrincipalAmount(item);
          final Money remainingInterest = remainingInterestAmount(item);
          final Money remainingTotal = remainingTotalAmount(item);
          expect(
            remainingTotal.minor,
            remainingPrincipal.minor + remainingInterest.minor,
          );
        }
      },
    );

    test('remainingTotalAmount uses total currency/scale', () {
      final CreditPaymentScheduleEntity item =
          buildItem(
            principalPlanned: 10000,
            principalPaid: 1000,
            interestPlanned: 2000,
            interestPaid: 100,
          ).copyWith(
            totalAmount: Money.fromMinor(
              BigInt.from(12000),
              currency: 'USD',
              scale: 3,
            ),
          );

      final Money total = remainingTotalAmount(item);
      expect(total.currency, 'USD');
      expect(total.scale, 3);
    });
  });
}
