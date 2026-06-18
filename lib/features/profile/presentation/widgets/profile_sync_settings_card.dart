// lib/features/profile/presentation/widgets/profile_sync_settings_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kopim/core/config/app_runtime.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/profile/presentation/controllers/data_mode_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/auth_controller.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';

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

    // В офлайн-сборке показываем простой информационный блок
    if (AppRuntimeConfig.isOfflineOnlyDistribution) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.cloud_off_outlined, color: iconColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Облако и синхронизация',
                  style: theme.textTheme.titleMedium,
                ),
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
      error: (Object error, _) => Text('Ошибка: $error'),
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
                      'Активация синхронизации',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Для включения облачных функций введите лицензионный ключ.',
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

        // Шаг 2: Ключ активен, но синхронизация localOnly
        if (mode == DataMode.localOnly) {
          final AuthUser? currentCloudUser = ref
              .watch(cloudAuthRepositoryProvider)
              .currentUser;

          // Пользователь залогинен, но обнаружены локальные данные (CloudMigrationRequired)
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
                        'Внимание',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Локальные данные обнаружены. Автоматическая синхронизация заблокирована. Перенос данных в облако будет реализован в следующем обновлении.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {
                    // Возвращаемся в чистый локальный режим (выходим из облачного аккаунта)
                    ref.read(authControllerProvider.notifier).signOut();
                  },
                  child: const Text('Остаться в локальном режиме'),
                ),
              ],
            );
          }

          // Пользователь еще не вошел в облако
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(Icons.cloud_queue_outlined, color: iconColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Облачный аккаунт',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Ключ синхронизации успешно активирован. Войдите в свой облачный аккаунт для включения синхронизации.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Перенаправляем на экран входа.
                  // Поскольку в данном тике мы не меняем роутинг,
                  // мы можем просто открыть стандартный диалог логина или перейти на экран.
                  // Обычно роут входа: '/auth/signin' или '/signin'
                  Navigator.of(context).pushNamed('/signin');
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
                    'Облако активно',
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
