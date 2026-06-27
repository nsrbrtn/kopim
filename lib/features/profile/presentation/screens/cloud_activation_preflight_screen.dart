import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kopim/features/profile/presentation/controllers/cloud_activation_decision_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/cloud_activation_preflight_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/data_mode_controller.dart';
import 'package:kopim/features/profile/presentation/screens/cloud_activation_choice_screen.dart';
import 'package:kopim/features/profile/presentation/screens/sign_in_screen.dart';

class CloudActivationPreflightScreen extends ConsumerWidget {
  const CloudActivationPreflightScreen({super.key});

  static const String routeName = '/cloud-activation-preflight';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final CloudActivationPreflightState state = ref.watch(
      cloudActivationPreflightProvider,
    );

    final _PreflightContent content = switch (state.status) {
      CloudActivationPreflightStatus.cloudUnavailableInBuild =>
        const _PreflightContent(
          icon: Icons.cloud_off_outlined,
          title: 'Облачные функции недоступны',
          body:
              'Эта сборка работает только локально. Подключение облачной синхронизации здесь недоступно.',
        ),
      CloudActivationPreflightStatus.signedOut => const _PreflightContent(
        icon: Icons.login_outlined,
        title: 'Нужен вход в аккаунт',
        body:
            'Лицензионный ключ уже активирован. Войдите в аккаунт, чтобы продолжить подключение облачных функций.',
        primaryLabel: 'Войти в аккаунт',
      ),
      CloudActivationPreflightStatus.entitlementRequired =>
        const _PreflightContent(
          icon: Icons.vpn_key_outlined,
          title: 'Сначала активируйте облачный доступ',
          body:
              'Сейчас данные хранятся только на этом устройстве. Сначала активируйте облачный доступ, а затем вернитесь к подключению синхронизации.',
          primaryLabel: 'Проверить доступ',
          secondaryLabel: 'Вернуться',
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
                  if (state.status ==
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
    switch (state.status) {
      case CloudActivationPreflightStatus.signedOut:
        context.push(SignInScreen.routeName);
        return;
      case CloudActivationPreflightStatus.blockedByLocalOnlyData:
      case CloudActivationPreflightStatus.readyForNextStep:
        if (canOpenCloudActivationChoiceScreen(state.status)) {
          context.push(CloudActivationChoiceScreen.routeName);
          return;
        }
      case CloudActivationPreflightStatus.entitlementRequired:
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
