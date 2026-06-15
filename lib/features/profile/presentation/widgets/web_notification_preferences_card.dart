import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/services/notifications_gateway.dart';
import 'package:kopim/core/services/push_permission_service.dart';
import 'package:kopim/l10n/app_localizations.dart';

class WebNotificationPreferencesCard extends ConsumerStatefulWidget {
  const WebNotificationPreferencesCard({super.key});

  @override
  ConsumerState<WebNotificationPreferencesCard> createState() =>
      _WebNotificationPreferencesCardState();
}

class _WebNotificationPreferencesCardState
    extends ConsumerState<WebNotificationPreferencesCard> {
  String _status = 'default';

  @override
  void initState() {
    super.initState();
    _updateStatus();
  }

  void _updateStatus() {
    if (!kIsWeb) return;
    final PushPermissionService pushPermissionService = ref.read(
      pushPermissionServiceProvider,
    );
    setState(() {
      _status = pushPermissionService.permissionStatus;
    });
  }

  Future<void> _requestPermission() async {
    final PushPermissionService pushPermissionService = ref.read(
      pushPermissionServiceProvider,
    );
    await pushPermissionService.ensurePermission(requestIfNeeded: true);
    _updateStatus();
  }

  Future<void> _sendTestNotification() async {
    final NotificationsGateway notifications = ref.read(
      notificationsGatewayProvider,
    );
    await notifications.showTestNotification();
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return const SizedBox.shrink();
    }

    final AppLocalizations strings = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(Icons.notifications_outlined, color: colors.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Уведомления браузера',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Получайте напоминания о предстоящих платежах прямо в браузере.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: strings.settingsNotificationsRetryTooltip,
              onPressed: _updateStatus,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildStatusBlock(strings, colors, theme),
      ],
    );
  }

  Widget _buildStatusBlock(
    AppLocalizations strings,
    ColorScheme colors,
    ThemeData theme,
  ) {
    if (_status == 'granted') {
      return _StatusBlock(
        title: 'Уведомления включены',
        subtitle: 'Вы будете получать напоминания в браузере.',
        action: OutlinedButton.icon(
          onPressed: _sendTestNotification,
          icon: const Icon(Icons.notifications_active_outlined),
          label: Text(strings.settingsNotificationsTestCta),
        ),
      );
    }

    if (_status == 'denied') {
      return const _StatusBlock(
        title: 'Доступ заблокирован',
        subtitle: 'Разрешите уведомления в настройках вашего браузера.',
        action: FilledButton(onPressed: null, child: Text('Заблокировано')),
      );
    }

    return _StatusBlock(
      title: 'Уведомления не настроены',
      subtitle: 'Включите уведомления, чтобы не пропустить важные платежи.',
      action: FilledButton.icon(
        onPressed: _requestPermission,
        icon: const Icon(Icons.notifications_active),
        label: const Text('Включить уведомления'),
      ),
    );
  }
}

class _StatusBlock extends StatelessWidget {
  const _StatusBlock({
    required this.title,
    required this.subtitle,
    required this.action,
  });

  final String title;
  final String subtitle;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface.withAlpha(120),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          action,
        ],
      ),
    );
  }
}
