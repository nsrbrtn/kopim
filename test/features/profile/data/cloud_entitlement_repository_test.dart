import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kopim/core/config/app_runtime.dart';
import 'package:kopim/features/profile/data/cloud_entitlement_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockIdTokenResult extends Mock implements IdTokenResult {}

void main() {
  group('CloudEntitlementRepository Tests', () {
    late SharedPreferences sharedPreferences;
    late MockFirebaseAuth mockFirebaseAuth;
    late MockUser mockUser;
    late MockIdTokenResult mockIdTokenResult;

    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      sharedPreferences = await SharedPreferences.getInstance();
      mockFirebaseAuth = MockFirebaseAuth();
      mockUser = MockUser();
      mockIdTokenResult = MockIdTokenResult();
      AppRuntimeConfig.configure(AppRuntimeFlavor.firebaseDev);
    });

    // DEMO-CLOUD-KEY was removed: all keys are now validated server-side.
    test(
      'should reject unknown keys (including former DEMO-CLOUD-KEY)',
      () async {
        final CloudEntitlementRepositoryImpl repository =
            CloudEntitlementRepositoryImpl(
              preferences: Future<SharedPreferences>.value(sharedPreferences),
              firebaseAuth: mockFirebaseAuth,
            );

        final CloudEntitlementResult result = await repository.activateKey(
          'DEMO-CLOUD-KEY',
        );
        expect(result.success, isFalse);
        expect(result.state, equals(CloudEntitlementState.invalid));
      },
    );

    test('should reject invalid keys', () async {
      final CloudEntitlementRepositoryImpl repository =
          CloudEntitlementRepositoryImpl(
            preferences: Future<SharedPreferences>.value(sharedPreferences),
            firebaseAuth: mockFirebaseAuth,
          );

      final CloudEntitlementResult result = await repository.activateKey(
        'INVALID-KEY',
      );
      expect(result.success, isFalse);
      expect(result.state, equals(CloudEntitlementState.invalid));
    });

    test(
      'should reject DEMO-CLOUD-KEY if in offlineOnly distribution mode',
      () async {
        AppRuntimeConfig.configure(AppRuntimeFlavor.offlineOnly);
        final CloudEntitlementRepositoryImpl repository =
            CloudEntitlementRepositoryImpl(
              preferences: Future<SharedPreferences>.value(sharedPreferences),
              firebaseAuth: mockFirebaseAuth,
            );

        final CloudEntitlementState cached = await repository.getCachedState();
        expect(cached, equals(CloudEntitlementState.unavailable));
      },
    );

    group('refreshFromCurrentToken', () {
      test('should return notActivated if user is null', () async {
        when(() => mockFirebaseAuth.currentUser).thenReturn(null);

        final CloudEntitlementRepositoryImpl repository =
            CloudEntitlementRepositoryImpl(
              preferences: Future<SharedPreferences>.value(sharedPreferences),
              firebaseAuth: mockFirebaseAuth,
            );

        final CloudEntitlementState state = await repository
            .refreshFromCurrentToken();
        expect(state, equals(CloudEntitlementState.notActivated));
        expect(
          await repository.getCachedState(),
          equals(CloudEntitlementState.notActivated),
        );
        final CloudEntitlementSnapshot snapshot = await repository
            .getCachedSnapshot();
        expect(snapshot.source, equals('signed-out'));
      });

      test(
        'should return active if claims are valid and not expired',
        () async {
          final int futureExpiry =
              DateTime.now().millisecondsSinceEpoch + 3600 * 1000;
          when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
          when(
            () => mockUser.getIdTokenResult(),
          ).thenAnswer((_) async => mockIdTokenResult);
          when(() => mockIdTokenResult.claims).thenReturn(<String, dynamic>{
            'cloudAccess': true,
            'cloudPlan': 'trial',
            'cloudAccessUntilMillis': futureExpiry,
          });

          final CloudEntitlementRepositoryImpl repository =
              CloudEntitlementRepositoryImpl(
                preferences: Future<SharedPreferences>.value(sharedPreferences),
                firebaseAuth: mockFirebaseAuth,
              );

          final CloudEntitlementState state = await repository
              .refreshFromCurrentToken();
          expect(state, equals(CloudEntitlementState.active));
          expect(
            await repository.getCachedState(),
            equals(CloudEntitlementState.active),
          );
          final CloudEntitlementSnapshot snapshot = await repository
              .getCachedSnapshot();
          expect(snapshot.plan, equals('trial'));
          expect(snapshot.accessUntilMillis, equals(futureExpiry));
          expect(snapshot.source, equals('claims:trial'));
          expect(snapshot.updatedAtMillis, isNotNull);
        },
      );

      test('should return expired if claims are valid but expired', () async {
        final int pastExpiry =
            DateTime.now().millisecondsSinceEpoch - 3600 * 1000;
        when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(
          () => mockUser.getIdTokenResult(),
        ).thenAnswer((_) async => mockIdTokenResult);
        when(() => mockIdTokenResult.claims).thenReturn(<String, dynamic>{
          'cloudAccess': true,
          'cloudPlan': 'paid',
          'cloudAccessUntilMillis': pastExpiry,
        });

        final CloudEntitlementRepositoryImpl repository =
            CloudEntitlementRepositoryImpl(
              preferences: Future<SharedPreferences>.value(sharedPreferences),
              firebaseAuth: mockFirebaseAuth,
            );

        final CloudEntitlementState state = await repository
            .refreshFromCurrentToken();
        expect(state, equals(CloudEntitlementState.expired));
        expect(
          await repository.getCachedState(),
          equals(CloudEntitlementState.expired),
        );
        final CloudEntitlementSnapshot snapshot = await repository
            .getCachedSnapshot();
        expect(snapshot.plan, equals('paid'));
        expect(snapshot.accessUntilMillis, equals(pastExpiry));
        expect(snapshot.source, equals('claims:paid'));
      });

      test('should return notActivated if cloudAccess is false', () async {
        when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(
          () => mockUser.getIdTokenResult(),
        ).thenAnswer((_) async => mockIdTokenResult);
        when(() => mockIdTokenResult.claims).thenReturn(<String, dynamic>{
          'cloudAccess': false,
          'cloudPlan': 'trial',
          'cloudAccessUntilMillis':
              DateTime.now().millisecondsSinceEpoch + 3600 * 1000,
        });

        final CloudEntitlementRepositoryImpl repository =
            CloudEntitlementRepositoryImpl(
              preferences: Future<SharedPreferences>.value(sharedPreferences),
              firebaseAuth: mockFirebaseAuth,
            );

        final CloudEntitlementState state = await repository
            .refreshFromCurrentToken();
        expect(state, equals(CloudEntitlementState.notActivated));
        final CloudEntitlementSnapshot snapshot = await repository
            .getCachedSnapshot();
        expect(snapshot.source, equals('claims-invalid'));
      });

      test(
        'should return active for manual plan with integer millis claim',
        () async {
          final int futureExpiry =
              DateTime.now().millisecondsSinceEpoch + 3600 * 1000;
          when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
          when(
            () => mockUser.getIdTokenResult(),
          ).thenAnswer((_) async => mockIdTokenResult);
          when(() => mockIdTokenResult.claims).thenReturn(<String, dynamic>{
            'cloudAccess': true,
            'cloudPlan': 'manual',
            'cloudAccessUntilMillis': futureExpiry,
          });

          final CloudEntitlementState state =
              await CloudEntitlementRepositoryImpl(
                preferences: Future<SharedPreferences>.value(sharedPreferences),
                firebaseAuth: mockFirebaseAuth,
              ).refreshFromCurrentToken();

          expect(state, equals(CloudEntitlementState.active));
        },
      );

      test('should return notActivated for unsupported cloud plan', () async {
        when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(
          () => mockUser.getIdTokenResult(),
        ).thenAnswer((_) async => mockIdTokenResult);
        when(() => mockIdTokenResult.claims).thenReturn(<String, dynamic>{
          'cloudAccess': true,
          'cloudPlan': 'testerCloud',
          'cloudAccessUntilMillis':
              DateTime.now().millisecondsSinceEpoch + 3600 * 1000,
        });

        final CloudEntitlementState state =
            await CloudEntitlementRepositoryImpl(
              preferences: Future<SharedPreferences>.value(sharedPreferences),
              firebaseAuth: mockFirebaseAuth,
            ).refreshFromCurrentToken();

        expect(state, equals(CloudEntitlementState.notActivated));
      });

      test('should return notActivated when expiry claim is missing', () async {
        when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(
          () => mockUser.getIdTokenResult(),
        ).thenAnswer((_) async => mockIdTokenResult);
        when(() => mockIdTokenResult.claims).thenReturn(<String, dynamic>{
          'cloudAccess': true,
          'cloudPlan': 'paid',
        });

        final CloudEntitlementState state =
            await CloudEntitlementRepositoryImpl(
              preferences: Future<SharedPreferences>.value(sharedPreferences),
              firebaseAuth: mockFirebaseAuth,
            ).refreshFromCurrentToken();

        expect(state, equals(CloudEntitlementState.notActivated));
      });

      test(
        'getCachedSnapshot returns notActivated snapshot when storage is empty',
        () async {
          final CloudEntitlementRepositoryImpl repository =
              CloudEntitlementRepositoryImpl(
                preferences: Future<SharedPreferences>.value(sharedPreferences),
                firebaseAuth: mockFirebaseAuth,
              );

          final CloudEntitlementSnapshot snapshot = await repository
              .getCachedSnapshot();

          expect(snapshot.state, equals(CloudEntitlementState.notActivated));
          expect(snapshot.plan, isNull);
          expect(snapshot.accessUntilMillis, isNull);
          expect(snapshot.source, isNull);
          expect(snapshot.updatedAtMillis, isNull);
        },
      );

      test('clearEntitlement clears cached snapshot metadata', () async {
        final int futureExpiry =
            DateTime.now().millisecondsSinceEpoch + 3600 * 1000;
        when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(
          () => mockUser.getIdTokenResult(),
        ).thenAnswer((_) async => mockIdTokenResult);
        when(() => mockIdTokenResult.claims).thenReturn(<String, dynamic>{
          'cloudAccess': true,
          'cloudPlan': 'manual',
          'cloudAccessUntilMillis': futureExpiry,
        });

        final CloudEntitlementRepositoryImpl repository =
            CloudEntitlementRepositoryImpl(
              preferences: Future<SharedPreferences>.value(sharedPreferences),
              firebaseAuth: mockFirebaseAuth,
            );

        await repository.refreshFromCurrentToken();
        await repository.clearEntitlement();

        final CloudEntitlementSnapshot snapshot = await repository
            .getCachedSnapshot();
        expect(snapshot.state, equals(CloudEntitlementState.notActivated));
        expect(snapshot.plan, isNull);
        expect(snapshot.accessUntilMillis, isNull);
        expect(snapshot.source, isNull);
        expect(snapshot.updatedAtMillis, isNull);
      });
    });
  });
}
