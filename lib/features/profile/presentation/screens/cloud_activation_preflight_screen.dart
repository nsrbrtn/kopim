import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kopim/core/config/app_runtime.dart';
import 'package:kopim/features/profile/presentation/controllers/auth_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/cloud_activation_decision_controller.dart';
import 'package:kopim/core/config/app_capabilities.dart';
import 'package:kopim/features/app_shell/presentation/widgets/main_navigation_shell.dart';
import 'package:kopim/features/profile/presentation/controllers/cloud_activation_preflight_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/data_mode_controller.dart';
import 'package:kopim/features/profile/presentation/screens/cloud_access_status_screen.dart';
import 'package:kopim/features/profile/presentation/screens/cloud_activation_choice_screen.dart';
import 'package:kopim/features/profile/presentation/screens/cloud_sync_intro_screen.dart';
import 'package:kopim/features/profile/presentation/screens/sign_in_screen.dart';

class CloudActivationPreflightScreen extends ConsumerStatefulWidget {
  const CloudActivationPreflightScreen({
    super.key,
    this.autoAdvance = false,
    this.fallbackToHome = false,
  });

  static const String routeName = '/cloud-activation-preflight';
  static String buildRouteLocation({
    bool autoAdvance = false,
    bool fallbackToHome = false,
  }) {
    final Uri uri = Uri(
      path: routeName,
      queryParameters: <String, String>{
        if (autoAdvance) 'autoAdvance': 'true',
        if (fallbackToHome) 'fallbackToHome': 'true',
      },
    );
    return uri.toString();
  }

  final bool autoAdvance;
  final bool fallbackToHome;

  @override
  ConsumerState<CloudActivationPreflightScreen> createState() =>
      _CloudActivationPreflightScreenState();
}

class _CloudActivationPreflightScreenState
    extends ConsumerState<CloudActivationPreflightScreen> {
  bool _autoAdvanceHandled = false;
  bool _autoAdvanceScheduled = false;

  @override
  Widget build(BuildContext context) {
    ref.listen<CloudActivationPreflightState>(
      cloudActivationPreflightProvider,
      (_, CloudActivationPreflightState next) {
        _scheduleAutoAdvance(next);
      },
    );

    final ThemeData theme = Theme.of(context);
    final AppCapabilities capabilities = ref.watch(appCapabilitiesProvider);
    final CloudActivationPreflightState state = ref.watch(
      cloudActivationPreflightProvider,
    );
    _scheduleAutoAdvance(state);
    final AsyncValue<dynamic> authState = ref.watch(authControllerProvider);
    final DataModeState? dataModeState = ref
        .watch(dataModeControllerProvider)
        .asData
        ?.value;
    final bool hasExpiredAccess =
        dataModeState?.entitlementState == CloudEntitlementState.expired;
    final bool showTransitionLoading =
        widget.autoAdvance &&
        _isWaitingForPostLoginState(
          preflightState: state,
          authState: authState,
        );
    final CloudActivationPreflightStatus effectiveStatus = showTransitionLoading
        ? CloudActivationPreflightStatus.unknown
        : state.status;

    final _PreflightContent content = switch (effectiveStatus) {
      CloudActivationPreflightStatus.cloudUnavailableInBuild =>
        const _PreflightContent(
          icon: Icons.cloud_off_outlined,
          title: 'Облачные функции недоступны',
          body:
              'Эта сборка работает только локально. Подключение облачной синхронизации здесь недоступно.',
        ),
      CloudActivationPreflightStatus.signedOut =>
        capabilities.canRegisterInApp
            ? const _PreflightContent(
                icon: Icons.login_outlined,
                title: 'Нужен вход в аккаунт',
                body:
                    'Лицензионный ключ уже активирован. Войдите в аккаунт, чтобы продолжить подключение облачных функций.',
                primaryLabel: 'Войти в аккаунт',
              )
            : const _PreflightContent(
                icon: Icons.login_outlined,
                title: 'Нужен вход в аккаунт',
                body:
                    'Войдите в аккаунт с активным доступом, чтобы продолжить подключение облачной синхронизации.',
                primaryLabel: 'Войти в аккаунт',
              ),
      CloudActivationPreflightStatus.entitlementRequired =>
        capabilities.canActivatePromoOrLicenseInApp
            ? const _PreflightContent(
                icon: Icons.vpn_key_outlined,
                title: 'Сначала активируйте облачный доступ',
                body:
                    'Сейчас данные хранятся только на этом устройстве. Сначала активируйте облачный доступ, а затем вернитесь к подключению синхронизации.',
                primaryLabel: 'Проверить доступ',
                secondaryLabel: 'Вернуться',
              )
            : _PreflightContent(
                icon: Icons.sync_disabled_outlined,
                title: hasExpiredAccess
                    ? 'Срок доступа истек'
                    : 'Доступ не активен',
                body: hasExpiredAccess
                    ? 'Срок облачного доступа для текущего аккаунта истек. Синхронизация остается на паузе, пока статус доступа не будет обновлен. До этого можно продолжать работать локально.'
                    : 'Синхронизация останется выключенной, пока для текущего аккаунта не появится активный доступ. Проверьте статус доступа снова или продолжайте работать локально.',
                primaryLabel: 'Проверить доступ снова',
                secondaryLabel: 'Продолжить локально',
              ),
      CloudActivationPreflightStatus.blockedByLocalOnlyData =>
        const _PreflightContent(
          icon: Icons.warning_amber_outlined,
          title: 'Нужно действие перед синхронизацией',
          body:
              'Перед включением синхронизации нужно отдельно решить, что делать с локальными данными на этом устройстве. Автоматический перенос в этом этапе не выполняется.',
          primaryLabel: 'Выбрать сценарий',
          secondaryLabel: 'Понятно',
        ),
      CloudActivationPreflightStatus.readyForNextStep => const _PreflightContent(
        icon: Icons.cloud_queue_outlined,
        title: 'Подключение подготовлено',
        body:
            'Текущих блокеров для следующего безопасного шага не найдено. Сам шаг подключения будет реализован отдельно, без автоматического включения синхронизации на этом экране.',
        primaryLabel: 'Выбрать сценарий',
      ),
      CloudActivationPreflightStatus.alreadyCloudEnabled =>
        const _PreflightContent(
          icon: Icons.cloud_done_outlined,
          title: 'Синхронизация уже включена',
          body:
              'Облачные функции уже активны. Дополнительный preflight для этого аккаунта сейчас не требуется.',
          primaryLabel: 'Вернуться',
        ),
      CloudActivationPreflightStatus.unknown => const _PreflightContent(
        icon: Icons.cloud_sync_outlined,
        title: 'Проверяем состояние подключения',
        body:
            'Подождите немного, приложение уточняет состояние облачных функций перед следующим шагом.',
      ),
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Подключение облака')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    content.icon,
                    size: 40,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    content.title,
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    content.body,
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  if (effectiveStatus ==
                      CloudActivationPreflightStatus.unknown) ...<Widget>[
                    const SizedBox(height: 24),
                    const Center(child: CircularProgressIndicator()),
                  ],
                  if (content.primaryLabel != null) ...<Widget>[
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () =>
                          _handlePrimaryAction(context, ref, state),
                      child: Text(content.primaryLabel!),
                    ),
                  ],
                  if (content.secondaryLabel != null) ...<Widget>[
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => _dismiss(context),
                      child: Text(content.secondaryLabel!),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handlePrimaryAction(
    BuildContext context,
    WidgetRef ref,
    CloudActivationPreflightState state,
  ) {
    final AppCapabilities capabilities = ref.read(appCapabilitiesProvider);
    switch (state.status) {
      case CloudActivationPreflightStatus.signedOut:
        if (!capabilities.canRegisterInApp &&
            capabilities.allowsLocalOnlyUsage) {
          context.push(CloudSyncIntroScreen.routeName);
          return;
        }
        context.push(
          SignInScreen.buildRouteLocation(resumeCloudActivation: true),
        );
        return;
      case CloudActivationPreflightStatus.blockedByLocalOnlyData:
      case CloudActivationPreflightStatus.readyForNextStep:
        if (canOpenCloudActivationChoiceScreen(state.status)) {
          context.push(CloudActivationChoiceScreen.routeName);
          return;
        }
      case CloudActivationPreflightStatus.entitlementRequired:
        if (!capabilities.canActivatePromoOrLicenseInApp) {
          context.push(CloudAccessStatusScreen.routeName);
          return;
        }
        _refreshEntitlement(context, ref);
        return;
      case CloudActivationPreflightStatus.alreadyCloudEnabled:
      case CloudActivationPreflightStatus.cloudUnavailableInBuild:
      case CloudActivationPreflightStatus.unknown:
        _dismiss(context);
        return;
    }
  }

  Future<void> _refreshEntitlement(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(dataModeControllerProvider.notifier).refreshEntitlement();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Статус доступа успешно обновлен')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не удалось обновить статус доступа: $e')),
        );
      }
    }
  }

  void _dismiss(BuildContext context) {
    final GoRouter? router = GoRouter.maybeOf(context);
    if (router != null && router.canPop()) {
      router.pop();
      return;
    }
    context.go('/');
  }

  bool _isWaitingForPostLoginState({
    required CloudActivationPreflightState preflightState,
    required AsyncValue<dynamic> authState,
  }) {
    if (preflightState.status == CloudActivationPreflightStatus.unknown) {
      return true;
    }
    if (preflightState.status != CloudActivationPreflightStatus.signedOut) {
      return false;
    }
    if (authState.isLoading) {
      return true;
    }
    return authState.asData?.value != null;
  }

  void _maybeAutoAdvance(CloudActivationPreflightState state) {
    if (!widget.autoAdvance || _autoAdvanceHandled || !mounted) {
      return;
    }

    final AppCapabilities capabilities = ref.read(appCapabilitiesProvider);
    switch (state.status) {
      case CloudActivationPreflightStatus.blockedByLocalOnlyData:
      case CloudActivationPreflightStatus.readyForNextStep:
        _autoAdvanceHandled = true;
        context.go(CloudActivationChoiceScreen.routeName);
        return;
      case CloudActivationPreflightStatus.entitlementRequired:
        if (!capabilities.canActivatePromoOrLicenseInApp) {
          _autoAdvanceHandled = true;
          context.go(CloudAccessStatusScreen.routeName);
        }
        return;
      case CloudActivationPreflightStatus.alreadyCloudEnabled:
      case CloudActivationPreflightStatus.cloudUnavailableInBuild:
        if (widget.fallbackToHome) {
          _autoAdvanceHandled = true;
          context.go(MainNavigationShell.routeName);
        }
        return;
      case CloudActivationPreflightStatus.signedOut:
      case CloudActivationPreflightStatus.unknown:
        return;
    }
  }

  void _scheduleAutoAdvance(CloudActivationPreflightState state) {
    if (!widget.autoAdvance || _autoAdvanceHandled || _autoAdvanceScheduled) {
      return;
    }
    _autoAdvanceScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoAdvanceScheduled = false;
      if (!mounted) {
        return;
      }
      _maybeAutoAdvance(state);
    });
  }
}

class _PreflightContent {
  const _PreflightContent({
    required this.icon,
    required this.title,
    required this.body,
    this.primaryLabel,
    this.secondaryLabel,
  });

  final IconData icon;
  final String title;
  final String body;
  final String? primaryLabel;
  final String? secondaryLabel;
}
