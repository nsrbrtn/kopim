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
    final TransactionType previousType = _parseType(existing.type);
    final double previousDelta = previousType.isIncome
        ? existing.amount
        : -existing.amount;
    final TransactionType newType = request.type;
    final double newDelta = newType.isIncome
        ? normalizedAmount
        : -normalizedAmount;
    final String normalizedNote = request.note?.trim() ?? '';
    final String? noteValue = normalizedNote.isEmpty ? null : normalizedNote;

    if (existing.accountId == request.accountId) {
      final double updatedBalance =
          originalAccount.balance - previousDelta + newDelta;
      final AccountEntity updatedAccount = originalAccount.copyWith(
        balance: updatedBalance,
        updatedAt: now,
      );
      await _accountRepository.upsert(updatedAccount);
    } else {
      final double originalUpdatedBalance =
          originalAccount.balance - previousDelta;
      final AccountEntity updatedSourceAccount = originalAccount.copyWith(
        balance: originalUpdatedBalance,
        updatedAt: now,
      );
      await _accountRepository.upsert(updatedSourceAccount);

      final AccountEntity? newAccount = await _accountRepository.findById(
        request.accountId,
      );
      if (newAccount == null) {
        throw StateError('Account not found for id ${request.accountId}');
      }
      final AccountEntity updatedTargetAccount = newAccount.copyWith(
        balance: newAccount.balance + newDelta,
        updatedAt: now,
      );
      await _accountRepository.upsert(updatedTargetAccount);
    }

    // Логика пересчета баланса кредита
    if (existing.categoryId != request.categoryId ||
        existing.amount != normalizedAmount ||
        existing.type != newType.storageValue) {
      // 1. Отменяем старый эффект на баланс кредита (если он был)
      if (existing.categoryId != null) {
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
      if (request.categoryId != null) {
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
      categoryId: request.categoryId,
      amount: normalizedAmount,
      date: request.date,
      note: noteValue,
      type: newType.storageValue,
      updatedAt: now,
    );

    await _transactionRepository.upsert(updatedTransaction);
  }

  TransactionType _parseType(String raw) {
    return raw == TransactionType.income.storageValue
        ? TransactionType.income
        : TransactionType.expense;
  }
}
