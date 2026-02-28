import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Резолвит URL аватара в [ImageProvider] c кэшем для data URL.
final class AvatarImageProviderResolver {
  AvatarImageProviderResolver._();

  static const int _maxDataUrlCacheEntries = 24;
  static final LinkedHashMap<String, ImageProvider<Object>> _dataUrlCache =
      LinkedHashMap<String, ImageProvider<Object>>();

  static ImageProvider<Object>? resolve(String? photoUrl) {
    if (photoUrl == null || photoUrl.isEmpty) {
      return null;
    }
    if (photoUrl.startsWith('assets/')) {
      return AssetImage(photoUrl);
    }
    if (photoUrl.startsWith('asset:')) {
      return AssetImage(photoUrl.substring('asset:'.length));
    }
    if (photoUrl.startsWith('data:image/')) {
      return _resolveDataUrl(photoUrl);
    }
    return NetworkImage(photoUrl);
  }

  static ImageProvider<Object>? _resolveDataUrl(String dataUrl) {
    final ImageProvider<Object>? cached = _dataUrlCache.remove(dataUrl);
    if (cached != null) {
      _dataUrlCache[dataUrl] = cached;
      return cached;
    }

    final int commaIndex = dataUrl.indexOf(',');
    if (commaIndex == -1) {
      return null;
    }
    final String encoded = dataUrl.substring(commaIndex + 1);
    try {
      final Uint8List bytes = base64Decode(encoded);
      final ImageProvider<Object> provider = MemoryImage(bytes);
      _dataUrlCache[dataUrl] = provider;
      if (_dataUrlCache.length > _maxDataUrlCacheEntries) {
        _dataUrlCache.remove(_dataUrlCache.keys.first);
      }
      return provider;
    } catch (_) {
      return null;
    }
  }
}
