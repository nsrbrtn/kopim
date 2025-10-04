import 'package:flutter/material.dart';

import 'package:kopim/features/categories/presentation/screens/manage_categories_screen.dart';
import 'package:kopim/features/profile/presentation/widgets/settings_button_theme.dart';
import 'package:kopim/features/recurring_transactions/presentation/screens/recurring_transactions_screen.dart';
import 'package:kopim/l10n/app_localizations.dart';

class GeneralSettingsScreen extends StatelessWidget {
  const GeneralSettingsScreen({super.key});

  static const String routeName = '/settings/general';

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(strings.profileGeneralSettingsTitle)),
      body: Theme(
        data: buildSettingsButtonTheme(theme),
        child: ListView(
          key: const PageStorageKey<String>('general-settings-sections'),
          padding: const EdgeInsets.all(24),
          children: <Widget>[
            _SettingsSection(
              title: strings.profileGeneralSettingsManagementSection,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pushNamed(ManageCategoriesScreen.routeName);
                    },
                    icon: const Icon(Icons.category_outlined),
                    label: Text(strings.profileManageCategoriesCta),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pushNamed(RecurringTransactionsScreen.routeName);
                    },
                    icon: const Icon(Icons.repeat),
                    label: Text(strings.profileRecurringTransactionsCta),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: PageStorageKey<String>('general-settings-$title'),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          initiallyExpanded: true,
          title: Text(title, style: theme.textTheme.titleMedium),
          children: <Widget>[child],
        ),
      ),
    );
  }
}
