import 'dart:async';
import 'dart:typed_data';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/profile/domain/entities/profile.dart';
import 'package:kopim/features/profile/domain/models/profile_command_result.dart';
import 'package:kopim/features/profile/domain/usecases/update_profile_avatar_use_case.dart';
import 'package:kopim/features/profile/presentation/services/profile_event_recorder.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
      final Connectivity connectivity = ref.read(connectivityProvider);
      final List<ConnectivityResult> results = await connectivity
          .checkConnectivity();
      final bool isOffline = results.every(
        (ConnectivityResult result) => result == ConnectivityResult.none,
      );
      final bool storeOfflineOnly = isOffline || uid.startsWith('guest-');

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
      await recorder.record(result.events);
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
