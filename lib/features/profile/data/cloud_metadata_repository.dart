import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/profile/domain/entities/cloud_metadata.dart';
import 'package:riverpod/riverpod.dart';

abstract class CloudMetadataRepository {
  Future<CloudMetadata?> getMetadata(String uid);
  Future<void> updateMetadata(String uid, CloudMetadata metadata);
  Future<void> setCloudDataState(String uid, CloudDataState state);
  Future<CloudMetadata> startFreshUpload({
    required String uid,
    required String uploadSessionId,
  });
  Future<CloudMetadata> completeFreshUpload({
    required String uid,
    required String uploadSessionId,
  });
}

enum CloudMetadataTransitionFailureReason {
  permissionDenied,
  stateMismatch,
  networkFailure,
  entitlementDenied,
  readbackMismatch,
}

class CloudMetadataTransitionException implements Exception {
  const CloudMetadataTransitionException(this.reason, this.message);

  final CloudMetadataTransitionFailureReason reason;
  final String message;

  @override
  String toString() => 'CloudMetadataTransitionException($reason): $message';
}

class FirestoreCloudMetadataRepository implements CloudMetadataRepository {
  FirestoreCloudMetadataRepository(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _docRef(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('cloud_meta')
        .doc('state');
  }

  @override
  Future<CloudMetadata?> getMetadata(String uid) async {
    final DocumentSnapshot<Map<String, dynamic>> doc = await _docRef(uid).get();
    if (!doc.exists || doc.data() == null) {
      return null;
    }
    return CloudMetadata.fromJson(doc.data()!);
  }

  @override
  Future<void> updateMetadata(String uid, CloudMetadata metadata) async {
    await _docRef(uid).set(metadata.toJson(), SetOptions(merge: true));
  }

  @override
  Future<void> setCloudDataState(String uid, CloudDataState state) async {
    await _docRef(uid).set(<String, dynamic>{
      'cloudDataState': state.name,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<CloudMetadata> startFreshUpload({
    required String uid,
    required String uploadSessionId,
  }) {
    return _transitionFreshUpload(
      uid: uid,
      uploadSessionId: uploadSessionId,
      expected: CloudDataState.deleted,
      next: CloudDataState.freshUploadInProgress,
    );
  }

  @override
  Future<CloudMetadata> completeFreshUpload({
    required String uid,
    required String uploadSessionId,
  }) {
    return _transitionFreshUpload(
      uid: uid,
      uploadSessionId: uploadSessionId,
      expected: CloudDataState.freshUploadInProgress,
      next: CloudDataState.active,
    );
  }

  Future<CloudMetadata> _transitionFreshUpload({
    required String uid,
    required String uploadSessionId,
    required CloudDataState expected,
    required CloudDataState next,
  }) async {
    final DocumentReference<Map<String, dynamic>> doc = _docRef(uid);
    try {
      await _firestore.runTransaction<void>((Transaction transaction) async {
        final DocumentSnapshot<Map<String, dynamic>> snapshot =
            await transaction.get(doc);
        final CloudMetadata? current = snapshot.exists
            ? CloudMetadata.fromJson(snapshot.data() ?? <String, Object?>{})
            : null;
        if (current?.cloudDataState != expected) {
          throw CloudMetadataTransitionException(
            CloudMetadataTransitionFailureReason.stateMismatch,
            'Expected ${expected.name}, got ${current?.cloudDataState.name ?? 'missing'}.',
          );
        }
        transaction.update(doc, <String, Object?>{
          'cloudDataState': next.name,
          'freshUploadSessionId': uploadSessionId,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } on CloudMetadataTransitionException {
      rethrow;
    } on FirebaseException catch (error) {
      final CloudMetadataTransitionFailureReason reason = switch (error.code) {
        'permission-denied' =>
          CloudMetadataTransitionFailureReason.permissionDenied,
        'unauthenticated' =>
          CloudMetadataTransitionFailureReason.entitlementDenied,
        'unavailable' || 'deadline-exceeded' =>
          CloudMetadataTransitionFailureReason.networkFailure,
        _ => CloudMetadataTransitionFailureReason.networkFailure,
      };
      throw CloudMetadataTransitionException(
        reason,
        error.message ?? error.code,
      );
    }

    final CloudMetadata? readback = await getMetadata(uid);
    if (readback?.cloudDataState != next ||
        readback?.freshUploadSessionId != uploadSessionId) {
      throw CloudMetadataTransitionException(
        CloudMetadataTransitionFailureReason.readbackMismatch,
        'Fresh Upload metadata readback did not confirm ${next.name}.',
      );
    }
    return readback!;
  }
}

final Provider<CloudMetadataRepository> cloudMetadataRepositoryProvider =
    Provider<CloudMetadataRepository>((Ref ref) {
      return FirestoreCloudMetadataRepository(ref.watch(firestoreProvider));
    });
