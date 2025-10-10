import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/data/database.dart';
import 'package:kopim/features/upcoming_payments/data/drift/daos/upcoming_payments_dao.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';

void main() {
  late AppDatabase database;
  late UpcomingPaymentsDao dao;
  const String defaultAccountId = 'account-1';
  const String defaultCategoryId = 'category-1';

  setUp(() async {
    database = AppDatabase.connect(
      drift.DatabaseConnection(NativeDatabase.memory()),
    );
    dao = UpcomingPaymentsDao(database);
    await database
        .into(database.accounts)
        .insert(
          AccountsCompanion(
            id: const drift.Value<String>(defaultAccountId),
            name: const drift.Value<String>('Main'),
            balance: const drift.Value<double>(0),
            currency: const drift.Value<String>('USD'),
            type: const drift.Value<String>('checking'),
            createdAt: drift.Value<DateTime>(DateTime.now()),
            updatedAt: drift.Value<DateTime>(DateTime.now()),
            isDeleted: const drift.Value<bool>(false),
            isPrimary: const drift.Value<bool>(false),
          ),
        );
    await database
        .into(database.categories)
        .insert(
          CategoriesCompanion(
            id: const drift.Value<String>(defaultCategoryId),
            name: const drift.Value<String>('Utilities'),
            type: const drift.Value<String>('expense'),
            createdAt: drift.Value<DateTime>(DateTime.now()),
            updatedAt: drift.Value<DateTime>(DateTime.now()),
            isDeleted: const drift.Value<bool>(false),
            isSystem: const drift.Value<bool>(false),
            isFavorite: const drift.Value<bool>(false),
          ),
        );
  });

  tearDown(() async {
    await database.close();
  });

  UpcomingPayment buildPayment({
    required String id,
    String accountId = defaultAccountId,
    String categoryId = defaultCategoryId,
    double amount = 100,
    int dayOfMonth = 10,
    int notifyDaysBefore = 1,
    String notifyTime = '09:30',
    bool autoPost = false,
    bool isActive = true,
    int? nextRunAtMs,
    int? nextNotifyAtMs,
    int createdAtMs = 1700000000000,
    int updatedAtMs = 1700000000000,
    String? note,
  }) {
    return UpcomingPayment(
      id: id,
      title: 'Payment $id',
      accountId: accountId,
      categoryId: categoryId,
      amount: amount,
      dayOfMonth: dayOfMonth,
      notifyDaysBefore: notifyDaysBefore,
      notifyTimeHhmm: notifyTime,
      note: note,
      autoPost: autoPost,
      isActive: isActive,
      nextRunAtMs: nextRunAtMs,
      nextNotifyAtMs: nextNotifyAtMs,
      createdAtMs: createdAtMs,
      updatedAtMs: updatedAtMs,
    );
  }

  test(
    'watchAll возвращает только активные платежи в корректном порядке',
    () async {
      final UpcomingPayment first = buildPayment(
        id: 'p1',
        nextNotifyAtMs: 2000,
        nextRunAtMs: 4000,
      );
      final UpcomingPayment second = buildPayment(
        id: 'p2',
        nextNotifyAtMs: 1000,
        nextRunAtMs: 5000,
      );
      final UpcomingPayment third = buildPayment(
        id: 'p3',
        nextNotifyAtMs: null,
        nextRunAtMs: 3000,
      );
      final UpcomingPayment inactive = buildPayment(
        id: 'p4',
        isActive: false,
        nextNotifyAtMs: 500,
      );

      await dao.upsert(first);
      await dao.upsert(second);
      await dao.upsert(third);
      await dao.upsert(inactive);

      final List<UpcomingPayment> items = await dao.watchAll().first;

      expect(items.map((UpcomingPayment e) => e.id).toList(), <String>[
        'p2',
        'p1',
        'p3',
      ]);
    },
  );

  test('upsert обновляет существующий платёж', () async {
    final UpcomingPayment original = buildPayment(id: 'p1', amount: 120);
    await dao.upsert(original);

    final UpcomingPayment updated = original.copyWith(
      amount: 250,
      note: 'Updated',
      updatedAtMs: original.updatedAtMs + 1000,
    );
    await dao.upsert(updated);

    final UpcomingPayment? loaded = await dao.getById('p1');
    expect(loaded, isNotNull);
    expect(loaded!.amount, 250);
    expect(loaded.note, 'Updated');
  });

  test('delete удаляет платёж', () async {
    final UpcomingPayment payment = buildPayment(id: 'p1');
    await dao.upsert(payment);

    await dao.delete('p1');

    final UpcomingPayment? loaded = await dao.getById('p1');
    expect(loaded, isNull);
  });

  test('валидатор отклоняет некорректные данные', () async {
    final UpcomingPayment invalidAmount = buildPayment(
      id: 'invalid-amount',
      amount: 0,
    );
    expect(() => dao.upsert(invalidAmount), throwsArgumentError);

    final UpcomingPayment invalidDay = buildPayment(
      id: 'invalid-day',
      dayOfMonth: 0,
    );
    expect(() => dao.upsert(invalidDay), throwsArgumentError);

    final UpcomingPayment invalidNotifyDays = buildPayment(
      id: 'invalid-notify',
      notifyDaysBefore: -1,
    );
    expect(() => dao.upsert(invalidNotifyDays), throwsArgumentError);

    final UpcomingPayment invalidTime = buildPayment(
      id: 'invalid-time',
      notifyTime: '24:15',
    );
    expect(() => dao.upsert(invalidTime), throwsArgumentError);
  });

  test('каскадное удаление аккаунта удаляет платежи', () async {
    const String cascadeAccount = 'account-cascade';
    await database
        .into(database.accounts)
        .insert(
          AccountsCompanion(
            id: const drift.Value<String>(cascadeAccount),
            name: const drift.Value<String>('Secondary'),
            balance: const drift.Value<double>(0),
            currency: const drift.Value<String>('USD'),
            type: const drift.Value<String>('checking'),
            createdAt: drift.Value<DateTime>(DateTime.now()),
            updatedAt: drift.Value<DateTime>(DateTime.now()),
            isDeleted: const drift.Value<bool>(false),
            isPrimary: const drift.Value<bool>(false),
          ),
        );
    final UpcomingPayment payment = buildPayment(
      id: 'cascade',
      accountId: cascadeAccount,
    );
    await dao.upsert(payment);

    await (database.delete(
      database.accounts,
    )..where((Accounts tbl) => tbl.id.equals(cascadeAccount))).go();

    final UpcomingPayment? loaded = await dao.getById('cascade');
    expect(loaded, isNull);
  });
}
