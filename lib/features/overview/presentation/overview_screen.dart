import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kopim/features/overview/presentation/overview_settings_screen.dart';
import 'package:kopim/l10n/app_localizations.dart';

class OverviewScreen extends ConsumerWidget {
  const OverviewScreen({super.key});

  static const String routeName = '/overview';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.overviewScreenTitle),
        actions: <Widget>[
          IconButton(
            tooltip: strings.overviewSettingsTooltip,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(OverviewSettingsScreen.routeName),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            strings.overviewScreenPlaceholder,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
