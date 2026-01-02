import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kopim/features/credits/domain/entities/debt_entity.dart';

class DebtRemoteDataSource {
  DebtRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore.collection('users').doc(userId).collection('debts');
  }

  DocumentReference<Map<String, dynamic>> _doc(String userId, String id) {
    return _collection(userId).doc(id);
  }

  Future<void> upsert(String userId, DebtEntity debt) async {
    await _doc(userId, debt.id).set(_mapDebt(debt), SetOptions(merge: true));
  }

  Future<void> delete(String userId, DebtEntity debt) async {
    await _doc(
      userId,
      debt.id,
    ).set(_mapDebt(debt.copyWith(isDeleted: true)), SetOptions(merge: true));
  }

  void upsertInTransaction(
    Transaction transaction,
    String userId,
    DebtEntity debt,
  ) {
    transaction.set(
      _doc(userId, debt.id),
      _mapDebt(debt),
      SetOptions(merge: true),
    );
  }

  void deleteInTransaction(
    Transaction transaction,
    String userId,
    DebtEntity debt,
  ) {
    transaction.set(
      _doc(userId, debt.id),
      _mapDebt(debt.copyWith(isDeleted: true)),
      SetOptions(merge: true),
    );
  }

  Future<List<DebtEntity>> fetchAll(String userId) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _collection(
      userId,
    ).get();
    return snapshot.docs.map(_fromDocument).toList(growable: false);
  }

  Map<String, dynamic> _mapDebt(DebtEntity debt) {
    return <String, dynamic>{
      'id': debt.id,
      'accountId': debt.accountId,
      'name': debt.name,
      'amount': debt.amount,
      'dueDate': Timestamp.fromDate(debt.dueDate.toUtc()),
      'note': debt.note,
      'createdAt': Timestamp.fromDate(debt.createdAt.toUtc()),
      'updatedAt': Timestamp.fromDate(debt.updatedAt.toUtc()),
      'isDeleted': debt.isDeleted,
    }..removeWhere((String key, Object? value) => value == null);
  }

  DebtEntity _fromDocument(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> data = doc.data();
    return DebtEntity(
      id: data['id'] as String? ?? doc.id,
      accountId: data['accountId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      dueDate: _parseTimestamp(data['dueDate']),
      note: data['note'] as String?,
      createdAt: _parseTimestamp(data['createdAt']),
      updatedAt: _parseTimestamp(data['updatedAt']),
      isDeleted: data['isDeleted'] as bool? ?? false,
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
}
