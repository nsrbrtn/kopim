import 'dart:async';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/config/app_runtime.dart';
import 'package:kopim/core/data/database.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/profile/data/cloud_activation_state_repository.dart';
import 'package:kopim/features/profile/data/cloud_entitlement_repository.dart';
import 'package:kopim/features/profile/data/cloud_metadata_repository.dart';
import 'package:kopim/features/profile/data/fresh_upload_finalization_repository.dart';
import 'package:kopim/features/profile/domain/entities/cloud_activation_state.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/entities/cloud_metadata.dart';
import 'package:kopim/features/profile/domain/entities/fresh_upload_finalization_marker.dart';
import 'package:kopim/features/profile/domain/entities/sign_in_request.dart';
import 'package:kopim/features/profile/domain/entities/sign_up_request.dart';
import 'package:kopim/features/profile/domain/repositories/auth_repository.dart';
import 'package:kopim/features/profile/presentation/controllers/data_mode_controller.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod/misc.dart' show Override;
import 'package:shared_preferences/shared_preferences.dart';

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
  Future<CloudEntitlementSnapshot> getCachedSnapshot() async {
    return const CloudEntitlementSnapshot(state: CloudEntitlementState.active);
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
  @override
  Future<void> saveInProgressScenario({
    required String uid,
    required String scenario,
  }) async {
    state = CloudActivationState(
      uid: uid,
      scenario: scenario,
      activatedAt: DateTime.utc(2024, 1, 1),
      localFingerprint: null,
      remoteFingerprint: null,
      version: 1,
      activationCompleted: false,
    );
  }

  @override
  Future<void> saveEnabledState({
    bool activationCompleted = true,
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
      activationCompleted: activationCompleted,
    );
  }
}

class _FakeCloudMetadataRepository implements CloudMetadataRepository {
  _FakeCloudMetadataRepository({this.metadata, this.error});

  final CloudMetadata? metadata;
  final Object? error;

  @override
  Future<CloudMetadata?> getMetadata(String uid) async {
    if (error != null) {
      throw error!;
    }
    return metadata;
  }

  @override
  Future<void> updateMetadata(String uid, CloudMetadata metadata) async {}

  @override
  Future<void> setCloudDataState(String uid, CloudDataState state) async {}

  @override
  Future<CloudMetadata> startFreshUpload({
    required String uid,
    required String uploadSessionId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<CloudMetadata> completeFreshUpload({
    required String uid,
    required String uploadSessionId,
  }) {
    throw UnimplementedError();
  }
}

class _FakeFreshUploadFinalizationRepository
    implements FreshUploadFinalizationRepository {
  _FakeFreshUploadFinalizationRepository({this.marker});

  FreshUploadFinalizationMarker? marker;

  @override
  Future<void> clearMarkerForUid(String uid) async {
    if (marker?.uid == uid) {
      marker = null;
    }
  }

  @override
  Future<FreshUploadFinalizationMarker?> getMarkerForUid(String uid) async {
    if (marker?.uid == uid) {
      return marker;
    }
    return null;
  }

  @override
  Future<void> saveCompleted({
    required String uid,
    required String uploadSessionId,
    required DateTime remoteStateConfirmedAt,
    required DateTime localFinalizationCompletedAt,
  }) async {
    marker = FreshUploadFinalizationMarker(
      uid: uid,
      uploadSessionId: uploadSessionId,
      remoteStateConfirmedAt: remoteStateConfirmedAt,
      localFinalizationCompletedAt: localFinalizationCompletedAt,
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
                activationCompleted: true,
              ),
            ),
          ),
          cloudMetadataRepositoryProvider.overrideWithValue(
            _FakeCloudMetadataRepository(
              metadata: CloudMetadata(
                cloudDataState: CloudDataState.active,
                updatedAt: DateTime.now().toUtc(),
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
    'returns cloudBlockedByLocalData when cloud user exists but ownership belongs to another uid',
    () async {
      AppRuntimeConfig.configure(AppRuntimeFlavor.firebaseDev);
      final AppDatabase database = AppDatabase.connect(
        DatabaseConnection(NativeDatabase.memory()),
      );
      addTearDown(database.close);

      await database
          .into(database.localRowOwnership)
          .insert(
            LocalRowOwnershipCompanion.insert(
              entityType: 'account',
              entityId: 'cloud-account-1',
              ownershipState: 'cloudOwned',
              source: 'syncPull',
              ownerUid: const Value<String?>('cloud-user-old'),
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
                uid: 'cloud-user-new',
                email: 'user@example.com',
                isAnonymous: false,
              ),
            ),
          ),
          cloudActivationStateRepositoryProvider.overrideWithValue(
            _FakeCloudActivationStateRepository(
              state: CloudActivationState(
                uid: 'cloud-user-new',
                scenario: 'enableCloudSync',
                activatedAt: DateTime.utc(2024, 1, 1),
                localFingerprint: 'local:cloudOwned-old-user',
                remoteFingerprint: 'remote:empty|uid:cloud-user-new',
                version: 1,
                activationCompleted: true,
              ),
            ),
          ),
          cloudMetadataRepositoryProvider.overrideWithValue(
            _FakeCloudMetadataRepository(
              metadata: CloudMetadata(
                cloudDataState: CloudDataState.active,
                updatedAt: DateTime.now().toUtc(),
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
    'expired to renewed with local writes keeps cloudBlockedByLocalData until controlled resume',
    () async {
      AppRuntimeConfig.configure(AppRuntimeFlavor.firebaseDev);
      final AppDatabase database = AppDatabase.connect(
        DatabaseConnection(NativeDatabase.memory()),
      );
      addTearDown(database.close);

      await database.updateCurrentSyncState('cloud-user-renewed', false);
      await database
          .into(database.accounts)
          .insert(
            AccountsCompanion.insert(
              id: 'local-during-expired',
              name: 'Local while expired',
              balance: 0,
              currency: 'RUB',
              type: 'cash',
              createdAt: Value<DateTime>(DateTime.utc(2024, 1, 1)),
              updatedAt: Value<DateTime>(DateTime.utc(2024, 1, 2)),
            ),
          );

      final LocalRowOwnershipRow? ownership = await database.getOwnership(
        'account',
        'local-during-expired',
      );
      expect(ownership != null, isTrue);
      expect(ownership!.ownershipState, equals('localOnly'));
      expect(ownership.ownerUid, equals(null));

      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[
          appDatabaseProvider.overrideWithValue(database),
          cloudEntitlementRepositoryProvider.overrideWithValue(
            _FakeCloudEntitlementRepository(),
          ),
          cloudAuthRepositoryProvider.overrideWithValue(
            _FakeAuthRepository(
              const AuthUser(
                uid: 'cloud-user-renewed',
                email: 'user@example.com',
                isAnonymous: false,
              ),
            ),
          ),
          cloudActivationStateRepositoryProvider.overrideWithValue(
            _FakeCloudActivationStateRepository(
              state: CloudActivationState(
                uid: 'cloud-user-renewed',
                scenario: 'enableCloudSync',
                activatedAt: DateTime.utc(2024, 1, 1),
                localFingerprint: 'local:changed-during-expired',
                remoteFingerprint: 'remote:active|uid:cloud-user-renewed',
                version: 1,
                activationCompleted: true,
              ),
            ),
          ),
          cloudMetadataRepositoryProvider.overrideWithValue(
            _FakeCloudMetadataRepository(
              metadata: CloudMetadata(
                cloudDataState: CloudDataState.active,
                updatedAt: DateTime.now().toUtc(),
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
    'expired to renewed without local writes can return to cloudEnabled',
    () async {
      AppRuntimeConfig.configure(AppRuntimeFlavor.firebaseDev);
      final AppDatabase database = AppDatabase.connect(
        DatabaseConnection(NativeDatabase.memory()),
      );
      addTearDown(database.close);

      await database.updateCurrentSyncState('cloud-user-renewed-clean', false);

      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[
          appDatabaseProvider.overrideWithValue(database),
          cloudEntitlementRepositoryProvider.overrideWithValue(
            _FakeCloudEntitlementRepository(),
          ),
          cloudAuthRepositoryProvider.overrideWithValue(
            _FakeAuthRepository(
              const AuthUser(
                uid: 'cloud-user-renewed-clean',
                email: 'user@example.com',
                isAnonymous: false,
              ),
            ),
          ),
          cloudActivationStateRepositoryProvider.overrideWithValue(
            _FakeCloudActivationStateRepository(
              state: CloudActivationState(
                uid: 'cloud-user-renewed-clean',
                scenario: 'enableCloudSync',
                activatedAt: DateTime.utc(2024, 1, 1),
                localFingerprint: 'local:unchanged-while-expired',
                remoteFingerprint: 'remote:active|uid:cloud-user-renewed-clean',
                version: 1,
                activationCompleted: true,
              ),
            ),
          ),
          cloudMetadataRepositoryProvider.overrideWithValue(
            _FakeCloudMetadataRepository(
              metadata: CloudMetadata(
                cloudDataState: CloudDataState.active,
                updatedAt: DateTime.now().toUtc(),
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final DataModeState state = await container.read(
        dataModeControllerProvider.future,
      );

      expect(state.dataMode, equals(DataMode.cloudEnabled));
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
          cloudMetadataRepositoryProvider.overrideWithValue(
            _FakeCloudMetadataRepository(
              metadata: CloudMetadata(
                cloudDataState: CloudDataState.active,
                updatedAt: DateTime.now().toUtc(),
              ),
            ),
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

  test(
    'returns localOnly and requiresFreshCloudUpload when cloud data state is deleted',
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
                uid: 'cloud-user-3',
                email: 'user@example.com',
                isAnonymous: false,
              ),
            ),
          ),
          cloudActivationStateRepositoryProvider.overrideWithValue(
            _FakeCloudActivationStateRepository(
              state: CloudActivationState(
                uid: 'cloud-user-3',
                scenario: 'enableCloudSync',
                activatedAt: DateTime.utc(2024, 1, 1),
                localFingerprint: 'local:empty',
                remoteFingerprint: 'remote:empty|uid:cloud-user-3',
                version: 1,
                activationCompleted: true,
              ),
            ),
          ),
          cloudMetadataRepositoryProvider.overrideWithValue(
            _FakeCloudMetadataRepository(
              metadata: CloudMetadata(
                cloudDataState: CloudDataState.deleted,
                updatedAt: DateTime.now().toUtc(),
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final DataModeState state = await container.read(
        dataModeControllerProvider.future,
      );

      expect(state.dataMode, equals(DataMode.localOnly));
      expect(state.isSyncBlockedByCloudState, isTrue);
      expect(state.requiresFreshCloudUpload, isTrue);
    },
  );

  test(
    'returns localOnly and blocks sync when cloud data state is freshUploadInProgress',
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
                uid: 'cloud-user-4',
                email: 'user@example.com',
                isAnonymous: false,
              ),
            ),
          ),
          cloudActivationStateRepositoryProvider.overrideWithValue(
            _FakeCloudActivationStateRepository(
              state: CloudActivationState(
                uid: 'cloud-user-4',
                scenario: 'enableCloudSync',
                activatedAt: DateTime.utc(2024, 1, 1),
                localFingerprint: 'local:empty',
                remoteFingerprint: 'remote:empty|uid:cloud-user-4',
                version: 1,
                activationCompleted: true,
              ),
            ),
          ),
          cloudMetadataRepositoryProvider.overrideWithValue(
            _FakeCloudMetadataRepository(
              metadata: CloudMetadata(
                cloudDataState: CloudDataState.freshUploadInProgress,
                updatedAt: DateTime.now().toUtc(),
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final DataModeState state = await container.read(
        dataModeControllerProvider.future,
      );

      expect(state.dataMode, equals(DataMode.localOnly));
      expect(state.isSyncBlockedByCloudState, isTrue);
      expect(state.requiresFreshCloudUpload, isFalse);
    },
  );

  test(
    'fails closed when cached cloud metadata exists but remote read fails',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'profile.cloud_data_state.cloud-user-5': CloudDataState.grace.name,
      });
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
                uid: 'cloud-user-5',
                email: 'user@example.com',
                isAnonymous: false,
              ),
            ),
          ),
          cloudActivationStateRepositoryProvider.overrideWithValue(
            _FakeCloudActivationStateRepository(
              state: CloudActivationState(
                uid: 'cloud-user-5',
                scenario: 'enableCloudSync',
                activatedAt: DateTime.utc(2024, 1, 1),
                localFingerprint: 'local:empty',
                remoteFingerprint: 'remote:empty|uid:cloud-user-5',
                version: 1,
                activationCompleted: true,
              ),
            ),
          ),
          cloudMetadataRepositoryProvider.overrideWithValue(
            _FakeCloudMetadataRepository(error: StateError('offline')),
          ),
        ],
      );
      addTearDown(container.dispose);

      final DataModeState state = await container.read(
        dataModeControllerProvider.future,
      );

      expect(state.cloudDataState, CloudDataState.cleanupPending);
      expect(state.isSyncBlockedByCloudState, isTrue);
      expect(state.dataMode, DataMode.localOnly);
    },
  );

  test(
    'active Fresh Upload metadata without local finalization marker keeps localOnly',
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
                uid: 'cloud-user-fresh',
                email: 'user@example.com',
                isAnonymous: false,
              ),
            ),
          ),
          cloudActivationStateRepositoryProvider.overrideWithValue(
            _FakeCloudActivationStateRepository(
              state: CloudActivationState(
                uid: 'cloud-user-fresh',
                scenario: 'freshUploadFromLocal',
                activatedAt: DateTime.utc(2024, 1, 1),
                localFingerprint: 'local',
                remoteFingerprint: 'remote',
                version: 1,
                activationCompleted: true,
              ),
            ),
          ),
          cloudMetadataRepositoryProvider.overrideWithValue(
            _FakeCloudMetadataRepository(
              metadata: CloudMetadata(
                cloudDataState: CloudDataState.active,
                freshUploadSessionId: 'fresh-session-1',
                updatedAt: DateTime.now().toUtc(),
              ),
            ),
          ),
          freshUploadFinalizationRepositoryProvider.overrideWithValue(
            _FakeFreshUploadFinalizationRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final DataModeState state = await container.read(
        dataModeControllerProvider.future,
      );

      expect(state.dataMode, DataMode.localOnly);
      expect(state.requiresFreshUploadFinalization, isTrue);
      expect(state.isSyncBlockedByCloudState, isTrue);
    },
  );

  test(
    'active Fresh Upload metadata with completed finalization marker enables cloud mode',
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
                uid: 'cloud-user-fresh-done',
                email: 'user@example.com',
                isAnonymous: false,
              ),
            ),
          ),
          cloudActivationStateRepositoryProvider.overrideWithValue(
            _FakeCloudActivationStateRepository(
              state: CloudActivationState(
                uid: 'cloud-user-fresh-done',
                scenario: 'freshUploadFromLocal',
                activatedAt: DateTime.utc(2024, 1, 1),
                localFingerprint: 'local',
                remoteFingerprint: 'remote',
                version: 1,
                activationCompleted: true,
              ),
            ),
          ),
          cloudMetadataRepositoryProvider.overrideWithValue(
            _FakeCloudMetadataRepository(
              metadata: CloudMetadata(
                cloudDataState: CloudDataState.active,
                freshUploadSessionId: 'fresh-session-2',
                updatedAt: DateTime.now().toUtc(),
              ),
            ),
          ),
          freshUploadFinalizationRepositoryProvider.overrideWithValue(
            _FakeFreshUploadFinalizationRepository(
              marker: FreshUploadFinalizationMarker(
                uid: 'cloud-user-fresh-done',
                uploadSessionId: 'fresh-session-2',
                remoteStateConfirmedAt: DateTime.utc(2024, 1, 1),
                localFinalizationCompletedAt: DateTime.utc(2024, 1, 1, 0, 1),
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

      expect(state.dataMode, DataMode.cloudEnabled);
      expect(state.requiresFreshUploadFinalization, isFalse);
    },
  );

  test(
    'fails closed when cloud metadata read fails and cache is missing',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
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
                uid: 'cloud-user-6',
                email: 'user@example.com',
                isAnonymous: false,
              ),
            ),
          ),
          cloudActivationStateRepositoryProvider.overrideWithValue(
            _FakeCloudActivationStateRepository(
              state: CloudActivationState(
                uid: 'cloud-user-6',
                scenario: 'enableCloudSync',
                activatedAt: DateTime.utc(2024, 1, 1),
                localFingerprint: 'local:empty',
                remoteFingerprint: 'remote:empty|uid:cloud-user-6',
                version: 1,
                activationCompleted: true,
              ),
            ),
          ),
          cloudMetadataRepositoryProvider.overrideWithValue(
            _FakeCloudMetadataRepository(error: StateError('offline')),
          ),
        ],
      );
      addTearDown(container.dispose);

      final DataModeState state = await container.read(
        dataModeControllerProvider.future,
      );

      expect(state.cloudDataState, CloudDataState.cleanupPending);
      expect(state.isSyncBlockedByCloudState, isTrue);
      expect(state.dataMode, DataMode.localOnly);
    },
  );

  test(
    'forces localOnly and disables capabilities when flavor is offlineOnly',
    () async {
      AppRuntimeConfig.configure(AppRuntimeFlavor.offlineOnly);
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
                uid: 'cloud-user-7',
                email: 'user@example.com',
                isAnonymous: false,
              ),
            ),
          ),
          cloudActivationStateRepositoryProvider.overrideWithValue(
            _FakeCloudActivationStateRepository(
              state: CloudActivationState(
                uid: 'cloud-user-7',
                scenario: 'enableCloudSync',
                activatedAt: DateTime.utc(2024, 1, 1),
                localFingerprint: 'local:empty',
                remoteFingerprint: 'remote:empty|uid:cloud-user-7',
                version: 1,
                activationCompleted: true,
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final DataModeState state = await container.read(
        dataModeControllerProvider.future,
      );

      expect(state.dataMode, equals(DataMode.localOnly));
      expect(state.entitlementState, equals(CloudEntitlementState.unavailable));
    },
  );
}
