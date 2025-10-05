import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kopim/features/savings/domain/entities/saving_goal.dart';

class SavingGoalRemoteDataSource {
  SavingGoalRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('saving_goals');
  }

  DocumentReference<Map<String, dynamic>> _doc(String userId, String id) {
    return _collection(userId).doc(id);
  }

  Future<void> upsert(String userId, SavingGoal goal) {
    return _doc(userId, goal.id).set(_mapGoal(goal), SetOptions(merge: true));
  }

  void upsertInTransaction(
    Transaction transaction,
    String userId,
    SavingGoal goal,
  ) {
    transaction.set(
      _doc(userId, goal.id),
      _mapGoal(goal),
      SetOptions(merge: true),
    );
  }

  Future<List<SavingGoal>> fetchAll(String userId) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _collection(
      userId,
    ).get();
    return snapshot.docs.map(_fromDocument).toList(growable: false);
  }

  Map<String, dynamic> _mapGoal(SavingGoal goal) {
    return <String, dynamic>{
      'id': goal.id,
      'userId': goal.userId,
      'name': goal.name,
      'targetAmount': goal.targetAmount,
      'currentAmount': goal.currentAmount,
      'note': goal.note,
      'createdAt': Timestamp.fromDate(goal.createdAt.toUtc()),
      'updatedAt': Timestamp.fromDate(goal.updatedAt.toUtc()),
      'archivedAt': goal.archivedAt != null
          ? Timestamp.fromDate(goal.archivedAt!.toUtc())
          : null,
    }..removeWhere((String key, Object? value) => value == null);
  }

  SavingGoal _fromDocument(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> data = doc.data();
    return SavingGoal(
      id: data['id'] as String? ?? doc.id,
      userId: data['userId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      targetAmount: (data['targetAmount'] as num?)?.toInt() ?? 0,
      currentAmount: (data['currentAmount'] as num?)?.toInt() ?? 0,
      note: data['note'] as String?,
      createdAt: _parseTimestamp(data['createdAt']),
      updatedAt: _parseTimestamp(data['updatedAt']),
      archivedAt: _parseOptionalTimestamp(data['archivedAt']),
    );
  }

  DateTime _parseTimestamp(Object? value) {
    if (value is Timestamp) {
      return value.toDate().toUtc();
    }
    if (value is DateTime) {
      return value.toUtc();
    }
    return DateTime.now().toUtc();
  }

  DateTime? _parseOptionalTimestamp(Object? value) {
    if (value == null) return null;
    return _parseTimestamp(value);
  }
}
