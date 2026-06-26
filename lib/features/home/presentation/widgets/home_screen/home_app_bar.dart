import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kopim/features/home/presentation/widgets/top_bar_avatar_icon.dart';
import 'package:kopim/features/home/presentation/widgets/sync_status_indicator.dart';
import 'package:kopim/features/profile/domain/entities/profile.dart';
import 'package:kopim/features/profile/presentation/controllers/profile_controller.dart';
import 'package:kopim/features/profile/presentation/screens/profile_management_screen.dart';
import 'package:kopim/l10n/app_localizations.dart';

class HomeAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key, required this.strings, required this.userId});

  final AppLocalizations strings;
  final String? userId;
  static const double appBarHeight = 40;

  @override
  Size get preferredSize => const Size.fromHeight(appBarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final double topPadding = MediaQuery.of(context).padding.top;
    final AsyncValue<Profile?> profileAsync = userId == null
        ? const AsyncValue<Profile?>.data(null)
        : ref.watch(profileControllerProvider(userId!));

    return SliverAppBar(
      automaticallyImplyLeading: false,
      floating: false,
      pinned: false,
      snap: false,
      elevation: 4,
      backgroundColor: theme.colorScheme.surface,
      surfaceTintColor: theme.colorScheme.surfaceTint,
      toolbarHeight: appBarHeight,
      collapsedHeight: topPadding + appBarHeight,
      expandedHeight: topPadding + appBarHeight,
      titleSpacing: 20,
      title: Image.asset(
        'assets/icons/kopim_logo.png',
        height: 24,
        fit: BoxFit.contain,
        semanticLabel: strings.homeLogoSemanticLabel,
      ),
      actions: <Widget>[
        const Center(child: SyncStatusIndicator()),
        const SizedBox(width: 12),
        profileAsync.when(
          data: (Profile? profile) => IconButton(
            tooltip: strings.homeProfileTooltip,
            padding: EdgeInsets.zero,
            iconSize: 48,
            icon: SizedBox(
              width: 48,
              height: 48,
              child: TopBarAvatarIcon(photoUrl: profile?.photoUrl),
            ),
            onPressed: () {
              context.push(ProfileManagementScreen.routeName);
            },
          ),
          loading: () => IconButton(
            tooltip: strings.homeProfileTooltip,
            padding: EdgeInsets.zero,
            onPressed: () {
              context.push(ProfileManagementScreen.routeName);
            },
            icon: const SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          error: (Object error, StackTrace? stackTrace) => IconButton(
            tooltip: strings.homeProfileTooltip,
            padding: EdgeInsets.zero,
            iconSize: 48,
            icon: const SizedBox(
              width: 48,
              height: 48,
              child: Icon(Icons.account_circle_outlined),
            ),
            onPressed: () {
              context.push(ProfileManagementScreen.routeName);
            },
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
