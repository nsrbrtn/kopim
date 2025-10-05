import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/data/database.dart';
import 'package:kopim/features/savings/data/sources/local/saving_goal_dao.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';

SavingGoal _goal({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  int target = 1000,
  int current = 0,
  DateTime? archivedAt,
}) {
  return SavingGoal(
    id: id,
    userId: 'user-1',
    name: 'Goal $id',
    targetAmount: target,
    currentAmount: current,
    createdAt: createdAt,
    updatedAt: updatedAt,
    archivedAt: archivedAt,
  );
}

void main() {
  late AppDatabase database;
  late SavingGoalDao dao;
  final DateTime now = DateTime.utc(2024, 1, 1);

  setUp(() {
    database = AppDatabase.connect(DatabaseConnection(NativeDatabase.memory()));
    dao = SavingGoalDao(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('getGoals returns active goals ordered by updatedAt desc', () async {
    final SavingGoal older = _goal(
      id: 'goal-1',
      createdAt: now,
      updatedAt: now,
    );
    final SavingGoal newer = _goal(
      id: 'goal-2',
      createdAt: now,
      updatedAt: now.add(const Duration(days: 1)),
    );

    await dao.upsert(older);
    await dao.upsert(newer);

    final List<SavingGoal> results = await dao.getGoals(includeArchived: false);

    expect(results, hasLength(2));
    expect(results.first.id, 'goal-2');
    expect(results.last.id, 'goal-1');
  });

  test('archive marks goal and hides it from active list', () async {
    final DateTime createdAt = now;
    final SavingGoal goal = _goal(
      id: 'goal-archive',
      createdAt: createdAt,
      updatedAt: createdAt,
    );
    await dao.upsert(goal);

    final DateTime archivedAt = now.add(const Duration(hours: 4));
    await dao.archive(goal.id, archivedAt);

    final SavingGoal? stored = await dao.findById(goal.id);
    expect(stored, isNotNull);
    expect(stored!.isArchived, isTrue);
    expect(stored.archivedAt, isNotNull);
    expect(stored.archivedAt!.isAtSameMomentAs(archivedAt), isTrue);
    expect(stored.updatedAt.isAtSameMomentAs(archivedAt), isTrue);

    final List<SavingGoal> active = await dao.getGoals(includeArchived: false);
    expect(active, isEmpty);

    final List<SavingGoal> all = await dao.getGoals(includeArchived: true);
    expect(all, hasLength(1));
    expect(all.single.id, goal.id);
  });
}
