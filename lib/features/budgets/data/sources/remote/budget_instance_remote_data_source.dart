import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kopim/features/budgets/domain/entities/budget_instance.dart';
import 'package:kopim/features/budgets/domain/entities/budget_instance_status.dart';

class BudgetInstanceRemoteDataSource {
  BudgetInstanceRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('budget_instances');
  }

  DocumentReference<Map<String, dynamic>> _doc(String userId, String id) {
    return _collection(userId).doc(id);
  }

  Future<void> upsert(String userId, BudgetInstance instance) {
    return _doc(
      userId,
      instance.id,
    ).set(_mapInstance(instance), SetOptions(merge: true));
  }

  Future<void> delete(String userId, BudgetInstance instance) {
    return _doc(userId, instance.id).set(<String, dynamic>{
      'id': instance.id,
      'deleted': true,
      'updatedAt': Timestamp.fromDate(instance.updatedAt.toUtc()),
    }, SetOptions(merge: true));
  }

  void upsertInTransaction(
    Transaction transaction,
    String userId,
    BudgetInstance instance,
  ) {
    transaction.set(
      _doc(userId, instance.id),
      _mapInstance(instance),
      SetOptions(merge: true),
    );
  }

  void deleteInTransaction(
    Transaction transaction,
    String userId,
    BudgetInstance instance,
  ) {
    transaction.set(_doc(userId, instance.id), <String, dynamic>{
      'id': instance.id,
      'deleted': true,
      'updatedAt': Timestamp.fromDate(instance.updatedAt.toUtc()),
    }, SetOptions(merge: true));
  }

  Future<List<BudgetInstance>> fetchAll(String userId) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _collection(
      userId,
    ).get();
    return snapshot.docs.map(_fromDocument).toList();
  }

  Map<String, dynamic> _mapInstance(BudgetInstance instance) {
    return <String, dynamic>{
      'id': instance.id,
      'budgetId': instance.budgetId,
      'periodStart': Timestamp.fromDate(instance.periodStart.toUtc()),
      'periodEnd': Timestamp.fromDate(instance.periodEnd.toUtc()),
      'amount': instance.amount,
      'spent': instance.spent,
      'status': instance.status.storageValue,
      'createdAt': Timestamp.fromDate(instance.createdAt.toUtc()),
      'updatedAt': Timestamp.fromDate(instance.updatedAt.toUtc()),
      'deleted': false,
    }..removeWhere((String key, Object? value) => value == null);
  }

  BudgetInstance _fromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final Map<String, dynamic> data = doc.data();
    final bool deleted = data['deleted'] as bool? ?? false;
    final BudgetInstanceStatus status = deleted
        ? BudgetInstanceStatus.closed
        : BudgetInstanceStatusX.fromStorage(data['status'] as String?);
    return BudgetInstance(
      id: data['id'] as String? ?? doc.id,
      budgetId: data['budgetId'] as String? ?? '',
      periodStart: _parseTimestamp(data['periodStart']),
      periodEnd: _parseTimestamp(data['periodEnd']),
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      spent: (data['spent'] as num?)?.toDouble() ?? 0,
      status: status,
      createdAt: _parseTimestamp(data['createdAt']),
      updatedAt: _parseTimestamp(data['updatedAt']),
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
