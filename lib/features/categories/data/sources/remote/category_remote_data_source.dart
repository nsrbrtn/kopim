import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';

class CategoryRemoteDataSource {
  CategoryRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore.collection('users').doc(userId).collection('categories');
  }

  Future<void> upsert(String userId, Category category) async {
    await _collection(userId)
        .doc(category.id)
        .set(_mapCategory(category), SetOptions(merge: true));
  }

  Future<void> delete(String userId, Category category) async {
    await _collection(userId)
        .doc(category.id)
        .set(_mapCategory(category.copyWith(isDeleted: true)), SetOptions(merge: true));
  }

  Map<String, dynamic> _mapCategory(Category category) {
    return {
      'id': category.id,
      'name': category.name,
      'type': category.type,
      'icon': category.icon,
      'color': category.color,
      'createdAt': Timestamp.fromDate(category.createdAt.toUtc()),
      'updatedAt': Timestamp.fromDate(category.updatedAt.toUtc()),
      'isDeleted': category.isDeleted,
    }..removeWhere((key, value) => value == null);
  }
}
