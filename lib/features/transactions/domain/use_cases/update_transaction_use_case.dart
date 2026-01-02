import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/repositories/account_repository.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/domain/entities/update_transaction_request.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:kopim/features/credits/domain/repositories/credit_repository.dart';
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';

class UpdateTransactionUseCase {
  UpdateTransactionUseCase({
    required TransactionRepository transactionRepository,
    required AccountRepository accountRepository,
    required CreditRepository creditRepository,
    DateTime Function()? clock,
  }) : _transactionRepository = transactionRepository,
       _accountRepository = accountRepository,
       _creditRepository = creditRepository,
       _clock = clock ?? DateTime.now;

  final TransactionRepository _transactionRepository;
  final AccountRepository _accountRepository;
  final CreditRepository _creditRepository;
  final DateTime Function() _clock;

  Future<void> call(UpdateTransactionRequest request) async {
    final TransactionEntity? existing = await _transactionRepository.findById(
      request.transactionId,
    );
    if (existing == null) {
      throw StateError('Transaction not found for id ${request.transactionId}');
    }

    final AccountEntity? originalAccount = await _accountRepository.findById(
      existing.accountId,
    );
    if (originalAccount == null) {
      throw StateError('Account not found for id ${existing.accountId}');
    }

    final DateTime now = _clock().toUtc();
    final double normalizedAmount = request.normalizedAmount;
    final TransactionType previousType = parseTransactionType(existing.type);
    final TransactionType newType = request.type;
    final String normalizedNote = request.note?.trim() ?? '';
    final String? noteValue = normalizedNote.isEmpty ? null : normalizedNote;

    if (newType.isTransfer &&
        (request.transferAccountId == null ||
            request.transferAccountId == request.accountId)) {
      throw StateError('Invalid transfer target account');
    }
    if (previousType.isTransfer &&
        (existing.transferAccountId == null ||
            existing.transferAccountId == existing.accountId)) {
      throw StateError('Invalid transfer source account');
    }

    final Map<String, double> previousEffect = _buildBalanceEffect(
      accountId: existing.accountId,
      transferAccountId: existing.transferAccountId,
      amount: existing.amount,
      type: previousType,
    );
    final Map<String, double> newEffect = _buildBalanceEffect(
      accountId: request.accountId,
      transferAccountId: request.transferAccountId,
      amount: normalizedAmount,
      type: newType,
    );
    final Set<String> affectedAccounts = <String>{
      ...previousEffect.keys,
      ...newEffect.keys,
    };
    for (final String accountId in affectedAccounts) {
      final AccountEntity? account = accountId == originalAccount.id
          ? originalAccount
          : await _accountRepository.findById(accountId);
      if (account == null) {
        throw StateError('Account not found for id $accountId');
      }
      final double delta =
          (newEffect[accountId] ?? 0) - (previousEffect[accountId] ?? 0);
      if (delta == 0) {
        continue;
      }
      await _accountRepository.upsert(
        account.copyWith(balance: account.balance + delta, updatedAt: now),
      );
    }

    // Логика пересчета баланса кредита
    if (existing.categoryId != request.categoryId ||
        existing.amount != normalizedAmount ||
        existing.type != newType.storageValue) {
      // 1. Отменяем старый эффект на баланс кредита (если он был)
      if (existing.categoryId != null && !previousType.isTransfer) {
        final CreditEntity? oldCredit = await _creditRepository
            .getCreditByCategoryId(existing.categoryId!);
        if (oldCredit != null) {
          final AccountEntity? oldCreditAccount = await _accountRepository
              .findById(oldCredit.accountId);
          if (oldCreditAccount != null) {
            final double oldRepaymentDelta =
                (existing.type == TransactionType.expense.storageValue)
                ? existing.amount
                : -existing.amount;
            await _accountRepository.upsert(
              oldCreditAccount.copyWith(
                balance: oldCreditAccount.balance - oldRepaymentDelta,
                updatedAt: now,
              ),
            );
          }
        }
      }

      // 2. Применяем новый эффект на баланс кредита (если он есть)
      if (request.categoryId != null && !newType.isTransfer) {
        final CreditEntity? newCredit = await _creditRepository
            .getCreditByCategoryId(request.categoryId!);
        if (newCredit != null) {
          final AccountEntity? newCreditAccount = await _accountRepository
              .findById(newCredit.accountId);
          if (newCreditAccount != null) {
            final double newRepaymentDelta = newType.isExpense
                ? normalizedAmount
                : -normalizedAmount;
            await _accountRepository.upsert(
              newCreditAccount.copyWith(
                balance: newCreditAccount.balance + newRepaymentDelta,
                updatedAt: now,
              ),
            );
          }
        }
      }
    }

    final TransactionEntity updatedTransaction = existing.copyWith(
      accountId: request.accountId,
      transferAccountId: request.transferAccountId,
      categoryId: newType.isTransfer ? null : request.categoryId,
      amount: normalizedAmount,
      date: request.date,
      note: noteValue,
      type: newType.storageValue,
      updatedAt: now,
    );

    await _transactionRepository.upsert(updatedTransaction);
  }

  Map<String, double> _buildBalanceEffect({
    required String accountId,
    required String? transferAccountId,
    required double amount,
    required TransactionType type,
  }) {
    if (type.isTransfer) {
      if (transferAccountId == null || transferAccountId == accountId) {
        return <String, double>{};
      }
      return <String, double>{accountId: -amount, transferAccountId: amount};
    }
    final double delta = type.isIncome ? amount : -amount;
    return <String, double>{accountId: delta};
  }
}
