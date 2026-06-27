import 'dart:async';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/config/app_runtime.dart';
import 'package:kopim/core/data/database.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/profile/data/cloud_activation_state_repository.dart';
import 'package:kopim/features/profile/data/cloud_entitlement_repository.dart';
import 'package:kopim/features/profile/domain/entities/cloud_activation_state.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/entities/sign_in_request.dart';
import 'package:kopim/features/profile/domain/entities/sign_up_request.dart';
import 'package:kopim/features/profile/domain/repositories/auth_repository.dart';
import 'package:kopim/features/profile/presentation/controllers/data_mode_controller.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod/misc.dart' show Override;

class _FakeCloudEntitlementRepository implements CloudEntitlementRepository {
  @override
  Future<CloudEntitlementResult> activateKey(String key) async {
    return const CloudEntitlementResult(
      success: true,
      state: CloudEntitlementState.active,
    );
  }

  @override
  Future<void> clearEntitlement() async {}

  @override
  Future<CloudEntitlementState> getCachedState() async {
    return CloudEntitlementState.active;
  }

  @override
  Future<CloudEntitlementState> refreshFromCurrentToken() async {
    return CloudEntitlementState.active;
  }
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository(this.initialUser);

  final AuthUser? initialUser;

  @override
  Stream<AuthUser?> authStateChanges() => const Stream<AuthUser?>.empty();

  @override
  AuthUser? get currentUser => initialUser;

  @override
  Future<void> deleteCurrentUser() async {}

  @override
  Future<AuthUser> reauthenticate(SignInRequest request) {
    throw UnimplementedError();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<AuthUser> signIn(SignInRequest request) {
    throw UnimplementedError();
  }

  @override
  Future<AuthUser> signInAnonymously() {
    throw UnimplementedError();
  }

  @override
  Future<AuthUser> signInOffline() {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<AuthUser> signUp(SignUpRequest request) {
    throw UnimplementedError();
  }

  @override
  Future<AuthUser> updateEmail({
    required String newEmail,
    required String currentPassword,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> forceRefreshIdToken() async {}
}

class _FakeCloudActivationStateRepository
    implements CloudActivationStateRepository {
  _FakeCloudActivationStateRepository({this.state});

  CloudActivationState? state;

  @override
  Future<void> clearStateForUid(String uid) async {
    if (state?.uid == uid) {
      state = null;
    }
  }

  @override
  Future<CloudActivationState?> getStateForUid(String uid) async {
    if (state?.uid == uid) {
      return state;
    }
    return null;
  }

  @override
  Future<void> saveEnabledState({
    required String uid,
    required String scenario,
    required String? localFingerprint,
    required String? remoteFingerprint,
  }) async {
    state = CloudActivationState(
      uid: uid,
      scenario: scenario,
      activatedAt: DateTime.utc(2024, 1, 1),
      localFingerprint: localFingerprint,
      remoteFingerprint: remoteFingerprint,
      version: 1,
    );
  }
}

void main() {
  test(
    'returns cloudBlockedByLocalData when cloud user exists and local-only data is present',
    () async {
      AppRuntimeConfig.configure(AppRuntimeFlavor.firebaseDev);
      final AppDatabase database = AppDatabase.connect(
        DatabaseConnection(NativeDatabase.memory()),
      );
      addTearDown(database.close);

      await database
          .into(database.accounts)
          .insert(
            AccountsCompanion.insert(
              id: 'local-account-1',
              name: 'Local account',
              balance: 0,
              currency: 'RUB',
              type: 'cash',
              createdAt: Value<DateTime>(DateTime.utc(2024, 1, 1)),
              updatedAt: Value<DateTime>(DateTime.utc(2024, 1, 2)),
            ),
          );

      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[
          appDatabaseProvider.overrideWithValue(database),
          cloudEntitlementRepositoryProvider.overrideWithValue(
            _FakeCloudEntitlementRepository(),
          ),
          cloudAuthRepositoryProvider.overrideWithValue(
            _FakeAuthRepository(
              const AuthUser(
                uid: 'cloud-user-1',
                email: 'user@example.com',
                isAnonymous: false,
              ),
            ),
          ),
          cloudActivationStateRepositoryProvider.overrideWithValue(
            _FakeCloudActivationStateRepository(
              state: CloudActivationState(
                uid: 'cloud-user-1',
                scenario: 'enableCloudSync',
                activatedAt: DateTime.utc(2024, 1, 1),
                localFingerprint: 'local:empty',
                remoteFingerprint: 'remote:empty|uid:cloud-user-1',
                version: 1,
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final DataModeState state = await container.read(
        dataModeControllerProvider.future,
      );

      expect(state.dataMode, equals(DataMode.cloudBlockedByLocalData));
      expect(state.entitlementState, equals(CloudEntitlementState.active));
    },
  );

  test(
    'keeps localOnly when cloud user exists but explicit activation flag is missing',
    () async {
      AppRuntimeConfig.configure(AppRuntimeFlavor.firebaseDev);
      final AppDatabase database = AppDatabase.connect(
        DatabaseConnection(NativeDatabase.memory()),
      );
      addTearDown(database.close);

      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[
          appDatabaseProvider.overrideWithValue(database),
          cloudEntitlementRepositoryProvider.overrideWithValue(
            _FakeCloudEntitlementRepository(),
          ),
          cloudAuthRepositoryProvider.overrideWithValue(
            _FakeAuthRepository(
              const AuthUser(
                uid: 'cloud-user-2',
                email: 'user@example.com',
                isAnonymous: false,
              ),
            ),
          ),
          cloudActivationStateRepositoryProvider.overrideWithValue(
            _FakeCloudActivationStateRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final DataModeState state = await container.read(
        dataModeControllerProvider.future,
      );

      expect(state.dataMode, equals(DataMode.localOnly));
      expect(state.entitlementState, equals(CloudEntitlementState.active));
    },
  );
}
