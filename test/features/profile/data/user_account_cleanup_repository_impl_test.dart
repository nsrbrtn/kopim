import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/data/database.dart';
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
    database = AppDatabase.connect(DatabaseConnection(NativeDatabase.memory()));
    firestore = FakeFirebaseFirestore();
    avatarRepository = _FakeProfileAvatarRepository();
    repository = UserAccountCleanupRepositoryImpl(
      firestore: firestore,
      database: database,
      profileAvatarRepository: avatarRepository,
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('deleteRemoteUserData removes recurring_payments collection', () async {
    const String uid = 'user-1';
    await firestore
        .collection('users')
        .doc(uid)
        .collection('recurring_payments')
        .doc('pay-1')
        .set(<String, dynamic>{'id': 'pay-1'});
    await firestore
        .collection('users')
        .doc(uid)
        .collection('reminders')
        .doc('rem-1')
        .set(<String, dynamic>{'id': 'rem-1'});

    await repository.deleteRemoteUserData(uid);

    final int recurringCount = (await firestore
            .collection('users')
            .doc(uid)
            .collection('recurring_payments')
            .get())
        .docs
        .length;
    final int remindersCount = (await firestore
            .collection('users')
            .doc(uid)
            .collection('reminders')
            .get())
        .docs
        .length;
    final bool userExists = (await firestore.collection('users').doc(uid).get())
        .exists;

    expect(recurringCount, 0);
    expect(remindersCount, 0);
    expect(userExists, isFalse);
    expect(avatarRepository.deletedUid, uid);
  });
}
