// lib/features/profile/presentation/widgets/profile_sync_settings_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kopim/core/config/app_capabilities.dart';
import 'package:kopim/core/config/app_runtime.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/profile/presentation/controllers/auth_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/data_mode_controller.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/presentation/screens/sign_in_screen.dart';

class ProfileSyncSettingsCard extends ConsumerStatefulWidget {
  const ProfileSyncSettingsCard({super.key});

  @override
  ConsumerState<ProfileSyncSettingsCard> createState() =>
      _ProfileSyncSettingsCardState();
}

class _ProfileSyncSettingsCardState
    extends ConsumerState<ProfileSyncSettingsCard> {
  final TextEditingController _keyController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _activateKey() async {
    final String key = _keyController.text.trim();
    if (key.isEmpty) {
      setState(() {
        _errorMessage = 'Введите лицензионный ключ';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref
          .read(dataModeControllerProvider.notifier)
          .activateEntitlementKey(key);
      _keyController.clear();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color iconColor = theme.colorScheme.onSurfaceVariant;
    final AppCapabilities capabilities = ref.watch(appCapabilitiesProvider);

    // В офлайн-сборке показываем простой информационный блок
    if (!capabilities.canRunCloudSync) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.cloud_off_outlined, color: iconColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Локально', style: theme.textTheme.titleMedium),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Сейчас Kopim хранит данные только на этом устройстве. Облачная синхронизация выключена.',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      );
    }

    // В облачной сборке получаем состояние режима данных
    final AsyncValue<DataModeState> dataModeAsync = ref.watch(
      dataModeControllerProvider,
    );

    return dataModeAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  Icons.sync_problem_outlined,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Ошибка синхронизации',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Не удалось получить состояние синхронизации. Попробуйте открыть экран позже.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text('$error', style: theme.textTheme.bodySmall),
          ],
        );
      },
      data: (DataModeState stateData) {
        final CloudEntitlementState entitlement = stateData.entitlementState;
        final DataMode mode = stateData.dataMode;

        // Шаг 1: Если ключ не активирован
        if (entitlement != CloudEntitlementState.active) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(Icons.vpn_key_outlined, color: iconColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Синхронизация выключена',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Сейчас данные хранятся только на этом устройстве. Чтобы включить облачные функции, введите лицензионный ключ.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _keyController,
                decoration: InputDecoration(
                  labelText: 'Лицензионный ключ',
                  errorText: _errorMessage,
                  border: const OutlineInputBorder(),
                ),
                enabled: !_isLoading,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _isLoading ? null : _activateKey,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Активировать'),
              ),
            ],
          );
        }

        if (mode == DataMode.cloudBlockedByLocalData) {
          final AuthUser? currentCloudUser = ref
              .watch(cloudAuthRepositoryProvider)
              .currentUser;

          if (currentCloudUser != null) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.warning_amber_outlined,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Нужно действие',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Вход в облачный аккаунт выполнен, но синхронизация заблокирована: в локальной базе уже есть данные, которые нельзя безопасно отправить в облако без отдельного решения.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {
                    ref.read(authControllerProvider.notifier).signOut();
                  },
                  child: const Text('Остаться в локальном режиме'),
                ),
              ],
            );
          }
        }

        // Шаг 2: Ключ активен, но синхронизация localOnly
        if (mode == DataMode.localOnly) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(Icons.cloud_queue_outlined, color: iconColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Синхронизация выключена',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Лицензионный ключ активирован. Войдите в аккаунт, чтобы включить синхронизацию.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(SignInScreen.routeName);
                },
                child: const Text('Войти в аккаунт'),
              ),
            ],
          );
        }

        // Шаг 3: Синхронизация включена (cloudEnabled)
        final AuthUser? currentCloudUser = ref
            .watch(cloudAuthRepositoryProvider)
            .currentUser;
        final String email = currentCloudUser?.email ?? 'Активен';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  Icons.cloud_done_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Синхронизация включена',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Синхронизация активна для аккаунта:\n$email',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                ref.read(authControllerProvider.notifier).signOut();
              },
              child: const Text('Выйти из облака'),
            ),
          ],
        );
      },
    );
  }
}
