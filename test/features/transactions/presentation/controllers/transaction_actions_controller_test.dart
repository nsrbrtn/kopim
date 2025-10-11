import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/profile/presentation/services/profile_event_recorder.dart';
import 'package:kopim/features/transactions/domain/models/transaction_command_result.dart';
import 'package:kopim/features/transactions/domain/use_cases/delete_transaction_use_case.dart';
import 'package:kopim/features/transactions/presentation/controllers/transaction_actions_controller.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';

class _MockDeleteTransactionUseCase extends Mock
    implements DeleteTransactionUseCase {}

class _MockProfileEventRecorder extends Mock implements ProfileEventRecorder {}

void main() {
  late ProviderContainer container;
  late _MockDeleteTransactionUseCase deleteUseCase;
  late _MockProfileEventRecorder eventRecorder;

  setUp(() {
    deleteUseCase = _MockDeleteTransactionUseCase();
    eventRecorder = _MockProfileEventRecorder();
    when(() => eventRecorder.record(any())).thenAnswer((_) async {});
    container = ProviderContainer(
      // ignore: always_specify_types, the Override type is internal to riverpod
      overrides: [
        deleteTransactionUseCaseProvider.overrideWithValue(deleteUseCase),
        profileEventRecorderProvider.overrideWithValue(eventRecorder),
      ],
    );
    addTearDown(container.dispose);
  });

  test('deleteTransaction updates state on success', () async {
    when(() => deleteUseCase('tx-1')).thenAnswer((_) async {
      return TransactionCommandResult<void>(value: null);
    });

    const TransactionActionsControllerProvider provider =
        transactionActionsControllerProvider;
    container.read(provider);
    final TransactionActionsController controller = container.read(
      provider.notifier,
    );

    final Future<bool> result = controller.deleteTransaction('tx-1');
    expect(container.read(provider), const AsyncLoading<void>());

    expect(await result, isTrue);
    expect(container.read(provider), const AsyncData<void>(null));
    verify(() => deleteUseCase('tx-1')).called(1);
    verify(() => eventRecorder.record(any())).called(1);
  });

  test('deleteTransaction captures errors', () async {
    when(() => deleteUseCase('tx-2')).thenThrow(Exception('failure'));

    const TransactionActionsControllerProvider provider =
        transactionActionsControllerProvider;
    container.read(provider);
    final TransactionActionsController controller = container.read(
      provider.notifier,
    );

    final bool result = await controller.deleteTransaction('tx-2');

    expect(result, isFalse);
    final AsyncValue<void> state = container.read(provider);
    expect(state.hasError, isTrue);
    verify(() => deleteUseCase('tx-2')).called(1);
    verifyNever(() => eventRecorder.record(any()));
  });
}
