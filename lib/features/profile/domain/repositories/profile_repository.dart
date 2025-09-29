import 'package:kopim/features/profile/domain/entities/profile.dart';

abstract class ProfileRepository {
  Stream<Profile?> watchProfile(String uid);

  Future<Profile?> getProfile(String uid);

  Future<Profile> updateProfile(Profile profile);
}
