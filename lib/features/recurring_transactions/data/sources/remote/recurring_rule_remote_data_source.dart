import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kopim/features/recurring_transactions/domain/entities/recurring_rule.dart';

class RecurringRuleRemoteDataSource {
  RecurringRuleRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('recurring_rules');
  }

  DocumentReference<Map<String, dynamic>> _doc(String userId, String id) {
    return _collection(userId).doc(id);
  }

  Future<void> upsert(String userId, RecurringRule rule) {
    return _doc(userId, rule.id).set(_mapRule(rule), SetOptions(merge: true));
  }

  void upsertInTransaction(
    Transaction transaction,
    String userId,
    RecurringRule rule,
  ) {
    transaction.set(
      _doc(userId, rule.id),
      _mapRule(rule),
      SetOptions(merge: true),
    );
  }

  Future<void> delete(String userId, RecurringRule rule) {
    return _doc(userId, rule.id).delete();
  }

  void deleteInTransaction(
    Transaction transaction,
    String userId,
    RecurringRule rule,
  ) {
    transaction.delete(_doc(userId, rule.id));
  }

  Future<List<RecurringRule>> fetchAll(String userId) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _collection(
      userId,
    ).get();
    return snapshot.docs.map(_fromDocument).toList(growable: false);
  }

  Map<String, dynamic> _mapRule(RecurringRule rule) {
    return <String, dynamic>{
      'id': rule.id,
      'title': rule.title,
      'accountId': rule.accountId,
      'categoryId': rule.categoryId,
      'amount': rule.amount,
      'currency': rule.currency,
      'startAt': Timestamp.fromDate(rule.startAt.toUtc()),
      'endAt': rule.endAt != null
          ? Timestamp.fromDate(rule.endAt!.toUtc())
          : null,
      'timezone': rule.timezone,
      'rrule': rule.rrule,
      'notes': rule.notes,
      'dayOfMonth': rule.dayOfMonth,
      'applyAtLocalHour': rule.applyAtLocalHour,
      'applyAtLocalMinute': rule.applyAtLocalMinute,
      'lastRunAt': rule.lastRunAt != null
          ? Timestamp.fromDate(rule.lastRunAt!.toUtc())
          : null,
      'nextDueLocalDate': rule.nextDueLocalDate != null
          ? Timestamp.fromDate(rule.nextDueLocalDate!.toUtc())
          : null,
      'isActive': rule.isActive,
      'autoPost': rule.autoPost,
      'reminderMinutesBefore': rule.reminderMinutesBefore,
      'shortMonthPolicy': rule.shortMonthPolicy.value,
      'createdAt': Timestamp.fromDate(rule.createdAt.toUtc()),
      'updatedAt': Timestamp.fromDate(rule.updatedAt.toUtc()),
    }..removeWhere((String key, Object? value) => value == null);
  }

  RecurringRule _fromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final Map<String, dynamic> data = snapshot.data();
    return RecurringRule(
      id: data['id'] as String? ?? snapshot.id,
      title: data['title'] as String? ?? '',
      accountId: data['accountId'] as String? ?? '',
      categoryId: data['categoryId'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      currency: data['currency'] as String? ?? 'USD',
      startAt: _parseTimestamp(data['startAt']),
      endAt: _parseOptionalTimestamp(data['endAt']),
      timezone: data['timezone'] as String? ?? 'UTC',
      rrule: data['rrule'] as String? ?? 'FREQ=MONTHLY;INTERVAL=1',
      notes: data['notes'] as String?,
      dayOfMonth: (data['dayOfMonth'] as num?)?.toInt() ?? 1,
      applyAtLocalHour: (data['applyAtLocalHour'] as num?)?.toInt() ?? 0,
      applyAtLocalMinute: (data['applyAtLocalMinute'] as num?)?.toInt() ?? 0,
      lastRunAt: _parseOptionalTimestamp(data['lastRunAt']),
      nextDueLocalDate: _parseOptionalTimestamp(data['nextDueLocalDate']),
      isActive: data['isActive'] as bool? ?? true,
      autoPost: data['autoPost'] as bool? ?? false,
      reminderMinutesBefore: (data['reminderMinutesBefore'] as num?)?.toInt(),
      shortMonthPolicy: data['shortMonthPolicy'] is String
          ? RecurringRuleShortMonthPolicy.fromValue(
              data['shortMonthPolicy'] as String,
            )
          : RecurringRuleShortMonthPolicy.clipToLastDay,
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

  DateTime? _parseOptionalTimestamp(Object? value) {
    if (value == null) {
      return null;
    }
    return _parseTimestamp(value);
  }
}
