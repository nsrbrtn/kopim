import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/repositories/account_repository.dart';
import 'package:kopim/core/money/currency_scale.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/domain/entities/update_transaction_request.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:kopim/features/credits/domain/use_cases/sync_credit_payment_schedule_use_case.dart';

class UpdateTransactionUseCase {
  UpdateTransactionUseCase({
    required TransactionRepository transactionRepository,
    required AccountRepository accountRepository,
    SyncCreditPaymentScheduleUseCase? syncCreditPaymentScheduleUseCase,
    DateTime Function()? clock,
  }) : _transactionRepository = transactionRepository,
       _accountRepository = accountRepository,
       _syncCreditPaymentScheduleUseCase = syncCreditPaymentScheduleUseCase,
       _clock = clock ?? DateTime.now;

  final TransactionRepository _transactionRepository;
  final AccountRepository _accountRepository;
  final SyncCreditPaymentScheduleUseCase? _syncCreditPaymentScheduleUseCase;
  final DateTime Function() _clock;

  Future<void> call(UpdateTransactionRequest request) async {
    final TransactionEntity? existing = await _transactionRepository.findById(
      request.transactionId,
    );
    if (existing == null) {
      throw StateError('Transaction not found for id ${request.transactionId}');
    }

    final DateTime now = _clock().toUtc();
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

    final AccountEntity? updatedAccount = await _accountRepository.findById(
      request.accountId,
    );
    if (updatedAccount == null) {
      throw StateError('Account not found for id ${request.accountId}');
    }
    if (newType.isTransfer) {
      final String? targetAccountId = request.transferAccountId;
      if (targetAccountId == null || targetAccountId == request.accountId) {
        throw StateError('Invalid transfer target account');
      }
      final AccountEntity? targetAccount = await _accountRepository.findById(
        targetAccountId,
      );
      if (targetAccount == null) {
        throw StateError('Account not found for id $targetAccountId');
      }
    }

    final int scale =
        updatedAccount.currencyScale ??
        resolveCurrencyScale(updatedAccount.currency);
    final MoneyAmount resolvedAmount = rescaleMoneyAmount(
      request.normalizedAmount,
      scale,
    );
    final TransactionEntity updatedTransaction = existing.copyWith(
      accountId: request.accountId,
      transferAccountId: request.transferAccountId,
      categoryId: newType.isTransfer ? null : request.categoryId,
      amountMinor: resolvedAmount.minor,
      amountScale: resolvedAmount.scale,
      date: request.date,
      note: noteValue,
      type: newType.storageValue,
      updatedAt: now,
    );

    await _transactionRepository.upsert(updatedTransaction);
    if (_syncCreditPaymentScheduleUseCase != null) {
      await _syncCreditPaymentScheduleUseCase.call(
        previous: existing,
        current: updatedTransaction,
      );
    }
  }
}
