import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/services/auth_sync_service.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/entities/sign_in_request.dart';
import 'package:kopim/features/profile/domain/entities/sign_up_request.dart';
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
  final StreamController<AuthUser?> _controller =
      StreamController<AuthUser?>.broadcast();

  @override
  Stream<AuthUser?> authStateChanges() => _controller.stream;

  @override
  AuthUser? get currentUser => initialUser;

  @override
  Future<AuthUser> signIn(SignInRequest request) =>
      Future<AuthUser>.error(UnimplementedError());

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
}
