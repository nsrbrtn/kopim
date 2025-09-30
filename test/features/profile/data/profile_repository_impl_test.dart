import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/features/profile/data/local/profile_dao.dart';
import 'package:kopim/features/profile/data/profile_repository_impl.dart';
import 'package:kopim/features/profile/data/remote/profile_remote_data_source.dart';
import 'package:kopim/features/profile/domain/entities/profile.dart';

void main() {
  late db.AppDatabase database;
  late OutboxDao outboxDao;
  late ProfileDao profileDao;
  late ProfileRemoteDataSource remoteDataSource;
  late FakeFirebaseFirestore firestore;
  late ProfileRepositoryImpl repository;

  setUp(() {
    database = db.AppDatabase.connect(
      DatabaseConnection(NativeDatabase.memory()),
    );
    outboxDao = OutboxDao(database);
    profileDao = ProfileDao(database);
    firestore = FakeFirebaseFirestore();
    remoteDataSource = ProfileRemoteDataSource(firestore);
    repository = ProfileRepositoryImpl(
      database: database,
      profileDao: profileDao,
      remoteDataSource: remoteDataSource,
      outboxDao: outboxDao,
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('updateProfile persists locally and enqueues outbox entry', () async {
    const String uid = 'user-1';
    final Profile profile = Profile(
      uid: uid,
      name: 'Alice',
      currency: ProfileCurrency.eur,
      locale: 'de',
      updatedAt: DateTime.now().toUtc(),
    );

    final Profile result = await repository.updateProfile(profile);

    final Profile? stored = await profileDao.getProfile(uid);
    expect(stored, isNotNull);
    expect(stored!.name, equals('Alice'));
    expect(stored.currency, equals(ProfileCurrency.eur));
    expect(stored.locale, equals('de'));

    final List<db.OutboxEntryRow> entries = await database
        .select(database.outboxEntries)
        .get();
    expect(entries, hasLength(1));
    final db.OutboxEntryRow entry = entries.first;
    expect(entry.entityType, equals('profile'));
    expect(entry.operation, equals(OutboxOperation.upsert.name));

    final Map<String, dynamic> payload = outboxDao.decodePayload(entry);
    expect(payload['name'], equals('Alice'));
    expect(payload['currency'], equals('eur'));

    expect(result.name, equals('Alice'));
  });

  test('getProfile fetches remote when cache miss and caches result', () async {
    const String uid = 'user-2';
    await firestore
        .collection('users')
        .doc(uid)
        .collection('profile')
        .doc('profile')
        .set(<String, dynamic>{
          'uid': uid,
          'name': 'Bob',
          'currency': 'RUB',
          'locale': 'en',
          'updatedAt': Timestamp.fromDate(DateTime.utc(2024, 1, 1)),
        });

    final Profile? profile = await repository.getProfile(uid);
    expect(profile, isNotNull);
    expect(profile!.name, equals('Bob'));

    final Profile? cached = await profileDao.getProfile(uid);
    expect(cached, isNotNull);
    expect(cached!.name, equals('Bob'));
  });

  test('watchProfile emits updates when cache changes', () async {
    const String uid = 'user-3';
    final Stream<Profile?> stream = repository.watchProfile(uid);
    final List<Profile?> profiles = <Profile?>[];
    final StreamSubscription<Profile?> sub = stream.listen(profiles.add);

    final Profile profile = Profile(
      uid: uid,
      name: 'Carol',
      currency: ProfileCurrency.gel,
      locale: 'ka',
      updatedAt: DateTime.now().toUtc(),
    );

    await repository.updateProfile(profile);

    await Future<void>.delayed(const Duration(milliseconds: 10));
    await sub.cancel();

    expect(profiles.last?.name, equals('Carol'));
  });
}
