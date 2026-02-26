import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/repositories/account_repository.dart';
import 'package:kopim/features/overview/domain/models/overview_behavior_progress.dart';
import 'package:kopim/features/overview/domain/use_cases/watch_overview_behavior_progress_use_case.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockAccountRepository extends Mock implements AccountRepository {}

class _MockTransactionRepository extends Mock
    implements TransactionRepository {}

void main() {
  group('WatchOverviewBehaviorProgressUseCase', () {
    late _MockAccountRepository accountRepository;
    late _MockTransactionRepository transactionRepository;
    late WatchOverviewBehaviorProgressUseCase useCase;

    setUp(() {
      accountRepository = _MockAccountRepository();
      transactionRepository = _MockTransactionRepository();
      useCase = WatchOverviewBehaviorProgressUseCase(
        accountRepository: accountRepository,
        transactionRepository: transactionRepository,
      );
    });

    test('считает streak и score по отфильтрованным транзакциям', () async {
      final DateTime reference = DateTime(2026, 2, 25);
      final DateTime createdAt = DateTime(2026, 1, 1);
      when(
        () => accountRepository.watchAccounts(),
      ).thenAnswer((_) => Stream<List<AccountEntity>>.value(_accounts()));
      when(() => transactionRepository.watchTransactions()).thenAnswer(
        (_) => Stream<List<TransactionEntity>>.value(<TransactionEntity>[
          _expense(
            id: 'a-today',
            accountId: 'a',
            categoryId: 'food',
            date: DateTime(2026, 2, 25),
            createdAt: createdAt,
          ),
          _expense(
            id: 'a-yesterday',
            accountId: 'a',
            categoryId: 'rent',
            date: DateTime(2026, 2, 24),
            createdAt: createdAt,
          ),
          _expense(
            id: 'b-two-days',
            accountId: 'b',
            categoryId: 'travel',
            date: DateTime(2026, 2, 23),
            createdAt: createdAt,
          ),
          _expense(
            id: 'a-no-category',
            accountId: 'a',
            categoryId: null,
            date: DateTime(2026, 2, 22),
            createdAt: createdAt,
          ),
        ]),
      );

      final OverviewBehaviorProgress result = await useCase
          .call(
            reference: reference,
            accountIdsFilter: <String>{'a'},
            categoryIdsFilter: <String>{'food', 'rent'},
          )
          .first;

      expect(result.activeDays30d, 2);
      expect(result.streakDays, 2);
      expect(result.disciplineScore, 10);
      expect(result.progress, closeTo(0.1, 0.0001));
    });

    test('игнорирует удаленные аккаунты и удаленные транзакции', () async {
      final DateTime reference = DateTime(2026, 2, 25);
      final DateTime createdAt = DateTime(2026, 1, 1);
      when(
        () => accountRepository.watchAccounts(),
      ).thenAnswer((_) => Stream<List<AccountEntity>>.value(_accounts()));
      when(() => transactionRepository.watchTransactions()).thenAnswer(
        (_) => Stream<List<TransactionEntity>>.value(<TransactionEntity>[
          _expense(
            id: 'active-a',
            accountId: 'a',
            categoryId: 'food',
            date: DateTime(2026, 2, 25),
            createdAt: createdAt,
          ),
          _expense(
            id: 'deleted-tx',
            accountId: 'a',
            categoryId: 'food',
            date: DateTime(2026, 2, 24),
            createdAt: createdAt,
            isDeleted: true,
          ),
          _expense(
            id: 'deleted-account-tx',
            accountId: 'deleted',
            categoryId: 'food',
            date: DateTime(2026, 2, 23),
            createdAt: createdAt,
          ),
        ]),
      );

      final OverviewBehaviorProgress result = await useCase
          .call(reference: reference)
          .first;

      expect(result.activeDays30d, 1);
      expect(result.streakDays, 1);
      expect(result.disciplineScore, 5);
    });
  });
}

List<AccountEntity> _accounts() {
  final DateTime now = DateTime(2026, 1, 1);
  return <AccountEntity>[
    AccountEntity(
      id: 'a',
      name: 'A',
      balanceMinor: BigInt.from(100000),
      openingBalanceMinor: BigInt.from(100000),
      currency: 'RUB',
      currencyScale: 2,
      type: 'cash',
      createdAt: now,
      updatedAt: now,
    ),
    AccountEntity(
      id: 'b',
      name: 'B',
      balanceMinor: BigInt.from(200000),
      openingBalanceMinor: BigInt.from(200000),
      currency: 'RUB',
      currencyScale: 2,
      type: 'cash',
      createdAt: now,
      updatedAt: now,
    ),
    AccountEntity(
      id: 'deleted',
      name: 'Deleted',
      balanceMinor: BigInt.from(200000),
      openingBalanceMinor: BigInt.from(200000),
      currency: 'RUB',
      currencyScale: 2,
      type: 'cash',
      createdAt: now,
      updatedAt: now,
      isDeleted: true,
    ),
  ];
}

TransactionEntity _expense({
  required String id,
  required String accountId,
  required String? categoryId,
  required DateTime date,
  required DateTime createdAt,
  bool isDeleted = false,
}) {
  return TransactionEntity(
    id: id,
    accountId: accountId,
    categoryId: categoryId,
    amountMinor: BigInt.from(-1000),
    amountScale: 2,
    date: date,
    type: TransactionType.expense.storageValue,
    createdAt: createdAt,
    updatedAt: createdAt,
    isDeleted: isDeleted,
  );
}
