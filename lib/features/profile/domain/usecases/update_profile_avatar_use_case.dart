import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:kopim/features/profile/domain/entities/profile.dart';
import 'package:kopim/features/profile/domain/events/profile_domain_event.dart';
import 'package:kopim/features/profile/domain/models/profile_command_result.dart';
import 'package:kopim/features/profile/domain/repositories/profile_repository.dart';
import 'package:kopim/features/profile/domain/repositories/profile_avatar_repository.dart';

enum AvatarImageSource { gallery, camera, predefined }

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
  }) : _avatarRepository = avatarRepository,
       _profileRepository = profileRepository;

  static const int _maxBytes = 512 * 1024;
  static const int _maxDimension = 512;

  final ProfileAvatarRepository _avatarRepository;
  final ProfileRepository _profileRepository;

  Future<ProfileCommandResult<Profile>> call(
    UpdateProfileAvatarRequest request,
  ) async {
    final List<ProfileDomainEvent> events = <ProfileDomainEvent>[];
    final Profile? existing = await _profileRepository.getProfile(request.uid);
    if (existing == null) {
      throw StateError('Profile not found for uid ${request.uid}');
    }

    final _CompressionResult compression = await _compress(
      request.bytes,
      onWarning: (String message) {
        events.add(
          ProfileDomainEvent.avatarProcessingWarning(message: message),
        );
      },
    );
    final Uint8List processedBytes = compression.bytes;
    final String resolvedContentType = compression.convertedToJpeg
        ? 'image/jpeg'
        : request.contentType;

    String downloadUrl;
    if (request.storeOfflineOnly) {
      downloadUrl = _encodeAsDataUrl(processedBytes, resolvedContentType);
    } else {
      downloadUrl = await _avatarRepository.upload(
        uid: request.uid,
        data: processedBytes,
        contentType: resolvedContentType,
      );
      downloadUrl = _withCacheBuster(downloadUrl);
    }

    final Profile updated = existing.copyWith(
      photoUrl: downloadUrl,
      updatedAt: DateTime.now().toUtc(),
    );
    await _profileRepository.updateProfile(updated);

    events
      ..add(ProfileDomainEvent.profileUpdated(profile: updated))
      ..add(
        ProfileDomainEvent.avatarUpdated(
          uid: request.uid,
          source: request.source,
          sizeBytes: processedBytes.lengthInBytes,
          offlineOnly: request.storeOfflineOnly,
        ),
      );

    return ProfileCommandResult<Profile>(value: updated, events: events);
  }

  String _encodeAsDataUrl(Uint8List bytes, String contentType) {
    final String base64Data = base64Encode(bytes);
    final String mime = contentType.isEmpty ? 'image/jpeg' : contentType;
    return 'data:$mime;base64,$base64Data';
  }

  Future<_CompressionResult> _compress(
    Uint8List data, {
    void Function(String message)? onWarning,
  }) async {
    if (data.lengthInBytes <= _maxBytes) {
      return _CompressionResult(data);
    }
    final img.Image? decoded = img.decodeImage(data);
    if (decoded == null) {
      onWarning?.call('Failed to decode avatar image for compression');
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

  String _withCacheBuster(String url) {
    final String separator = url.contains('?') ? '&' : '?';
    final int timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$url${separator}v=$timestamp';
  }
}

class _CompressionResult {
  const _CompressionResult(this.bytes, {this.convertedToJpeg = false});

  final Uint8List bytes;
  final bool convertedToJpeg;
}
