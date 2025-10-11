import 'package:kopim/features/profile/domain/entities/profile.dart';
import 'package:kopim/features/profile/domain/events/profile_domain_event.dart';
import 'package:kopim/features/profile/domain/models/profile_command_result.dart';
import 'package:kopim/features/profile/domain/repositories/profile_repository.dart';
import 'package:kopim/features/profile/domain/usecases/update_profile_use_case.dart';

/// Use case that persists profile updates locally and emits domain events.
class UpdateProfileUseCaseImpl implements UpdateProfileUseCase {
  UpdateProfileUseCaseImpl({required ProfileRepository repository})
    : _repository = repository;

  final ProfileRepository _repository;

  @override
  Future<ProfileCommandResult<Profile>> call(Profile profile) async {
    final Profile updated = await _repository.updateProfile(profile);
    return ProfileCommandResult<Profile>(
      value: updated,
      events: <ProfileDomainEvent>[
        ProfileDomainEvent.profileUpdated(profile: updated),
      ],
    );
  }
}
