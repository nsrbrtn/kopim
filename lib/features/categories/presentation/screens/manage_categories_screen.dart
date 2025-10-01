import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kopim/l10n/app_localizations.dart';

/// Screen that will host category creation and editing flows.
class ManageCategoriesScreen extends ConsumerWidget {
  const ManageCategoriesScreen({super.key});

  static const String routeName = '/categories/manage';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(strings.profileManageCategoriesTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            strings.profileManageCategoriesPlaceholder,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
