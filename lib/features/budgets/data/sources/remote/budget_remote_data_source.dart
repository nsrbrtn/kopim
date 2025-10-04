import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kopim/features/budgets/domain/entities/budget.dart';
import 'package:kopim/features/budgets/domain/entities/budget_period.dart';
import 'package:kopim/features/budgets/domain/entities/budget_scope.dart';

class BudgetRemoteDataSource {
  BudgetRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore.collection('users').doc(userId).collection('budgets');
  }

  DocumentReference<Map<String, dynamic>> _doc(String userId, String id) {
    return _collection(userId).doc(id);
  }

  Future<void> upsert(String userId, Budget budget) {
    return _doc(
      userId,
      budget.id,
    ).set(_mapBudget(budget), SetOptions(merge: true));
  }

  Future<void> delete(String userId, Budget budget) {
    return _doc(userId, budget.id).set(
      _mapBudget(budget.copyWith(isDeleted: true)),
      SetOptions(merge: true),
    );
  }

  void upsertInTransaction(
    Transaction transaction,
    String userId,
    Budget budget,
  ) {
    transaction.set(
      _doc(userId, budget.id),
      _mapBudget(budget),
      SetOptions(merge: true),
    );
  }

  void deleteInTransaction(
    Transaction transaction,
    String userId,
    Budget budget,
  ) {
    transaction.set(
      _doc(userId, budget.id),
      _mapBudget(budget.copyWith(isDeleted: true)),
      SetOptions(merge: true),
    );
  }

  Future<List<Budget>> fetchAll(String userId) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _collection(
      userId,
    ).get();
    return snapshot.docs.map(_fromDocument).toList();
  }

  Map<String, dynamic> _mapBudget(Budget budget) {
    return <String, dynamic>{
      'id': budget.id,
      'title': budget.title,
      'period': budget.period.storageValue,
      'startDate': Timestamp.fromDate(budget.startDate.toUtc()),
      'endDate': budget.endDate != null
          ? Timestamp.fromDate(budget.endDate!.toUtc())
          : null,
      'amount': budget.amount,
      'scope': budget.scope.storageValue,
      'categories': budget.categories,
      'accounts': budget.accounts,
      'createdAt': Timestamp.fromDate(budget.createdAt.toUtc()),
      'updatedAt': Timestamp.fromDate(budget.updatedAt.toUtc()),
      'isDeleted': budget.isDeleted,
    }..removeWhere((String key, Object? value) => value == null);
  }

  Budget _fromDocument(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> data = doc.data();
    return Budget(
      id: data['id'] as String? ?? doc.id,
      title: data['title'] as String? ?? '',
      period: BudgetPeriodX.fromStorage(data['period'] as String?),
      startDate: _parseTimestamp(data['startDate']),
      endDate: _parseOptionalTimestamp(data['endDate']),
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      scope: BudgetScopeX.fromStorage(data['scope'] as String?),
      categories: _parseStringList(data['categories']),
      accounts: _parseStringList(data['accounts']),
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

  DateTime? _parseOptionalTimestamp(Object? value) {
    if (value == null) return null;
    return _parseTimestamp(value);
  }

  List<String> _parseStringList(Object? value) {
    if (value is Iterable) {
      return value
          .whereType<Object?>()
          .map((Object? item) => item?.toString() ?? '')
          .where((String item) => item.isNotEmpty)
          .toList();
    }
    return const <String>[];
  }
}
