import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kopim/core/services/analytics_service.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/features/profile/data/auth_repository_impl.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/entities/sign_in_request.dart';
import 'package:kopim/features/profile/domain/failures/auth_failure.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockLoggerService extends Mock implements LoggerService {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}

class FakeUserMetadata extends Fake implements UserMetadata {
  FakeUserMetadata({this.creationTime, this.lastSignInTime});

  @override
  final DateTime? creationTime;

  @override
  final DateTime? lastSignInTime;
}

void main() {
  late MockFirebaseAuth firebaseAuth;
  late MockGoogleSignIn googleSignIn;
  late MockLoggerService loggerService;
  late MockAnalyticsService analyticsService;
  late AuthRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue('');
    registerFallbackValue(StackTrace.empty);
    registerFallbackValue(FirebaseAuthException(code: 'fallback'));
  });

  setUp(() {
    firebaseAuth = MockFirebaseAuth();
    googleSignIn = MockGoogleSignIn();
    loggerService = MockLoggerService();
    analyticsService = MockAnalyticsService();

    repository = AuthRepositoryImpl(
      firebaseAuth: firebaseAuth,
      googleSignIn: googleSignIn,
      loggerService: loggerService,
      analyticsService: analyticsService,
    );
  });

  group('AuthRepositoryImpl', () {
    test('signIn with email returns mapped AuthUser', () async {
      final MockUserCredential credential = MockUserCredential();
      final MockUser user = MockUser();
      final FakeUserMetadata metadata = FakeUserMetadata(
        creationTime: DateTime.utc(2024, 1, 1),
        lastSignInTime: DateTime.utc(2024, 1, 2),
      );

      when(
        () => firebaseAuth.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => credential);
      when(() => credential.user).thenReturn(user);
      when(() => user.uid).thenReturn('uid-123');
      when(() => user.email).thenReturn('test@example.com');
      when(() => user.displayName).thenReturn('Tester');
      when(() => user.photoURL).thenReturn('https://example.com/photo.png');
      when(() => user.isAnonymous).thenReturn(false);
      when(() => user.emailVerified).thenReturn(true);
      when(() => user.metadata).thenReturn(metadata);

      final AuthUser result = await repository.signIn(
        const SignInRequest.email(
          email: 'test@example.com',
          password: 'secret123',
        ),
      );

      expect(result.uid, 'uid-123');
      expect(result.email, 'test@example.com');
      expect(result.displayName, 'Tester');
      expect(result.isAnonymous, isFalse);
    });

    test('signIn propagates FirebaseAuthException as AuthFailure', () async {
      when(
        () => firebaseAuth.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(
        FirebaseAuthException(
          code: 'wrong-password',
          message: 'Invalid credentials',
        ),
      );

      expect(
        () => repository.signIn(
          const SignInRequest.email(
            email: 'user@kopim.app',
            password: 'password',
          ),
        ),
        throwsA(
          isA<AuthFailure>().having(
            (AuthFailure f) => f.code,
            'code',
            'wrong-password',
          ),
        ),
      );
    });

    test(
      'signInAnonymously falls back to guest user on network error',
      () async {
        when(() => firebaseAuth.currentUser).thenReturn(null);
        when(() => firebaseAuth.signInAnonymously()).thenThrow(
          FirebaseAuthException(
            code: 'network-request-failed',
            message: 'No connectivity',
          ),
        );

        final AuthUser result = await repository.signInAnonymously();

        expect(result.isAnonymous, isTrue);
        expect(result.uid, startsWith('guest-'));
      },
    );
  });
}
