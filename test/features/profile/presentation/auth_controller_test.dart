import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/services/auth_sync_service.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/entities/sign_in_request.dart';
import 'package:kopim/features/profile/domain/entities/sign_up_request.dart';
import 'package:kopim/features/profile/domain/failures/auth_failure.dart';
import 'package:kopim/features/profile/domain/repositories/auth_repository.dart';
import 'package:kopim/features/profile/presentation/controllers/auth_controller.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/src/framework.dart';

class MockConnectivity extends Mock implements Connectivity {}

class MockAuthSyncService extends Mock implements AuthSyncService {}

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.initialUser});

  AuthUser? initialUser;
  bool signInAnonymouslyCalled = false;
  Future<AuthUser> Function(SignInRequest request)? onSignIn;
  Future<AuthUser> Function()? onAnonymousSignIn;
  final StreamController<AuthUser?> _controller =
      StreamController<AuthUser?>.broadcast();

  @override
  Stream<AuthUser?> authStateChanges() => _controller.stream;

  @override
  AuthUser? get currentUser => initialUser;

  @override
  Future<AuthUser> signIn(SignInRequest request) {
    final Future<AuthUser> Function(SignInRequest request)? handler = onSignIn;
    if (handler != null) {
      return handler(request);
    }
    return Future<AuthUser>.error(UnimplementedError());
  }

  @override
  Future<AuthUser> signUp(SignUpRequest request) =>
      Future<AuthUser>.error(UnimplementedError());

  @override
  Future<void> signOut() => Future<void>.error(UnimplementedError());

  @override
  Future<AuthUser> reauthenticate(SignInRequest request) =>
      Future<AuthUser>.error(UnimplementedError());

  @override
  Future<AuthUser> signInAnonymously() async {
    final Future<AuthUser> Function()? handler = onAnonymousSignIn;
    if (handler != null) {
      return handler();
    }
    signInAnonymouslyCalled = true;
    final AuthUser user = AuthUser.guest(createdAt: DateTime.utc(2024, 1, 1));
    initialUser = user;
    _controller.add(user);
    return user;
  }

  void dispose() {
    _controller.close();
  }
}

void main() {
  late FakeAuthRepository authRepository;
  late MockConnectivity connectivity;
  late MockAuthSyncService authSyncService;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(<ConnectivityResult>[]);
    registerFallbackValue(
      AuthUser(
        uid: 'fallback',
        isAnonymous: false,
        emailVerified: false,
        creationTime: DateTime.utc(2024, 1, 1),
        lastSignInTime: DateTime.utc(2024, 1, 1),
      ),
    );
  });

  setUp(() {
    authRepository = FakeAuthRepository();
    connectivity = MockConnectivity();
    authSyncService = MockAuthSyncService();

    when(
      () => connectivity.checkConnectivity(),
    ).thenAnswer((_) async => <ConnectivityResult>[ConnectivityResult.none]);
    when(
      () => connectivity.onConnectivityChanged,
    ).thenAnswer((_) => const Stream<List<ConnectivityResult>>.empty());
    when(
      () => authSyncService.synchronizeOnLogin(
        user: any(named: 'user'),
        previousUser: any(named: 'previousUser'),
      ),
    ).thenAnswer((_) async {});

    container = ProviderContainer(
      overrides: <Override>[
        authRepositoryProvider.overrideWithValue(authRepository),
        connectivityProvider.overrideWithValue(connectivity),
        authSyncServiceProvider.overrideWithValue(authSyncService),
      ],
    );
  });

  tearDown(() {
    authRepository.dispose();
    container.dispose();
  });

  test(
    'initializes anonymous session when offline and no session exists',
    () async {
      final AuthUser? user = await container.read(
        authControllerProvider.future,
      );

      expect(user, isNotNull);
      expect(user!.isAnonymous, isTrue);
      expect(authRepository.signInAnonymouslyCalled, isTrue);
    },
  );

  test(
    'continueWithOfflineMode creates local guest session without Firebase',
    () async {
      final FakeAuthRepository localAuthRepository = FakeAuthRepository();
      final MockConnectivity onlineConnectivity = MockConnectivity();

      when(
        () => onlineConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => <ConnectivityResult>[ConnectivityResult.wifi]);
      when(
        () => onlineConnectivity.onConnectivityChanged,
      ).thenAnswer((_) => const Stream<List<ConnectivityResult>>.empty());

      final ProviderContainer localContainer = ProviderContainer(
        overrides: <Override>[
          authRepositoryProvider.overrideWithValue(localAuthRepository),
          connectivityProvider.overrideWithValue(onlineConnectivity),
          authSyncServiceProvider.overrideWithValue(authSyncService),
        ],
      );

      addTearDown(() {
        localAuthRepository.dispose();
        localContainer.dispose();
      });

      final AuthController controller = localContainer.read(
        authControllerProvider.notifier,
      );

      final AuthUser? initialUser = await localContainer.read(
        authControllerProvider.future,
      );
      expect(initialUser, isNull);
      expect(localAuthRepository.signInAnonymouslyCalled, isFalse);

      await controller.continueWithOfflineMode();

      final AuthUser? offlineUser = localContainer
          .read(authControllerProvider)
          .value;
      expect(localAuthRepository.signInAnonymouslyCalled, isFalse);
      expect(offlineUser, isNotNull);
      expect(offlineUser!.isGuest, isTrue);
    },
  );

  test('signIn failure keeps previous state and rethrows', () async {
    authRepository.onSignIn = (SignInRequest request) => Future<AuthUser>.error(
      const AuthFailure(code: 'invalid-credentials', message: 'invalid'),
    );

    final AuthController controller = container.read(
      authControllerProvider.notifier,
    );

    final AuthUser? user = await container.read(authControllerProvider.future);
    expect(user, isNotNull);
    expect(user!.isAnonymous, isTrue);

    await expectLater(
      controller.signIn(
        const SignInRequest.email(
          email: 'user@example.com',
          password: 'pass123',
        ),
      ),
      throwsA(isA<AuthFailure>()),
    );

    final AsyncValue<AuthUser?> state = container.read(authControllerProvider);
    expect(state.hasError, isFalse);
    expect(state.value, equals(user));
  });
}
