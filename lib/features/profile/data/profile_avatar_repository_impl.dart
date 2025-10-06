import 'dart:typed_data';

import 'package:kopim/features/profile/data/remote/avatar_remote_data_source.dart';
import 'package:kopim/features/profile/domain/repositories/profile_avatar_repository.dart';

class ProfileAvatarRepositoryImpl implements ProfileAvatarRepository {
  ProfileAvatarRepositoryImpl({
    required AvatarRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final AvatarRemoteDataSource _remoteDataSource;

  @override
  Future<void> delete(String uid) {
    return _remoteDataSource.delete(uid);
  }

  @override
  Future<String> upload({
    required String uid,
    required Uint8List data,
    required String contentType,
  }) {
    return _remoteDataSource.upload(
      uid: uid,
      data: data,
      contentType: contentType,
    );
  }
}
