import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kopim/features/app_shell/presentation/models/navigation_tab_content.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/presentation/controllers/auth_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/avatar_controller.dart';
import 'package:kopim/features/categories/presentation/screens/manage_categories_screen.dart';
import 'package:kopim/features/upcoming_payments/presentation/screens/upcoming_payments_screen.dart';
import 'package:kopim/features/profile/presentation/screens/general_settings_screen.dart';
import 'package:kopim/features/profile/presentation/widgets/profile_management_body.dart';
import 'package:kopim/l10n/app_localizations.dart';

final GlobalKey<NavigatorState> profileTabNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'profileTabNavigator');

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
    bodyBuilder: (BuildContext context, WidgetRef ref) =>
        _ProfileTabNavigator(navigatorKey: profileTabNavigatorKey),
  );
}

class _ProfileTabNavigator extends StatefulWidget {
  const _ProfileTabNavigator({required this.navigatorKey});

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  State<_ProfileTabNavigator> createState() => _ProfileTabNavigatorState();
}

class _ProfileTabNavigatorState extends State<_ProfileTabNavigator> {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: widget.navigatorKey,
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case GeneralSettingsScreen.routeName:
            return MaterialPageRoute<void>(
              builder: (_) => const GeneralSettingsScreen(),
              settings: settings,
            );
          case ManageCategoriesScreen.routeName:
            return MaterialPageRoute<void>(
              builder: (_) => const ManageCategoriesScreen(),
              settings: settings,
            );
          case UpcomingPaymentsScreen.routeName:
            return MaterialPageRoute<void>(
              builder: (_) => const UpcomingPaymentsScreen(),
              settings: settings,
            );
          default:
            return MaterialPageRoute<void>(
              builder: (_) => const _ProfileOverviewPage(),
              settings: settings,
            );
        }
      },
    );
  }
}

class _ProfileOverviewPage extends ConsumerWidget {
  const _ProfileOverviewPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final AuthUser? user = ref.watch(authControllerProvider).value;
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.profileTitle),
        actions: <Widget>[
          if (user != null)
            PopupMenuButton<_ProfileMenuAction>(
              icon: const Icon(Icons.more_vert),
              onSelected: (_ProfileMenuAction action) {
                if (action == _ProfileMenuAction.changeAvatar) {
                  _showAvatarSourceSheet(context, ref, user.uid);
                }
              },
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<_ProfileMenuAction>>[
                    PopupMenuItem<_ProfileMenuAction>(
                      value: _ProfileMenuAction.changeAvatar,
                      child: Text(strings.profileChangeAvatar),
                    ),
                  ],
            ),
          IconButton(
            tooltip: strings.profileGeneralSettingsTooltip,
            icon: const Icon(Icons.tune),
            onPressed: () {
              Navigator.of(context).pushNamed(GeneralSettingsScreen.routeName);
            },
          ),
        ],
      ),
      body: const ProfileManagementBody(),
    );
  }
}

enum _ProfileMenuAction { changeAvatar }

void _showAvatarSourceSheet(BuildContext context, WidgetRef ref, String uid) {
  final AppLocalizations strings = AppLocalizations.of(context)!;
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (BuildContext sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(strings.profileChangeAvatarGallery),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                await ref
                    .read(avatarControllerProvider.notifier)
                    .changeAvatar(source: AvatarUploadSource.gallery, uid: uid);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(strings.profileChangeAvatarCamera),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                await ref
                    .read(avatarControllerProvider.notifier)
                    .changeAvatar(source: AvatarUploadSource.camera, uid: uid);
              },
            ),
          ],
        ),
      );
    },
  );
}
