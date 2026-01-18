import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/repositories/account_repository.dart';
import 'package:kopim/core/money/currency_scale.dart';
import 'package:kopim/core/money/money.dart';
import 'package:kopim/features/transactions/domain/entities/add_transaction_request.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:kopim/features/profile/domain/entities/user_progress.dart';
import 'package:kopim/features/profile/domain/events/profile_domain_event.dart';
import 'package:kopim/features/profile/domain/models/profile_command_result.dart';
import 'package:kopim/features/profile/domain/usecases/on_transaction_created_use_case.dart';
import 'package:uuid/uuid.dart';
import 'package:kopim/features/transactions/domain/models/transaction_command_result.dart';

class AddTransactionUseCase {
  AddTransactionUseCase({
    required TransactionRepository transactionRepository,
    required AccountRepository accountRepository,
    OnTransactionCreatedUseCase? onTransactionCreatedUseCase,
    String Function()? idGenerator,
    DateTime Function()? clock,
  }) : _transactionRepository = transactionRepository,
       _accountRepository = accountRepository,
       _onTransactionCreatedUseCase = onTransactionCreatedUseCase,
       _generateId = idGenerator ?? _defaultIdGenerator,
       _clock = clock ?? _defaultClock;

  static String _defaultIdGenerator() => const Uuid().v4();

  static DateTime _defaultClock() => DateTime.now();

  final TransactionRepository _transactionRepository;
  final AccountRepository _accountRepository;
  final OnTransactionCreatedUseCase? _onTransactionCreatedUseCase;
  final String Function() _generateId;
  final DateTime Function() _clock;

  Future<TransactionCommandResult<TransactionEntity>> call(
    AddTransactionRequest request,
  ) async {
    final AccountEntity? account = await _accountRepository.findById(
      request.accountId,
    );
    if (account == null) {
      throw StateError('Account not found for id ${request.accountId}');
    }

    final DateTime now = _clock().toUtc();
    final double amount = request.normalizedAmount;
    final TransactionType type = request.type;
    final int scale =
        request.amountScale ?? resolveCurrencyScale(account.currency);
    final BigInt amountMinor = request.amountMinor ??
        Money.fromDouble(
          amount,
          currency: account.currency,
          scale: scale,
        ).minor;
    final TransactionEntity transaction = TransactionEntity(
      id: _generateId(),
      accountId: request.accountId,
      transferAccountId: request.transferAccountId,
      categoryId: type.isTransfer ? null : request.categoryId,
      savingGoalId: request.savingGoalId,
      amount: amount,
      amountMinor: amountMinor,
      amountScale: scale,
      date: request.date,
      note: request.note?.trim().isEmpty ?? true ? null : request.note!.trim(),
      type: type.storageValue,
      createdAt: now,
      updatedAt: now,
    );

    if (type.isTransfer) {
      final String? targetAccountId = request.transferAccountId;
      if (targetAccountId == null || targetAccountId == request.accountId) {
        throw StateError('Invalid transfer target account');
      }
      final AccountEntity? targetAccount =
          await _accountRepository.findById(targetAccountId);
      if (targetAccount == null) {
        throw StateError('Account not found for id $targetAccountId');
      }
    }

    await _transactionRepository.upsert(transaction);

    final List<ProfileDomainEvent> events = <ProfileDomainEvent>[];
    if (_onTransactionCreatedUseCase != null) {
      final ProfileCommandResult<UserProgress> progressResult =
          await _onTransactionCreatedUseCase.call();
      events.addAll(progressResult.events);
    }

    return TransactionCommandResult<TransactionEntity>(
      value: transaction,
      profileEvents: events,
    );
  }
}
