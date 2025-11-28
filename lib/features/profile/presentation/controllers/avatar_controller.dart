import 'dart:async';

import 'package:image_picker/image_picker.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/profile/domain/entities/profile.dart';
import 'package:kopim/features/profile/domain/models/profile_command_result.dart';
import 'package:kopim/features/profile/domain/usecases/update_profile_avatar_use_case.dart';
import 'package:kopim/features/profile/presentation/services/profile_event_recorder.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:kopim/core/services/logger_service.dart';

part 'avatar_controller.g.dart';

enum AvatarUploadSource { gallery, camera }

@riverpod
class AvatarController extends _$AvatarController {
  final ImagePicker _picker = ImagePicker();

  @override
  AsyncValue<void> build() => const AsyncValue<void>.data(null);

  Future<void> changeAvatar({
    required AvatarUploadSource source,
    required String uid,
  }) async {
    state = const AsyncValue<void>.loading();
    try {
      // Всегда храним аватар локально (data URL), не трогаем Firebase Storage.
      const bool storeOfflineOnly = true;

      final XFile? file = await _picker.pickImage(
        source: source == AvatarUploadSource.gallery
            ? ImageSource.gallery
            : ImageSource.camera,
        imageQuality: 95,
        maxWidth: 2048,
        maxHeight: 2048,
      );
      if (file == null) {
        state = const AsyncValue<void>.data(null);
        return;
      }
      final Uint8List bytes = await file.readAsBytes();
      final String contentType =
          file.mimeType ?? _guessContentType(file.path) ?? 'image/jpeg';
      final LoggerService logger = ref.read(loggerServiceProvider);
      logger.logInfo(
        'Avatar upload start: source=$source, uid=$uid, '
        'bytes=${bytes.lengthInBytes}, mime=$contentType, offlineOnly=$storeOfflineOnly',
      );
      final UpdateProfileAvatarUseCase useCase = ref.read(
        updateProfileAvatarUseCaseProvider,
      );
      final ProfileEventRecorder recorder = ref.read(
        profileEventRecorderProvider,
      );
      final ProfileCommandResult<Profile> result = await useCase(
        UpdateProfileAvatarRequest(
          uid: uid,
          bytes: bytes,
          contentType: contentType,
          source: source == AvatarUploadSource.gallery
              ? AvatarImageSource.gallery
              : AvatarImageSource.camera,
          storeOfflineOnly: storeOfflineOnly,
        ),
      );
      unawaited(recorder.record(result.events));
      logger.logInfo(
        'Avatar upload success: uid=$uid, bytes=${bytes.lengthInBytes}, mime=$contentType',
      );
      state = const AsyncValue<void>.data(null);
    } catch (error, stackTrace) {
      ref
          .read(loggerServiceProvider)
          .logError('Avatar upload failed for uid=$uid', error);
      state = AsyncValue<void>.error(error, stackTrace);
    }
  }

  Future<void> selectPresetAvatar({
    required String uid,
    required String assetPath,
  }) async {
    state = const AsyncValue<void>.loading();
    try {
      // Пресетные картинки храним только локально, чтобы не трогать Firebase.
      const bool storeOfflineOnly = true;
      final ByteData data = await rootBundle.load(assetPath);
      final Uint8List bytes = data.buffer.asUint8List();
      final String contentType = _guessContentType(assetPath) ?? 'image/png';
      final UpdateProfileAvatarUseCase useCase = ref.read(
        updateProfileAvatarUseCaseProvider,
      );
      await useCase(
        UpdateProfileAvatarRequest(
          uid: uid,
          bytes: bytes,
          contentType: contentType,
          source: AvatarImageSource.predefined,
          storeOfflineOnly: storeOfflineOnly,
        ),
      );
      state = const AsyncValue<void>.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue<void>.error(error, stackTrace);
    }
  }

  String? _guessContentType(String path) {
    final String lower = path.toLowerCase();
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      return 'image/jpeg';
    }
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return null;
  }
}
