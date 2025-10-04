import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kopim/features/app_shell/presentation/models/navigation_tab_content.dart';
import 'package:kopim/features/profile/presentation/screens/general_settings_screen.dart';
import 'package:kopim/features/profile/presentation/widgets/profile_management_body.dart';
import 'package:kopim/l10n/app_localizations.dart';

/// Экран профиля в составе нижней навигации.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const String routeName = '/settings';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final NavigationTabContent content = buildProfileTabContent(context, ref);
    return Scaffold(
      appBar: content.appBarBuilder?.call(context, ref),
      body: content.bodyBuilder(context, ref),
      floatingActionButton: content.floatingActionButtonBuilder?.call(
        context,
        ref,
      ),
    );
  }
}

NavigationTabContent buildProfileTabContent(
  BuildContext context,
  WidgetRef ref,
) {
  return NavigationTabContent(
    appBarBuilder: (BuildContext context, WidgetRef ref) {
      final AppLocalizations strings = AppLocalizations.of(context)!;
      return AppBar(
        title: Text(strings.profileTitle),
        actions: <Widget>[
          IconButton(
            tooltip: strings.profileGeneralSettingsTooltip,
            icon: const Icon(Icons.tune),
            onPressed: () {
              Navigator.of(context).pushNamed(GeneralSettingsScreen.routeName);
            },
          ),
        ],
      );
    },
    bodyBuilder: (BuildContext context, WidgetRef ref) =>
        const ProfileManagementBody(),
  );
}
