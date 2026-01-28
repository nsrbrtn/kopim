import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:kopim/features/profile/domain/entities/user_progress.dart';
import 'package:kopim/features/profile/domain/events/profile_domain_event.dart';
import 'package:kopim/features/profile/domain/models/profile_command_result.dart';
import 'package:kopim/features/profile/domain/usecases/on_transaction_deleted_use_case.dart';
import 'package:kopim/features/transactions/domain/models/transaction_command_result.dart';
import 'package:kopim/features/credits/domain/use_cases/sync_credit_payment_schedule_use_case.dart';

class DeleteTransactionUseCase {
  DeleteTransactionUseCase({
    required TransactionRepository transactionRepository,
    OnTransactionDeletedUseCase? onTransactionDeletedUseCase,
    SyncCreditPaymentScheduleUseCase? syncCreditPaymentScheduleUseCase,
  }) : _transactionRepository = transactionRepository,
       _onTransactionDeletedUseCase = onTransactionDeletedUseCase,
       _syncCreditPaymentScheduleUseCase = syncCreditPaymentScheduleUseCase;

  final TransactionRepository _transactionRepository;
  final OnTransactionDeletedUseCase? _onTransactionDeletedUseCase;
  final SyncCreditPaymentScheduleUseCase? _syncCreditPaymentScheduleUseCase;

  Future<TransactionCommandResult<void>> call(String transactionId) async {
    final TransactionEntity? existing = await _transactionRepository.findById(
      transactionId,
    );
    if (existing == null) {
      return TransactionCommandResult<void>(value: null);
    }

    await _transactionRepository.softDelete(transactionId);
    if (_syncCreditPaymentScheduleUseCase != null) {
      await _syncCreditPaymentScheduleUseCase.call(previous: existing);
    }
    final List<ProfileDomainEvent> events = <ProfileDomainEvent>[];
    if (_onTransactionDeletedUseCase != null) {
      final ProfileCommandResult<UserProgress> progressResult =
          await _onTransactionDeletedUseCase.call();
      events.addAll(progressResult.events);
    }
    return TransactionCommandResult<void>(value: null, profileEvents: events);
  }
}
