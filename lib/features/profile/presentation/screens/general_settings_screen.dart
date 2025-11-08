import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kopim/features/home/domain/entities/home_dashboard_preferences.dart';
import 'package:kopim/features/home/presentation/controllers/home_dashboard_preferences_controller.dart';
import 'package:kopim/features/profile/presentation/widgets/home_dashboard_visibility_card.dart';
import 'package:kopim/l10n/app_localizations.dart';

class GeneralSettingsScreen extends ConsumerWidget {
  const GeneralSettingsScreen({super.key});

  static const String routeName = '/settings/general';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final AsyncValue<HomeDashboardPreferences> preferencesAsync = ref.watch(
      homeDashboardPreferencesControllerProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.profileGeneralSettingsTitle),
      ),
      body: SafeArea(
        child: preferencesAsync.when(
          data: (HomeDashboardPreferences preferences) => ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              HomeDashboardVisibilityCard(
                strings: strings,
                preferences: preferences,
                onToggleGamification: (bool value) => ref
                    .read(homeDashboardPreferencesControllerProvider.notifier)
                    .setShowGamification(value),
                onToggleBudget: (bool value) => ref
                    .read(homeDashboardPreferencesControllerProvider.notifier)
                    .setShowBudget(value),
                onToggleRecurring: (bool value) => ref
                    .read(homeDashboardPreferencesControllerProvider.notifier)
                    .setShowRecurring(value),
                onToggleSavings: (bool value) => ref
                    .read(homeDashboardPreferencesControllerProvider.notifier)
                    .setShowSavings(value),
              ),
            ],
          ),
          loading: () => const _SettingsSkeleton(),
          error: (Object error, _) => _SettingsErrorMessage(
            message: strings.homeDashboardPreferencesError(
              error.toString(),
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsSkeleton extends StatelessWidget {
  const _SettingsSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _SettingsErrorMessage extends StatelessWidget {
  const _SettingsErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        message,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.error,
        ),
      ),
    );
  }
}
