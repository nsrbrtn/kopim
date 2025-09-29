import 'package:kopim/features/profile/domain/entities/profile.dart';

/// Contract for updating the current user profile and resolving the stored value.
abstract class UpdateProfileUseCase {
  /// Persists the provided [profile] and returns the version stored locally.
  Future<Profile> call(Profile profile);
}
