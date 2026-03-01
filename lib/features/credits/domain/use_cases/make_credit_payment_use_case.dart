import 'package:kopim/core/money/money.dart';
import 'package:kopim/features/accounts/domain/repositories/account_repository.dart';
import 'package:kopim/features/categories/domain/repositories/category_repository.dart';
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
    required AccountRepository accountRepository,
    required CategoryRepository categoryRepository,
    required Uuid uuid,
  }) : _creditRepository = creditRepository,
       _transactionRepository = transactionRepository,
       _accountRepository = accountRepository,
       _categoryRepository = categoryRepository,
       _uuid = uuid;

  final CreditRepository _creditRepository;
  final TransactionRepository _transactionRepository;
  final AccountRepository _accountRepository;
  final CategoryRepository _categoryRepository;
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
    final String? normalizedIdempotencyKey = _normalizeId(idempotencyKey);
    final String effectiveIdempotencyKey =
        normalizedIdempotencyKey ?? 'credit-payment:${_uuid.v4()}';
    if (principalPaid.minor < BigInt.zero ||
        interestPaid.minor < BigInt.zero ||
        feesPaid.minor < BigInt.zero) {
      throw ArgumentError('Суммы платежа не могут быть отрицательными');
    }
    if (totalOutflow.minor <= BigInt.zero) {
      throw ArgumentError('Сумма платежа должна быть больше нуля');
    }
    _ensureSameMoneyContext(
      reference: totalOutflow,
      value: principalPaid,
      fieldName: 'principalPaid',
    );
    _ensureSameMoneyContext(
      reference: totalOutflow,
      value: interestPaid,
      fieldName: 'interestPaid',
    );
    _ensureSameMoneyContext(
      reference: totalOutflow,
      value: feesPaid,
      fieldName: 'feesPaid',
    );
    final BigInt expectedOutflowMinor =
        principalPaid.minor + interestPaid.minor + feesPaid.minor;
    if (expectedOutflowMinor != totalOutflow.minor) {
      throw ArgumentError(
        'Сумма totalOutflow должна быть равна principal + interest + fees',
      );
    }

    await _transactionRepository.runInTransaction<void>(() async {
      if (normalizedIdempotencyKey != null) {
        final bool alreadyProcessed =
            await _creditRepository.findPaymentGroupByIdempotencyKey(
              creditId: creditId,
              idempotencyKey: normalizedIdempotencyKey,
            ) !=
            null;
        if (alreadyProcessed) {
          return;
        }
      }
      final bool sourceAccountExists =
          await _accountRepository.findById(sourceAccountId) != null;
      if (!sourceAccountExists) {
        throw StateError('Счет списания не найден: $sourceAccountId');
      }
      final List<CreditEntity> allCredits = await _creditRepository
          .getCredits();
      final CreditEntity targetCredit = allCredits.firstWhere(
        (CreditEntity c) => c.id == creditId,
      );
      final String? principalTransferAccountId =
          await _resolveExistingTransferAccountId(targetCredit.accountId);
      final String? principalCategoryId = await _resolveExistingCategoryId(
        targetCredit.categoryId,
      );
      final String? interestCategoryId = await _resolveExistingCategoryId(
        targetCredit.interestCategoryId,
      );
      final String? feesCategoryId = await _resolveExistingCategoryId(
        targetCredit.feesCategoryId,
      );

      final String groupId = _uuid.v4();
      final DateTime now = DateTime.now();

      // 1. Resolve Schedule item if needed
      String? scheduleItemId;
      CreditPaymentScheduleEntity? updatedScheduleItem;
      if (periodKey != null) {
        final List<CreditPaymentScheduleEntity> schedule =
            await _creditRepository.getSchedule(creditId);
        final CreditPaymentScheduleEntity? item = schedule
            .cast<CreditPaymentScheduleEntity?>()
            .firstWhere(
              (CreditPaymentScheduleEntity? s) => s?.periodKey == periodKey,
              orElse: () => null,
            );
        if (item == null) {
          throw StateError(
            'Schedule item not found for creditId=$creditId and periodKey=$periodKey',
          );
        }
        scheduleItemId = item.id;

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

        updatedScheduleItem = item.copyWith(
          principalPaid: updatedPrincipalPaid,
          interestPaid: updatedInterestPaid,
          status: isFullyPaid
              ? CreditPaymentStatus.paid
              : CreditPaymentStatus.partiallyPaid,
          paidAt: isFullyPaid ? paidAt : item.paidAt,
        );
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
        idempotencyKey: effectiveIdempotencyKey,
      );
      final bool groupInserted = await _creditRepository
          .addPaymentGroupIfAbsent(group);
      if (!groupInserted) {
        return;
      }

      // 3. Update Schedule
      if (updatedScheduleItem != null) {
        await _creditRepository.updateScheduleItem(updatedScheduleItem);
      }

      // 4. Transaction: Principal (Transfer)
      if (principalPaid.minor > BigInt.zero) {
        if (principalTransferAccountId == null) {
          throw StateError(
            'Не найден счет кредита для перевода основного долга: creditId=$creditId',
          );
        }
        final String txId = _uuid.v4();
        final TransactionEntity principalTx = TransactionEntity(
          id: txId,
          accountId: sourceAccountId,
          transferAccountId: principalTransferAccountId,
          // Для transfer категория опциональна: если категория отсутствует,
          // безопасно сохраняем без categoryId.
          categoryId: principalCategoryId,
          groupId: groupId,
          amountMinor: principalPaid.minor,
          amountScale: principalPaid.scale,
          idempotencyKey: '$effectiveIdempotencyKey:principal',
          date: paidAt,
          type: 'transfer',
          note: note ?? 'Платёж по кредиту: основной долг',
          createdAt: now,
          updatedAt: now,
        );
        await _transactionRepository.upsert(principalTx);
      }

      // 5. Transaction: Interest (Expense)
      if (interestPaid.minor > BigInt.zero) {
        final String txId = _uuid.v4();
        final TransactionEntity interestTx = TransactionEntity(
          id: txId,
          accountId: sourceAccountId,
          categoryId: interestCategoryId,
          groupId: groupId,
          amountMinor: interestPaid.minor,
          amountScale: interestPaid.scale,
          idempotencyKey: '$effectiveIdempotencyKey:interest',
          date: paidAt,
          type: 'expense',
          note: note ?? 'Платёж по кредиту: проценты',
          createdAt: now,
          updatedAt: now,
        );
        await _transactionRepository.upsert(interestTx);
      }

      // 6. Transaction: Fees (Expense)
      if (feesPaid.minor > BigInt.zero) {
        final String txId = _uuid.v4();
        final TransactionEntity feesTx = TransactionEntity(
          id: txId,
          accountId: sourceAccountId,
          categoryId: feesCategoryId,
          groupId: groupId,
          amountMinor: feesPaid.minor,
          amountScale: feesPaid.scale,
          idempotencyKey: '$effectiveIdempotencyKey:fees',
          date: paidAt,
          type: 'expense',
          note: note ?? 'Платёж по кредиту: комиссии',
          createdAt: now,
          updatedAt: now,
        );
        await _transactionRepository.upsert(feesTx);
      }
    });
  }

  Future<String?> _resolveExistingTransferAccountId(String? accountId) async {
    final String? normalized = _normalizeId(accountId);
    if (normalized == null) {
      return null;
    }
    final bool exists = await _accountRepository.findById(normalized) != null;
    return exists ? normalized : null;
  }

  Future<String?> _resolveExistingCategoryId(String? categoryId) async {
    final String? normalized = _normalizeId(categoryId);
    if (normalized == null) {
      return null;
    }
    final bool exists = await _categoryRepository.findById(normalized) != null;
    return exists ? normalized : null;
  }

  String? _normalizeId(String? id) {
    final String? trimmed = id?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }

  void _ensureSameMoneyContext({
    required Money reference,
    required Money value,
    required String fieldName,
  }) {
    if (value.currency != reference.currency ||
        value.scale != reference.scale) {
      throw ArgumentError(
        '$fieldName должен совпадать по currency/scale с totalOutflow',
      );
    }
  }
}
