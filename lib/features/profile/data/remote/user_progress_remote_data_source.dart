import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kopim/features/profile/domain/repositories/user_progress_repository.dart';

class UserProgressRemoteDataSource {
  UserProgressRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _doc(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('progress')
        .doc('progress');
  }

  Future<ProgressSnapshot?> fetch(String uid) async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot = await _doc(
      uid,
    ).get();
    if (!snapshot.exists) {
      return null;
    }
    final Map<String, dynamic> data = snapshot.data()!;
    final int totalTx = (data['total_tx'] as num?)?.toInt() ?? 0;
    final Timestamp? updatedAtRaw = data['updated_at'] as Timestamp?;
    final DateTime updatedAt = (updatedAtRaw ?? Timestamp.now())
        .toDate()
        .toUtc();
    return ProgressSnapshot(totalTx: totalTx, updatedAt: updatedAt);
  }

  Future<void> upsert({
    required String uid,
    required int totalTx,
    required DateTime updatedAt,
  }) async {
    await _doc(uid).set(<String, dynamic>{
      'total_tx': totalTx,
      'updated_at': Timestamp.fromDate(updatedAt.toUtc()),
    }, SetOptions(merge: true));
  }
}
