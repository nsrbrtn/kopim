import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:kopim/core/services/analytics_service.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/features/profile/domain/entities/profile.dart';
import 'package:kopim/features/profile/domain/repositories/profile_repository.dart';
import 'package:kopim/features/profile/domain/repositories/profile_avatar_repository.dart';
import 'package:kopim/features/profile/domain/exceptions/avatar_storage_exception.dart';

enum AvatarImageSource { gallery, camera }

class UpdateProfileAvatarRequest {
  const UpdateProfileAvatarRequest({
    required this.uid,
    required this.bytes,
    required this.contentType,
    required this.source,
    this.storeOfflineOnly = false,
  });

  final String uid;
  final Uint8List bytes;
  final String contentType;
  final AvatarImageSource source;
  final bool storeOfflineOnly;
}

class UpdateProfileAvatarUseCase {
  UpdateProfileAvatarUseCase({
    required ProfileAvatarRepository avatarRepository,
    required ProfileRepository profileRepository,
    required AnalyticsService analyticsService,
    required LoggerService loggerService,
  }) : _avatarRepository = avatarRepository,
       _profileRepository = profileRepository,
       _analyticsService = analyticsService,
       _logger = loggerService;

  static const int _maxBytes = 512 * 1024;
  static const int _maxDimension = 512;

  final ProfileAvatarRepository _avatarRepository;
  final ProfileRepository _profileRepository;
  final AnalyticsService _analyticsService;
  final LoggerService _logger;

  Future<Profile> call(UpdateProfileAvatarRequest request) async {
    final Profile? existing = await _profileRepository.getProfile(request.uid);
    if (existing == null) {
      throw StateError('Profile not found for uid ${request.uid}');
    }

    final _CompressionResult compression = await _compress(request.bytes);
    final Uint8List processedBytes = compression.bytes;
    final String resolvedContentType = compression.convertedToJpeg
        ? 'image/jpeg'
        : request.contentType;

    String downloadUrl;
    if (request.storeOfflineOnly) {
      downloadUrl = _encodeAsDataUrl(processedBytes, resolvedContentType);
    } else {
      try {
        downloadUrl = await _avatarRepository.upload(
          uid: request.uid,
          data: processedBytes,
          contentType: resolvedContentType,
        );
      } on AvatarStorageException catch (error, stackTrace) {
        _logger.logError('Failed to upload avatar: ${error.code}');
        _logger.logError(stackTrace.toString());
        rethrow;
      } catch (error, stackTrace) {
        _logger.logError('Failed to upload avatar: $error');
        _logger.logError(stackTrace.toString());
        rethrow;
      }
    }

    final Profile updated = existing.copyWith(
      photoUrl: downloadUrl,
      updatedAt: DateTime.now().toUtc(),
    );
    await _profileRepository.updateProfile(updated);

    await _analyticsService.logEvent('avatar_updated', <String, Object?>{
      'source': request.source.name,
      'size_kb': (processedBytes.lengthInBytes / 1024).round(),
      'mode': request.storeOfflineOnly ? 'offline' : 'remote',
    });

    return updated;
  }

  String _encodeAsDataUrl(Uint8List bytes, String contentType) {
    final String base64Data = base64Encode(bytes);
    final String mime = contentType.isEmpty ? 'image/jpeg' : contentType;
    return 'data:$mime;base64,$base64Data';
  }

  Future<_CompressionResult> _compress(Uint8List data) async {
    if (data.lengthInBytes <= _maxBytes) {
      return _CompressionResult(data);
    }
    final img.Image? decoded = img.decodeImage(data);
    if (decoded == null) {
      _logger.logError('Failed to decode avatar image for compression');
      return _CompressionResult(data);
    }
    final int targetWidth = decoded.width > decoded.height
        ? _maxDimension
        : max(1, (decoded.width * _maxDimension) ~/ decoded.height);
    final int targetHeight = decoded.height >= decoded.width
        ? _maxDimension
        : max(1, (decoded.height * _maxDimension) ~/ decoded.width);
    final img.Image resized = img.copyResize(
      decoded,
      width: targetWidth,
      height: targetHeight,
    );
    int quality = 90;
    Uint8List encoded = Uint8List.fromList(
      img.encodeJpg(resized, quality: quality),
    );
    while (encoded.lengthInBytes > _maxBytes && quality > 50) {
      quality -= 10;
      encoded = Uint8List.fromList(img.encodeJpg(resized, quality: quality));
    }
    if (encoded.lengthInBytes <= _maxBytes) {
      return _CompressionResult(encoded, convertedToJpeg: true);
    }
    return _CompressionResult(data);
  }
}

class _CompressionResult {
  const _CompressionResult(this.bytes, {this.convertedToJpeg = false});

  final Uint8List bytes;
  final bool convertedToJpeg;
}
