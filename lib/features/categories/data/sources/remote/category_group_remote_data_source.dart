import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kopim/features/categories/domain/entities/category_group.dart';

class CategoryGroupRemoteDataSource {
  CategoryGroupRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('category_groups');
  }

  DocumentReference<Map<String, dynamic>> _doc(String userId, String id) {
    return _collection(userId).doc(id);
  }

  Future<void> upsert(String userId, CategoryGroup group) async {
    await _doc(userId, group.id).set(mapGroup(group), SetOptions(merge: true));
  }

  Future<void> delete(String userId, CategoryGroup group) async {
    await _doc(
      userId,
      group.id,
    ).set(mapGroup(group.copyWith(isDeleted: true)), SetOptions(merge: true));
  }

  void upsertInTransaction(
    Transaction transaction,
    String userId,
    CategoryGroup group,
  ) {
    transaction.set(
      _doc(userId, group.id),
      mapGroup(group),
      SetOptions(merge: true),
    );
  }

  void deleteInTransaction(
    Transaction transaction,
    String userId,
    CategoryGroup group,
  ) {
    transaction.set(
      _doc(userId, group.id),
      mapGroup(group.copyWith(isDeleted: true)),
      SetOptions(merge: true),
    );
  }

  Future<List<CategoryGroup>> fetchAll(String userId) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _collection(
      userId,
    ).get();
    return snapshot.docs.map(_fromDocument).toList();
  }

  Map<String, dynamic> mapGroup(CategoryGroup group) {
    return <String, dynamic>{
      'id': group.id,
      'name': group.name,
      'sortOrder': group.sortOrder,
      'createdAt': Timestamp.fromDate(group.createdAt.toUtc()),
      'updatedAt': Timestamp.fromDate(group.updatedAt.toUtc()),
      'isDeleted': group.isDeleted,
    };
  }

  CategoryGroup _fromDocument(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> data = doc.data();
    return CategoryGroup(
      id: data['id'] as String? ?? doc.id,
      name: data['name'] as String? ?? '',
      sortOrder: data['sortOrder'] as int? ?? 0,
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
