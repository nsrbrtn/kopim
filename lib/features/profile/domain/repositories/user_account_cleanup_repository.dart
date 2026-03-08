abstract class UserAccountCleanupRepository {
  Future<void> deleteUserData(String uid);
}
