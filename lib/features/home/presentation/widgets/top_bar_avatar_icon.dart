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
    final String value = photoUrl!;
    if (value.startsWith('assets/')) {
      return AssetImage(value);
    }
    if (value.startsWith('asset:')) {
      return AssetImage(value.substring('asset:'.length));
    }
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
