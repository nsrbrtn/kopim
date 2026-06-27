import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kopim/core/utils/web_platform_utils.dart';
import 'package:kopim/features/profile/application/cloud_activation_execution_service.dart';
import 'package:kopim/features/profile/presentation/controllers/cloud_activation_decision_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/cloud_activation_execution_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/cloud_activation_intent_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/cloud_activation_readiness_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/data_mode_controller.dart';
import 'package:kopim/features/profile/presentation/models/cloud_activation_readiness_models.dart';

class CloudActivationChoiceScreen extends ConsumerStatefulWidget {
  const CloudActivationChoiceScreen({super.key});

  static const String routeName = '/cloud-activation-choice';

  @override
  ConsumerState<CloudActivationChoiceScreen> createState() =>
      _CloudActivationChoiceScreenState();
}

class _CloudActivationChoiceScreenState
    extends ConsumerState<CloudActivationChoiceScreen> {
  @override
  void initState() {
    super.initState();
    ref.listenManual<
      AsyncValue<CloudActivationExecutionResult>
    >(cloudActivationExecutionControllerProvider, (
      AsyncValue<CloudActivationExecutionResult>? previous,
      AsyncValue<CloudActivationExecutionResult> next,
    ) {
      final CloudActivationExecutionResult? result = next.asData?.value;
      if (result == null || !mounted) {
        return;
      }
      switch (result.status) {
        case CloudActivationExecutionStatus.succeeded:
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(_successMessage(result))));
          ref.read(cloudActivationExecutionControllerProvider.notifier).reset();
          if (kIsWeb) {
            reloadWebPage();
          } else {
            _dismiss(context);
          }
          return;
        case CloudActivationExecutionStatus.blocked:
        case CloudActivationExecutionStatus.failed:
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(_executionMessage(result))));
          ref.read(cloudActivationExecutionControllerProvider.notifier).reset();
          return;
        case CloudActivationExecutionStatus.idle:
          return;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final CloudActivationDecisionState state = ref.watch(
      cloudActivationDecisionProvider,
    );
    final CloudActivationIntentState intentState = ref.watch(
      cloudActivationIntentProvider,
    );
    final AsyncValue<CloudActivationReadinessState> readinessAsync = ref.watch(
      cloudActivationReadinessProvider,
    );
    final CloudActivationReadinessState readinessState =
        readinessAsync.asData?.value ??
        const CloudActivationReadinessState(
          status: CloudActivationReadinessStatus.loading,
          localSnapshotState: LocalSnapshotState.unknown,
          remoteSnapshotState: RemoteSnapshotState.unknown,
        );
    final AsyncValue<CloudActivationExecutionResult> executionState = ref.watch(
      cloudActivationExecutionControllerProvider,
    );
    final DataModeState? dataModeState = ref
        .watch(dataModeControllerProvider)
        .value;
    final bool canConfirmEnableCloudSync =
        readinessState.status ==
            CloudActivationReadinessStatus.waitingForConfirmation &&
        intentState.pendingChoice == CloudActivationChoice.enableCloudSync;
    final bool canConfirmStartWithEmptyCloud =
        readinessState.status ==
            CloudActivationReadinessStatus.waitingForConfirmation &&
        intentState.pendingChoice == CloudActivationChoice.startWithEmptyCloud;
    final bool canConfirmMigrateLocalToCloud =
        readinessState.status ==
            CloudActivationReadinessStatus.waitingForConfirmation &&
        intentState.pendingChoice == CloudActivationChoice.migrateLocalToCloud;
    final bool canConfirmReplaceLocalWithCloud =
        readinessState.status ==
            CloudActivationReadinessStatus.waitingForConfirmation &&
        intentState.pendingChoice ==
            CloudActivationChoice.replaceLocalWithCloud;
    final bool canConfirmFreshUpload =
        canConfirmReplaceLocalWithCloud &&
        dataModeState?.requiresFreshCloudUpload == true;
    final bool isExecuting = executionState.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Подключение облака')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: <Widget>[
                Text(
                  state.title,
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  state.subtitle,
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  state.body,
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                _InfoBanner(message: state.followupNote),
                if (intentState.hasPendingChoice) ...<Widget>[
                  const SizedBox(height: 12),
                  _InfoBanner(
                    message:
                        'Для следующего этапа сохранён выбор: ${cloudActivationChoiceLabel(intentState.pendingChoice!)}. Данные и синхронизация пока не менялись.',
                  ),
                ],
                if (canConfirmEnableCloudSync) ...<Widget>[
                  const SizedBox(height: 12),
                  const _InfoBanner(
                    message:
                        'Перед включением Kopim ещё раз проверит локальное и облачное состояние. Если что-то изменилось, сценарий будет безопасно остановлен без отправки данных.',
                  ),
                ],
                if (canConfirmStartWithEmptyCloud) ...<Widget>[
                  const SizedBox(height: 12),
                  const _InfoBanner(
                    message:
                        'Перед запуском Kopim создаст backup локальных данных, затем ещё раз проверит локальное и облачное состояние и только после этого очистит активное локальное рабочее пространство. Локальная база не будет загружена в облако.',
                  ),
                ],
                if (canConfirmMigrateLocalToCloud) ...<Widget>[
                  const SizedBox(height: 12),
                  const _InfoBanner(
                    message:
                        'Следующий шаг пока не запускает upload. Kopim только выполнит migration preflight: включит write-freeze, снимет стабильный локальный snapshot и прогонит inventory/readiness validator. Если хотя бы одна строка небезопасна, перенос останется заблокированным.',
                  ),
                ],
                if (canConfirmReplaceLocalWithCloud) ...<Widget>[
                  const SizedBox(height: 12),
                  _InfoBanner(
                    message: canConfirmFreshUpload
                        ? 'При подтверждении Kopim начнёт Fresh Upload: переведёт remote metadata в freshUploadInProgress, загрузит локальный граф, проверит облако, финализирует локальное состояние и только потом включит синхронизацию.'
                        : 'При подтверждении Kopim сохранит флаг активации облака и при следующем запуске синхронизации полностью скачает существующие данные из облака на это устройство.',
                  ),
                ],
                if (state.canChoose) ...<Widget>[
                  const SizedBox(height: 24),
                  for (final CloudActivationDecisionOption option
                      in state.options) ...<Widget>[
                    _ChoiceCard(
                      option: option,
                      isSelected: intentState.pendingChoice == option.choice,
                      onPressed: () =>
                          _handleChoice(context, ref, state, option),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (canConfirmEnableCloudSync) ...<Widget>[
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: isExecuting
                          ? null
                          : () => ref
                                .read(
                                  cloudActivationExecutionControllerProvider
                                      .notifier,
                                )
                                .confirmEnableCloudSync(),
                      child: Text(
                        isExecuting
                            ? 'Проверяем и включаем...'
                            : 'Подтвердить включение',
                      ),
                    ),
                  ],
                  if (canConfirmStartWithEmptyCloud) ...<Widget>[
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: isExecuting
                          ? null
                          : () => _confirmStartWithEmptyCloud(context, ref),
                      child: Text(
                        isExecuting
                            ? 'Создаём backup и переключаем...'
                            : 'Создать backup и начать с пустого облака',
                      ),
                    ),
                  ],
                  if (canConfirmMigrateLocalToCloud) ...<Widget>[
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: isExecuting
                          ? null
                          : () => ref
                                .read(
                                  cloudActivationExecutionControllerProvider
                                      .notifier,
                                )
                                .confirmMigrateLocalToCloud(),
                      child: Text(
                        isExecuting
                            ? 'Проверяем migration readiness...'
                            : 'Запустить migration preflight',
                      ),
                    ),
                  ],
                  if (canConfirmReplaceLocalWithCloud) ...<Widget>[
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: isExecuting
                          ? null
                          : () {
                              final CloudActivationExecutionController
                              controller = ref.read(
                                cloudActivationExecutionControllerProvider
                                    .notifier,
                              );
                              if (canConfirmFreshUpload) {
                                controller.confirmFreshUploadFromLocal();
                                return;
                              }
                              controller.confirmReplaceLocalWithCloud();
                            },
                      child: Text(
                        isExecuting
                            ? 'Подключаем...'
                            : canConfirmFreshUpload
                            ? 'Загрузить локальные данные в облако'
                            : 'Загрузить облачные данные',
                      ),
                    ),
                  ],
                ] else ...<Widget>[
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _dismiss(context),
                    child: const Text('Вернуться'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmStartWithEmptyCloud(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final bool confirmed =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Начать с пустого облака'),
              content: const Text(
                'Kopim сначала создаст backup локальных данных, затем очистит активное локальное рабочее пространство и только после этого переключится на новый пустой облачный профиль. Локальные финансовые данные не будут загружены в облако автоматически.',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Отмена'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Продолжить'),
                ),
              ],
            );
          },
        ) ??
        false;
    if (!confirmed || !context.mounted) {
      return;
    }

    await ref
        .read(cloudActivationExecutionControllerProvider.notifier)
        .confirmStartWithEmptyCloud();
  }

  Future<void> _handleChoice(
    BuildContext context,
    WidgetRef ref,
    CloudActivationDecisionState state,
    CloudActivationDecisionOption option,
  ) async {
    switch (option.availability) {
      case CloudActivationChoiceAvailability.available:
        if (option.choice == CloudActivationChoice.stayLocalOnly) {
          ref.read(cloudActivationIntentProvider.notifier).clearPendingChoice();
          final ScaffoldMessengerState messenger = ScaffoldMessenger.of(
            context,
          );
          _dismiss(context);
          messenger.showSnackBar(
            const SnackBar(
              content: Text(
                'Остаёмся в локальном режиме. Данные и подключение не менялись.',
              ),
            ),
          );
          return;
        }
        _savePendingChoice(ref, state, option);
        _showPendingChoiceSnackBar(context, option);
        return;
      case CloudActivationChoiceAvailability.requiresConfirmation:
        final bool confirmed =
            await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(option.title),
                  content: Text(
                    option.followupNote ??
                        'На этом шаге выбор только фиксирует направление следующего этапа без изменения данных.',
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Отмена'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Понятно'),
                    ),
                  ],
                );
              },
            ) ??
            false;
        if (!context.mounted) {
          return;
        }
        if (confirmed) {
          _savePendingChoice(ref, state, option);
          _showPendingChoiceSnackBar(context, option);
        }
        return;
      case CloudActivationChoiceAvailability.unavailableForCurrentScenario:
      case CloudActivationChoiceAvailability.unavailableUntilExecutionFlow:
        _showPlaceholderSnackBar(context, option);
        return;
    }
  }

  void _savePendingChoice(
    WidgetRef ref,
    CloudActivationDecisionState state,
    CloudActivationDecisionOption option,
  ) {
    ref
        .read(cloudActivationIntentProvider.notifier)
        .savePendingChoice(choice: option.choice, decisionState: state);
  }

  void _showPendingChoiceSnackBar(
    BuildContext context,
    CloudActivationDecisionOption option,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          option.followupNote ??
              'Выбор сохранён для следующего этапа. Данные и подключение пока не менялись.',
        ),
      ),
    );
  }

  String _successMessage(CloudActivationExecutionResult result) {
    if (result.message != null && result.message!.trim().isNotEmpty) {
      return result.message!;
    }

    return 'Облачная синхронизация включена для пустого рабочего пространства.';
  }

  void _showPlaceholderSnackBar(
    BuildContext context,
    CloudActivationDecisionOption option,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          option.followupNote ??
              'Этот сценарий пока доступен только как подготовительный продуктовый выбор без изменения данных.',
        ),
      ),
    );
  }

  void _dismiss(BuildContext context) {
    final GoRouter? router = GoRouter.maybeOf(context);
    if (router != null && router.canPop()) {
      router.pop();
      return;
    }
    context.go('/');
  }

  String _executionMessage(CloudActivationExecutionResult result) {
    if (result.message != null && result.message!.trim().isNotEmpty) {
      return result.message!;
    }

    return switch (result.blockReason) {
      null => 'Не удалось завершить включение облака.',
      CloudActivationExecutionBlockReason.signInRequired =>
        'Сначала нужно войти в облачный аккаунт.',
      CloudActivationExecutionBlockReason.entitlementRequired =>
        'Для этого шага нужен активный cloud-доступ.',
      CloudActivationExecutionBlockReason.localNotEmpty =>
        'Локальное состояние изменилось: найден пользовательский контент или служебные следы, поэтому включение остановлено.',
      CloudActivationExecutionBlockReason.remoteMetadataPresent =>
        'В облаке уже есть metadata-состояние. Этот случай остаётся заблокированным до отдельного этапа.',
      CloudActivationExecutionBlockReason.remoteNotEmpty =>
        'Удалённое состояние больше не пустое, поэтому включение не выполняется автоматически.',
      CloudActivationExecutionBlockReason.remotePermissionDenied =>
        'Не удалось безопасно прочитать облачное состояние из-за прав доступа.',
      CloudActivationExecutionBlockReason.remoteUnavailable =>
        'Облачное состояние сейчас недоступно. Попробуйте ещё раз позже.',
      CloudActivationExecutionBlockReason.staleReadiness =>
        'Состояние изменилось после выбора сценария. Пройдите readiness/choice ещё раз.',
      CloudActivationExecutionBlockReason.alreadyCloudEnabled =>
        'Облачная синхронизация уже включена для текущего аккаунта.',
      CloudActivationExecutionBlockReason.activationInProgress =>
        'Включение уже выполняется.',
      CloudActivationExecutionBlockReason.capabilitiesDisabled =>
        'Текущая сборка не поддерживает облачную синхронизацию.',
      CloudActivationExecutionBlockReason.pendingIntentMissing ||
      CloudActivationExecutionBlockReason.invalidPendingIntent =>
        'Сначала заново выберите сценарий включения.',
      CloudActivationExecutionBlockReason.backupExportFailed =>
        'Не удалось создать backup локальных данных. Локальное рабочее пространство не менялось.',
      CloudActivationExecutionBlockReason.localResetFailed =>
        'Backup создан, но локальное рабочее пространство не удалось безопасно очистить. Облако не было включено автоматически.',
      CloudActivationExecutionBlockReason.migrationReadinessBlocked =>
        'Не пройдены проверки готовности к миграции.',
      CloudActivationExecutionBlockReason.migrationExecutionNotImplemented =>
        'Перенос данных в облако ещё не поддерживается.',
      CloudActivationExecutionBlockReason.runtimeTransitionFailed =>
        'Флаг активации сохранён, но приложение не смогло безопасно перейти в облачный режим. При следующем входе проверки будут повторены.',
      CloudActivationExecutionBlockReason.migrationNetworkRetryable =>
        'Ошибка сети при миграции. Проверьте подключение и повторите попытку.',
      CloudActivationExecutionBlockReason.migrationRemoteOccupied =>
        'Облако уже занято другой миграцией или содержит существующие данные.',
      CloudActivationExecutionBlockReason.migrationPayloadMismatch =>
        'Несоответствие данных при проверке remote/local payload.',
      CloudActivationExecutionBlockReason.migrationUidChanged =>
        'UID пользователя изменился во время миграции.',
      CloudActivationExecutionBlockReason.migrationLocalDataChanged =>
        'Локальные данные изменились. Пройдите проверку готовности заново.',
      CloudActivationExecutionBlockReason.migrationConversionIntegrityFailed =>
        'Ошибка проверки целостности локальной базы данных после конверсии.',
      CloudActivationExecutionBlockReason.migrationUnknownFailure =>
        'Неизвестная ошибка во время выполнения миграции.',
    };
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          message,
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.option,
    required this.isSelected,
    required this.onPressed,
  });

  final CloudActivationDecisionOption option;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String availabilityLabel = switch (option.availability) {
      CloudActivationChoiceAvailability.available => 'Доступно',
      CloudActivationChoiceAvailability.requiresConfirmation =>
        'Нужно подтверждение',
      CloudActivationChoiceAvailability.unavailableForCurrentScenario =>
        'Пока недоступно',
      CloudActivationChoiceAvailability.unavailableUntilExecutionFlow =>
        'Следующий этап',
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                Text(option.title, style: theme.textTheme.titleMedium),
                Chip(label: Text(availabilityLabel)),
                if (isSelected) const Chip(label: Text('Выбрано')),
              ],
            ),
            const SizedBox(height: 12),
            Text(option.body, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton(
                onPressed: onPressed,
                child: const Text('Выбрать'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
