import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/profile/presentation/services/profile_event_recorder.dart';
import 'package:kopim/features/transactions/domain/models/transaction_command_result.dart';
import 'package:kopim/features/transactions/domain/use_cases/delete_transaction_use_case.dart';

part 'transaction_actions_controller.g.dart';

@Riverpod(keepAlive: true)
class TransactionActionsController extends _$TransactionActionsController {
  @override
  AsyncValue<void> build() => const AsyncData<void>(null);

  Future<bool> deleteTransaction(String transactionId) async {
    try {
      state = const AsyncLoading<void>();
      final DeleteTransactionUseCase useCase = ref.read(
        deleteTransactionUseCaseProvider,
      );
      final ProfileEventRecorder recorder = ref.read(
        profileEventRecorderProvider,
      );
      final TransactionCommandResult<void> result = await useCase(
        transactionId,
      );
      if (!ref.mounted) {
        return false;
      }
      unawaited(recorder.record(result.profileEvents));
      state = const AsyncData<void>(null);
      return true;
    } catch (error, stackTrace) {
      if (!ref.mounted) {
        return false;
      }
      debugPrint(
        'Ошибка удаления транзакции $transactionId: $error\n$stackTrace',
      );
      state = AsyncError<void>(error, stackTrace);
      return false;
    }
  }

  void reset() {
    state = const AsyncData<void>(null);
  }
}
