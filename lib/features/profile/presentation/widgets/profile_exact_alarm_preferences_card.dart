import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/services/notifications_gateway.dart';
import 'package:kopim/features/settings/presentation/controllers/exact_alarm_controller.dart';
import 'package:kopim/l10n/app_localizations.dart';

class ProfileExactAlarmPreferencesCard extends ConsumerStatefulWidget {
  const ProfileExactAlarmPreferencesCard({super.key});

  @override
  ConsumerState<ProfileExactAlarmPreferencesCard> createState() =>
      _ProfileExactAlarmPreferencesCardState();
}

class _ProfileExactAlarmPreferencesCardState
    extends ConsumerState<ProfileExactAlarmPreferencesCard>
    with WidgetsBindingObserver {
  bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isAndroid || state != AppLifecycleState.resumed) {
      return;
    }
    unawaited(ref.read(exactAlarmControllerProvider.notifier).refresh());
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAndroid) {
      return const SizedBox.shrink();
    }

    final AppLocalizations strings = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final AsyncValue<bool> exactAlarmState = ref.watch(
      exactAlarmControllerProvider,
    );
    final ExactAlarmController controller = ref.read(
      exactAlarmControllerProvider.notifier,
    );
    final NotificationsGateway notifications = ref.read(
      notificationsGatewayProvider,
    );

    Future<void> openSettings() async {
      await controller.request();
    }

    Future<void> refreshStatus() async {
      await controller.refresh();
    }

    Future<void> sendTestNotification() async {
      await notifications.showTestNotification();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(Icons.alarm_on_outlined, color: colors.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    strings.settingsNotificationsExactTitle,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    strings.settingsNotificationsExactSubtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: strings.settingsNotificationsRetryTooltip,
              onPressed: refreshStatus,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        const SizedBox(height: 16),
        exactAlarmState.when(
          data: (bool enabled) {
            if (enabled) {
              return _ExactAlarmStatusBlock(
                title: strings.recurringExactAlarmEnabledTitle,
                subtitle: strings.recurringExactAlarmEnabledSubtitle,
                action: OutlinedButton.icon(
                  onPressed: sendTestNotification,
                  icon: const Icon(Icons.notifications_active_outlined),
                  label: Text(strings.settingsNotificationsTestCta),
                ),
              );
            }
            return _ExactAlarmStatusBlock(
              title: strings.recurringExactAlarmPromptTitle,
              subtitle: strings.recurringExactAlarmPromptSubtitle,
              action: FilledButton.icon(
                onPressed: openSettings,
                icon: const Icon(Icons.open_in_new),
                label: Text(strings.recurringExactAlarmPromptCta),
              ),
            );
          },
          loading: () => const LinearProgressIndicator(),
          error: (Object error, StackTrace stackTrace) {
            return _ExactAlarmStatusBlock(
              title: strings.recurringExactAlarmErrorTitle,
              subtitle: strings.settingsNotificationsExactError(
                error.toString(),
              ),
              action: FilledButton(
                onPressed: refreshStatus,
                child: Text(strings.recurringExactAlarmRetryCta),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ExactAlarmStatusBlock extends StatelessWidget {
  const _ExactAlarmStatusBlock({
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
