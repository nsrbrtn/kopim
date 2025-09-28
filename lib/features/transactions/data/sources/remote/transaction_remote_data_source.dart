import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';

class TransactionRemoteDataSource {
  TransactionRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore.collection('users').doc(userId).collection('transactions');
  }

  Future<void> upsert(String userId, TransactionEntity transaction) async {
    await _collection(userId)
        .doc(transaction.id)
        .set(_mapTransaction(transaction), SetOptions(merge: true));
  }

  Future<void> delete(String userId, TransactionEntity transaction) async {
    await _collection(userId)
        .doc(transaction.id)
        .set(_mapTransaction(transaction.copyWith(isDeleted: true)), SetOptions(merge: true));
  }

  Map<String, dynamic> _mapTransaction(TransactionEntity transaction) {
    return {
      'id': transaction.id,
      'accountId': transaction.accountId,
      'categoryId': transaction.categoryId,
      'amount': transaction.amount,
      'date': Timestamp.fromDate(transaction.date.toUtc()),
      'note': transaction.note,
      'type': transaction.type,
      'createdAt': Timestamp.fromDate(transaction.createdAt.toUtc()),
      'updatedAt': Timestamp.fromDate(transaction.updatedAt.toUtc()),
      'isDeleted': transaction.isDeleted,
    }..removeWhere((key, value) => value == null);
  }
}
