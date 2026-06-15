import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/data/database.dart';
import 'package:kopim/core/services/sync/sync_contract.dart';
import 'package:kopim/core/services/sync/sync_metadata_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kopim/features/profile/data/user_account_cleanup_repository_impl.dart';
import 'package:kopim/features/profile/domain/repositories/profile_avatar_repository.dart';
import 'dart:typed_data';

class _FakeProfileAvatarRepository implements ProfileAvatarRepository {
  String? deletedUid;

  @override
  Future<void> delete(String uid) async {
    deletedUid = uid;
  }

  @override
  Future<String> upload({
    required String uid,
    required Uint8List data,
    required String contentType,
  }) {
    throw UnimplementedError();
  }
}

void main() {
  late AppDatabase database;
  late FakeFirebaseFirestore firestore;
  late _FakeProfileAvatarRepository avatarRepository;
  late UserAccountCleanupRepositoryImpl repository;

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    database = AppDatabase.connect(DatabaseConnection(NativeDatabase.memory()));
    firestore = FakeFirebaseFirestore();
    avatarRepository = _FakeProfileAvatarRepository();
    repository = UserAccountCleanupRepositoryImpl(
      firestore: firestore,
      database: database,
      profileAvatarRepository: avatarRepository,
      syncMetadataRepository: SyncMetadataRepository(),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'deleteRemoteUserData removes every manifest cleanup collection and root doc',
    () async {
      const String uid = 'user-1';
      await firestore.collection('users').doc(uid).set(<String, dynamic>{
        'uid': uid,
        'name': 'User',
      });
      for (final String collection in SyncContract.remoteCleanupCollections) {
        await firestore
            .collection('users')
            .doc(uid)
            .collection(collection)
            .doc('$collection-doc')
            .set(<String, dynamic>{'id': '$collection-doc'});
      }

      await repository.deleteRemoteUserData(uid);

      for (final String collection in SyncContract.remoteCleanupCollections) {
        final int count =
            (await firestore
                    .collection('users')
                    .doc(uid)
                    .collection(collection)
                    .get())
                .docs
                .length;
        expect(count, 0, reason: 'Коллекция $collection должна удаляться.');
      }
      final bool userExists =
          (await firestore.collection('users').doc(uid).get()).exists;

      expect(userExists, isFalse);
      expect(avatarRepository.deletedUid, uid);
    },
  );

  test('deleteLocalUserData clears local user tables and outbox', () async {
    await database
        .into(database.accounts)
        .insert(
          AccountsCompanion.insert(
            id: 'acc-1',
            name: 'Main',
            balance: 0,
            currency: 'RUB',
            type: 'cash',
          ),
        );
    await database
        .into(database.profiles)
        .insert(ProfilesCompanion.insert(uid: 'user-1'));
    await database
        .into(database.outboxEntries)
        .insert(
          OutboxEntriesCompanion.insert(
            entityType: 'account',
            entityId: 'acc-1',
            operation: 'upsert',
            payload: '{}',
          ),
        );

    await repository.deleteLocalUserData('user-1');

    expect((await database.select(database.accounts).get()), isEmpty);
    expect((await database.select(database.profiles).get()), isEmpty);
    expect((await database.select(database.outboxEntries).get()), isEmpty);
  });
}
