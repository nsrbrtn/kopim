import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

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
    await ref.putData(data, metadata);
    return ref.getDownloadURL();
  }

  Future<void> delete(String uid) {
    return _reference(uid).delete();
  }
}
