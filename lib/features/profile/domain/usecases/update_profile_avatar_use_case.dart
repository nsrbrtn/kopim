import 'dart:math';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:kopim/core/services/analytics_service.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/features/profile/domain/entities/profile.dart';
import 'package:kopim/features/profile/domain/repositories/profile_repository.dart';
import 'package:kopim/features/profile/domain/repositories/profile_avatar_repository.dart';

enum AvatarImageSource { gallery, camera }

class UpdateProfileAvatarRequest {
  const UpdateProfileAvatarRequest({
    required this.uid,
    required this.bytes,
    required this.contentType,
    required this.source,
  });

  final String uid;
  final Uint8List bytes;
  final String contentType;
  final AvatarImageSource source;
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

    final Uint8List compressed = await _compress(request.bytes);
    final String downloadUrl = await _avatarRepository.upload(
      uid: request.uid,
      data: compressed,
      contentType: request.contentType,
    );

    final Profile updated = existing.copyWith(
      photoUrl: downloadUrl,
      updatedAt: DateTime.now().toUtc(),
    );
    await _profileRepository.updateProfile(updated);

    await _analyticsService.logEvent('avatar_updated', <String, Object?>{
      'source': request.source.name,
      'size_kb': (compressed.lengthInBytes / 1024).round(),
    });

    return updated;
  }

  Future<Uint8List> _compress(Uint8List data) async {
    if (data.lengthInBytes <= _maxBytes) {
      return data;
    }
    final img.Image? decoded = img.decodeImage(data);
    if (decoded == null) {
      _logger.logError('Failed to decode avatar image for compression');
      return data;
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
    return encoded.lengthInBytes <= _maxBytes ? encoded : data;
  }
}
