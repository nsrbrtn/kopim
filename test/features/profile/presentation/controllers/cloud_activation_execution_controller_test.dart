import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:kopim/core/config/app_runtime.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/profile/application/cloud_activation_execution_service.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/entities/user_progress.dart';
import 'package:kopim/features/profile/domain/models/profile_command_result.dart';
import 'package:kopim/features/profile/domain/usecases/recompute_user_progress_use_case.dart';
import 'package:kopim/features/profile/presentation/controllers/auth_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/cloud_activation_execution_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/cloud_activation_intent_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/data_mode_controller.dart';
import 'package:kopim/core/services/auth_sync_service.dart';

class _FakeAuthUser implements AuthUser {
  @override
  String get uid => 'user-123';
  @override
  String get email => 'test@example.com';
  @override
  bool get isAnonymous => false;
  @override
  bool get isGuest => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestAuthController extends AuthController {
  _TestAuthController(this.user);
  final AuthUser? user;

  @override
  Future<AuthUser?> build() async => user;
}

class _FakeCloudActivationExecutionService
    implements CloudActivationExecutionService {
  bool confirmReplaceCalled = false;
  bool clearActivationStateCalled = false;
  String? clearUid;
  bool shouldFailClearActivation = false;

  @override
  Future<CloudActivationExecutionResult> confirmReplaceLocalWithCloud({
    required AuthUser? currentUser,
    required CloudActivationIntentState intentState,
    required DataModeState? currentMode,
    required Future<DataModeState> Function() refreshRuntimeMode,
  }) async {
    confirmReplaceCalled = true;
    return const CloudActivationExecutionResult.succeeded();
  }

  @override
  Future<void> clearActivationState(String uid) async {
    clearActivationStateCalled = true;
    clearUid = uid;
    if (shouldFailClearActivation) {
      throw Exception('Database crash during clearActivationState');
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeDataModeController extends DataModeController {
  _FakeDataModeController(this.stateValue);
  final DataModeState stateValue;
  bool refreshCalled = false;
  bool shouldFailRefresh = false;

  @override
  Future<DataModeState> build() async => stateValue;

  @override
  Future<DataModeState> refreshForCurrentContext() async {
    refreshCalled = true;
    if (shouldFailRefresh) {
      throw Exception('SharedPreferences failure during refresh');
    }
    return stateValue;
  }
}

class _FakeAuthSyncService implements AuthSyncService {
  bool synchronizeOnLoginCalled = false;
  bool shouldThrowOnSync = false;

  @override
  Future<void> synchronizeOnLogin({
    required AuthUser user,
    MigrationDecision? migrationDecision,
    AuthUser? previousUser,
  }) async {
    synchronizeOnLoginCalled = true;
    if (shouldThrowOnSync) {
      throw Exception('Network disconnected during sync');
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeRecomputeUserProgressUseCase
    implements RecomputeUserProgressUseCase {
  bool callCalled = false;

  @override
  Future<ProfileCommandResult<UserProgress>> call() async {
    callCalled = true;
    return ProfileCommandResult<UserProgress>(
      value: UserProgress(
        title: 'test',
        nextThreshold: 100,
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('CloudActivationExecutionController Rollback Path', () {
    late _FakeCloudActivationExecutionService fakeExecutionService;
    late _FakeDataModeController fakeDataModeController;
    late _FakeAuthSyncService fakeAuthSyncService;
    late _FakeRecomputeUserProgressUseCase fakeRecomputeUseCase;
    late ProviderContainer container;

    setUp(() {
      fakeExecutionService = _FakeCloudActivationExecutionService();
      fakeDataModeController = _FakeDataModeController(
        const DataModeState(
          dataMode: DataMode.cloudEnabled,
          entitlementState: CloudEntitlementState.active,
          migrationDecision: MigrationDecision.none,
        ),
      );
      fakeAuthSyncService = _FakeAuthSyncService();
      fakeRecomputeUseCase = _FakeRecomputeUserProgressUseCase();

      container = ProviderContainer(
        overrides: <Override>[
          authControllerProvider.overrideWith(
            () => _TestAuthController(_FakeAuthUser()),
          ),
          cloudActivationExecutionServiceProvider.overrideWithValue(
            fakeExecutionService,
          ),
          dataModeControllerProvider.overrideWith(() => fakeDataModeController),
          authSyncServiceProvider.overrideWithValue(fakeAuthSyncService),
          recomputeUserProgressUseCaseProvider.overrideWithValue(
            fakeRecomputeUseCase,
          ),
          cloudActivationIntentProvider.overrideWith(
            () => CloudActivationIntentController(),
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial sync success does not trigger rollback', () async {
      final CloudActivationExecutionController controller = container.read(
        cloudActivationExecutionControllerProvider.notifier,
      );

      final CloudActivationExecutionResult result = await controller
          .confirmReplaceLocalWithCloud();

      expect(result.status, CloudActivationExecutionStatus.succeeded);
      expect(fakeExecutionService.confirmReplaceCalled, isTrue);
      expect(fakeAuthSyncService.synchronizeOnLoginCalled, isTrue);
      expect(fakeRecomputeUseCase.callCalled, isTrue);
      expect(fakeExecutionService.clearActivationStateCalled, isFalse);
      expect(fakeDataModeController.refreshCalled, isFalse);
    });

    test(
      'initial sync failure triggers rollback and returns failed result',
      () async {
        fakeAuthSyncService.shouldThrowOnSync = true;
        final CloudActivationExecutionController controller = container.read(
          cloudActivationExecutionControllerProvider.notifier,
        );

        final CloudActivationExecutionResult result = await controller
            .confirmReplaceLocalWithCloud();

        expect(result.status, CloudActivationExecutionStatus.failed);
        expect(
          result.message,
          contains(
            'Не удалось загрузить данные из облака: Exception: Network disconnected during sync. Активация отменена.',
          ),
        );
        expect(fakeExecutionService.confirmReplaceCalled, isTrue);
        expect(fakeAuthSyncService.synchronizeOnLoginCalled, isTrue);
        expect(fakeRecomputeUseCase.callCalled, isFalse);
        expect(fakeExecutionService.clearActivationStateCalled, isTrue);
        expect(fakeExecutionService.clearUid, 'user-123');
        expect(fakeDataModeController.refreshCalled, isTrue);
      },
    );

    test(
      'initial sync failure and rollback failure logs critical error but still returns failed result',
      () async {
        fakeAuthSyncService.shouldThrowOnSync = true;
        fakeExecutionService.shouldFailClearActivation = true;
        final CloudActivationExecutionController controller = container.read(
          cloudActivationExecutionControllerProvider.notifier,
        );

        final CloudActivationExecutionResult result = await controller
            .confirmReplaceLocalWithCloud();

        expect(result.status, CloudActivationExecutionStatus.failed);
        expect(
          result.message,
          contains(
            'Не удалось загрузить данные из облака: Exception: Network disconnected during sync. Активация отменена.',
          ),
        );
        expect(fakeExecutionService.confirmReplaceCalled, isTrue);
        expect(fakeAuthSyncService.synchronizeOnLoginCalled, isTrue);
        expect(fakeRecomputeUseCase.callCalled, isFalse);
        expect(fakeExecutionService.clearActivationStateCalled, isTrue);
        // Verify it did not crash the controller flow itself
        expect(
          container
              .read(cloudActivationExecutionControllerProvider)
              .value
              ?.status,
          CloudActivationExecutionStatus.failed,
        );
      },
    );
  });
}
