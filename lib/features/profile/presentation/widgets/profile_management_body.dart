import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:kopim/core/application/sync_preferences_provider.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/utils/avatar_image_provider_resolver.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/entities/profile.dart';
import 'package:kopim/features/profile/domain/entities/user_progress.dart';
import 'package:kopim/features/profile/domain/exceptions/avatar_storage_exception.dart';
import 'package:kopim/features/profile/domain/failures/auth_failure.dart';
import 'package:kopim/features/profile/domain/policies/level_policy.dart';
import 'package:kopim/features/profile/presentation/controllers/profile_activity_days_provider.dart';
import 'package:kopim/features/profile/presentation/controllers/avatar_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/auth_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/profile_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/user_progress_controller.dart';
import 'package:kopim/features/profile/presentation/screens/profile_settings_screen.dart';
import 'package:kopim/features/profile/presentation/widgets/profile_data_transfer_section.dart';
import 'package:kopim/features/profile/presentation/screens/sign_in_screen.dart';
import 'package:kopim/l10n/app_localizations.dart';

class ProfileManagementBody extends ConsumerWidget {
  const ProfileManagementBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final AsyncValue<AuthUser?> authState = ref.watch(authControllerProvider);

    return authState.when(
      loading: () => const _CenteredProgress(),
      error: (Object error, StackTrace? stackTrace) =>
          _ErrorView(message: error.toString()),
      data: (AuthUser? user) {
        if (user == null) {
          return _ErrorView(message: strings.profileSignInPrompt);
        }

        final AsyncValue<Profile?> profileAsync = ref.watch(
          profileControllerProvider(user.uid),
        );
        final AsyncValue<UserProgress> progressAsync = ref.watch(
          userProgressProvider(user.uid),
        );
        final AsyncValue<void> avatarState = ref.watch(
          avatarControllerProvider,
        );
        final AsyncValue<Set<DateTime>> activeDaysAsync = ref.watch(
          profileActivityDaysProvider,
        );
        final AsyncValue<bool> onlineSyncEnabledAsync = ref.watch(
          onlineSyncPreferencesControllerProvider,
        );
        final bool isOnlineSyncEnabled = onlineSyncEnabledAsync.maybeWhen(
          data: (bool value) => value,
          orElse: () => true,
        );
        final bool canManageOnlineSync = !user.isAnonymous;
        final bool effectiveOnlineSyncEnabled =
            canManageOnlineSync && isOnlineSyncEnabled;
        ref.listen<AsyncValue<void>>(avatarControllerProvider, (
          AsyncValue<void>? previous,
          AsyncValue<void> next,
        ) {
          if (!context.mounted) {
            return;
          }
          if (next.hasError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 3),
                  content: Text(_mapAvatarError(strings, next.error)),
                ),
              );
            return;
          }
          if (previous?.isLoading == true && next.hasValue) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 3),
                  content: Text(strings.profileAvatarUploadSuccess),
                ),
              );
          }
        });

        final ThemeData theme = Theme.of(context);
        final Profile? profile = profileAsync.value;
        final String displayName = (profile?.name.trim().isEmpty ?? true)
            ? strings.profileUnnamed
            : profile!.name.trim();

        return SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _HeaderSection(
                      uid: user.uid,
                      displayName: displayName,
                      photoUrl: profile?.photoUrl,
                      avatarState: avatarState,
                      onOpenSettings: () => _openProfileSettings(context),
                    ),
                    const SizedBox(height: 16),
                    _ActivitySection(activeDaysAsync: activeDaysAsync),
                    const SizedBox(height: 16),
                    _ProgressSection(progressAsync: progressAsync),
                    const SizedBox(height: 16),
                    _SecuritySection(
                      isOnlineSyncEnabled: effectiveOnlineSyncEnabled,
                      canManageOnlineSync: canManageOnlineSync,
                      onToggleOnlineSync: () => _toggleOnlineSync(
                        context,
                        ref,
                        enabled: !isOnlineSyncEnabled,
                      ),
                    ),
                    if (profileAsync.hasError) ...<Widget>[
                      const SizedBox(height: 12),
                      Text(
                        strings.profileLoadError(profileAsync.error.toString()),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 16),
                    _SignOutButton(onSignOut: () => _signOut(context, ref)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _openProfileSettings(BuildContext context) {
    final GoRouter? router = GoRouter.maybeOf(context);
    if (router != null) {
      router.push(ProfileSettingsScreen.routeName);
      return;
    }
    Navigator.of(context).pushNamed(ProfileSettingsScreen.routeName);
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final NavigatorState navigator = Navigator.of(context);
    final GoRouter? router = GoRouter.maybeOf(context);
    try {
      await ref.read(authControllerProvider.notifier).signOut();
      if (!context.mounted) {
        return;
      }
      if (router != null) {
        router.go(SignInScreen.routeName);
        return;
      }
      navigator.popUntil((Route<dynamic> route) => route.isFirst);
    } on AuthFailure catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 3),
            content: Text(error.message),
          ),
        );
    }
  }

  Future<void> _toggleOnlineSync(
    BuildContext context,
    WidgetRef ref, {
    required bool enabled,
  }) async {
    try {
      await ref
          .read(onlineSyncPreferencesControllerProvider.notifier)
          .setEnabled(enabled);
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      final AppLocalizations strings = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 3),
            content: Text(strings.genericErrorMessage),
          ),
        );
    }
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({
    required this.uid,
    required this.displayName,
    required this.photoUrl,
    required this.avatarState,
    required this.onOpenSettings,
  });

  final String uid;
  final String displayName;
  final String? photoUrl;
  final AsyncValue<void> avatarState;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    return Stack(
      children: <Widget>[
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: <Widget>[
              _ProfileAvatar(
                uid: uid,
                photoUrl: photoUrl,
                avatarState: avatarState,
              ),
              const SizedBox(height: 16),
              Text(
                strings.profileGreeting(displayName),
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            tooltip: strings.profileSettingsTitle,
            onPressed: onOpenSettings,
            icon: const Icon(Icons.settings_outlined),
          ),
        ),
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.uid,
    required this.photoUrl,
    required this.avatarState,
  });

  final String uid;
  final String? photoUrl;
  final AsyncValue<void> avatarState;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    final Color borderColor = theme.colorScheme.primary;
    final Color backgroundColor = theme.colorScheme.surface;
    final ImageProvider<Object>? imageProvider =
        AvatarImageProviderResolver.resolve(photoUrl);
    final bool isUploading = avatarState.isLoading;

    return Container(
      width: 114,
      height: 114,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2),
        color: backgroundColor,
      ),
      clipBehavior: Clip.antiAlias,
      child: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          return Material(
            color: Colors.transparent,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: isUploading
                  ? null
                  : () => _showAvatarActionSheet(context, ref, uid, strings),
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  SizedBox.expand(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: backgroundColor,
                        image: imageProvider == null
                            ? null
                            : DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                      ),
                      child: imageProvider == null
                          ? Icon(
                              Icons.person_outline,
                              size: 42,
                              color: theme.colorScheme.onSurfaceVariant,
                            )
                          : null,
                    ),
                  ),
                  if (isUploading)
                    Container(
                      color: theme.colorScheme.surface.withValues(alpha: 0.5),
                      alignment: Alignment.center,
                      child: const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ActivitySection extends StatelessWidget {
  const _ActivitySection({required this.activeDaysAsync});

  final AsyncValue<Set<DateTime>> activeDaysAsync;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    final Locale locale = Localizations.localeOf(context);
    final DateTime now = DateTime.now();
    final String monthLabel =
        toBeginningOfSentenceCase(
          DateFormat.MMMM(locale.toLanguageTag()).format(now),
        ) ??
        DateFormat.MMMM().format(now);

    final Set<DateTime> activeDays = activeDaysAsync.maybeWhen(
      data: (Set<DateTime> value) => value,
      orElse: () => const <DateTime>{},
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                strings.profileActivityTitle,
                style: theme.textTheme.labelLarge,
              ),
              Text(
                monthLabel,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: List<Widget>.generate(7, (int index) {
              final DateTime date = now.subtract(Duration(days: 6 - index));
              final DateTime normalizedDate = DateTime(
                date.year,
                date.month,
                date.day,
              );
              final bool isToday = DateUtils.isSameDay(date, now);
              final bool isActive = activeDays.contains(normalizedDate);
              final TextStyle dayStyle = theme.textTheme.labelSmall!.copyWith(
                color: isToday
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              );
              final TextStyle dateStyle = isToday
                  ? theme.textTheme.labelSmall!.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    )
                  : theme.textTheme.labelSmall!.copyWith(
                      color: theme.colorScheme.onSurface,
                    );

              return Expanded(
                child: _DayActivityCell(
                  weekdayLabel: DateFormat.E(
                    locale.toLanguageTag(),
                  ).format(date).toUpperCase(),
                  dayLabel: '${date.day}',
                  isToday: isToday,
                  isActive: isActive,
                  weekdayStyle: dayStyle,
                  dayStyle: dateStyle,
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _DayActivityCell extends StatelessWidget {
  const _DayActivityCell({
    required this.weekdayLabel,
    required this.dayLabel,
    required this.isToday,
    required this.isActive,
    required this.weekdayStyle,
    required this.dayStyle,
  });

  final String weekdayLabel;
  final String dayLabel;
  final bool isToday;
  final bool isActive;
  final TextStyle weekdayStyle;
  final TextStyle dayStyle;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Widget dayContent = SizedBox(
      width: 36,
      height: 36,
      child: Center(child: Text(dayLabel, style: dayStyle)),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(weekdayLabel, style: weekdayStyle, maxLines: 1),
        const SizedBox(height: 8),
        isToday
            ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.primary),
                ),
                child: dayContent,
              )
            : dayContent,
        const SizedBox(height: 4),
        SizedBox(
          width: 6,
          height: 6,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceContainerHighest,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProgressSection extends ConsumerWidget {
  const _ProgressSection({required this.progressAsync});

  final AsyncValue<UserProgress> progressAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: progressAsync.when(
        loading: () => const _CenteredProgress(size: 24),
        error: (Object error, StackTrace? stackTrace) => Text(
          strings.profileProgressError(error.toString()),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
        data: (UserProgress progress) {
          final LevelPolicy policy = ref.read(levelPolicyProvider);
          final String title = strings.profileLevelBadge(
            progress.level,
            progress.title,
          );
          final int nextThreshold = progress.nextThreshold;
          final int previousThreshold = policy.previousThreshold(
            progress.level,
          );
          final double value = nextThreshold == previousThreshold
              ? 1
              : ((progress.totalTx - previousThreshold) /
                        (nextThreshold - previousThreshold))
                    .clamp(0, 1)
                    .toDouble();
          final int percentage = (value * 100).round();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.workspace_premium_outlined,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(title, style: theme.textTheme.titleMedium),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    strings.profileProgressToNextLevel(progress.level + 1),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '$percentage%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(value: value, minHeight: 8),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SecuritySection extends StatelessWidget {
  const _SecuritySection({
    required this.isOnlineSyncEnabled,
    required this.canManageOnlineSync,
    required this.onToggleOnlineSync,
  });

  final bool isOnlineSyncEnabled;
  final bool canManageOnlineSync;
  final VoidCallback onToggleOnlineSync;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            strings.profileDataSecurityTitle,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: <Widget>[
              _SecurityRow(
                icon: Icons.cloud_done_outlined,
                label: strings.profileBackupTitle,
                value: isOnlineSyncEnabled
                    ? strings.profileBackupEnabled
                    : strings.profileBackupDisabled,
                highlightedValue: isOnlineSyncEnabled,
                onTap: canManageOnlineSync ? onToggleOnlineSync : null,
                trailing: Switch(
                  value: isOnlineSyncEnabled,
                  onChanged: canManageOnlineSync
                      ? (_) => onToggleOnlineSync()
                      : null,
                ),
              ),
              Divider(
                height: 1,
                color: theme.colorScheme.outlineVariant,
                indent: 16,
                endIndent: 16,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: ProfileDataTransferSection(
                  title: strings.profileExportDataFullCta,
                  subtitle: strings.profileImportDataCta,
                  icon: Icons.file_download_outlined,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SecurityRow extends StatelessWidget {
  const _SecurityRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.value,
    this.highlightedValue = false,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final String? value;
  final bool highlightedValue;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: <Widget>[
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
            if (value != null)
              Text(
                value!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: highlightedValue
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            if (trailing != null) ...<Widget>[
              const SizedBox(width: 8),
              trailing!,
            ] else ...<Widget>[
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SignOutButton extends StatelessWidget {
  const _SignOutButton({required this.onSignOut});

  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);

    return FilledButton(
      onPressed: onSignOut,
      style: FilledButton.styleFrom(
        backgroundColor: theme.colorScheme.errorContainer,
        foregroundColor: theme.colorScheme.error,
        minimumSize: const Size.fromHeight(52),
      ),
      child: Text(strings.profileSignOutFullCta),
    );
  }
}

String _mapAvatarError(AppLocalizations strings, Object? error) {
  if (error is AvatarStorageException) {
    return strings.profileAvatarUploadError;
  }
  return strings.profileAvatarUploadError;
}

void _showAvatarActionSheet(
  BuildContext context,
  WidgetRef ref,
  String uid,
  AppLocalizations strings,
) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (BuildContext sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.collections_outlined),
              title: Text(strings.profilePresetAvatarButton),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _showPresetAvatarSheet(context, ref, uid, strings);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(strings.profileChangeAvatar),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _showAvatarSourceSheet(context, ref, uid, strings);
              },
            ),
          ],
        ),
      );
    },
  );
}

void _showAvatarSourceSheet(
  BuildContext context,
  WidgetRef ref,
  String uid,
  AppLocalizations strings,
) {
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

void _showPresetAvatarSheet(
  BuildContext context,
  WidgetRef ref,
  String uid,
  AppLocalizations strings,
) {
  final ThemeData theme = Theme.of(context);
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (BuildContext sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                strings.profilePresetAvatarTitle,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                strings.profilePresetAvatarSubtitle,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                child: GridView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: _presetAvatarAssetPaths.length,
                  itemBuilder: (BuildContext gridContext, int index) {
                    final String assetPath = _presetAvatarAssetPaths[index];
                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () async {
                        Navigator.of(sheetContext).pop();
                        await ref
                            .read(avatarControllerProvider.notifier)
                            .selectPresetAvatar(uid: uid, assetPath: assetPath);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ClipOval(
                            child: Image.asset(
                              assetPath,
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (
                                    BuildContext context,
                                    Object error,
                                    StackTrace? stackTrace,
                                  ) => Container(
                                    width: 72,
                                    height: 72,
                                    color: theme
                                        .colorScheme
                                        .surfaceContainerHighest,
                                    child: Icon(
                                      Icons.person,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            strings.profilePresetAvatarLabel(index + 1),
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      );
    },
  );
}

const List<String> _presetAvatarAssetPaths = <String>[
  'assets/avatars/avatar_blue.png',
  'assets/avatars/avatar_coral.png',
  'assets/avatars/avatar_green.png',
  'assets/avatars/avatar_mustard.png',
  'assets/avatars/avatar_mauve.png',
  'assets/avatars/avatar_teal.png',
];

class _CenteredProgress extends StatelessWidget {
  const _CenteredProgress({this.size = 32});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: const CircularProgressIndicator(),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
