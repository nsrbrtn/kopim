import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kopim/features/app_shell/presentation/widgets/main_navigation_shell.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/profile/presentation/controllers/data_mode_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/feature_access_provider.dart';
import 'package:kopim/features/profile/presentation/screens/sign_in_screen.dart';

class WebEntitlementGateScreen extends ConsumerStatefulWidget {
  const WebEntitlementGateScreen({super.key});

  @override
  ConsumerState<WebEntitlementGateScreen> createState() =>
      _WebEntitlementGateScreenState();
}

class _WebEntitlementGateScreenState
    extends ConsumerState<WebEntitlementGateScreen> {
  bool _isRefreshing = false;
  bool _isSigningOut = false;
  String? _errorMessage;

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

      final FeatureGate nextGate = ref.read(featureAccessProvider).webApp;
      if (nextGate.status == FeatureAccessStatus.enabled) {
        context.go(MainNavigationShell.routeName);
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

  Future<void> _signOut() async {
    setState(() {
      _isSigningOut = true;
      _errorMessage = null;
    });

    try {
      await ref.read(cloudAuthRepositoryProvider).signOut();
      if (!mounted) {
        return;
      }
      context.go(SignInScreen.routeName);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = 'Не удалось выйти из аккаунта: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSigningOut = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final FeatureAccess access = ref.watch(featureAccessProvider);
    final bool isExpired =
        access.entitlementState == EntitlementAccessState.cloudExpired;
    final bool isBusy = _isRefreshing || _isSigningOut;

    final IconData icon = _isRefreshing
        ? Icons.cloud_sync_outlined
        : isExpired
        ? Icons.lock_clock_outlined
        : Icons.cloud_off_outlined;
    final String title = _isRefreshing
        ? 'Проверяем доступ'
        : isExpired
        ? 'Срок доступа истек'
        : 'Доступ к веб-версии не активен';
    final String body = _isRefreshing
        ? 'Подождите немного, приложение обновляет статус облачного доступа для текущего аккаунта.'
        : isExpired
        ? 'Срок доступа для этого аккаунта истек. Веб-версия остается в fail-closed barrier состоянии: редактирование и синхронизация недоступны, пока доступ не будет обновлен.'
        : 'Для этого аккаунта пока нет активного доступа к веб-версии. Проверьте статус снова или выйдите, чтобы войти под другим аккаунтом.';

    return Scaffold(
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
                  Icon(icon, size: 40, color: theme.colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    body,
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
                    onPressed: isBusy ? null : _refreshAccess,
                    child: const Text('Проверить доступ снова'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: isBusy ? null : _signOut,
                    child: const Text('Выйти из аккаунта'),
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
