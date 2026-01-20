import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kopim/core/money/money.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/budgets/domain/entities/budget.dart';
import 'package:kopim/features/budgets/domain/entities/budget_category_allocation.dart';
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
    final MoneyAmount amount = budget.amountValue;
    return <String, dynamic>{
      'id': budget.id,
      'title': budget.title,
      'period': budget.period.storageValue,
      'startDate': Timestamp.fromDate(budget.startDate.toUtc()),
      'endDate': budget.endDate != null
          ? Timestamp.fromDate(budget.endDate!.toUtc())
          : null,
      'amount': amount.toDouble(),
      'amountMinor': amount.minor.toString(),
      'amountScale': amount.scale,
      'scope': budget.scope.storageValue,
      'categories': budget.categories,
      'accounts': budget.accounts,
      'categoryAllocations': budget.categoryAllocations
          .map((BudgetCategoryAllocation allocation) => allocation.toJson())
          .toList(),
      'createdAt': Timestamp.fromDate(budget.createdAt.toUtc()),
      'updatedAt': Timestamp.fromDate(budget.updatedAt.toUtc()),
      'isDeleted': budget.isDeleted,
    }..removeWhere((String key, Object? value) => value == null);
  }

  Budget _fromDocument(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> data = doc.data();
    final int scale = _readInt(data['amountScale']) ?? 2;
    final double legacyAmount = (data['amount'] as num?)?.toDouble() ?? 0;
    final BigInt? minor = _readBigInt(data['amountMinor']);
    final BigInt resolvedMinor =
        minor ?? Money.fromDouble(legacyAmount, currency: 'XXX', scale: scale).minor;
    return Budget(
      id: data['id'] as String? ?? doc.id,
      title: data['title'] as String? ?? '',
      period: BudgetPeriodX.fromStorage(data['period'] as String?),
      startDate: _parseTimestamp(data['startDate']),
      endDate: _parseOptionalTimestamp(data['endDate']),
      amountMinor: resolvedMinor,
      amountScale: scale,
      scope: BudgetScopeX.fromStorage(data['scope'] as String?),
      categories: _parseStringList(data['categories']),
      accounts: _parseStringList(data['accounts']),
      categoryAllocations: _parseAllocations(data['categoryAllocations']),
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

  BigInt? _readBigInt(Object? value) {
    if (value == null) return null;
    if (value is BigInt) return value;
    if (value is int) return BigInt.from(value);
    if (value is num) return BigInt.from(value.toInt());
    return BigInt.tryParse(value.toString());
  }

  int? _readInt(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
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

  List<BudgetCategoryAllocation> _parseAllocations(Object? value) {
    if (value is Iterable) {
      return value
          .map((Object? item) {
            if (item is Map<String, dynamic>) {
              return item;
            }
            if (item is Map<Object?, Object?>) {
              return item.map(
                (Object? key, Object? value) =>
                    MapEntry<String, dynamic>(key?.toString() ?? '', value),
              );
            }
            return null;
          })
          .whereType<Map<String, dynamic>>()
          .map(BudgetCategoryAllocation.fromJson)
          .toList();
    }
    return const <BudgetCategoryAllocation>[];
  }
}
