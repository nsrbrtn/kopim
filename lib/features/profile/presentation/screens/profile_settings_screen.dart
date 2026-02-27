import 'package:flutter/material.dart';

import 'package:kopim/features/profile/presentation/widgets/profile_account_settings_card.dart';
import 'package:kopim/features/profile/presentation/widgets/profile_theme_preferences_card.dart';
import 'package:kopim/l10n/app_localizations.dart';

class ProfileSettingsScreen extends StatelessWidget {
  const ProfileSettingsScreen({super.key});

  static const String routeName = '/settings/profile';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profileSettingsTitle),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: const <Widget>[
            _ProfileSettingsSection(child: ProfileAccountSettingsCard()),
            SizedBox(height: 16),
            _ProfileSettingsSection(child: ProfileThemePreferencesCard()),
          ],
        ),
      ),
    );
  }
}

class _ProfileSettingsSection extends StatelessWidget {
  const _ProfileSettingsSection({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.all(24),
      child: child,
    );
  }
}
