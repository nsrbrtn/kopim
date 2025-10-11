import 'package:kopim/features/profile/domain/entities/profile.dart';
import 'package:kopim/features/profile/domain/models/profile_command_result.dart';

/// Contract for updating the current user profile and resolving the stored value.
abstract class UpdateProfileUseCase {
  /// Persists the provided [profile] and returns the version stored locally with
  /// any domain events that should be observed by upper layers.
  Future<ProfileCommandResult<Profile>> call(Profile profile);
}
