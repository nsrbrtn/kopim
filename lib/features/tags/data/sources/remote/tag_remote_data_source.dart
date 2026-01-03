import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kopim/features/tags/domain/entities/tag.dart';

class TagRemoteDataSource {
  TagRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore.collection('users').doc(userId).collection('tags');
  }

  DocumentReference<Map<String, dynamic>> _doc(String userId, String id) {
    return _collection(userId).doc(id);
  }

  Future<void> upsert(String userId, TagEntity tag) async {
    await _doc(userId, tag.id).set(
      mapTag(tag.copyWith(isDeleted: false)),
      SetOptions(merge: true),
    );
  }

  Future<void> delete(String userId, TagEntity tag) async {
    await _doc(userId, tag.id).set(
      mapTag(tag.copyWith(isDeleted: true)),
      SetOptions(merge: true),
    );
  }

  void upsertInTransaction(
    Transaction transaction,
    String userId,
    TagEntity tag,
  ) {
    transaction.set(
      _doc(userId, tag.id),
      mapTag(tag.copyWith(isDeleted: false)),
      SetOptions(merge: true),
    );
  }

  void deleteInTransaction(
    Transaction transaction,
    String userId,
    TagEntity tag,
  ) {
    transaction.set(
      _doc(userId, tag.id),
      mapTag(tag.copyWith(isDeleted: true)),
      SetOptions(merge: true),
    );
  }

  Future<List<TagEntity>> fetchAll(String userId) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _collection(
      userId,
    ).get();
    return snapshot.docs.map(_fromDocument).toList();
  }

  Map<String, dynamic> mapTag(TagEntity tag) {
    return <String, dynamic>{
      'id': tag.id,
      'name': tag.name,
      'color': tag.color,
      'createdAt': Timestamp.fromDate(tag.createdAt.toUtc()),
      'updatedAt': Timestamp.fromDate(tag.updatedAt.toUtc()),
      'isDeleted': tag.isDeleted,
    };
  }

  TagEntity _fromDocument(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> data = doc.data();
    return TagEntity(
      id: data['id'] as String? ?? doc.id,
      name: data['name'] as String? ?? '',
      color: data['color'] as String? ?? '',
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
