import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/repositories/account_repository.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:kopim/features/profile/domain/entities/user_progress.dart';
import 'package:kopim/features/profile/domain/events/profile_domain_event.dart';
import 'package:kopim/features/profile/domain/models/profile_command_result.dart';
import 'package:kopim/features/profile/domain/usecases/on_transaction_deleted_use_case.dart';
import 'package:kopim/features/transactions/domain/models/transaction_command_result.dart';

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

  Future<TransactionCommandResult<void>> call(String transactionId) async {
    final TransactionEntity? existing = await _transactionRepository.findById(
      transactionId,
    );
    if (existing == null) {
      return TransactionCommandResult<void>(value: null);
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
    final List<ProfileDomainEvent> events = <ProfileDomainEvent>[];
    if (_onTransactionDeletedUseCase != null) {
      final ProfileCommandResult<UserProgress> progressResult =
          await _onTransactionDeletedUseCase.call();
      events.addAll(progressResult.events);
    }
    return TransactionCommandResult<void>(value: null, profileEvents: events);
  }

  TransactionType _parseType(String raw) {
    return raw == TransactionType.income.storageValue
        ? TransactionType.income
        : TransactionType.expense;
  }
}
