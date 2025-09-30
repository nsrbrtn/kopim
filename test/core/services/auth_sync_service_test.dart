import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/core/services/analytics_service.dart';
import 'package:kopim/core/services/auth_sync_service.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/features/accounts/data/sources/local/account_dao.dart';
import 'package:kopim/features/accounts/data/sources/remote/account_remote_data_source.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/data/sources/local/category_dao.dart';
import 'package:kopim/features/categories/data/sources/remote/category_remote_data_source.dart';
import 'package:kopim/features/profile/data/local/profile_dao.dart';
import 'package:kopim/features/profile/data/remote/profile_remote_data_source.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/entities/profile.dart';
import 'package:kopim/features/profile/domain/failures/auth_failure.dart';
import 'package:kopim/features/transactions/data/sources/local/transaction_dao.dart';
import 'package:kopim/features/transactions/data/sources/remote/transaction_remote_data_source.dart';
import 'package:mocktail/mocktail.dart';

class MockLoggerService extends Mock implements LoggerService {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

class ThrowingAccountRemoteDataSource extends AccountRemoteDataSource {
  ThrowingAccountRemoteDataSource(super.firestore);

  @override
  void upsertInTransaction(
    Transaction transaction,
    String userId,
    AccountEntity account,
  ) {
    throw FirebaseException(plugin: 'cloud_firestore', message: 'boom');
  }
}

void main() {
  late db.AppDatabase database;
  late OutboxDao outboxDao;
  late AccountDao accountDao;
  late CategoryDao categoryDao;
  late TransactionDao transactionDao;
  late ProfileDao profileDao;
  late FirebaseFirestore firestore;
  late MockLoggerService logger;
  late MockAnalyticsService analytics;

  AuthSyncService buildService({
    AccountRemoteDataSource? accountRemoteDataSource,
  }) {
    return AuthSyncService(
      database: database,
      outboxDao: outboxDao,
      accountDao: accountDao,
      categoryDao: categoryDao,
      transactionDao: transactionDao,
      profileDao: profileDao,
      accountRemoteDataSource:
          accountRemoteDataSource ?? AccountRemoteDataSource(firestore),
      categoryRemoteDataSource: CategoryRemoteDataSource(firestore),
      transactionRemoteDataSource: TransactionRemoteDataSource(firestore),
      profileRemoteDataSource: ProfileRemoteDataSource(firestore),
      firestore: firestore,
      loggerService: logger,
      analyticsService: analytics,
    );
  }

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(StackTrace.empty);
  });

  setUp(() {
    database = db.AppDatabase.connect(
      DatabaseConnection(NativeDatabase.memory()),
    );
    outboxDao = OutboxDao(database);
    accountDao = AccountDao(database);
    categoryDao = CategoryDao(database);
    transactionDao = TransactionDao(database);
    profileDao = ProfileDao(database);
    firestore = FakeFirebaseFirestore();
    logger = MockLoggerService();
    analytics = MockAnalyticsService();

    when(() => analytics.logEvent(any(), any())).thenAnswer((_) async {});
    when(() => analytics.reportError(any(), any())).thenReturn(null);
  });

  tearDown(() async {
    await database.close();
  });

  group('AuthSyncService', () {
    test(
      'replays outbox entries, merges remote data and profile on login',
      () async {
        final AuthSyncService service = buildService();
        const String userId = 'user-1';
        final AccountEntity account = AccountEntity(
          id: 'acc-1',
          name: 'Main',
          balance: 1500,
          currency: 'RUB',
          type: 'checking',
          createdAt: DateTime.utc(2024, 1, 1),
          updatedAt: DateTime.utc(2024, 1, 2),
          isDeleted: false,
        );

        await firestore
            .collection('users')
            .doc(userId)
            .collection('accounts')
            .doc(account.id)
            .set(<String, dynamic>{
              'id': account.id,
              'name': 'Legacy',
              'balance': 300,
              'currency': 'RUB',
              'type': 'checking',
              'createdAt': Timestamp.fromDate(DateTime.utc(2023, 1, 1)),
              'updatedAt': Timestamp.fromDate(DateTime.utc(2023, 1, 1)),
              'isDeleted': false,
            });

        await firestore
            .collection('users')
            .doc(userId)
            .collection('profile')
            .doc('profile')
            .set(<String, dynamic>{
              'uid': userId,
              'name': 'Old Name',
              'currency': 'RUB',
              'locale': 'en',
              'updatedAt': Timestamp.fromDate(DateTime.utc(2023, 1, 1)),
            });

        await outboxDao.enqueue(
          entityType: 'account',
          entityId: account.id,
          operation: OutboxOperation.upsert,
          payload: account.toJson()
            ..['updatedAt'] = account.updatedAt.toIso8601String()
            ..['createdAt'] = account.createdAt.toIso8601String(),
        );

        const Map<String, String> profilePayload = <String, String>{
          'uid': userId,
          'name': 'Alice',
          'currency': 'eur',
          'locale': 'de',
          'updatedAt': '2024-02-01T00:00:00.000Z',
        };

        await outboxDao.enqueue(
          entityType: 'profile',
          entityId: userId,
          operation: OutboxOperation.upsert,
          payload: profilePayload,
        );

        final AuthUser authUser = AuthUser(
          uid: userId,
          email: 'user@kopim.app',
          displayName: 'User',
          photoUrl: null,
          isAnonymous: false,
          emailVerified: true,
          creationTime: DateTime.utc(2024, 1, 1),
          lastSignInTime: DateTime.utc(2024, 1, 2),
        );

        await service.synchronizeOnLogin(user: authUser, previousUser: null);

        final DocumentSnapshot<Map<String, dynamic>> remoteDoc = await firestore
            .collection('users')
            .doc(userId)
            .collection('accounts')
            .doc(account.id)
            .get();

        expect(remoteDoc.exists, isTrue);
        expect(remoteDoc.data()?['balance'], equals(1500));

        final List<AccountEntity> localAccounts = await accountDao
            .getAllAccounts();
        expect(localAccounts, hasLength(1));
        expect(localAccounts.single.balance, equals(1500));

        final DocumentSnapshot<Map<String, dynamic>> profileDoc =
            await firestore
                .collection('users')
                .doc(userId)
                .collection('profile')
                .doc('profile')
                .get();
        expect(profileDoc.exists, isTrue);
        expect(profileDoc.data()?['name'], equals('Alice'));
        expect(profileDoc.data()?['currency'], equals('EUR'));
        expect(profileDoc.data()?['locale'], equals('de'));

        final Profile? localProfile = await profileDao.getProfile(userId);
        expect(localProfile, isNotNull);
        expect(localProfile!.name, equals('Alice'));
        expect(localProfile.currency, equals(ProfileCurrency.eur));
        expect(localProfile.locale, equals('de'));

        expect(await outboxDao.pendingCount(), equals(0));

        verify(() => analytics.logEvent('auth_sync_start', any())).called(1);
        verify(() => analytics.logEvent('auth_sync_success', any())).called(1);
      },
    );

    test('resets outbox entries when transaction fails', () async {
      final ThrowingAccountRemoteDataSource throwingDataSource =
          ThrowingAccountRemoteDataSource(firestore);
      final AuthSyncService service = buildService(
        accountRemoteDataSource: throwingDataSource,
      );
      const String userId = 'user-2';

      final AccountEntity account = AccountEntity(
        id: 'acc-2',
        name: 'Savings',
        balance: 200,
        currency: 'RUB',
        type: 'savings',
        createdAt: DateTime.utc(2024, 1, 1),
        updatedAt: DateTime.utc(2024, 1, 5),
        isDeleted: false,
      );

      await outboxDao.enqueue(
        entityType: 'account',
        entityId: account.id,
        operation: OutboxOperation.upsert,
        payload: account.toJson()
          ..['updatedAt'] = account.updatedAt.toIso8601String()
          ..['createdAt'] = account.createdAt.toIso8601String(),
      );

      final AuthUser authUser = AuthUser(
        uid: userId,
        isAnonymous: false,
        emailVerified: true,
        creationTime: DateTime.utc(2024, 1, 1),
        lastSignInTime: DateTime.utc(2024, 1, 2),
      );

      expect(
        () => service.synchronizeOnLogin(user: authUser, previousUser: null),
        throwsA(isA<AuthFailure>()),
      );

      final List<db.OutboxEntryRow> entries = await database
          .select(database.outboxEntries)
          .get();
      expect(entries, hasLength(1));
      expect(entries.single.status, equals(OutboxStatus.pending.name));
    });
  });
}
