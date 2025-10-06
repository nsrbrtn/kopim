import 'dart:typed_data';

abstract class ProfileAvatarRepository {
  Future<String> upload({
    required String uid,
    required Uint8List data,
    required String contentType,
  });

  Future<void> delete(String uid);
}
