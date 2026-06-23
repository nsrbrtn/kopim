import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kopim/features/profile/application/cloud_activation_execution_service.dart';
import 'package:kopim/features/profile/presentation/controllers/auth_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/cloud_activation_intent_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/data_mode_controller.dart';

class CloudActivationExecutionController
    extends AsyncNotifier<CloudActivationExecutionResult> {
  @override
  Future<CloudActivationExecutionResult> build() async {
    return const CloudActivationExecutionResult.idle();
  }

  Future<CloudActivationExecutionResult> confirmEnableCloudSync() async {
    state = const AsyncLoading<CloudActivationExecutionResult>();

    final CloudActivationExecutionResult result = await ref
        .read(cloudActivationExecutionServiceProvider)
        .confirmEnableCloudSync(
          currentUser: ref.read(authControllerProvider).asData?.value,
          intentState: ref.read(cloudActivationIntentProvider),
          currentMode: ref.read(dataModeControllerProvider).value,
          refreshRuntimeMode: () => ref
              .read(dataModeControllerProvider.notifier)
              .refreshForCurrentContext(),
        );

    if (result.status == CloudActivationExecutionStatus.succeeded ||
        result.status == CloudActivationExecutionStatus.blocked) {
      ref.read(cloudActivationIntentProvider.notifier).clearPendingChoice();
    }

    state = AsyncData<CloudActivationExecutionResult>(result);
    return result;
  }

  Future<CloudActivationExecutionResult> confirmStartWithEmptyCloud() async {
    state = const AsyncLoading<CloudActivationExecutionResult>();

    final CloudActivationExecutionResult result = await ref
        .read(cloudActivationExecutionServiceProvider)
        .confirmStartWithEmptyCloud(
          currentUser: ref.read(authControllerProvider).asData?.value,
          intentState: ref.read(cloudActivationIntentProvider),
          currentMode: ref.read(dataModeControllerProvider).value,
          refreshRuntimeMode: () => ref
              .read(dataModeControllerProvider.notifier)
              .refreshForCurrentContext(),
        );

    if (result.status == CloudActivationExecutionStatus.succeeded ||
        result.status == CloudActivationExecutionStatus.blocked) {
      ref.read(cloudActivationIntentProvider.notifier).clearPendingChoice();
    }

    state = AsyncData<CloudActivationExecutionResult>(result);
    return result;
  }

  Future<CloudActivationExecutionResult> confirmMigrateLocalToCloud() async {
    state = const AsyncLoading<CloudActivationExecutionResult>();

    final CloudActivationExecutionResult result = await ref
        .read(cloudActivationExecutionServiceProvider)
        .confirmMigrateLocalToCloudPreflight(
          currentUser: ref.read(authControllerProvider).asData?.value,
          intentState: ref.read(cloudActivationIntentProvider),
          currentMode: ref.read(dataModeControllerProvider).value,
        );

    if (result.status == CloudActivationExecutionStatus.succeeded ||
        result.status == CloudActivationExecutionStatus.blocked) {
      ref.read(cloudActivationIntentProvider.notifier).clearPendingChoice();
    }

    state = AsyncData<CloudActivationExecutionResult>(result);
    return result;
  }

  void reset() {
    state = const AsyncData<CloudActivationExecutionResult>(
      CloudActivationExecutionResult.idle(),
    );
  }
}

final AsyncNotifierProvider<
  CloudActivationExecutionController,
  CloudActivationExecutionResult
>
cloudActivationExecutionControllerProvider =
    AsyncNotifierProvider<
      CloudActivationExecutionController,
      CloudActivationExecutionResult
    >(CloudActivationExecutionController.new);
