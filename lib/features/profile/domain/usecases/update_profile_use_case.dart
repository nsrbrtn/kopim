import 'package:kopim/features/profile/domain/entities/profile.dart';

abstract class UpdateProfileUseCase {
  Future<Profile> call(Profile profile);
}
