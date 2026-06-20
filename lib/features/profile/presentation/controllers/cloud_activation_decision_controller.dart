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
        'Это подготовительный экран: choice/readiness только фиксирует безопасный сценарий без sync side effects.',
    localSnapshotState: _mapLocalSnapshot(readinessState.localSnapshotState),
    remoteSnapshotState: _mapRemoteSnapshot(readinessState.remoteSnapshotState),
    localFingerprint: readinessState.localFingerprint,
    remoteFingerprint: readinessState.remoteFingerprint,
    options: <CloudActivationDecisionOption>[
      const CloudActivationDecisionOption(
        choice: CloudActivationChoice.stayLocalOnly,
        title: 'Остаться локально',
        body: 'Закрыть flow и пока не переходить к облачному сценарию.',
        availability: CloudActivationChoiceAvailability.available,
      ),
      CloudActivationDecisionOption(
        choice: CloudActivationChoice.enableCloudSync,
        title: 'Включить облачную синхронизацию',
        body:
            'Обычное включение синхронизации доступно только когда локально нет пользовательских данных, а в облаке вообще нет удалённого снимка.',
        availability: enableCloudSyncAvailable
            ? CloudActivationChoiceAvailability.available
            : CloudActivationChoiceAvailability.unavailableForCurrentScenario,
        followupNote:
            'Первый execution path поддерживает только полностью пустое облако: наличие metadata тоже оставляет сценарий заблокированным.',
      ),
      CloudActivationDecisionOption(
        choice: CloudActivationChoice.migrateLocalToCloud,
        title: 'Перенести данные в облако',
        body:
            'Будущий execution flow переноса локальных данных в облако без ручного экспорта.',
        availability: migrateLocalToCloudRelevant
            ? CloudActivationChoiceAvailability.unavailableUntilExecutionFlow
            : CloudActivationChoiceAvailability.unavailableForCurrentScenario,
        followupNote:
            'Execution flow для миграции ещё не реализован, поэтому перенос сейчас не запускается.',
      ),
      CloudActivationDecisionOption(
        choice: CloudActivationChoice.startWithEmptyCloud,
        title: 'Начать с пустого облака',
        body:
            'Отдельный продуктовый выбор для случая, когда локальные данные не нужно отправлять в облако.',
        availability: startWithEmptyCloudAvailable
            ? CloudActivationChoiceAvailability.requiresConfirmation
            : remoteMetadataOnly && localHasData
            ? CloudActivationChoiceAvailability.unavailableUntilExecutionFlow
            : CloudActivationChoiceAvailability.unavailableForCurrentScenario,
        followupNote:
            'Перед переключением Kopim сначала создаст backup локальных данных, затем очистит активное локальное рабочее пространство и только после этого включит пустое облако.',
      ),
      CloudActivationDecisionOption(
        choice: CloudActivationChoice.replaceLocalWithCloud,
        title: 'Заменить локальные данные облачными',
        body:
            'Сценарий актуален только когда облачный финансовый снимок уже подтверждён для текущего аккаунта.',
        availability: replaceLocalWithCloudRelevant
            ? CloudActivationChoiceAvailability.unavailableUntilExecutionFlow
            : CloudActivationChoiceAvailability.unavailableForCurrentScenario,
        followupNote:
            'Execution flow для замены локальных данных облачными ещё не реализован.',
      ),
      CloudActivationDecisionOption(
        choice: CloudActivationChoice.mergeLocalAndCloud,
        title: 'Объединить локальные и облачные данные',
        body:
            'Merge имеет смысл только когда подтверждены и локальные, и облачные пользовательские данные.',
        availability: mergeRelevant
            ? CloudActivationChoiceAvailability.unavailableUntilExecutionFlow
            : CloudActivationChoiceAvailability.unavailableForCurrentScenario,
        followupNote:
            'Для merge пока нет execution flow и правил объединения на текущем этапе.',
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
    return 'На устройстве и в облаке уже есть подтверждённые пользовательские данные. Пока приложение не выполняет merge автоматически и остаётся в design-gate режиме.';
  }
  if (localHasData) {
    return remoteMetadataOnly
        ? 'На устройстве уже есть локальные данные, а в облаке подтверждены только служебные metadata. Обычное включение синхронизации здесь не подменяет отдельный выбор сценария.'
        : 'На этом устройстве уже есть локальные данные. Пока приложение не выполняет перенос, объединение или замену данных автоматически.';
  }
  if (remoteHasData) {
    return 'Локального блока для миграции сейчас нет, но в облаке уже есть подтверждённые пользовательские данные. Поэтому обычное включение синхронизации остаётся закрытым до отдельного execution flow.';
  }
  if (remoteMetadataOnly) {
    return 'Локально пользовательских данных нет, а в облаке найдены только служебные metadata без финансового снимка. Это эквивалент безопасного пустого старта для текущего readiness-этапа.';
  }
  return 'На устройстве сейчас нет подтверждённого локального блока для миграции, и облачный финансовый снимок тоже не найден. Приложение всё равно не включает облако автоматически на этом шаге.';
}
