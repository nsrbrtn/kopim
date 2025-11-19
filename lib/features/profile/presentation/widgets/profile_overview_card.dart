import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/profile/domain/entities/profile.dart';
import 'package:kopim/features/profile/domain/entities/user_progress.dart';
import 'package:kopim/features/profile/domain/policies/level_policy.dart';
import 'package:kopim/l10n/app_localizations.dart';
import 'package:kopim/features/profile/presentation/controllers/avatar_controller.dart';

class ProfileOverviewCard extends ConsumerWidget {
  const ProfileOverviewCard({
    super.key,
    required this.profile,
    required this.progressAsync,
    required this.uid,
    required this.avatarState,
  });

  final Profile? profile;
  final AsyncValue<UserProgress> progressAsync;
  final String uid;
  final AsyncValue<void> avatarState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    final bool isUploading = avatarState.isLoading;

    final String displayName = (profile?.name.trim().isEmpty ?? true)
        ? strings.profileUnnamed
        : profile!.name.trim();

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _AvatarPreview(
                  photoUrl: profile?.photoUrl,
                  isUploading: isUploading,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(displayName, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      progressAsync.when(
                        data: (UserProgress progress) {
                          final LevelPolicy policy = ref.read(
                            levelPolicyProvider,
                          );
                          final int previousThreshold = policy
                              .previousThreshold(progress.level);
                          final int nextThreshold = progress.nextThreshold;
                          final int xpToNext = math.max(
                            0,
                            nextThreshold - progress.totalTx,
                          );
                          final double ratio =
                              nextThreshold == previousThreshold
                              ? 1.0
                              : ((progress.totalTx - previousThreshold) /
                                        (nextThreshold - previousThreshold))
                                    .clamp(0.0, 1.0);
                          final String badgeLabel = strings.profileLevelBadge(
                            progress.level,
                            progress.title,
                          );
                          final String xpLabel =
                              nextThreshold == progress.totalTx
                              ? strings.profileXpMax(progress.totalTx)
                              : strings.profileXp(
                                  progress.totalTx,
                                  nextThreshold,
                                );

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Chip(
                                label: Text(badgeLabel),
                                avatar: const Icon(Icons.emoji_events_outlined),
                              ),
                              const SizedBox(height: 8),
                              Text(xpLabel, style: theme.textTheme.bodyMedium),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(12),
                                ),
                                child: LinearProgressIndicator(value: ratio),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                nextThreshold == progress.totalTx
                                    ? strings.profileLevelMaxReached
                                    : strings.profileXpToNext(xpToNext),
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          );
                        },
                        loading: () => const Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        error: (Object error, StackTrace? stackTrace) => Text(
                          strings.profileProgressError(error.toString()),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: <Widget>[
                FilledButton.tonalIcon(
                  onPressed: isUploading
                      ? null
                      : () => _showAvatarSourceSheet(context, ref),
                  icon: const Icon(Icons.photo_camera_back_outlined),
                  label: Text(strings.profileChangeAvatar),
                ),
                FilledButton.tonalIcon(
                  onPressed: isUploading
                      ? null
                      : () => _showPresetAvatarSheet(context, ref, isUploading),
                  icon: const Icon(Icons.collections_outlined),
                  label: Text(strings.profilePresetAvatarButton),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAvatarSourceSheet(BuildContext context, WidgetRef ref) {
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
                      .changeAvatar(
                        source: AvatarUploadSource.gallery,
                        uid: uid,
                      );
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: Text(strings.profileChangeAvatarCamera),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await ref
                      .read(avatarControllerProvider.notifier)
                      .changeAvatar(
                        source: AvatarUploadSource.camera,
                        uid: uid,
                      );
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
    bool isUploading,
  ) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
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
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                        onTap: isUploading
                            ? null
                            : () async {
                                Navigator.of(sheetContext).pop();
                                await ref
                                    .read(avatarControllerProvider.notifier)
                                    .selectPresetAvatar(
                                      uid: uid,
                                      assetPath: assetPath,
                                    );
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
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
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
}

class _AvatarPreview extends StatelessWidget {
  const _AvatarPreview({required this.photoUrl, required this.isUploading});

  final String? photoUrl;
  final bool isUploading;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ImageProvider<Object>? imageProvider = _resolveImageProvider();
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        CircleAvatar(
          radius: 36,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          backgroundImage: imageProvider,
          onBackgroundImageError: imageProvider is NetworkImage
              ? (Object error, StackTrace? stackTrace) {
                  // Игнорируем сетевые ошибки и показываем плейсхолдер,
                  // чтобы офлайн-режим не приводил к падению виджета.
                }
              : null,
          child: imageProvider == null
              ? Icon(
                  Icons.person,
                  size: 32,
                  color: theme.colorScheme.onSurfaceVariant,
                )
              : null,
        ),
        if (isUploading)
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }

  ImageProvider<Object>? _resolveImageProvider() {
    if (photoUrl == null || photoUrl!.isEmpty) {
      return null;
    }
    final String value = photoUrl!;
    if (value.startsWith('data:image/')) {
      final int commaIndex = value.indexOf(',');
      if (commaIndex == -1) {
        return null;
      }
      final String encoded = value.substring(commaIndex + 1);
      try {
        final Uint8List bytes = base64Decode(encoded);
        return MemoryImage(bytes);
      } catch (_) {
        return null;
      }
    }
    return NetworkImage(value);
  }
}

const List<String> _presetAvatarAssetPaths = <String>[
  'assets/avatars/avatar_blue.png',
  'assets/avatars/avatar_coral.png',
  'assets/avatars/avatar_green.png',
  'assets/avatars/avatar_mustard.png',
  'assets/avatars/avatar_mauve.png',
  'assets/avatars/avatar_teal.png',
];
