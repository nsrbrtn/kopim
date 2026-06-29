import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kopim/core/config/app_runtime.dart';
import 'package:kopim/features/profile/presentation/controllers/data_mode_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/feature_access_provider.dart';
import 'package:kopim/features/profile/presentation/screens/cloud_activation_preflight_screen.dart';

class CloudAccessStatusScreen extends ConsumerStatefulWidget {
  const CloudAccessStatusScreen({super.key});

  static const String routeName = '/cloud-access-status';

  @override
  ConsumerState<CloudAccessStatusScreen> createState() =>
      _CloudAccessStatusScreenState();
}

class _CloudAccessStatusScreenState
    extends ConsumerState<CloudAccessStatusScreen> {
  bool _isRefreshing = false;
  String? _errorMessage;

  bool _hasExpiredAccess(WidgetRef ref) {
    final DataModeState? dataModeState = ref
        .watch(dataModeControllerProvider)
        .asData
        ?.value;
    return dataModeState?.entitlementState == CloudEntitlementState.expired;
  }

  Future<void> _refreshAccess() async {
    setState(() {
      _isRefreshing = true;
      _errorMessage = null;
    });

    try {
      await ref.read(dataModeControllerProvider.notifier).refreshEntitlement();
      if (!mounted) {
        return;
      }

      final FeatureAccessStatus nextStatus = ref
          .read(cloudSyncFeatureGateProvider)
          .status;
      if (nextStatus != FeatureAccessStatus.requiresEntitlement) {
        context.go(CloudActivationPreflightScreen.routeName);
        return;
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = 'Не удалось обновить статус доступа: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  void _continueLocal() {
    final GoRouter? router = GoRouter.maybeOf(context);
    if (router != null && router.canPop()) {
      router.pop();
      return;
    }
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool hasExpiredAccess = _hasExpiredAccess(ref);

    return Scaffold(
      appBar: AppBar(title: const Text('Статус доступа')),
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
                    _isRefreshing
                        ? Icons.cloud_sync_outlined
                        : hasExpiredAccess
                        ? Icons.history_toggle_off_outlined
                        : Icons.sync_disabled_outlined,
                    size: 40,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isRefreshing
                        ? 'Проверяем доступ'
                        : hasExpiredAccess
                        ? 'Срок доступа истек'
                        : 'Доступ не активен',
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isRefreshing
                        ? 'Подождите немного, приложение обновляет статус облачного доступа для текущего аккаунта.'
                        : hasExpiredAccess
                        ? 'Для текущего аккаунта срок облачного доступа истек. Синхронизация остается на паузе, но локальные данные на этом устройстве доступны. Проверьте статус снова, если доступ уже обновлен.'
                        : 'Войдите в аккаунт с активным доступом и проверьте статус снова. Пока можно продолжать работать локально на этом устройстве.',
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  if (_errorMessage != null) ...<Widget>[
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (_isRefreshing) ...<Widget>[
                    const SizedBox(height: 24),
                    const Center(child: CircularProgressIndicator()),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _isRefreshing ? null : _refreshAccess,
                    child: const Text('Проверить доступ снова'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _isRefreshing ? null : _continueLocal,
                    child: const Text('Вернуться'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
