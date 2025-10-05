import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/core/services/sync_service.dart';
import 'package:kopim/features/accounts/data/sources/remote/account_remote_data_source.dart';
import 'package:kopim/features/budgets/data/sources/remote/budget_instance_remote_data_source.dart';
import 'package:kopim/features/budgets/data/sources/remote/budget_remote_data_source.dart';
import 'package:kopim/features/categories/data/sources/remote/category_remote_data_source.dart';
import 'package:kopim/features/profile/data/local/profile_dao.dart';
import 'package:kopim/features/profile/data/profile_repository_impl.dart';
import 'package:kopim/features/profile/data/remote/profile_remote_data_source.dart';
import 'package:kopim/features/profile/domain/entities/profile.dart';
import 'package:kopim/features/savings/data/sources/remote/saving_goal_remote_data_source.dart';
import 'package:kopim/features/transactions/data/sources/remote/transaction_remote_data_source.dart';
import 'package:mocktail/mocktail.dart';

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _MockUser extends Mock implements User {}

class _MockConnectivity extends Mock implements Connectivity {}

void main() {
  setUpAll(() {
    registerFallbackValue(<ConnectivityResult>[]);
  });

  test('syncPending pushes queued profile update to Firestore', () async {
    final db.AppDatabase database = db.AppDatabase.connect(
      DatabaseConnection(NativeDatabase.memory()),
    );
    final OutboxDao outboxDao = OutboxDao(database);
    final ProfileDao profileDao = ProfileDao(database);
    final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
    final ProfileRemoteDataSource profileRemote = ProfileRemoteDataSource(
      firestore,
    );
    final ProfileRepositoryImpl repository = ProfileRepositoryImpl(
      database: database,
      profileDao: profileDao,
      remoteDataSource: profileRemote,
      outboxDao: outboxDao,
    );

    const String uid = 'user-sync';
    final Profile profile = Profile(
      uid: uid,
      name: 'Alice',
      currency: ProfileCurrency.eur,
      locale: 'de',
      updatedAt: DateTime.utc(2024, 1, 1),
    );

    await repository.updateProfile(profile);

    final _MockFirebaseAuth firebaseAuth = _MockFirebaseAuth();
    final _MockUser firebaseUser = _MockUser();
    when(() => firebaseUser.uid).thenReturn(uid);
    when(() => firebaseAuth.currentUser).thenReturn(firebaseUser);

    final _MockConnectivity connectivity = _MockConnectivity();
    final StreamController<List<ConnectivityResult>> connectivityController =
        StreamController<List<ConnectivityResult>>.broadcast();

    when(
      () => connectivity.checkConnectivity(),
    ).thenAnswer((_) async => <ConnectivityResult>[ConnectivityResult.wifi]);
    when(
      () => connectivity.onConnectivityChanged,
    ).thenAnswer((_) => connectivityController.stream);

    final SyncService service = SyncService(
      outboxDao: outboxDao,
      accountRemoteDataSource: AccountRemoteDataSource(firestore),
      categoryRemoteDataSource: CategoryRemoteDataSource(firestore),
      transactionRemoteDataSource: TransactionRemoteDataSource(firestore),
      budgetRemoteDataSource: BudgetRemoteDataSource(firestore),
      budgetInstanceRemoteDataSource: BudgetInstanceRemoteDataSource(firestore),
      savingGoalRemoteDataSource: SavingGoalRemoteDataSource(firestore),
      profileRemoteDataSource: profileRemote,
      firebaseAuth: firebaseAuth,
      connectivity: connectivity,
    );

    await service.initialize();
    await service.syncPending();

    final DocumentSnapshot<Map<String, dynamic>> profileDoc = await firestore
        .collection('users')
        .doc(uid)
        .collection('profile')
        .doc('profile')
        .get();

    expect(profileDoc.exists, isTrue);
    expect(profileDoc.data()?['name'], equals('Alice'));
    expect(profileDoc.data()?['currency'], equals('EUR'));
    expect(profileDoc.data()?['locale'], equals('de'));

    final Profile? cached = await profileDao.getProfile(uid);
    expect(cached, isNotNull);
    expect(cached!.name, equals('Alice'));

    expect(await outboxDao.pendingCount(), isZero);

    await service.dispose();
    await connectivityController.close();
    await database.close();
  });
}
