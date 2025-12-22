import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kopim/core/theme/application/theme_mode_controller.dart';
import 'package:kopim/core/theme/domain/app_theme_mode.dart';
import 'package:kopim/l10n/app_localizations.dart';

class ProfileThemePreferencesCard extends ConsumerWidget {
  const ProfileThemePreferencesCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final AppThemeMode mode = ref.watch(themeModeControllerProvider);
    final ThemeModeController controller = ref.read(
      themeModeControllerProvider.notifier,
    );
    final ThemeData theme = Theme.of(context);
    final bool isDark = mode.maybeWhen(dark: () => true, orElse: () => false);
    final Color iconColor = theme.colorScheme.onSurfaceVariant;
    final String subtitle = isDark
        ? strings.profileThemeDarkDescription
        : strings.profileThemeLightDescription;

    void handleToggle(bool value) {
      final AppThemeMode target = value
          ? const AppThemeMode.dark()
          : const AppThemeMode.light();
      unawaited(controller.setMode(target));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(Icons.dark_mode_outlined, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    strings.profileThemeHeader,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(value: isDark, onChanged: handleToggle),
          ],
        ),
      ],
    );
  }
}
