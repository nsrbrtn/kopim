import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';

class TransactionRemoteDataSource {
  TransactionRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions');
  }

  DocumentReference<Map<String, dynamic>> _doc(String userId, String id) {
    return _collection(userId).doc(id);
  }

  Future<void> upsert(String userId, TransactionEntity transaction) async {
    await _doc(
      userId,
      transaction.id,
    ).set(mapTransaction(transaction), SetOptions(merge: true));
  }

  Future<void> delete(String userId, TransactionEntity transaction) async {
    await _doc(userId, transaction.id).set(
      mapTransaction(transaction.copyWith(isDeleted: true)),
      SetOptions(merge: true),
    );
  }

  void upsertInTransaction(
    Transaction transaction,
    String userId,
    TransactionEntity entity,
  ) {
    transaction.set(
      _doc(userId, entity.id),
      mapTransaction(entity),
      SetOptions(merge: true),
    );
  }

  void deleteInTransaction(
    Transaction transaction,
    String userId,
    TransactionEntity entity,
  ) {
    transaction.set(
      _doc(userId, entity.id),
      mapTransaction(entity.copyWith(isDeleted: true)),
      SetOptions(merge: true),
    );
  }

  Future<List<TransactionEntity>> fetchAll(String userId) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _collection(
      userId,
    ).get();
    return snapshot.docs.map(_fromDocument).toList();
  }

  Map<String, dynamic> mapTransaction(TransactionEntity transaction) {
    return <String, dynamic>{
      'id': transaction.id,
      'accountId': transaction.accountId,
      'categoryId': transaction.categoryId,
      'savingGoalId': transaction.savingGoalId,
      'amount': transaction.amount,
      'date': Timestamp.fromDate(transaction.date.toUtc()),
      'note': transaction.note,
      'type': transaction.type,
      'createdAt': Timestamp.fromDate(transaction.createdAt.toUtc()),
      'updatedAt': Timestamp.fromDate(transaction.updatedAt.toUtc()),
      'isDeleted': transaction.isDeleted,
    }..removeWhere((String key, Object? value) => value == null);
  }

  TransactionEntity _fromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final Map<String, dynamic> data = doc.data();
    return TransactionEntity(
      id: data['id'] as String? ?? doc.id,
      accountId: data['accountId'] as String,
      categoryId: data['categoryId'] as String?,
      savingGoalId: data['savingGoalId'] as String?,
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      date: _parseTimestamp(data['date']),
      note: data['note'] as String?,
      type: data['type'] as String? ?? 'expense',
      createdAt: _parseTimestamp(data['createdAt']),
      updatedAt: _parseTimestamp(data['updatedAt']),
      isDeleted: data['isDeleted'] as bool? ?? false,
    );
  }

  DateTime _parseTimestamp(dynamic value) {
    if (value is Timestamp) {
      return value.toDate().toUtc();
    }
    if (value is DateTime) {
      return value.toUtc();
    }
    return DateTime.now().toUtc();
  }
}
