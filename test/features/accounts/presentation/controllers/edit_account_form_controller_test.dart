import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/accounts/domain/repositories/account_repository.dart';
import 'package:kopim/features/accounts/domain/use_cases/add_account_use_case.dart';
import 'package:kopim/features/accounts/presentation/controllers/edit_account_form_controller.dart';
import 'package:riverpod/riverpod.dart';

void main() {
  group('EditAccountFormController', () {
    test('updates account using addAccountUseCase', () async {
      final _RecordingAccountRepository repository =
          _RecordingAccountRepository();
      final ProviderContainer container = ProviderContainer(
        // ignore: always_specify_types, the Override type is internal to riverpod
        overrides: [
          addAccountUseCaseProvider.overrideWithValue(
            AddAccountUseCase(repository),
          ),
        ],
      );
      addTearDown(container.dispose);

      final DateTime createdAt = DateTime.utc(2024, 1, 1);
      final AccountEntity original = AccountEntity(
        id: 'acc-1',
        name: 'Wallet',
        balance: 100,
        currency: 'USD',
        type: 'cash',
        createdAt: createdAt,
        updatedAt: createdAt,
      );

      final EditAccountFormController controller = container.read(
        editAccountFormControllerProvider(original).notifier,
      );

      controller
        ..updateName(' Wallet Plus ')
        ..updateBalance('250,75')
        ..updateCurrency('EUR');

      await controller.submit();

      expect(repository.lastUpserted, isNotNull);
      final AccountEntity updated = repository.lastUpserted!;
      expect(updated.id, original.id);
      expect(updated.name, 'Wallet Plus');
      expect(updated.balance, closeTo(250.75, 1e-6));
      expect(updated.currency, 'EUR');
      expect(updated.type, original.type);
      expect(updated.createdAt, original.createdAt);
      expect(updated.updatedAt.isAfter(original.updatedAt), isTrue);

      final EditAccountFormState state = container.read(
        editAccountFormControllerProvider(original),
      );
      expect(state.submissionSuccess, isTrue);
    });

    test('validates empty name and invalid balance', () async {
      final ProviderContainer container = ProviderContainer(
        // ignore: always_specify_types, the Override type is internal to riverpod
        overrides: [
          addAccountUseCaseProvider.overrideWithValue(
            AddAccountUseCase(_RecordingAccountRepository()),
          ),
        ],
      );
      addTearDown(container.dispose);

      final DateTime now = DateTime.utc(2024, 1, 1);
      final AccountEntity original = AccountEntity(
        id: 'acc-2',
        name: 'Savings',
        balance: 500,
        currency: 'USD',
        type: 'bank',
        createdAt: now,
        updatedAt: now,
      );

      final EditAccountFormController controller = container.read(
        editAccountFormControllerProvider(original).notifier,
      );

      controller
        ..updateName('   ')
        ..updateBalance('abc');

      await controller.submit();

      final EditAccountFormState state = container.read(
        editAccountFormControllerProvider(original),
      );

      expect(state.nameError, EditAccountFieldError.emptyName);
      expect(state.balanceError, EditAccountFieldError.invalidBalance);
      expect(state.submissionSuccess, isFalse);
    });
  });
}

class _RecordingAccountRepository implements AccountRepository {
  AccountEntity? lastUpserted;

  @override
  Future<AccountEntity?> findById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<List<AccountEntity>> loadAccounts() {
    throw UnimplementedError();
  }

  @override
  Future<void> softDelete(String id) {
    throw UnimplementedError();
  }

  @override
  Future<void> upsert(AccountEntity account) async {
    lastUpserted = account;
  }

  @override
  Stream<List<AccountEntity>> watchAccounts() {
    throw UnimplementedError();
  }
}
