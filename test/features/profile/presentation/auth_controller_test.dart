import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/application/firebase_availability.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/services/auth_sync_service.dart';
import 'package:kopim/core/config/app_runtime.dart';
import 'package:kopim/core/services/sync/sync_ownership_guard.dart';
import 'package:kopim/features/profile/data/local_auth_repository.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/entities/sign_in_request.dart';
import 'package:kopim/features/profile/domain/entities/sign_up_request.dart';
import 'package:kopim/features/profile/domain/failures/auth_failure.dart';
import 'package:kopim/features/profile/domain/repositories/auth_repository.dart';
import 'package:kopim/features/profile/domain/repositories/user_account_cleanup_repository.dart';
import 'package:kopim/features/profile/presentation/controllers/auth_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/cloud_activation_decision_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/cloud_activation_intent_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/data_mode_controller.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/src/framework.dart';

class MockConnectivity extends Mock implements Connectivity {}

class MockAuthSyncService extends Mock implements AuthSyncService {}

class MockLocalAuthRepository extends Mock implements LocalAuthRepository {}

class _FakeDataModeController extends DataModeController {
  _FakeDataModeController(this._nextState);

  final DataModeState _nextState;

  @override
  FutureOr<DataModeState> build() async => _nextState;

  @override
  Future<DataModeState> refreshForCurrentContext() async {
    state = AsyncData<DataModeState>(_nextState);
    return _nextState;
  }
}

class FakeUserAccountCleanupRepository implements UserAccountCleanupRepository {
  Future<void> Function(String uid)? onDeleteRemoteUserData;
  Future<void> Function()? onDeleteLocalUserData;

  @override
  Future<void> deleteRemoteUserData(String uid) async {
    final Future<void> Function(String uid)? handler = onDeleteRemoteUserData;
    if (handler != null) {
      await handler(uid);
    }
  }

  @override
  Future<void> deleteLocalUserData(String uid) async {
    final Future<void> Function()? handler = onDeleteLocalUserData;
    if (handler != null) {
      await handler();
    }
  }
}

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

  Future<void> Function()? onDeleteCurrentUser;
  Future<AuthUser> Function(SignInRequest request)? onReauthenticate;

  @override
  Future<void> deleteCurrentUser() {
    final Future<void> Function()? handler = onDeleteCurrentUser;
    if (handler != null) {
      return handler();
    }
    return Future<void>.error(UnimplementedError());
  }

  @override
  Future<AuthUser> reauthenticate(SignInRequest request) {
    final Future<AuthUser> Function(SignInRequest request)? handler =
        onReauthenticate;
    if (handler != null) {
      return handler(request);
    }
    return Future<AuthUser>.error(UnimplementedError());
  }

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

  @override
  Future<AuthUser> signInOffline() async {
    final AuthUser user = AuthUser.guest(createdAt: DateTime.utc(2024, 1, 1));
    initialUser = user;
    _controller.add(user);
    return user;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      Future<void>.error(UnimplementedError());

  @override
  Future<AuthUser> updateEmail({
    required String newEmail,
    required String currentPassword,
  }) {
    final Future<AuthUser> Function({
      required String newEmail,
      required String currentPassword,
    })?
    handler = onUpdateEmail;
    if (handler != null) {
      return handler(newEmail: newEmail, currentPassword: currentPassword);
    }
    return Future<AuthUser>.error(UnimplementedError());
  }

  @override
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    final Future<void> Function({
      required String currentPassword,
      required String newPassword,
    })?
    handler = onUpdatePassword;
    if (handler != null) {
      return handler(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    }
    return Future<void>.error(UnimplementedError());
  }

  Future<AuthUser> Function({
    required String newEmail,
    required String currentPassword,
  })?
  onUpdateEmail;
  Future<void> Function({
    required String currentPassword,
    required String newPassword,
  })?
  onUpdatePassword;

  void dispose() {
    _controller.close();
  }
}

void main() {
  late FakeAuthRepository authRepository;
  late MockLocalAuthRepository localAuthRepository;
  late MockConnectivity connectivity;
  late MockAuthSyncService authSyncService;
  late FakeUserAccountCleanupRepository cleanupRepository;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(<ConnectivityResult>[]);
    registerFallbackValue(MigrationDecision.none);
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
    localAuthRepository = MockLocalAuthRepository();
    when(
      () => localAuthRepository.signInAnonymously(),
    ).thenAnswer((_) async => AuthUser.local(uid: 'local-test-uid'));
    when(
      () => localAuthRepository.restoreLocalSession(),
    ).thenAnswer((_) async => AuthUser.local(uid: 'local-test-uid'));
    when(
      () => localAuthRepository.signInOffline(),
    ).thenAnswer((_) async => AuthUser.local(uid: 'local-test-uid'));
    connectivity = MockConnectivity();
    authSyncService = MockAuthSyncService();
    cleanupRepository = FakeUserAccountCleanupRepository();

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
        migrationDecision: any(named: 'migrationDecision'),
      ),
    ).thenAnswer((_) async {});

    container = ProviderContainer(
      overrides: <Override>[
        authRepositoryProvider.overrideWithValue(authRepository),
        cloudAuthRepositoryProvider.overrideWithValue(authRepository),
        localAuthRepositoryProvider.overrideWithValue(localAuthRepository),
        activeAuthRepositoryProvider.overrideWithValue(authRepository),
        userAccountCleanupRepositoryProvider.overrideWithValue(
          cleanupRepository,
        ),
        connectivityProvider.overrideWithValue(connectivity),
        authSyncServiceProvider.overrideWithValue(authSyncService),
        dataModeControllerProvider.overrideWith(
          () => _FakeDataModeController(
            const DataModeState(
              dataMode: DataMode.cloudEnabled,
              entitlementState: CloudEntitlementState.active,
              migrationDecision: MigrationDecision.none,
            ),
          ),
        ),
      ],
    );
    container
        .read(firebaseAvailabilityProvider.notifier)
        .setUnavailable('test');
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
      final MockLocalAuthRepository mockLocalAuth = MockLocalAuthRepository();
      final MockConnectivity onlineConnectivity = MockConnectivity();

      when(
        () => onlineConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => <ConnectivityResult>[ConnectivityResult.wifi]);
      when(
        () => onlineConnectivity.onConnectivityChanged,
      ).thenAnswer((_) => const Stream<List<ConnectivityResult>>.empty());
      when(() => mockLocalAuth.signInOffline()).thenAnswer(
        (_) async => AuthUser.guest(createdAt: DateTime.utc(2024, 1, 1)),
      );

      final ProviderContainer localContainer = ProviderContainer(
        overrides: <Override>[
          authRepositoryProvider.overrideWithValue(localAuthRepository),
          cloudAuthRepositoryProvider.overrideWithValue(localAuthRepository),
          localAuthRepositoryProvider.overrideWithValue(mockLocalAuth),
          activeAuthRepositoryProvider.overrideWithValue(mockLocalAuth),
          userAccountCleanupRepositoryProvider.overrideWithValue(
            cleanupRepository,
          ),
          connectivityProvider.overrideWithValue(onlineConnectivity),
          authSyncServiceProvider.overrideWithValue(authSyncService),
        ],
      );
      localContainer
          .read(firebaseAvailabilityProvider.notifier)
          .setUnavailable('test');

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

  test(
    'does not restore local session on startup when cloud build is online and cloud user is absent',
    () async {
      final MockLocalAuthRepository mockLocalAuth = MockLocalAuthRepository();
      final MockConnectivity onlineConnectivity = MockConnectivity();

      when(
        () => onlineConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => <ConnectivityResult>[ConnectivityResult.wifi]);
      when(
        () => onlineConnectivity.onConnectivityChanged,
      ).thenAnswer((_) => const Stream<List<ConnectivityResult>>.empty());
      when(
        () => mockLocalAuth.signInAnonymously(),
      ).thenAnswer((_) async => AuthUser.local(uid: 'local-test-uid'));
      when(
        () => mockLocalAuth.restoreLocalSession(),
      ).thenAnswer((_) async => AuthUser.local(uid: 'local-test-uid'));

      final FakeAuthRepository cloudAuthRepository = FakeAuthRepository();
      final ProviderContainer localContainer = ProviderContainer(
        overrides: <Override>[
          authRepositoryProvider.overrideWithValue(mockLocalAuth),
          activeAuthRepositoryProvider.overrideWithValue(mockLocalAuth),
          cloudAuthRepositoryProvider.overrideWithValue(cloudAuthRepository),
          localAuthRepositoryProvider.overrideWithValue(mockLocalAuth),
          userAccountCleanupRepositoryProvider.overrideWithValue(
            cleanupRepository,
          ),
          connectivityProvider.overrideWithValue(onlineConnectivity),
          authSyncServiceProvider.overrideWithValue(authSyncService),
        ],
      );
      localContainer
          .read(firebaseAvailabilityProvider.notifier)
          .setUnavailable('test');

      addTearDown(() {
        cloudAuthRepository.dispose();
        localContainer.dispose();
      });

      final AuthUser? user = await localContainer.read(
        authControllerProvider.future,
      );

      expect(user, isNull);
      verifyNever(() => mockLocalAuth.restoreLocalSession());
      verifyNever(() => mockLocalAuth.signInAnonymously());
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

  test(
    'signIn keeps cloud session when login sync is blocked by local data',
    () async {
      const AuthUser cloudUser = AuthUser(
        uid: 'cloud-blocked-user',
        email: 'user@example.com',
        isAnonymous: false,
      );
      authRepository.onSignIn = (SignInRequest request) async => cloudUser;
      when(
        () => authSyncService.synchronizeOnLogin(
          user: any(named: 'user'),
          previousUser: any(named: 'previousUser'),
          migrationDecision: any(named: 'migrationDecision'),
        ),
      ).thenThrow(
        const SyncOwnershipException(
          'Синхронизация заблокирована: обнаружены локальные данные.',
        ),
      );
      container.read(firebaseAvailabilityProvider.notifier).setAvailable();

      final AuthController controller = container.read(
        authControllerProvider.notifier,
      );

      await container.read(authControllerProvider.future);
      await controller.signIn(
        const SignInRequest.email(
          email: 'user@example.com',
          password: 'pass123',
        ),
      );

      final AsyncValue<AuthUser?> state = container.read(
        authControllerProvider,
      );
      expect(state.hasError, isFalse);
      expect(state.value, equals(cloudUser));
    },
  );

  test(
    'pending product choice does not trigger login sync before explicit activation succeeds',
    () async {
      const AuthUser cloudUser = AuthUser(
        uid: 'cloud-user-1',
        email: 'user@example.com',
        isAnonymous: false,
      );
      authRepository.onSignIn = (SignInRequest request) async => cloudUser;
      final ProviderContainer gatedContainer = ProviderContainer(
        overrides: <Override>[
          authRepositoryProvider.overrideWithValue(authRepository),
          cloudAuthRepositoryProvider.overrideWithValue(authRepository),
          localAuthRepositoryProvider.overrideWithValue(localAuthRepository),
          activeAuthRepositoryProvider.overrideWithValue(authRepository),
          userAccountCleanupRepositoryProvider.overrideWithValue(
            cleanupRepository,
          ),
          connectivityProvider.overrideWithValue(connectivity),
          authSyncServiceProvider.overrideWithValue(authSyncService),
          dataModeControllerProvider.overrideWith(
            () => _FakeDataModeController(
              const DataModeState(
                dataMode: DataMode.localOnly,
                entitlementState: CloudEntitlementState.active,
                migrationDecision: MigrationDecision.none,
              ),
            ),
          ),
        ],
      );
      addTearDown(gatedContainer.dispose);
      gatedContainer.read(firebaseAvailabilityProvider.notifier).setAvailable();
      when(
        () => authSyncService.synchronizeOnLogin(
          user: any(named: 'user'),
          previousUser: any(named: 'previousUser'),
          migrationDecision: any(named: 'migrationDecision'),
        ),
      ).thenThrow(
        const SyncOwnershipException(
          'Синхронизация заблокирована: legacy handoff остаётся узким.',
        ),
      );
      gatedContainer
          .read(cloudActivationIntentProvider.notifier)
          .savePendingChoice(
            choice: CloudActivationChoice.enableCloudSync,
            decisionState: const CloudActivationDecisionState(
              status: CloudActivationDecisionStatus.choiceRequired,
              title: 'Как включить облачные функции',
              subtitle: 'subtitle',
              body: 'body',
              followupNote: 'note',
              localSnapshotState: CloudActivationSnapshotState.empty,
              remoteSnapshotState: CloudActivationSnapshotState.empty,
              localFingerprint: 'local:empty',
              remoteFingerprint: 'remote:empty|uid:cloud-user-1',
              scenario: CloudActivationScenario.localEmptyRemoteEmpty,
              options: <CloudActivationDecisionOption>[],
            ),
          );

      final AuthController controller = gatedContainer.read(
        authControllerProvider.notifier,
      );
      await gatedContainer.read(authControllerProvider.future);

      await controller.signIn(
        const SignInRequest.email(
          email: 'user@example.com',
          password: 'pass123',
        ),
      );

      verifyNever(
        () => authSyncService.synchronizeOnLogin(
          user: cloudUser,
          previousUser: any(named: 'previousUser'),
          migrationDecision: MigrationDecision.none,
        ),
      );
    },
  );

  test('deleteAccount clears auth state after successful deletion', () async {
    authRepository.initialUser = const AuthUser(
      uid: 'user-123',
      email: 'user@example.com',
      isAnonymous: false,
    );
    authRepository.onReauthenticate = (SignInRequest request) async {
      expect(
        request,
        const SignInRequest.email(
          email: 'user@example.com',
          password: 'secret123',
        ),
      );
      return authRepository.initialUser!;
    };
    final List<String> calls = <String>[];
    cleanupRepository.onDeleteRemoteUserData = (String uid) async {
      expect(uid, 'user-123');
      calls.add('remote');
    };
    cleanupRepository.onDeleteLocalUserData = () async {
      calls.add('local');
    };
    authRepository.onDeleteCurrentUser = () async {
      calls.add('auth');
      authRepository.initialUser = null;
      authRepository._controller.add(null);
    };

    final AuthController controller = container.read(
      authControllerProvider.notifier,
    );

    final AuthUser? user = await container.read(authControllerProvider.future);
    expect(user?.uid, 'user-123');

    await controller.deleteAccount(currentPassword: 'secret123');

    final AsyncValue<AuthUser?> state = container.read(authControllerProvider);
    expect(state.value, isNull);
    expect(calls, equals(<String>['remote', 'auth', 'local']));
  });

  test(
    'deleteAccount does not clear local data when auth deletion fails',
    () async {
      authRepository.initialUser = const AuthUser(
        uid: 'user-123',
        email: 'user@example.com',
        isAnonymous: false,
      );
      final List<String> calls = <String>[];
      authRepository.onReauthenticate = (SignInRequest request) async {
        return authRepository.initialUser!;
      };
      cleanupRepository.onDeleteRemoteUserData = (String uid) async {
        calls.add('remote');
      };
      cleanupRepository.onDeleteLocalUserData = () async {
        calls.add('local');
      };
      authRepository.onDeleteCurrentUser = () async {
        calls.add('auth');
        throw const AuthFailure(
          code: 'delete-failed',
          message: 'cannot delete user',
        );
      };

      final AuthController controller = container.read(
        authControllerProvider.notifier,
      );

      await container.read(authControllerProvider.future);

      await expectLater(
        controller.deleteAccount(currentPassword: 'secret123'),
        throwsA(isA<AuthFailure>()),
      );

      final AsyncValue<AuthUser?> state = container.read(
        authControllerProvider,
      );
      expect(state.value?.uid, 'user-123');
      expect(calls, equals(<String>['remote', 'auth']));
    },
  );
}
