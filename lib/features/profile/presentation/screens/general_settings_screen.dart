import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kopim/features/profile/presentation/widgets/profile_theme_preferences_card.dart';
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
