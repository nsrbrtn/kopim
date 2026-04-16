import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/budgets/domain/entities/budget.dart';
import 'package:kopim/features/budgets/domain/entities/budget_category_allocation.dart';
import 'package:kopim/features/budgets/domain/entities/budget_instance.dart';
import 'package:kopim/features/budgets/domain/entities/budget_instance_status.dart';
import 'package:kopim/features/budgets/domain/entities/budget_period.dart';
import 'package:kopim/features/budgets/domain/entities/budget_scope.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/profile/domain/entities/profile.dart';
import 'package:kopim/features/profile/domain/entities/user_progress.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/settings/domain/entities/export_bundle.dart';
import 'package:kopim/features/settings/domain/services/export_bundle_integrity_service.dart';
import 'package:kopim/features/settings/domain/services/export_bundle_json_decoder.dart';
import 'package:kopim/features/settings/domain/services/export_bundle_json_encoder.dart';
import 'package:kopim/features/tags/domain/entities/tag.dart';
import 'package:kopim/features/tags/domain/entities/transaction_tag.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/payment_reminder.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';

void main() {
  const ExportBundleJsonEncoder encoder = ExportBundleJsonEncoder();
  const ExportBundleJsonDecoder decoder = ExportBundleJsonDecoder();
  const ExportBundleIntegrityService integrityService =
      ExportBundleIntegrityService();

  test('encodes and decodes extended JSON bundle', () {
    final ExportBundle sourceBundle = ExportBundle(
      schemaVersion: '1.7.0',
      generatedAt: DateTime.utc(2024, 2, 10, 12, 30),
      accounts: <AccountEntity>[
        AccountEntity(
          id: 'a1',
          name: 'Hidden account',
          balanceMinor: BigInt.from(120050),
          openingBalanceMinor: BigInt.zero,
          currency: 'USD',
          currencyScale: 2,
          type: 'checking',
          typeVersion: 1,
          createdAt: DateTime.utc(2024, 1, 1),
          updatedAt: DateTime.utc(2024, 2, 1),
          isHidden: true,
        ),
      ],
      categories: <Category>[
        Category(
          id: 'c1',
          name: 'Food',
          type: 'expense',
          createdAt: DateTime.utc(2024, 1, 1),
          updatedAt: DateTime.utc(2024, 1, 2),
        ),
      ],
      tags: <TagEntity>[
        TagEntity(
          id: 'tag-1',
          name: 'Urgent',
          color: '#ff0000',
          createdAt: DateTime.utc(2024, 1, 1),
          updatedAt: DateTime.utc(2024, 1, 2),
        ),
      ],
      transactions: <TransactionEntity>[
        TransactionEntity(
          id: 't1',
          accountId: 'a1',
          categoryId: 'c1',
          amountMinor: BigInt.from(1240),
          amountScale: 2,
          date: DateTime.utc(2024, 2, 9),
          type: 'expense',
          createdAt: DateTime.utc(2024, 2, 9),
          updatedAt: DateTime.utc(2024, 2, 9),
        ),
      ],
      transactionTags: <TransactionTagEntity>[
        TransactionTagEntity(
          transactionId: 't1',
          tagId: 'tag-1',
          createdAt: DateTime.utc(2024, 2, 9),
          updatedAt: DateTime.utc(2024, 2, 9),
        ),
      ],
      savingGoals: <SavingGoal>[
        SavingGoal(
          id: 'goal-1',
          userId: 'user-1',
          name: 'Emergency',
          accountId: 'a1',
          storageAccountIds: const <String>['a1', 'a2'],
          targetAmount: 75000,
          currentAmount: 4000,
          createdAt: DateTime.utc(2024, 2, 1),
          updatedAt: DateTime.utc(2024, 2, 10),
        ),
      ],
      budgets: <Budget>[
        Budget(
          id: 'budget-1',
          title: 'Food budget',
          period: BudgetPeriod.monthly,
          startDate: DateTime.utc(2024, 2, 1),
          amountMinor: BigInt.from(50000),
          amountScale: 2,
          scope: BudgetScope.byCategory,
          categories: <String>['c1'],
          categoryAllocations: <BudgetCategoryAllocation>[
            BudgetCategoryAllocation(
              categoryId: 'c1',
              limitMinor: BigInt.from(50000),
              limitScale: 2,
            ),
          ],
          createdAt: DateTime.utc(2024, 2, 1),
          updatedAt: DateTime.utc(2024, 2, 1),
        ),
      ],
      budgetInstances: <BudgetInstance>[
        BudgetInstance(
          id: 'budget-instance-1',
          budgetId: 'budget-1',
          periodStart: DateTime.utc(2024, 2, 1),
          periodEnd: DateTime.utc(2024, 2, 29),
          amountMinor: BigInt.from(50000),
          spentMinor: BigInt.from(1200),
          amountScale: 2,
          status: BudgetInstanceStatus.active,
          createdAt: DateTime.utc(2024, 2, 1),
          updatedAt: DateTime.utc(2024, 2, 10),
        ),
      ],
      upcomingPayments: <UpcomingPayment>[
        UpcomingPayment(
          id: 'upcoming-1',
          title: 'Rent',
          accountId: 'a1',
          categoryId: 'c1',
          amountMinor: BigInt.from(100000),
          amountScale: 2,
          dayOfMonth: 15,
          notifyDaysBefore: 3,
          notifyTimeHhmm: '09:30',
          autoPost: true,
          isActive: true,
          createdAtMs: 1706745600000,
          updatedAtMs: 1707523200000,
        ),
      ],
      paymentReminders: <PaymentReminder>[
        PaymentReminder(
          id: 'reminder-1',
          title: 'Insurance',
          amountMinor: BigInt.from(25000),
          amountScale: 2,
          whenAtMs: 1707523200000,
          isDone: false,
          createdAtMs: 1706745600000,
          updatedAtMs: 1707523200000,
        ),
      ],
      profile: Profile(
        uid: 'user-1',
        name: 'Artem',
        currency: ProfileCurrency.usd,
        locale: 'ru',
        photoUrl: 'https://example.com/avatar.png',
        updatedAt: DateTime.utc(2024, 2, 10, 12, 30),
      ),
      progress: UserProgress(
        totalTx: 1,
        level: 1,
        title: 'Уровень 1',
        nextThreshold: 100,
        updatedAt: DateTime.utc(2024, 2, 10, 12, 30),
      ),
    );
    final ExportBundle bundle = sourceBundle.copyWith(
      integrity: integrityService.buildIntegrity(sourceBundle),
    );

    final Uint8List bytes = encoder.encode(bundle).bytes;
    final ExportBundle decoded = decoder.decode(bytes);

    expect(decoded, bundle);
    expect(decoded.accounts.single.isHidden, isTrue);
    expect(decoded.savingGoals.single.storageAccountIds, <String>['a1', 'a2']);
    expect(decoded.integrity?.contentHash, isNotEmpty);
    expect(decoded.profile?.uid, 'user-1');
    expect(decoded.progress?.totalTx, 1);
  });

  test('decodes legacy JSON backup without typeVersion as version zero', () {
    final Map<String, Object?> payload = <String, Object?>{
      'schemaVersion': '1.5.0',
      'generatedAt': '2024-02-10T12:30:00.000Z',
      'accounts': <Object?>[
        <String, Object?>{
          'id': 'a1',
          'name': 'Legacy account',
          'balance': 12.5,
          'openingBalance': 10.0,
          'balanceMinor': '1250',
          'openingBalanceMinor': '1000',
          'currency': 'USD',
          'currencyScale': 2,
          'type': 'card',
          'createdAt': '2024-01-01T00:00:00.000Z',
          'updatedAt': '2024-02-01T00:00:00.000Z',
          'isDeleted': false,
          'isPrimary': false,
          'isHidden': false,
        },
      ],
      'categories': <Object?>[],
      'tags': <Object?>[],
      'transactionTags': <Object?>[],
      'transactions': <Object?>[],
      'savingGoals': <Object?>[],
      'credits': <Object?>[],
      'creditCards': <Object?>[],
      'debts': <Object?>[],
      'budgets': <Object?>[],
      'budgetInstances': <Object?>[],
      'upcomingPayments': <Object?>[],
      'paymentReminders': <Object?>[],
    };

    final ExportBundle decoded = decoder.decode(
      Uint8List.fromList(utf8.encode(jsonEncode(payload))),
    );

    expect(decoded.accounts.single.type, 'card');
    expect(decoded.accounts.single.typeVersion, 0);
  });

  test('fails on partial JSON backup for current schema', () {
    final Map<String, Object?> payload = <String, Object?>{
      'schemaVersion': '1.4.0',
      'generatedAt': '2024-01-01T00:00:00Z',
      'accounts': <Object?>[],
      'categories': <Object?>[],
      'transactions': <Object?>[],
      'savingGoals': <Object?>[],
      'credits': <Object?>[],
      'debts': <Object?>[],
    };
    final Uint8List bytes = Uint8List.fromList(
      utf8.encode(jsonEncode(payload)),
    );

    expect(
      () => decoder.decode(bytes),
      throwsA(
        isA<FormatException>().having(
          (FormatException error) => error.message,
          'message',
          contains('creditCards'),
        ),
      ),
    );
  });

  test('fails on newer schema version', () {
    final Map<String, Object?> payload = <String, Object?>{
      'schemaVersion': '9.0.0',
      'generatedAt': '2024-01-01T00:00:00Z',
      'accounts': <Object?>[],
      'categories': <Object?>[],
      'transactions': <Object?>[],
      'savingGoals': <Object?>[],
      'credits': <Object?>[],
      'creditCards': <Object?>[],
      'debts': <Object?>[],
    };
    final Uint8List bytes = Uint8List.fromList(
      utf8.encode(jsonEncode(payload)),
    );

    expect(
      () => decoder.decode(bytes),
      throwsA(
        isA<FormatException>().having(
          (FormatException error) => error.message,
          'message',
          contains('более новую схему'),
        ),
      ),
    );
  });
}
