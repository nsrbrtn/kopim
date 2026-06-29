import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kopim/features/profile/presentation/controllers/cloud_activation_preflight_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/cloud_activation_readiness_controller.dart';
import 'package:kopim/features/profile/presentation/models/cloud_activation_readiness_models.dart';

enum CloudActivationDecisionStatus {
  blocked,
  choiceRequired,
  alreadyCloudEnabled,
  unavailable,
  unknown,
}

enum CloudActivationScenario {
  localEmptyRemoteEmpty,
  localEmptyRemoteMetadataOnly,
  localEmptyRemoteHasData,
  localHasDataRemoteEmpty,
  localHasDataRemoteMetadataOnly,
  localHasDataRemoteHasData,
}

enum CloudActivationSnapshotState { empty, hasData, unknown }

enum CloudActivationChoice {
  enableCloudSync,
  stayLocalOnly,
  migrateLocalToCloud,
  startWithEmptyCloud,
  replaceLocalWithCloud,
  mergeLocalAndCloud,
}

enum CloudActivationChoiceAvailability {
  available,
  requiresConfirmation,
  unavailableForCurrentScenario,
  unavailableUntilExecutionFlow,
}

class CloudActivationDecisionOption {
  const CloudActivationDecisionOption({
    required this.choice,
    required this.title,
    required this.body,
    required this.availability,
    this.followupNote,
  });

  final CloudActivationChoice choice;
  final String title;
  final String body;
  final CloudActivationChoiceAvailability availability;
  final String? followupNote;
}

class CloudActivationDecisionState {
  const CloudActivationDecisionState({
    required this.status,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.followupNote,
    required this.recommendedChoice,
    required this.localSnapshotState,
    required this.remoteSnapshotState,
    required this.localFingerprint,
    required this.remoteFingerprint,
    required this.options,
    this.scenario,
  });

  final CloudActivationDecisionStatus status;
  final String title;
  final String subtitle;
  final String body;
  final String followupNote;
  final CloudActivationChoice? recommendedChoice;
  final CloudActivationSnapshotState localSnapshotState;
  final CloudActivationSnapshotState remoteSnapshotState;
  final String? localFingerprint;
  final String? remoteFingerprint;
  final List<CloudActivationDecisionOption> options;
  final CloudActivationScenario? scenario;

  bool get canChoose =>
      status == CloudActivationDecisionStatus.blocked ||
      status == CloudActivationDecisionStatus.choiceRequired;
}

String cloudActivationChoiceLabel(CloudActivationChoice choice) {
  return switch (choice) {
    CloudActivationChoice.enableCloudSync => 'Включить облачную синхронизацию',
    CloudActivationChoice.stayLocalOnly => 'Остаться локально',
    CloudActivationChoice.migrateLocalToCloud => 'Перенести данные в облако',
    CloudActivationChoice.startWithEmptyCloud => 'Начать с пустого облака',
    CloudActivationChoice.replaceLocalWithCloud =>
      'Заменить локальные данные облачными',
    CloudActivationChoice.mergeLocalAndCloud =>
      'Объединить локальные и облачные данные',
  };
}

bool canOpenCloudActivationChoiceScreen(CloudActivationPreflightStatus status) {
  return status == CloudActivationPreflightStatus.blockedByLocalOnlyData ||
      status == CloudActivationPreflightStatus.readyForNextStep;
}

CloudActivationDecisionState resolveCloudActivationDecisionState({
  required CloudActivationReadinessState readinessState,
}) {
  return switch (readinessState.status) {
    CloudActivationReadinessStatus.readyForChoice ||
    CloudActivationReadinessStatus.waitingForConfirmation =>
      _resolveMatrixScenario(readinessState),
    CloudActivationReadinessStatus.executionBlocked =>
      const CloudActivationDecisionState(
        status: CloudActivationDecisionStatus.alreadyCloudEnabled,
        title: 'Синхронизация уже включена',
        subtitle: 'Дополнительный выбор сценария сейчас не нужен.',
        body:
            'Облачные функции уже активны для этого аккаунта. Этот экран не запускает повторное подключение.',
        followupNote: 'Никакие данные не меняются на этом шаге.',
        recommendedChoice: null,
        localSnapshotState: CloudActivationSnapshotState.unknown,
        remoteSnapshotState: CloudActivationSnapshotState.unknown,
        localFingerprint: null,
        remoteFingerprint: null,
        options: <CloudActivationDecisionOption>[],
      ),
    CloudActivationReadinessStatus.unavailable =>
      const CloudActivationDecisionState(
        status: CloudActivationDecisionStatus.unavailable,
        title: 'Синхронизация сейчас недоступна',
        subtitle: 'Сначала нужно завершить предыдущий шаг.',
        body:
            'Этот экран выбора сценария открывается только после того, как облачные функции реально доступны для следующего безопасного шага.',
        followupNote:
            'Данные не отправляются и не меняются, пока preflight не разрешит следующий этап.',
        recommendedChoice: null,
        localSnapshotState: CloudActivationSnapshotState.unknown,
        remoteSnapshotState: CloudActivationSnapshotState.unknown,
        localFingerprint: null,
        remoteFingerprint: null,
        options: <CloudActivationDecisionOption>[],
      ),
    CloudActivationReadinessStatus.loading ||
    CloudActivationReadinessStatus
        .unknown => const CloudActivationDecisionState(
      status: CloudActivationDecisionStatus.unknown,
      title: 'Проверяем состояние подключения',
      subtitle: 'Сценарий пока не определён.',
      body:
          'Приложение ещё уточняет, какой следующий шаг безопасен. Пока выбор сценария недоступен.',
      followupNote:
          'Этот экран остаётся fail-closed, пока состояние не стало надёжным.',
      recommendedChoice: null,
      localSnapshotState: CloudActivationSnapshotState.unknown,
      remoteSnapshotState: CloudActivationSnapshotState.unknown,
      localFingerprint: null,
      remoteFingerprint: null,
      options: <CloudActivationDecisionOption>[],
    ),
  };
}

CloudActivationDecisionState _resolveMatrixScenario(
  CloudActivationReadinessState readinessState,
) {
  final CloudActivationScenario? scenario = _mapScenario(
    readinessState.matrixScenario,
  );
  if (scenario == null) {
    return const CloudActivationDecisionState(
      status: CloudActivationDecisionStatus.unknown,
      title: 'Проверяем состояние подключения',
      subtitle: 'Сценарий пока не определён.',
      body:
          'Приложение ещё не подтвердило безопасную комбинацию локального и облачного состояния.',
      followupNote:
          'Пока состояние не подтверждено, никакой сценарий не выполняется автоматически.',
      recommendedChoice: null,
      localSnapshotState: CloudActivationSnapshotState.unknown,
      remoteSnapshotState: CloudActivationSnapshotState.unknown,
      localFingerprint: null,
      remoteFingerprint: null,
      options: <CloudActivationDecisionOption>[],
    );
  }

  final bool localHasData =
      readinessState.localSnapshotState == LocalSnapshotState.hasUserData;
  final bool remoteHasData =
      readinessState.remoteSnapshotState == RemoteSnapshotState.hasUserData;
  final bool remoteMetadataOnly =
      readinessState.remoteSnapshotState == RemoteSnapshotState.hasOnlyMetadata;
  final bool enableCloudSyncAvailable =
      !localHasData &&
      readinessState.remoteSnapshotState == RemoteSnapshotState.empty;
  final bool startWithEmptyCloudAvailable =
      localHasData &&
      readinessState.remoteSnapshotState == RemoteSnapshotState.empty;
  final bool migrateLocalToCloudRelevant =
      localHasData &&
      (readinessState.remoteSnapshotState == RemoteSnapshotState.empty ||
          remoteMetadataOnly);
  final bool replaceLocalWithCloudRelevant = !localHasData && remoteHasData;
  final bool mergeRelevant = localHasData && remoteHasData;

  return CloudActivationDecisionState(
    status: localHasData
        ? CloudActivationDecisionStatus.blocked
        : CloudActivationDecisionStatus.choiceRequired,
    scenario: scenario,
    title: 'Как включить облачные функции',
    subtitle:
        'Сначала выберите, как Kopim должен работать с вашими данными дальше.',
    body: _buildBody(
      localHasData: localHasData,
      remoteHasData: remoteHasData,
      remoteMetadataOnly: remoteMetadataOnly,
    ),
    followupNote:
        'Этот экран помогает выбрать следующий безопасный шаг. Пока данные на устройстве и в облаке не меняются.',
    recommendedChoice: _recommendedChoiceForScenario(scenario),
    localSnapshotState: _mapLocalSnapshot(readinessState.localSnapshotState),
    remoteSnapshotState: _mapRemoteSnapshot(readinessState.remoteSnapshotState),
    localFingerprint: readinessState.localFingerprint,
    remoteFingerprint: readinessState.remoteFingerprint,
    options: <CloudActivationDecisionOption>[
      const CloudActivationDecisionOption(
        choice: CloudActivationChoice.stayLocalOnly,
        title: 'Остаться локально',
        body: 'Закрыть этот экран и пока не подключать облачные функции.',
        availability: CloudActivationChoiceAvailability.available,
      ),
      CloudActivationDecisionOption(
        choice: CloudActivationChoice.enableCloudSync,
        title: 'Включить облачную синхронизацию',
        body:
            'Подходит, когда на устройстве ещё нет пользовательских данных и в облаке тоже нет финансового набора.',
        availability: enableCloudSyncAvailable
            ? CloudActivationChoiceAvailability.available
            : CloudActivationChoiceAvailability.unavailableForCurrentScenario,
        followupNote:
            'Этот вариант работает только для полностью пустого старта. Если в облаке уже есть следы прежнего подключения, сначала нужен другой сценарий.',
      ),
      CloudActivationDecisionOption(
        choice: CloudActivationChoice.migrateLocalToCloud,
        title: 'Перенести данные в облако',
        body:
            'Подходит, когда на устройстве уже есть ваши данные, а в облаке ещё нет рабочего набора.',
        availability:
            localHasData &&
                readinessState.remoteSnapshotState == RemoteSnapshotState.empty
            ? CloudActivationChoiceAvailability.requiresConfirmation
            : migrateLocalToCloudRelevant
            ? CloudActivationChoiceAvailability.unavailableUntilExecutionFlow
            : CloudActivationChoiceAvailability.unavailableForCurrentScenario,
        followupNote:
            'Kopim сначала проверит готовность данных к безопасному переносу и только потом позволит перейти к следующему шагу.',
      ),
      CloudActivationDecisionOption(
        choice: CloudActivationChoice.startWithEmptyCloud,
        title: 'Начать с пустого облака',
        body:
            'Подходит, если вы хотите сохранить локальные данные отдельно и начать новый пустой облачный профиль.',
        availability: startWithEmptyCloudAvailable
            ? CloudActivationChoiceAvailability.requiresConfirmation
            : remoteMetadataOnly && localHasData
            ? CloudActivationChoiceAvailability.unavailableUntilExecutionFlow
            : CloudActivationChoiceAvailability.unavailableForCurrentScenario,
        followupNote:
            'Перед переключением Kopim сначала создаст backup локальных данных и только потом подготовит новый пустой облачный профиль.',
      ),
      CloudActivationDecisionOption(
        choice: CloudActivationChoice.replaceLocalWithCloud,
        title: 'Загрузить облачные данные',
        body:
            'Подходит, когда на устройстве ещё нет ваших данных, а в облаке они уже есть.',
        availability: replaceLocalWithCloudRelevant
            ? CloudActivationChoiceAvailability.requiresConfirmation
            : CloudActivationChoiceAvailability.unavailableForCurrentScenario,
        followupNote:
            'Kopim ещё раз проверит, что устройство пустое, а облачные данные доступны для текущего аккаунта, и только после этого начнёт подключение.',
      ),
      CloudActivationDecisionOption(
        choice: CloudActivationChoice.mergeLocalAndCloud,
        title: 'Объединить локальные и облачные данные',
        body:
            'Этот вариант нужен только если и на устройстве, и в облаке уже есть разные наборы данных.',
        availability: mergeRelevant
            ? CloudActivationChoiceAvailability.unavailableUntilExecutionFlow
            : CloudActivationChoiceAvailability.unavailableForCurrentScenario,
        followupNote:
            'Пока Kopim не умеет безопасно объединять такие данные автоматически, поэтому этот вариант недоступен.',
      ),
    ],
  );
}

final Provider<CloudActivationDecisionState> cloudActivationDecisionProvider =
    Provider<CloudActivationDecisionState>((Ref ref) {
      return resolveCloudActivationDecisionState(
        readinessState: ref
            .watch(cloudActivationReadinessProvider)
            .asData!
            .value,
      );
    });

CloudActivationScenario? _mapScenario(CloudActivationMatrixScenario? scenario) {
  return switch (scenario) {
    CloudActivationMatrixScenario.localEmptyRemoteEmpty =>
      CloudActivationScenario.localEmptyRemoteEmpty,
    CloudActivationMatrixScenario.localEmptyRemoteMetadataOnly =>
      CloudActivationScenario.localEmptyRemoteMetadataOnly,
    CloudActivationMatrixScenario.localEmptyRemoteHasUserData =>
      CloudActivationScenario.localEmptyRemoteHasData,
    CloudActivationMatrixScenario.localHasUserDataRemoteEmpty =>
      CloudActivationScenario.localHasDataRemoteEmpty,
    CloudActivationMatrixScenario.localHasUserDataRemoteMetadataOnly =>
      CloudActivationScenario.localHasDataRemoteMetadataOnly,
    CloudActivationMatrixScenario.localHasUserDataRemoteHasUserData =>
      CloudActivationScenario.localHasDataRemoteHasData,
    null => null,
  };
}

CloudActivationSnapshotState _mapLocalSnapshot(LocalSnapshotState state) {
  return switch (state) {
    LocalSnapshotState.empty ||
    LocalSnapshotState.hasOnlySystemData => CloudActivationSnapshotState.empty,
    LocalSnapshotState.hasUserData => CloudActivationSnapshotState.hasData,
    LocalSnapshotState.hasPendingOutbox ||
    LocalSnapshotState.hasLocalOnlyPlaceholders ||
    LocalSnapshotState.activationInProgress ||
    LocalSnapshotState.unknown => CloudActivationSnapshotState.unknown,
  };
}

CloudActivationSnapshotState _mapRemoteSnapshot(RemoteSnapshotState state) {
  return switch (state) {
    RemoteSnapshotState.empty ||
    RemoteSnapshotState.hasOnlyMetadata => CloudActivationSnapshotState.empty,
    RemoteSnapshotState.hasUserData => CloudActivationSnapshotState.hasData,
    RemoteSnapshotState.hasTombstonesOnly ||
    RemoteSnapshotState.activationInProgress ||
    RemoteSnapshotState.unavailable ||
    RemoteSnapshotState.permissionDenied ||
    RemoteSnapshotState.unauthenticated ||
    RemoteSnapshotState.unknown => CloudActivationSnapshotState.unknown,
  };
}

String _buildBody({
  required bool localHasData,
  required bool remoteHasData,
  required bool remoteMetadataOnly,
}) {
  if (localHasData && remoteHasData) {
    return 'На устройстве и в облаке уже есть данные. Автоматически объединить их сейчас нельзя, поэтому сначала нужен отдельный безопасный сценарий.';
  }
  if (localHasData) {
    return remoteMetadataOnly
        ? 'На устройстве уже есть ваши данные, а в облаке найдены только служебные следы прежнего подключения. Здесь нужен отдельный выбор следующего шага.'
        : 'На этом устройстве уже есть ваши данные. Сначала выберите, нужно ли перенести их в облако или начать новый пустой облачный профиль.';
  }
  if (remoteHasData) {
    return 'На этом устройстве ещё нет ваших данных, но в облаке они уже есть. Обычное включение синхронизации здесь не подходит.';
  }
  if (remoteMetadataOnly) {
    return 'На устройстве пользовательских данных нет, а в облаке найдены только служебные следы без финансового набора. Это близко к безопасному пустому старту.';
  }
  return 'На устройстве пока нет ваших данных, и в облаке тоже не найден готовый финансовый набор. Выберите, хотите ли вы включить облачные функции для пустого старта.';
}

CloudActivationChoice? _recommendedChoiceForScenario(
  CloudActivationScenario scenario,
) {
  return switch (scenario) {
    CloudActivationScenario.localEmptyRemoteEmpty =>
      CloudActivationChoice.enableCloudSync,
    CloudActivationScenario.localEmptyRemoteMetadataOnly => null,
    CloudActivationScenario.localEmptyRemoteHasData =>
      CloudActivationChoice.replaceLocalWithCloud,
    CloudActivationScenario.localHasDataRemoteEmpty =>
      CloudActivationChoice.migrateLocalToCloud,
    CloudActivationScenario.localHasDataRemoteMetadataOnly =>
      CloudActivationChoice.migrateLocalToCloud,
    CloudActivationScenario.localHasDataRemoteHasData => null,
  };
}
