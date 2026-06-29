import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:kopim/features/profile/presentation/screens/sign_in_screen.dart';

class CloudSyncIntroScreen extends StatelessWidget {
  const CloudSyncIntroScreen({super.key});

  static const String routeName = '/cloud-sync-intro';

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Подключение синхронизации')),
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
                    Icons.cloud_sync_outlined,
                    size: 40,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Включить синхронизацию',
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Войдите в аккаунт с активным доступом, чтобы подключить облачную синхронизацию.',
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => context.push(
                      SignInScreen.buildRouteLocation(
                        resumeCloudActivation: true,
                      ),
                    ),
                    child: const Text('Войти в аккаунт'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => context.pop(),
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
