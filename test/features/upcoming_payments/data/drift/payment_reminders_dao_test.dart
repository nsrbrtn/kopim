import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/data/database.dart';
import 'package:kopim/features/upcoming_payments/data/drift/daos/payment_reminders_dao.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/payment_reminder.dart';

void main() {
  late AppDatabase database;
  late PaymentRemindersDao dao;

  setUp(() async {
    database = AppDatabase.connect(
      drift.DatabaseConnection(NativeDatabase.memory()),
    );
    dao = PaymentRemindersDao(database);
  });

  tearDown(() async {
    await database.close();
  });

  PaymentReminder buildReminder({
    required String id,
    double amount = 50,
    int whenAtMs = 1700000000000,
    String? note,
    bool isDone = false,
    int? lastNotifiedAtMs,
    int createdAtMs = 1700000000000,
    int updatedAtMs = 1700000000000,
  }) {
    return PaymentReminder(
      id: id,
      title: 'Reminder $id',
      amount: amount,
      whenAtMs: whenAtMs,
      note: note,
      isDone: isDone,
      lastNotifiedAtMs: lastNotifiedAtMs,
      createdAtMs: createdAtMs,
      updatedAtMs: updatedAtMs,
    );
  }

  test('watchAll сортирует по времени', () async {
    final PaymentReminder first = buildReminder(id: 'r1', whenAtMs: 1000);
    final PaymentReminder second = buildReminder(id: 'r2', whenAtMs: 500);
    final PaymentReminder third = buildReminder(id: 'r3', whenAtMs: 2000);

    await dao.upsert(first);
    await dao.upsert(second);
    await dao.upsert(third);

    final List<PaymentReminder> items = await dao.watchAll().first;
    expect(items.map((PaymentReminder e) => e.id).toList(), <String>[
      'r2',
      'r1',
      'r3',
    ]);
  });

  test('watchUpcoming фильтрует выполненные и учитывает limit', () async {
    final PaymentReminder activeSoon = buildReminder(id: 'r1', whenAtMs: 1000);
    final PaymentReminder activeLater = buildReminder(id: 'r2', whenAtMs: 2000);
    final PaymentReminder done = buildReminder(
      id: 'r3',
      whenAtMs: 500,
      isDone: true,
    );

    await dao.upsert(activeSoon);
    await dao.upsert(activeLater);
    await dao.upsert(done);

    final List<PaymentReminder> limited = await dao
        .watchUpcoming(limit: 1)
        .first;
    expect(limited, hasLength(1));
    expect(limited.first.id, 'r1');

    final List<PaymentReminder> all = await dao.watchUpcoming().first;
    expect(all.map((PaymentReminder e) => e.id).toList(), <String>['r1', 'r2']);
  });

  test('upsert обновляет напоминание', () async {
    final PaymentReminder reminder = buildReminder(id: 'r1', note: 'call');
    await dao.upsert(reminder);

    final PaymentReminder updated = reminder.copyWith(
      note: 'call again',
      updatedAtMs: reminder.updatedAtMs + 100,
    );
    await dao.upsert(updated);

    final PaymentReminder? loaded = await dao.getById('r1');
    expect(loaded, isNotNull);
    expect(loaded!.note, 'call again');
  });

  test('delete удаляет напоминание', () async {
    final PaymentReminder reminder = buildReminder(id: 'r1');
    await dao.upsert(reminder);

    await dao.delete('r1');
    final PaymentReminder? loaded = await dao.getById('r1');
    expect(loaded, isNull);
  });

  test('валидатор отклоняет некорректные значения', () async {
    final PaymentReminder invalidAmount = buildReminder(
      id: 'bad-amount',
      amount: 0,
    );
    expect(() => dao.upsert(invalidAmount), throwsArgumentError);

    final PaymentReminder invalidTime = buildReminder(
      id: 'bad-time',
      whenAtMs: 0,
    );
    expect(() => dao.upsert(invalidTime), throwsArgumentError);
  });
}
