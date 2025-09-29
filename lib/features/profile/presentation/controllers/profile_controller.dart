import 'dart:async';

import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/profile/domain/entities/profile.dart';
import 'package:kopim/features/profile/domain/repositories/profile_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_controller.g.dart';

@riverpod
class ProfileController extends _$ProfileController {
  StreamSubscription<Profile?>? _subscription;

  @override
  FutureOr<Profile?> build(String uid) async {
    final ProfileRepository repository = ref.watch(profileRepositoryProvider);
    final Stream<Profile?> stream = repository.watchProfile(uid);

    _subscription = stream.listen((Profile? profile) {
      if (!ref.mounted) return;
      state = AsyncValue<Profile?>.data(profile);
    });
    ref.onDispose(() => _subscription?.cancel());

    final Profile? profile = await repository.getProfile(uid);
    return profile;
  }

  Future<void> refresh() async {
    final String controllerUid = uid;
    final ProfileRepository repository = ref.read(profileRepositoryProvider);
    state = const AsyncValue<Profile?>.loading();
    try {
      final Profile? profile = await repository.getProfile(controllerUid);
      state = AsyncValue<Profile?>.data(profile);
    } on Object catch (error, stackTrace) {
      state = AsyncValue<Profile?>.error(error, stackTrace);
    }
  }
}
