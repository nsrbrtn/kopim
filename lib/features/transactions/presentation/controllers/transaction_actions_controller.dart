import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/transactions/domain/use_cases/delete_transaction_use_case.dart';

part 'transaction_actions_controller.g.dart';

@riverpod
class TransactionActionsController extends _$TransactionActionsController {
  @override
  AsyncValue<void> build() => const AsyncData<void>(null);

  Future<bool> deleteTransaction(String transactionId) async {
    state = const AsyncLoading<void>();
    final DeleteTransactionUseCase useCase = ref.read(
      deleteTransactionUseCaseProvider,
    );
    try {
      await useCase(transactionId);
      state = const AsyncData<void>(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncError<void>(error, stackTrace);
      return false;
    }
  }

  void reset() {
    state = const AsyncData<void>(null);
  }
}
