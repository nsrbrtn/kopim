import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/transactions/domain/entities/add_transaction_request.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/domain/entities/update_transaction_request.dart';
import 'package:kopim/features/transactions/domain/use_cases/add_transaction_use_case.dart';
import 'package:kopim/features/transactions/domain/use_cases/update_transaction_use_case.dart';
import 'package:kopim/features/transactions/presentation/controllers/transaction_form_controller.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';

class _MockAddTransactionUseCase extends Mock
    implements AddTransactionUseCase {}

class _MockUpdateTransactionUseCase extends Mock
    implements UpdateTransactionUseCase {}

void main() {
  late ProviderContainer container;
  late _MockAddTransactionUseCase addUseCase;
  late _MockUpdateTransactionUseCase updateUseCase;

  setUpAll(() {
    registerFallbackValue(
      AddTransactionRequest(
        accountId: 'acc',
        amount: 1,
        date: DateTime.utc(2024, 1, 1),
        type: TransactionType.expense,
      ),
    );
    registerFallbackValue(
      UpdateTransactionRequest(
        transactionId: 'tx',
        accountId: 'acc',
        amount: 1,
        date: DateTime.utc(2024, 1, 1),
        type: TransactionType.expense,
      ),
    );
  });

  setUp(() {
    addUseCase = _MockAddTransactionUseCase();
    updateUseCase = _MockUpdateTransactionUseCase();
    container = ProviderContainer(
      overrides: [
        addTransactionUseCaseProvider.overrideWithValue(addUseCase),
        updateTransactionUseCaseProvider.overrideWithValue(updateUseCase),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('initial state uses provided defaults', () {
    const TransactionFormArgs args = TransactionFormArgs(
      defaultAccountId: 'acc-1',
    );

    final TransactionFormState state = container.read(
      transactionFormControllerProvider(args),
    );

    expect(state.accountId, 'acc-1');
    expect(state.type, TransactionType.expense);
    expect(state.amount, isEmpty);
    expect(state.isSubmitting, isFalse);
  });

  test('submit creates a transaction via add use case', () async {
    const TransactionFormArgs args = TransactionFormArgs(
      defaultAccountId: 'acc-1',
    );
    final TransactionFormControllerProvider provider =
        transactionFormControllerProvider(args);
    container.read(provider);
    final TransactionFormController controller = container.read(
      provider.notifier,
    );

    when(() => addUseCase(any())).thenAnswer((_) async {});

    controller
      ..updateAccount('acc-1')
      ..updateAmount('42.5')
      ..updateType(TransactionType.income)
      ..updateCategory('cat-1')
      ..updateNote('Snacks')
      ..updateDate(DateTime.utc(2024, 4, 1));

    await controller.submit();

    final AddTransactionRequest request =
        verify(() => addUseCase(captureAny())).captured.single
            as AddTransactionRequest;
    expect(request.accountId, 'acc-1');
    expect(request.categoryId, 'cat-1');
    expect(request.amount, closeTo(42.5, 1e-9));
    expect(request.type, TransactionType.income);
    expect(request.note, 'Snacks');
    expect(request.date, DateTime.utc(2024, 4, 1));

    final TransactionFormState state = container.read(provider);
    expect(state.isSuccess, isTrue);
    expect(state.isSubmitting, isFalse);
  });

  test('submit updates an existing transaction', () async {
    final TransactionEntity transaction = TransactionEntity(
      id: 'tx-1',
      accountId: 'acc-1',
      categoryId: 'cat-1',
      amount: 30,
      date: DateTime.utc(2024, 3, 1),
      note: 'Lunch',
      type: TransactionType.expense.storageValue,
      createdAt: DateTime.utc(2024, 3, 1),
      updatedAt: DateTime.utc(2024, 3, 1),
    );
    final TransactionFormArgs args = TransactionFormArgs(
      initialTransaction: transaction,
    );
    final TransactionFormControllerProvider provider =
        transactionFormControllerProvider(args);
    container.read(provider);
    final TransactionFormController controller = container.read(
      provider.notifier,
    );

    when(() => updateUseCase(any())).thenAnswer((_) async {});

    controller
      ..updateAmount('55')
      ..updateType(TransactionType.expense)
      ..updateCategory('cat-2')
      ..updateNote('Updated note')
      ..updateDate(DateTime.utc(2024, 3, 10));

    await controller.submit();

    final UpdateTransactionRequest request =
        verify(() => updateUseCase(captureAny())).captured.single
            as UpdateTransactionRequest;
    expect(request.transactionId, 'tx-1');
    expect(request.accountId, 'acc-1');
    expect(request.categoryId, 'cat-2');
    expect(request.amount, closeTo(55, 1e-9));
    expect(request.type, TransactionType.expense);
    expect(request.note, 'Updated note');
    expect(request.date, DateTime.utc(2024, 3, 10));

    final TransactionFormState state = container.read(provider);
    expect(state.isSuccess, isTrue);
    expect(state.isSubmitting, isFalse);
  });
}
