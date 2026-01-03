import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kopim/features/tags/domain/entities/transaction_tag.dart';

class TransactionTagRemoteDataSource {
  TransactionTagRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('transaction_tags');
  }

  DocumentReference<Map<String, dynamic>> _doc(
    String userId,
    TransactionTagEntity link,
  ) {
    return _collection(userId).doc(_docId(link.transactionId, link.tagId));
  }

  Future<void> upsert(String userId, TransactionTagEntity link) async {
    await _doc(userId, link).set(
      mapLink(link),
      SetOptions(merge: true),
    );
  }

  Future<void> delete(String userId, TransactionTagEntity link) async {
    await _doc(userId, link).set(
      mapLink(link.copyWith(isDeleted: true)),
      SetOptions(merge: true),
    );
  }

  void upsertInTransaction(
    Transaction transaction,
    String userId,
    TransactionTagEntity link,
  ) {
    transaction.set(
      _doc(userId, link),
      mapLink(link.copyWith(isDeleted: false)),
      SetOptions(merge: true),
    );
  }

  void deleteInTransaction(
    Transaction transaction,
    String userId,
    TransactionTagEntity link,
  ) {
    transaction.set(
      _doc(userId, link),
      mapLink(link.copyWith(isDeleted: true)),
      SetOptions(merge: true),
    );
  }

  Future<List<TransactionTagEntity>> fetchAll(String userId) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _collection(
      userId,
    ).get();
    return snapshot.docs.map(_fromDocument).toList();
  }

  Map<String, dynamic> mapLink(TransactionTagEntity link) {
    return <String, dynamic>{
      'transactionId': link.transactionId,
      'tagId': link.tagId,
      'createdAt': Timestamp.fromDate(link.createdAt.toUtc()),
      'updatedAt': Timestamp.fromDate(link.updatedAt.toUtc()),
      'isDeleted': link.isDeleted,
    };
  }

  TransactionTagEntity _fromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final Map<String, dynamic> data = doc.data();
    return TransactionTagEntity(
      transactionId: data['transactionId'] as String? ?? '',
      tagId: data['tagId'] as String? ?? '',
      createdAt: _parseTimestamp(data['createdAt']),
      updatedAt: _parseTimestamp(data['updatedAt']),
      isDeleted: data['isDeleted'] as bool? ?? false,
    );
  }

  String _docId(String transactionId, String tagId) {
    return '$transactionId::$tagId';
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
