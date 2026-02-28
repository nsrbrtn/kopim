import 'package:flutter/material.dart';
import 'package:kopim/core/utils/avatar_image_provider_resolver.dart';

/// Аватар для верхнего бара: показывает фото или иконку-заглушку.
class TopBarAvatarIcon extends StatelessWidget {
  const TopBarAvatarIcon({this.photoUrl, super.key});

  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ImageProvider<Object>? imageProvider =
        AvatarImageProviderResolver.resolve(photoUrl);
    return CircleAvatar(
      radius: 24,
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      backgroundImage: imageProvider,
      child: imageProvider == null
          ? Icon(
              Icons.account_circle_outlined,
              size: 28,
              color: theme.colorScheme.onSurfaceVariant,
            )
          : null,
    );
  }
}
