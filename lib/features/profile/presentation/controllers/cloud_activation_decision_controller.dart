import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kopim/core/config/app_runtime.dart';
import 'package:kopim/features/profile/presentation/controllers/cloud_activation_preflight_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/data_mode_controller.dart';

enum CloudActivationDecisionStatus {
  blocked,
  choiceRequired,
  alreadyCloudEnabled,
  unavailable,
  unknown,
}

enum CloudActivationScenario {
  localHasDataRemoteUnknown,
  localEmptyRemoteUnknown,
}

enum CloudActivationSnapshotState { empty, hasData, unknown }

enum CloudActivationChoice {
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
  final List<CloudActivationDecisionOption> options;
  final CloudActivationScenario? scenario;

  bool get canChoose =>
      status == CloudActivationDecisionStatus.blocked ||
      status == CloudActivationDecisionStatus.choiceRequired;
}

bool canOpenCloudActivationChoiceScreen(CloudActivationPreflightStatus status) {
  return status == CloudActivationPreflightStatus.blockedByLocalOnlyData ||
      status == CloudActivationPreflightStatus.readyForNextStep;
}

CloudActivationDecisionState resolveCloudActivationDecisionState({
  required CloudActivationPreflightState preflightState,
  required AsyncValue<DataModeState> dataModeAsync,
}) {
  return switch (preflightState.status) {
    CloudActivationPreflightStatus.blockedByLocalOnlyData =>
      _resolveLocalDataScenario(dataModeAsync),
    CloudActivationPreflightStatus.readyForNextStep =>
      _resolveEmptyLocalScenario(dataModeAsync),
    CloudActivationPreflightStatus.alreadyCloudEnabled =>
      const CloudActivationDecisionState(
        status: CloudActivationDecisionStatus.alreadyCloudEnabled,
        title: 'Синхронизация уже включена',
        subtitle: 'Дополнительный выбор сценария сейчас не нужен.',
        body:
            'Облачные функции уже активны для этого аккаунта. Этот экран не запускает повторное подключение.',
        followupNote: 'Никакие данные не меняются на этом шаге.',
        localSnapshotState: CloudActivationSnapshotState.unknown,
        remoteSnapshotState: CloudActivationSnapshotState.unknown,
        options: <CloudActivationDecisionOption>[],
      ),
    CloudActivationPreflightStatus.cloudUnavailableInBuild ||
    CloudActivationPreflightStatus.signedOut ||
    CloudActivationPreflightStatus
        .entitlementRequired => const CloudActivationDecisionState(
      status: CloudActivationDecisionStatus.unavailable,
      title: 'Синхронизация сейчас недоступна',
      subtitle: 'Сначала нужно завершить предыдущий шаг.',
      body:
          'Этот экран выбора сценария открывается только после того, как облачные функции реально доступны для следующего безопасного шага.',
      followupNote:
          'Данные не отправляются и не меняются, пока preflight не разрешит следующий этап.',
      localSnapshotState: CloudActivationSnapshotState.unknown,
      remoteSnapshotState: CloudActivationSnapshotState.unknown,
      options: <CloudActivationDecisionOption>[],
    ),
    CloudActivationPreflightStatus.unknown => const CloudActivationDecisionState(
      status: CloudActivationDecisionStatus.unknown,
      title: 'Проверяем состояние подключения',
      subtitle: 'Сценарий пока не определён.',
      body:
          'Приложение ещё уточняет, какой следующий шаг безопасен. Пока выбор сценария недоступен.',
      followupNote:
          'Этот экран остаётся fail-closed, пока состояние не стало надёжным.',
      localSnapshotState: CloudActivationSnapshotState.unknown,
      remoteSnapshotState: CloudActivationSnapshotState.unknown,
      options: <CloudActivationDecisionOption>[],
    ),
  };
}

CloudActivationDecisionState _resolveLocalDataScenario(
  AsyncValue<DataModeState> dataModeAsync,
) {
  final DataMode? dataMode = dataModeAsync.asData?.value.dataMode;
  if (dataMode != DataMode.cloudBlockedByLocalData) {
    return const CloudActivationDecisionState(
      status: CloudActivationDecisionStatus.unknown,
      title: 'Проверяем состояние подключения',
      subtitle: 'Сценарий пока не определён.',
      body:
          'Локальное состояние ещё не подтверждено, поэтому экран выбора не предлагает рискованные шаги.',
      followupNote:
          'Пока состояние не подтверждено, никакой сценарий не выполняется автоматически.',
      localSnapshotState: CloudActivationSnapshotState.unknown,
      remoteSnapshotState: CloudActivationSnapshotState.unknown,
      options: <CloudActivationDecisionOption>[],
    );
  }

  return const CloudActivationDecisionState(
    status: CloudActivationDecisionStatus.blocked,
    scenario: CloudActivationScenario.localHasDataRemoteUnknown,
    title: 'Как включить облачные функции',
    subtitle:
        'Сначала выберите, как Kopim должен работать с вашими данными дальше.',
    body:
        'На этом устройстве уже есть локальные данные. Пока приложение не выполняет перенос, объединение или замену данных автоматически.',
    followupNote:
        'Это только подготовительный шаг: локальные данные пока никуда не отправлены, а облачная синхронизация не включится сама.',
    localSnapshotState: CloudActivationSnapshotState.hasData,
    remoteSnapshotState: CloudActivationSnapshotState.unknown,
    options: <CloudActivationDecisionOption>[
      CloudActivationDecisionOption(
        choice: CloudActivationChoice.stayLocalOnly,
        title: 'Остаться локально',
        body:
            'Закрыть этот flow и продолжить работу только с данными на устройстве.',
        availability: CloudActivationChoiceAvailability.available,
      ),
      CloudActivationDecisionOption(
        choice: CloudActivationChoice.migrateLocalToCloud,
        title: 'Перенести данные в облако',
        body:
            'Будущий сценарий переноса текущих локальных данных в облако без ручного экспорта.',
        availability:
            CloudActivationChoiceAvailability.unavailableUntilExecutionFlow,
        followupNote:
            'Этот execution flow ещё не реализован, поэтому перенос сейчас не запускается.',
      ),
      CloudActivationDecisionOption(
        choice: CloudActivationChoice.startWithEmptyCloud,
        title: 'Начать с пустого облака',
        body:
            'Подготовить сценарий, в котором облачный режим стартует без отправки текущих локальных данных.',
        availability: CloudActivationChoiceAvailability.requiresConfirmation,
        followupNote:
            'На этом шаге это только подтверждение продуктового выбора без изменения данных.',
      ),
      CloudActivationDecisionOption(
        choice: CloudActivationChoice.replaceLocalWithCloud,
        title: 'Заменить локальные данные облачными',
        body:
            'Будущий сценарий, в котором источник данных для устройства приходит из облака.',
        availability:
            CloudActivationChoiceAvailability.unavailableForCurrentScenario,
        followupNote:
            'Удалённый снимок данных пока не подтверждён, поэтому этот путь скрыт за fail-closed ограничением.',
      ),
      CloudActivationDecisionOption(
        choice: CloudActivationChoice.mergeLocalAndCloud,
        title: 'Объединить локальные и облачные данные',
        body:
            'Будущий сценарий безопасного объединения локальных и облачных данных.',
        availability:
            CloudActivationChoiceAvailability.unavailableUntilExecutionFlow,
        followupNote:
            'Для этого пути ещё нет execution flow и правил merge на текущем этапе.',
      ),
    ],
  );
}

CloudActivationDecisionState _resolveEmptyLocalScenario(
  AsyncValue<DataModeState> dataModeAsync,
) {
  final DataMode? dataMode = dataModeAsync.asData?.value.dataMode;
  if (dataMode != DataMode.localOnly) {
    return const CloudActivationDecisionState(
      status: CloudActivationDecisionStatus.unknown,
      title: 'Проверяем состояние подключения',
      subtitle: 'Сценарий пока не определён.',
      body:
          'Приложение ещё не подтвердило безопасный локальный стартовый сценарий, поэтому выбор временно закрыт.',
      followupNote:
          'Никакой путь не будет запущен автоматически, пока состояние не стало надёжным.',
      localSnapshotState: CloudActivationSnapshotState.unknown,
      remoteSnapshotState: CloudActivationSnapshotState.unknown,
      options: <CloudActivationDecisionOption>[],
    );
  }

  return const CloudActivationDecisionState(
    status: CloudActivationDecisionStatus.choiceRequired,
    scenario: CloudActivationScenario.localEmptyRemoteUnknown,
    title: 'Как включить облачные функции',
    subtitle:
        'Сначала выберите, как Kopim должен работать с вашими данными дальше.',
    body:
        'На устройстве сейчас нет подтверждённого локального блока для переноса, но приложение всё равно не включает облако автоматически на этом шаге.',
    followupNote:
        'Это подготовительный экран: сценарий можно выбрать заранее, но данные пока не отправляются и не подгружаются.',
    localSnapshotState: CloudActivationSnapshotState.empty,
    remoteSnapshotState: CloudActivationSnapshotState.unknown,
    options: <CloudActivationDecisionOption>[
      CloudActivationDecisionOption(
        choice: CloudActivationChoice.stayLocalOnly,
        title: 'Остаться локально',
        body: 'Закрыть flow и пока не переходить к облачному сценарию.',
        availability: CloudActivationChoiceAvailability.available,
      ),
      CloudActivationDecisionOption(
        choice: CloudActivationChoice.migrateLocalToCloud,
        title: 'Перенести данные в облако',
        body:
            'Сценарий переноса нужен только когда есть локальные данные для отправки.',
        availability:
            CloudActivationChoiceAvailability.unavailableForCurrentScenario,
      ),
      CloudActivationDecisionOption(
        choice: CloudActivationChoice.startWithEmptyCloud,
        title: 'Начать с пустого облака',
        body:
            'Подготовить пустой облачный старт как следующий продуктовый шаг.',
        availability: CloudActivationChoiceAvailability.requiresConfirmation,
        followupNote:
            'Даже после подтверждения на этом этапе не создаётся и не очищается удалённое состояние.',
      ),
      CloudActivationDecisionOption(
        choice: CloudActivationChoice.replaceLocalWithCloud,
        title: 'Заменить локальные данные облачными',
        body:
            'Этот путь имеет смысл только если облачные данные уже подтверждены отдельно.',
        availability:
            CloudActivationChoiceAvailability.unavailableForCurrentScenario,
      ),
      CloudActivationDecisionOption(
        choice: CloudActivationChoice.mergeLocalAndCloud,
        title: 'Объединить локальные и облачные данные',
        body: 'Merge станет отдельным этапом, когда появится execution flow.',
        availability:
            CloudActivationChoiceAvailability.unavailableUntilExecutionFlow,
      ),
    ],
  );
}

final Provider<CloudActivationDecisionState> cloudActivationDecisionProvider =
    Provider<CloudActivationDecisionState>((Ref ref) {
      return resolveCloudActivationDecisionState(
        preflightState: ref.watch(cloudActivationPreflightProvider),
        dataModeAsync: ref.watch(dataModeControllerProvider),
      );
    });
