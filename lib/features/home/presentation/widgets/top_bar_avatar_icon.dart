import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Аватар для верхнего бара: показывает фото или иконку-заглушку.
class TopBarAvatarIcon extends StatelessWidget {
  const TopBarAvatarIcon({this.photoUrl, super.key});

  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ImageProvider<Object>? imageProvider = _resolveImageProvider();
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

  ImageProvider<Object>? _resolveImageProvider() {
    if (photoUrl == null || photoUrl!.isEmpty) {
      return null;
    }
    if (photoUrl!.startsWith('data:image/')) {
      final int commaIndex = photoUrl!.indexOf(',');
      if (commaIndex == -1) {
        return null;
      }
      final String encoded = photoUrl!.substring(commaIndex + 1);
      try {
        final Uint8List bytes = base64Decode(encoded);
        return MemoryImage(bytes);
      } catch (_) {
        return null;
      }
    }
    return NetworkImage(photoUrl!);
  }
}
