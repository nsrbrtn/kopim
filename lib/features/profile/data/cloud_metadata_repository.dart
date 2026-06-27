import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/profile/domain/entities/cloud_metadata.dart';
import 'package:riverpod/riverpod.dart';

abstract class CloudMetadataRepository {
  Future<CloudMetadata?> getMetadata(String uid);
  Future<void> updateMetadata(String uid, CloudMetadata metadata);
  Future<void> setCloudDataState(String uid, CloudDataState state);
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
}

final Provider<CloudMetadataRepository> cloudMetadataRepositoryProvider =
    Provider<CloudMetadataRepository>((Ref ref) {
      return FirestoreCloudMetadataRepository(ref.watch(firestoreProvider));
    });
