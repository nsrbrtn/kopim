import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:kopim/features/profile/domain/exceptions/avatar_storage_exception.dart';

class AvatarRemoteDataSource {
  AvatarRemoteDataSource(this._storage);

  final FirebaseStorage _storage;

  Reference _reference(String uid) {
    return _storage.ref().child('users/$uid/avatar.jpg');
  }

  Future<String> upload({
    required String uid,
    required Uint8List data,
    required String contentType,
  }) async {
    final Reference ref = _reference(uid);
    final SettableMetadata metadata = SettableMetadata(
      contentType: contentType,
    );
    try {
      final UploadTask task = ref.putData(data, metadata);
      final TaskSnapshot snapshot = await task.whenComplete(() {});
      return snapshot.ref.getDownloadURL();
    } on FirebaseException catch (error) {
      throw AvatarStorageException(error.code, error.message);
    }
  }

  Future<void> delete(String uid) async {
    try {
      await _reference(uid).delete();
    } on FirebaseException catch (error) {
      throw AvatarStorageException(error.code, error.message);
    }
  }
}
