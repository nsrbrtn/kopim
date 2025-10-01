import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/repositories/account_repository.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/domain/entities/update_transaction_request.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';

class UpdateTransactionUseCase {
  UpdateTransactionUseCase({
    required TransactionRepository transactionRepository,
    required AccountRepository accountRepository,
    DateTime Function()? clock,
  }) : _transactionRepository = transactionRepository,
       _accountRepository = accountRepository,
       _clock = clock ?? DateTime.now;

  final TransactionRepository _transactionRepository;
  final AccountRepository _accountRepository;
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
