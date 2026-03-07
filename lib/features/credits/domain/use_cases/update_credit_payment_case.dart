import 'package:kopim/core/money/money.dart';
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/features/credits/domain/entities/credit_payment_group.dart';
import 'package:kopim/features/credits/domain/entities/credit_payment_schedule.dart';
import 'package:kopim/features/credits/domain/repositories/credit_repository.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:uuid/uuid.dart';

class UpdateCreditPaymentUseCase {
  UpdateCreditPaymentUseCase({
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
    required String groupId,
    required Money principalPaid,
    required Money interestPaid,
    required Money feesPaid,
    required Money totalOutflow,
    String? note,
  }) async {
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
      final CreditPaymentGroupEntity? existingGroup = await _creditRepository
          .findPaymentGroupById(groupId);
      if (existingGroup == null) {
        throw StateError('Платежная группа не найдена: $groupId');
      }

      final CreditEntity credit = await _loadCredit(existingGroup.creditId);
      _ensureSameMoneyContext(
        reference: existingGroup.totalOutflow,
        value: totalOutflow,
        fieldName: 'totalOutflow',
      );

      final List<TransactionEntity> existingTransactions =
          await _transactionRepository.findByGroupId(groupId);
      final _ResolvedGroupTransactions resolved = _resolveGroupTransactions(
        transactions: existingTransactions,
        credit: credit,
      );

      final CreditPaymentGroupEntity updatedGroup = existingGroup.copyWith(
        totalOutflow: totalOutflow,
        principalPaid: principalPaid,
        interestPaid: interestPaid,
        feesPaid: feesPaid,
        note: _normalizeNote(note),
      );
      await _creditRepository.updatePaymentGroup(updatedGroup);

      if (updatedGroup.scheduleItemId != null &&
          updatedGroup.scheduleItemId!.isNotEmpty) {
        await _updateScheduleItem(
          groupBeforeUpdate: existingGroup,
          groupAfterUpdate: updatedGroup,
        );
      }

      await _syncComponentTransaction(
        existing: resolved.principal,
        amount: principalPaid,
        transactionType: TransactionType.transfer,
        accountId: updatedGroup.sourceAccountId,
        transferAccountId: credit.accountId,
        categoryId: credit.categoryId,
        paidAt: updatedGroup.paidAt,
        groupId: updatedGroup.id,
        note: updatedGroup.note,
        idempotencyKey: _componentIdempotencyKey(
          updatedGroup.idempotencyKey,
          'principal',
        ),
        fallbackNote: 'Платёж по кредиту: основной долг',
      );
      await _syncComponentTransaction(
        existing: resolved.interest,
        amount: interestPaid,
        transactionType: TransactionType.expense,
        accountId: updatedGroup.sourceAccountId,
        transferAccountId: null,
        categoryId: credit.interestCategoryId,
        paidAt: updatedGroup.paidAt,
        groupId: updatedGroup.id,
        note: updatedGroup.note,
        idempotencyKey: _componentIdempotencyKey(
          updatedGroup.idempotencyKey,
          'interest',
        ),
        fallbackNote: 'Платёж по кредиту: проценты',
      );
      await _syncComponentTransaction(
        existing: resolved.fees,
        amount: feesPaid,
        transactionType: TransactionType.expense,
        accountId: updatedGroup.sourceAccountId,
        transferAccountId: null,
        categoryId: credit.feesCategoryId,
        paidAt: updatedGroup.paidAt,
        groupId: updatedGroup.id,
        note: updatedGroup.note,
        idempotencyKey: _componentIdempotencyKey(
          updatedGroup.idempotencyKey,
          'fees',
        ),
        fallbackNote: 'Платёж по кредиту: комиссии',
      );
    });
  }

  Future<CreditEntity> _loadCredit(String creditId) async {
    final List<CreditEntity> credits = await _creditRepository.getCredits();
    for (final CreditEntity credit in credits) {
      if (credit.id == creditId) {
        return credit;
      }
    }
    throw StateError('Кредит не найден: $creditId');
  }

  _ResolvedGroupTransactions _resolveGroupTransactions({
    required List<TransactionEntity> transactions,
    required CreditEntity credit,
  }) {
    TransactionEntity? principal;
    TransactionEntity? interest;
    TransactionEntity? fees;
    final List<TransactionEntity> unknown = <TransactionEntity>[];

    for (final TransactionEntity transaction in transactions) {
      final _PaymentComponent component = _resolveComponent(
        transaction: transaction,
        credit: credit,
      );
      switch (component) {
        case _PaymentComponent.principal:
          if (principal != null) {
            throw StateError('Найдено несколько principal-транзакций в группе');
          }
          principal = transaction;
        case _PaymentComponent.interest:
          if (interest != null) {
            throw StateError('Найдено несколько interest-транзакций в группе');
          }
          interest = transaction;
        case _PaymentComponent.fees:
          if (fees != null) {
            throw StateError('Найдено несколько fees-транзакций в группе');
          }
          fees = transaction;
        case _PaymentComponent.unknown:
          unknown.add(transaction);
      }
    }

    if (unknown.isNotEmpty) {
      throw StateError(
        'В группе есть неподдерживаемые транзакции: ${unknown.map((TransactionEntity tx) => tx.id).join(', ')}',
      );
    }

    return _ResolvedGroupTransactions(
      principal: principal,
      interest: interest,
      fees: fees,
    );
  }

  _PaymentComponent _resolveComponent({
    required TransactionEntity transaction,
    required CreditEntity credit,
  }) {
    final String? key = transaction.idempotencyKey;
    if (key != null) {
      if (key.endsWith(':principal')) {
        return _PaymentComponent.principal;
      }
      if (key.endsWith(':interest')) {
        return _PaymentComponent.interest;
      }
      if (key.endsWith(':fees')) {
        return _PaymentComponent.fees;
      }
    }

    final TransactionType type = parseTransactionType(transaction.type);
    if (type.isTransfer && transaction.transferAccountId == credit.accountId) {
      return _PaymentComponent.principal;
    }
    if (transaction.categoryId == credit.interestCategoryId) {
      return _PaymentComponent.interest;
    }
    if (transaction.categoryId == credit.feesCategoryId) {
      return _PaymentComponent.fees;
    }
    if (transaction.categoryId == credit.categoryId) {
      return _PaymentComponent.principal;
    }
    return _PaymentComponent.unknown;
  }

  Future<void> _updateScheduleItem({
    required CreditPaymentGroupEntity groupBeforeUpdate,
    required CreditPaymentGroupEntity groupAfterUpdate,
  }) async {
    final String scheduleItemId = groupAfterUpdate.scheduleItemId!;
    final List<CreditPaymentScheduleEntity> schedule = await _creditRepository
        .getSchedule(groupAfterUpdate.creditId);
    CreditPaymentScheduleEntity? target;
    for (final CreditPaymentScheduleEntity item in schedule) {
      if (item.id == scheduleItemId) {
        target = item;
        break;
      }
    }
    if (target == null) {
      throw StateError('Элемент графика не найден: $scheduleItemId');
    }

    final List<CreditPaymentGroupEntity> groups = await _creditRepository
        .getPaymentGroups(groupAfterUpdate.creditId);
    final List<CreditPaymentGroupEntity> related =
        groups
            .where(
              (CreditPaymentGroupEntity group) =>
                  group.scheduleItemId == scheduleItemId &&
                  group.id != groupBeforeUpdate.id,
            )
            .toList(growable: true)
          ..add(groupAfterUpdate);

    BigInt principalMinor = BigInt.zero;
    BigInt interestMinor = BigInt.zero;
    DateTime? latestPaidAt;
    for (final CreditPaymentGroupEntity group in related) {
      principalMinor += group.principalPaid.minor;
      interestMinor += group.interestPaid.minor;
      if (latestPaidAt == null || group.paidAt.isAfter(latestPaidAt)) {
        latestPaidAt = group.paidAt;
      }
    }

    final Money principalPaid = Money.fromMinor(
      principalMinor,
      currency: target.principalPaid.currency,
      scale: target.principalPaid.scale,
    );
    final Money interestPaid = Money.fromMinor(
      interestMinor,
      currency: target.interestPaid.currency,
      scale: target.interestPaid.scale,
    );

    final bool hasAnyPaid =
        principalPaid.minor > BigInt.zero || interestPaid.minor > BigInt.zero;
    final bool fullyPaid =
        principalPaid.minor == target.principalAmount.minor &&
        interestPaid.minor == target.interestAmount.minor;
    final CreditPaymentStatus status = fullyPaid
        ? CreditPaymentStatus.paid
        : hasAnyPaid
        ? CreditPaymentStatus.partiallyPaid
        : CreditPaymentStatus.planned;

    await _creditRepository.updateScheduleItem(
      target.copyWith(
        principalPaid: principalPaid,
        interestPaid: interestPaid,
        status: status,
        paidAt: status == CreditPaymentStatus.planned ? null : latestPaidAt,
      ),
    );
  }

  Future<void> _syncComponentTransaction({
    required TransactionEntity? existing,
    required Money amount,
    required TransactionType transactionType,
    required String accountId,
    required String? transferAccountId,
    required String? categoryId,
    required DateTime paidAt,
    required String groupId,
    required String? note,
    required String? idempotencyKey,
    required String fallbackNote,
  }) async {
    if (amount.minor > BigInt.zero) {
      final TransactionEntity next =
          (existing ??
                  TransactionEntity(
                    id: _uuid.v4(),
                    accountId: accountId,
                    transferAccountId: transferAccountId,
                    categoryId: categoryId,
                    groupId: groupId,
                    idempotencyKey: idempotencyKey,
                    amountMinor: amount.minor,
                    amountScale: amount.scale,
                    date: paidAt,
                    note: note ?? fallbackNote,
                    type: transactionType.storageValue,
                    createdAt: DateTime.now().toUtc(),
                    updatedAt: DateTime.now().toUtc(),
                  ))
              .copyWith(
                accountId: accountId,
                transferAccountId: transferAccountId,
                categoryId: categoryId,
                groupId: groupId,
                idempotencyKey: idempotencyKey,
                amountMinor: amount.minor,
                amountScale: amount.scale,
                date: paidAt,
                note: note ?? fallbackNote,
                type: transactionType.storageValue,
              );
      await _transactionRepository.upsert(next);
      return;
    }

    if (existing != null) {
      await _transactionRepository.softDelete(existing.id);
    }
  }

  String? _componentIdempotencyKey(String? baseKey, String suffix) {
    if (baseKey == null || baseKey.isEmpty) {
      return null;
    }
    return '$baseKey:$suffix';
  }

  String? _normalizeNote(String? note) {
    final String? trimmed = note?.trim();
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

class _ResolvedGroupTransactions {
  const _ResolvedGroupTransactions({
    required this.principal,
    required this.interest,
    required this.fees,
  });

  final TransactionEntity? principal;
  final TransactionEntity? interest;
  final TransactionEntity? fees;
}

enum _PaymentComponent { principal, interest, fees, unknown }
