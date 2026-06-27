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

    test('should allow DEMO-CLOUD-KEY in dev/debug modes', () async {
      final CloudEntitlementRepositoryImpl repository =
          CloudEntitlementRepositoryImpl(
            preferences: Future<SharedPreferences>.value(sharedPreferences),
            firebaseAuth: mockFirebaseAuth,
          );

      final CloudEntitlementResult result = await repository.activateKey(
        'DEMO-CLOUD-KEY',
      );
      expect(result.success, isTrue);
      expect(result.state, equals(CloudEntitlementState.active));

      final CloudEntitlementState cached = await repository.getCachedState();
      expect(cached, equals(CloudEntitlementState.active));
    });

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
        AppRuntimeConfig.configure(AppRuntimeFlavor.offline);
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
      });

      test(
        'should return active if claims are valid and not expired',
        () async {
          final int futureExpiry =
              (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 3600;
          when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
          when(
            () => mockUser.getIdTokenResult(),
          ).thenAnswer((_) async => mockIdTokenResult);
          when(() => mockIdTokenResult.claims).thenReturn(<String, dynamic>{
            'cloudAccess': true,
            'cloudPlan': 'testerCloud',
            'cloudAccessExpiresAt': futureExpiry,
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
        },
      );

      test('should return expired if claims are valid but expired', () async {
        final int pastExpiry =
            (DateTime.now().millisecondsSinceEpoch ~/ 1000) - 3600;
        when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(
          () => mockUser.getIdTokenResult(),
        ).thenAnswer((_) async => mockIdTokenResult);
        when(() => mockIdTokenResult.claims).thenReturn(<String, dynamic>{
          'cloudAccess': true,
          'cloudPlan': 'paidCloud',
          'cloudAccessExpiresAt': pastExpiry,
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
      });

      test('should return notActivated if cloudAccess is false', () async {
        when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(
          () => mockUser.getIdTokenResult(),
        ).thenAnswer((_) async => mockIdTokenResult);
        when(() => mockIdTokenResult.claims).thenReturn(<String, dynamic>{
          'cloudAccess': false,
          'cloudPlan': 'testerCloud',
          'cloudAccessExpiresAt':
              (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 3600,
        });

        final CloudEntitlementRepositoryImpl repository =
            CloudEntitlementRepositoryImpl(
              preferences: Future<SharedPreferences>.value(sharedPreferences),
              firebaseAuth: mockFirebaseAuth,
            );

        final CloudEntitlementState state = await repository
            .refreshFromCurrentToken();
        expect(state, equals(CloudEntitlementState.notActivated));
      });
    });
  });
}
