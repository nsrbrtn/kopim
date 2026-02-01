import 'package:kopim/core/money/money.dart';

import 'package:kopim/features/credits/domain/entities/credit_payment_group.dart';
import 'package:kopim/features/credits/domain/entities/credit_payment_schedule.dart';
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/features/credits/domain/repositories/credit_repository.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:uuid/uuid.dart';

class MakeCreditPaymentUseCase {
  MakeCreditPaymentUseCase({
    required CreditRepository creditRepository,
    required TransactionRepository transactionRepository,
    required Uuid uuid,
  }) : _creditRepository = creditRepository,
       _transactionRepository = transactionRepository,
       _uuid = uuid;

  final CreditRepository _creditRepository;
  final TransactionRepository _transactionRepository;
  final Uuid _uuid;

  Future<void> call({
    required String creditId,
    required String sourceAccountId,
    required DateTime paidAt,
    required Money principalPaid,
    required Money interestPaid,
    required Money feesPaid,
    required Money totalOutflow,
    String? note,
    String? idempotencyKey,
    String? periodKey, // To link with schedule
  }) async {
    // Usually UseCase takes ID. CreditRepository has getCreditByAccountId but might need getCreditById.
    // Let me check CreditRepository methods again.

    // Check CreditRepository... Oh, it has getCreditByAccountId. I'll use that for now if I don't have getCreditById.
    // Actually, I'll assume getCredits() and filter or add getCreditById if missing.
    // Looking at CreditRepository: it has watchCredits, getCredits.
    // I'll add getCreditById to CreditRepository in a moment if needed.

    final List<CreditEntity> allCredits = await _creditRepository.getCredits();
    final CreditEntity targetCredit =
        allCredits.firstWhere((CreditEntity c) => c.id == creditId);

    final String groupId = _uuid.v4();
    final DateTime now = DateTime.now();

    // 1. Update Schedule if needed
    String? scheduleItemId;
    if (periodKey != null) {
      final List<CreditPaymentScheduleEntity> schedule =
          await _creditRepository.getSchedule(creditId);
      final CreditPaymentScheduleEntity item = schedule.firstWhere(
        (CreditPaymentScheduleEntity s) => s.periodKey == periodKey,
      );
      scheduleItemId = item.id;

      // Update item logic (simplified: mark as paid if principal/interest fully paid)
      // Robust logic would accumulate partial payments.
      final Money updatedPrincipalPaid = Money(
        minor: item.principalPaid.minor + principalPaid.minor,
        currency: item.principalPaid.currency,
        scale: item.principalPaid.scale,
      );
      final Money updatedInterestPaid = Money(
        minor: item.interestPaid.minor + interestPaid.minor,
        currency: item.interestPaid.currency,
        scale: item.interestPaid.scale,
      );

      final bool isFullyPaid =
          updatedPrincipalPaid.minor >= item.principalAmount.minor &&
          updatedInterestPaid.minor >= item.interestAmount.minor;

      final CreditPaymentScheduleEntity updatedItem = item.copyWith(
        principalPaid: updatedPrincipalPaid,
        interestPaid: updatedInterestPaid,
        status: isFullyPaid
            ? CreditPaymentStatus.paid
            : CreditPaymentStatus.partiallyPaid,
        paidAt: isFullyPaid ? paidAt : item.paidAt,
      );

      // I need a way to update schedule item in repository.
      // I'll add updateScheduleItem to CreditRepository.
      await _creditRepository.updateScheduleItem(updatedItem);
    }

    // 2. Create Payment Group
    final CreditPaymentGroupEntity group = CreditPaymentGroupEntity(
      id: groupId,
      creditId: creditId,
      sourceAccountId: sourceAccountId,
      scheduleItemId: scheduleItemId,
      paidAt: paidAt,
      totalOutflow: totalOutflow,
      principalPaid: principalPaid,
      interestPaid: interestPaid,
      feesPaid: feesPaid,
      note: note,
      idempotencyKey: idempotencyKey,
    );
    await _creditRepository.addPaymentGroup(group);

    // 3. Transaction: Principal (Transfer)
    if (principalPaid.minor > BigInt.zero) {
      final String txId = _uuid.v4();
      final TransactionEntity principalTx = TransactionEntity(
        id: txId,
        accountId: sourceAccountId,
        transferAccountId: targetCredit.accountId,
        categoryId: targetCredit.categoryId,
        groupId: groupId,
        amountMinor: principalPaid.minor,
        amountScale: principalPaid.scale,
        date: paidAt,
        type: 'transfer',
        note: note ?? 'Credit Payment: Principal',
        createdAt: now,
        updatedAt: now,
      );
      await _transactionRepository.upsert(principalTx);
    }

    // 4. Transaction: Interest (Expense)
    if (interestPaid.minor > BigInt.zero) {
      final String txId = _uuid.v4();
      final TransactionEntity interestTx = TransactionEntity(
        id: txId,
        accountId: sourceAccountId,
        categoryId: targetCredit.interestCategoryId,
        groupId: groupId,
        amountMinor: interestPaid.minor,
        amountScale: interestPaid.scale,
        date: paidAt,
        type: 'expense',
        note: note ?? 'Credit Payment: Interest',
        createdAt: now,
        updatedAt: now,
      );
      await _transactionRepository.upsert(interestTx);
    }

    // 5. Transaction: Fees (Expense)
    if (feesPaid.minor > BigInt.zero) {
      final String txId = _uuid.v4();
      final TransactionEntity feesTx = TransactionEntity(
        id: txId,
        accountId: sourceAccountId,
        categoryId: targetCredit.feesCategoryId,
        groupId: groupId,
        amountMinor: feesPaid.minor,
        amountScale: feesPaid.scale,
        date: paidAt,
        type: 'expense',
        note: note ?? 'Credit Payment: Fees',
        createdAt: now,
        updatedAt: now,
      );
      await _transactionRepository.upsert(feesTx);
    }
  }
}
