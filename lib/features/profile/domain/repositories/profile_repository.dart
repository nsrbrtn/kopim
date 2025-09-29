import 'package:kopim/features/profile/domain/entities/profile.dart';

/// Defines how profile data is retrieved and persisted across offline caches and remote storage.
abstract class ProfileRepository {
  /// Emits local profile changes for the given [uid].
  Stream<Profile?> watchProfile(String uid);

  /// Returns the profile for [uid], preferring the local cache and seeding it from Firestore on a miss.
  Future<Profile?> getProfile(String uid);

  /// Persists [profile] locally, enqueues it for sync, and returns the stored snapshot.
  Future<Profile> updateProfile(Profile profile);
}
