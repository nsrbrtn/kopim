import 'package:flutter/material.dart';

import 'package:kopim/features/categories/presentation/screens/manage_categories_screen.dart';
import 'package:kopim/features/recurring_transactions/presentation/screens/recurring_transactions_screen.dart';
import 'package:kopim/l10n/app_localizations.dart';

class GeneralSettingsScreen extends StatelessWidget {
  const GeneralSettingsScreen({super.key});

  static const String routeName = '/settings/general';

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(strings.profileGeneralSettingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: <Widget>[
          _SettingsTile(
            icon: Icons.category_outlined,
            title: strings.profileManageCategoriesCta,
            onTap: () {
              Navigator.of(context).pushNamed(ManageCategoriesScreen.routeName);
            },
          ),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.repeat,
            title: strings.profileRecurringTransactionsCta,
            onTap: () {
              Navigator.of(
                context,
              ).pushNamed(RecurringTransactionsScreen.routeName);
            },
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Icon(icon),
        title: Text(title, style: theme.textTheme.titleMedium),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
