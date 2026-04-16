import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:kopim/core/domain/icons/phosphor_icon_descriptor.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/budgets/domain/entities/budget.dart';
import 'package:kopim/features/budgets/domain/entities/budget_category_allocation.dart';
import 'package:kopim/features/budgets/domain/entities/budget_instance.dart';
import 'package:kopim/features/budgets/domain/entities/budget_instance_status.dart';
import 'package:kopim/features/budgets/domain/entities/budget_period.dart';
import 'package:kopim/features/budgets/domain/entities/budget_scope.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/credits/domain/entities/credit_card_entity.dart';
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/features/credits/domain/entities/debt_entity.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';
import 'package:kopim/features/settings/domain/entities/export_bundle.dart';
import 'package:kopim/features/settings/domain/services/export_bundle_csv_decoder.dart';
import 'package:kopim/features/settings/domain/services/export_bundle_csv_encoder.dart';
import 'package:kopim/features/tags/domain/entities/tag.dart';
import 'package:kopim/features/tags/domain/entities/transaction_tag.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/payment_reminder.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';

void main() {
  const ExportBundleCsvEncoder encoder = ExportBundleCsvEncoder();
  const ExportBundleCsvDecoder decoder = ExportBundleCsvDecoder();

  test('encodes and decodes CSV bundle with escaped fields', () {
    final ExportBundle bundle = ExportBundle(
      schemaVersion: '1.6.0',
      generatedAt: DateTime.utc(2024, 2, 10, 12, 30),
      accounts: <AccountEntity>[
        AccountEntity(
          id: 'a1',
          name: 'Main account',
          balanceMinor: BigInt.from(120050),
          openingBalanceMinor: BigInt.zero,
          currency: 'USD',
          currencyScale: 2,
          type: 'checking',
          typeVersion: 1,
          createdAt: DateTime.utc(2024, 1, 1),
          updatedAt: DateTime.utc(2024, 2, 1),
          isPrimary: true,
          isHidden: true,
        ),
      ],
      categories: <Category>[
        Category(
          id: 'c1',
          name: 'Food',
          type: 'expense',
          icon: const PhosphorIconDescriptor(
            name: 'fork-knife',
            style: PhosphorIconStyle.bold,
          ),
          createdAt: DateTime.utc(2024, 1, 1),
          updatedAt: DateTime.utc(2024, 1, 2),
          isFavorite: true,
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
          note: 'Lunch, cafe\nSecond line',
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
          name: 'Vacation',
          accountId: 'a1',
          storageAccountIds: const <String>['a1', 'a2'],
          targetAmount: 90000,
          currentAmount: 1200,
          createdAt: DateTime.utc(2024, 2, 1),
          updatedAt: DateTime.utc(2024, 2, 10),
        ),
      ],
      credits: <CreditEntity>[
        CreditEntity(
          id: 'cr1',
          accountId: 'a1',
          categoryId: 'c1',
          totalAmountMinor: BigInt.from(500000),
          totalAmountScale: 2,
          interestRate: 11.5,
          termMonths: 12,
          startDate: DateTime.utc(2024, 1, 10),
          firstPaymentDate: DateTime.utc(2024, 2, 10),
          createdAt: DateTime.utc(2024, 1, 10),
          updatedAt: DateTime.utc(2024, 1, 10),
        ),
      ],
      creditCards: <CreditCardEntity>[
        CreditCardEntity(
          id: 'cc1',
          accountId: 'a1',
          creditLimitMinor: BigInt.from(100000),
          creditLimitScale: 2,
          statementDay: 5,
          paymentDueDays: 20,
          interestRateAnnual: 29.9,
          createdAt: DateTime.utc(2024, 1, 5),
          updatedAt: DateTime.utc(2024, 1, 5),
        ),
      ],
      debts: <DebtEntity>[
        DebtEntity(
          id: 'd1',
          accountId: 'a1',
          name: 'Friend',
          amountMinor: BigInt.from(15000),
          amountScale: 2,
          dueDate: DateTime.utc(2024, 3, 1),
          createdAt: DateTime.utc(2024, 2, 1),
          updatedAt: DateTime.utc(2024, 2, 1),
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
    );

    final Uint8List bytes = encoder.encode(bundle).bytes;
    final ExportBundle decoded = decoder.decode(bytes);

    expect(decoded, bundle);
    expect(decoded.accounts.single.isHidden, isTrue);
    expect(decoded.savingGoals.single.storageAccountIds, <String>['a1', 'a2']);
  });

  test('decodes legacy CSV backup without type_version as zero', () {
    const String csv = '''
#kopim-export
#schema_version,1.5.0
#generated_at,2024-02-10T12:30:00.000Z
#accounts
id,name,balance,opening_balance,balance_minor,opening_balance_minor,currency_scale,currency,type,created_at,updated_at,color,gradient_id,icon_name,icon_style,is_deleted,is_primary,is_hidden
a1,Legacy account,12.5,10.0,1250,1000,2,USD,card,2024-01-01T00:00:00.000Z,2024-02-01T00:00:00.000Z,,,,,false,false,false
#categories
id,name,type,parent_id,icon_name,icon_style,color,created_at,updated_at,is_system,is_hidden,is_favorite
#tags
id,name,color,created_at,updated_at,is_deleted
#transaction_tags
transaction_id,tag_id,created_at,updated_at,is_deleted
#saving_goals
id,user_id,name,account_id,target_date,target_amount,current_amount,note,created_at,updated_at,archived_at
goal-1,user-1,Legacy goal,a1,,50000,1200,,2024-01-01T00:00:00.000Z,2024-02-01T00:00:00.000Z,
#credits
id,account_id,category_id,interest_category_id,fees_category_id,total_amount,total_amount_minor,total_amount_scale,interest_rate,term_months,start_date,first_payment_date,payment_day,created_at,updated_at,is_deleted
#credit_cards
id,account_id,credit_limit,credit_limit_minor,credit_limit_scale,statement_day,payment_due_days,interest_rate_annual,created_at,updated_at,is_deleted
#debts
id,account_id,name,amount,amount_minor,amount_scale,due_date,note,created_at,updated_at,is_deleted
#budgets
id,title,amount,amount_minor,amount_scale,period,start_date,end_date,scope,categories,category_allocations,accounts,created_at,updated_at,is_deleted
#budget_instances
id,budget_id,period_start,period_end,amount,amount_minor,spent,spent_minor,amount_scale,status,created_at,updated_at
#upcoming_payments
id,title,account_id,category_id,amount,amount_minor,amount_scale,day_of_month,notify_days_before,notify_time_hhmm,auto_post,is_active,created_at_ms,updated_at_ms
#payment_reminders
id,title,amount,amount_minor,amount_scale,when_at_ms,is_done,created_at_ms,updated_at_ms
#transactions
id,account_id,transfer_account_id,category_id,saving_goal_id,idempotency_key,group_id,amount,amount_minor,amount_scale,date,note,type,created_at,updated_at,is_deleted
''';

    final ExportBundle decoded = decoder.decode(
      Uint8List.fromList(utf8.encode(csv)),
    );

    expect(decoded.accounts.single.type, 'card');
    expect(decoded.accounts.single.typeVersion, 0);
    expect(decoded.savingGoals.single.storageAccountIds, <String>['a1']);
  });

  test('fails when schema version is missing', () {
    const String csv = '#kopim-export\n#generated_at,2024-01-01T00:00:00Z';
    final Uint8List bytes = Uint8List.fromList(utf8.encode(csv));

    expect(() => decoder.decode(bytes), throwsFormatException);
  });

  test('fails on partial CSV backup for current schema', () {
    const String csv = '''
#kopim-export
#schema_version,1.4.0
#generated_at,2024-01-01T00:00:00Z
#accounts
id,name,balance,opening_balance,balance_minor,opening_balance_minor,currency_scale,currency,type,created_at,updated_at,color,gradient_id,icon_name,icon_style,is_deleted,is_primary,is_hidden
''';
    final Uint8List bytes = Uint8List.fromList(utf8.encode(csv));

    expect(
      () => decoder.decode(bytes),
      throwsA(
        isA<FormatException>().having(
          (FormatException error) => error.message,
          'message',
          contains('#categories'),
        ),
      ),
    );
  });
}
