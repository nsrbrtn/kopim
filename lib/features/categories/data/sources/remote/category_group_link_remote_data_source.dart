import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kopim/features/categories/domain/entities/category_group_link.dart';

class CategoryGroupLinkRemoteDataSource {
  CategoryGroupLinkRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('category_group_links');
  }

  DocumentReference<Map<String, dynamic>> _doc(
    String userId,
    String groupId,
    String categoryId,
  ) {
    return _collection(userId).doc('$groupId:$categoryId');
  }

  Future<void> upsert(String userId, CategoryGroupLink link) async {
    await _doc(
      userId,
      link.groupId,
      link.categoryId,
    ).set(mapLink(link), SetOptions(merge: true));
  }

  Future<void> delete(String userId, CategoryGroupLink link) async {
    await _doc(
      userId,
      link.groupId,
      link.categoryId,
    ).set(mapLink(link.copyWith(isDeleted: true)), SetOptions(merge: true));
  }

  void upsertInTransaction(
    Transaction transaction,
    String userId,
    CategoryGroupLink link,
  ) {
    transaction.set(
      _doc(userId, link.groupId, link.categoryId),
      mapLink(link),
      SetOptions(merge: true),
    );
  }

  void deleteInTransaction(
    Transaction transaction,
    String userId,
    CategoryGroupLink link,
  ) {
    transaction.set(
      _doc(userId, link.groupId, link.categoryId),
      mapLink(link.copyWith(isDeleted: true)),
      SetOptions(merge: true),
    );
  }

  Future<List<CategoryGroupLink>> fetchAll(String userId) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _collection(
      userId,
    ).get();
    return snapshot.docs.map(_fromDocument).toList();
  }

  Map<String, dynamic> mapLink(CategoryGroupLink link) {
    return <String, dynamic>{
      'groupId': link.groupId,
      'categoryId': link.categoryId,
      'createdAt': Timestamp.fromDate(link.createdAt.toUtc()),
      'updatedAt': Timestamp.fromDate(link.updatedAt.toUtc()),
      'isDeleted': link.isDeleted,
    };
  }

  CategoryGroupLink _fromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final Map<String, dynamic> data = doc.data();
    return CategoryGroupLink(
      groupId: data['groupId'] as String? ?? '',
      categoryId: data['categoryId'] as String? ?? '',
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
