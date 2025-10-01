import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kopim/core/domain/icons/phosphor_icon_descriptor.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';

class CategoryRemoteDataSource {
  CategoryRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore.collection('users').doc(userId).collection('categories');
  }

  DocumentReference<Map<String, dynamic>> _doc(String userId, String id) {
    return _collection(userId).doc(id);
  }

  Future<void> upsert(String userId, Category category) async {
    await _doc(
      userId,
      category.id,
    ).set(mapCategory(category), SetOptions(merge: true));
  }

  Future<void> delete(String userId, Category category) async {
    await _doc(userId, category.id).set(
      mapCategory(category.copyWith(isDeleted: true)),
      SetOptions(merge: true),
    );
  }

  void upsertInTransaction(
    Transaction transaction,
    String userId,
    Category category,
  ) {
    transaction.set(
      _doc(userId, category.id),
      mapCategory(category),
      SetOptions(merge: true),
    );
  }

  void deleteInTransaction(
    Transaction transaction,
    String userId,
    Category category,
  ) {
    transaction.set(
      _doc(userId, category.id),
      mapCategory(category.copyWith(isDeleted: true)),
      SetOptions(merge: true),
    );
  }

  Future<List<Category>> fetchAll(String userId) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _collection(
      userId,
    ).get();
    return snapshot.docs.map(_fromDocument).toList();
  }

  Map<String, dynamic> mapCategory(Category category) {
    return <String, dynamic>{
      'id': category.id,
      'name': category.name,
      'type': category.type,
      'icon': category.icon?.name,
      'iconName': category.icon?.name,
      'iconStyle': category.icon?.style.label,
      'iconDescriptor': category.icon?.toJson(),
      'color': category.color,
      'parentId': category.parentId,
      'createdAt': Timestamp.fromDate(category.createdAt.toUtc()),
      'updatedAt': Timestamp.fromDate(category.updatedAt.toUtc()),
      'isDeleted': category.isDeleted,
    }..removeWhere((String key, Object? value) => value == null);
  }

  Category _fromDocument(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> data = doc.data();
    PhosphorIconDescriptor? descriptor;
    final Object? iconDescriptorRaw = data['iconDescriptor'];
    if (iconDescriptorRaw is Map<String, Object?>) {
      descriptor = PhosphorIconDescriptor.fromJson(iconDescriptorRaw);
    } else {
      final String? iconName = (data['iconName'] ?? data['icon']) as String?;
      if (iconName != null && iconName.isNotEmpty) {
        descriptor = PhosphorIconDescriptor(
          name: iconName,
          style: PhosphorIconStyleX.fromName(data['iconStyle'] as String?),
        );
      }
    }
    return Category(
      id: data['id'] as String? ?? doc.id,
      name: data['name'] as String? ?? '',
      type: data['type'] as String? ?? 'unknown',
      icon: descriptor,
      color: data['color'] as String?,
      parentId: data['parentId'] as String?,
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
