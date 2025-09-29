import 'package:kopim/features/profile/domain/entities/profile.dart';
import 'package:kopim/features/profile/domain/repositories/profile_repository.dart';
import 'package:kopim/features/profile/domain/usecases/update_profile_use_case.dart';

class UpdateProfileUseCaseImpl implements UpdateProfileUseCase {
  UpdateProfileUseCaseImpl(this._repository);

  final ProfileRepository _repository;

  @override
  Future<Profile> call(Profile profile) {
    return _repository.updateProfile(profile);
  }
}
