import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/repositories/account_repository.dart';
import 'package:kopim/features/transactions/domain/entities/add_transaction_request.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:uuid/uuid.dart';

class AddTransactionUseCase {
  AddTransactionUseCase({
    required TransactionRepository transactionRepository,
    required AccountRepository accountRepository,
    String Function()? idGenerator,
    DateTime Function()? clock,
  }) : _transactionRepository = transactionRepository,
       _accountRepository = accountRepository,
       _generateId = idGenerator ?? _defaultIdGenerator,
       _clock = clock ?? _defaultClock;

  static String _defaultIdGenerator() => const Uuid().v4();

  static DateTime _defaultClock() => DateTime.now();

  final TransactionRepository _transactionRepository;
  final AccountRepository _accountRepository;
  final String Function() _generateId;
  final DateTime Function() _clock;

  Future<void> call(AddTransactionRequest request) async {
    final AccountEntity? account = await _accountRepository.findById(
      request.accountId,
    );
    if (account == null) {
      throw StateError('Account not found for id ${request.accountId}');
    }

    final DateTime now = _clock().toUtc();
    final double amount = request.normalizedAmount;
    final TransactionType type = request.type;
    final TransactionEntity transaction = TransactionEntity(
      id: _generateId(),
      accountId: request.accountId,
      categoryId: request.categoryId,
      savingGoalId: request.savingGoalId,
      amount: amount,
      date: request.date,
      note: request.note?.trim().isEmpty ?? true ? null : request.note!.trim(),
      type: type.storageValue,
      createdAt: now,
      updatedAt: now,
    );

    await _transactionRepository.upsert(transaction);

    final double delta = type.isIncome ? amount : -amount;
    final AccountEntity updatedAccount = account.copyWith(
      balance: account.balance + delta,
      updatedAt: now,
    );
    await _accountRepository.upsert(updatedAccount);
  }
}
