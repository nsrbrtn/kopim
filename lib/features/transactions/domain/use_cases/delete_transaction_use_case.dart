import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/repositories/account_repository.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:kopim/features/profile/domain/usecases/on_transaction_deleted_use_case.dart';

class DeleteTransactionUseCase {
  DeleteTransactionUseCase({
    required TransactionRepository transactionRepository,
    required AccountRepository accountRepository,
    OnTransactionDeletedUseCase? onTransactionDeletedUseCase,
    DateTime Function()? clock,
  }) : _transactionRepository = transactionRepository,
       _accountRepository = accountRepository,
       _onTransactionDeletedUseCase = onTransactionDeletedUseCase,
       _clock = clock ?? DateTime.now;

  final TransactionRepository _transactionRepository;
  final AccountRepository _accountRepository;
  final OnTransactionDeletedUseCase? _onTransactionDeletedUseCase;
  final DateTime Function() _clock;

  Future<void> call(String transactionId) async {
    final TransactionEntity? existing = await _transactionRepository.findById(
      transactionId,
    );
    if (existing == null) {
      return;
    }

    final AccountEntity? account = await _accountRepository.findById(
      existing.accountId,
    );
    if (account == null) {
      throw StateError('Account not found for id ${existing.accountId}');
    }

    final DateTime now = _clock().toUtc();
    final TransactionType type = _parseType(existing.type);
    final double balanceDelta = type.isIncome
        ? -existing.amount
        : existing.amount;
    final AccountEntity updatedAccount = account.copyWith(
      balance: account.balance + balanceDelta,
      updatedAt: now,
    );
    await _accountRepository.upsert(updatedAccount);

    await _transactionRepository.softDelete(transactionId);
    await _onTransactionDeletedUseCase?.call();
  }

  TransactionType _parseType(String raw) {
    return raw == TransactionType.income.storageValue
        ? TransactionType.income
        : TransactionType.expense;
  }
}
