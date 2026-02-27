import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kopim/features/profile/presentation/widgets/profile_theme_preferences_card.dart';
import 'package:kopim/features/settings/presentation/controllers/exact_alarm_controller.dart';
import 'package:kopim/l10n/app_localizations.dart';

class GeneralSettingsScreen extends ConsumerWidget {
  const GeneralSettingsScreen({super.key});

  static const String routeName = '/settings/general';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(strings.profileGeneralSettingsTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            const _SettingsSectionContainer(
              child: ProfileThemePreferencesCard(),
            ),
            const SizedBox(height: 16),
            const _ExactRemindersSection(),
          ],
        ),
      ),
    );
  }
}

class _SettingsSectionContainer extends StatelessWidget {
  const _SettingsSectionContainer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color background = theme.colorScheme.surfaceContainerHighest
        .withAlpha((255 * (isDark ? 0.4 : 0.8)).round());
    return Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.all(24),
      child: child,
    );
  }
}

class _ExactRemindersSection extends ConsumerWidget {
  const _ExactRemindersSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final AsyncValue<bool> permissionAsync = ref.watch(
      exactAlarmControllerProvider,
    );
    final ThemeData theme = Theme.of(context);

    return _SettingsSectionContainer(
      child: permissionAsync.when(
        data: (bool isEnabled) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  Icons.notifications_active_outlined,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
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
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: isEnabled,
                  onChanged: (_) =>
                      ref.read(exactAlarmControllerProvider.notifier).request(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () =>
                    ref.read(exactAlarmControllerProvider.notifier).refresh(),
                icon: const Icon(Icons.refresh),
                label: Text(strings.settingsNotificationsRetryTooltip),
              ),
            ),
          ],
        ),
        loading: () => Row(
          children: <Widget>[
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text(strings.settingsNotificationsExactTitle),
          ],
        ),
        error: (Object error, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  Icons.notifications_active_outlined,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    strings.settingsNotificationsExactTitle,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              strings.settingsNotificationsExactError(error.toString()),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () =>
                    ref.read(exactAlarmControllerProvider.notifier).refresh(),
                icon: const Icon(Icons.refresh),
                label: Text(strings.settingsNotificationsRetryTooltip),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
