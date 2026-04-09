abstract class UserAccountCleanupRepository {
  Future<void> deleteRemoteUserData(String uid);
  Future<void> deleteLocalUserData();
}
