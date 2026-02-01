import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/upcoming_payment.dart';

class UpcomingPaymentRemoteDataSource {
  UpcomingPaymentRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('recurring_payments');
  }

  DocumentReference<Map<String, dynamic>> _doc(String userId, String id) {
    return _collection(userId).doc(id);
  }

  Future<void> upsert(String userId, UpcomingPayment payment) async {
    await _doc(
      userId,
      payment.id,
    ).set(_mapPayment(payment), SetOptions(merge: true));
  }

  Future<void> delete(String userId, UpcomingPayment payment) async {
    await _doc(userId, payment.id).set(
      _mapPayment(payment.copyWith(isActive: false)),
      SetOptions(merge: true),
    );
  }

  void upsertInTransaction(
    Transaction transaction,
    String userId,
    UpcomingPayment payment,
  ) {
    transaction.set(_doc(userId, payment.id), _mapPayment(payment));
  }

  void deleteInTransaction(
    Transaction transaction,
    String userId,
    UpcomingPayment payment,
  ) {
    transaction.set(
      _doc(userId, payment.id),
      _mapPayment(payment.copyWith(isActive: false)),
    );
  }

  Future<List<UpcomingPayment>> fetchAll(String userId) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _collection(
      userId,
    ).get();
    return snapshot.docs.map(_fromDocument).toList(growable: false);
  }

  Map<String, dynamic> _mapPayment(UpcomingPayment payment) {
    return <String, dynamic>{
      'id': payment.id,
      'title': payment.title,
      'accountId': payment.accountId,
      'categoryId': payment.categoryId,
      'amount': payment.amountValue.toDouble(),
      'amountMinor': payment.amountMinor?.toString(),
      'amountScale': payment.amountScale,
      'dayOfMonth': payment.dayOfMonth,
      'notifyDaysBefore': payment.notifyDaysBefore,
      'notifyTimeHhmm': payment.notifyTimeHhmm,
      'note': payment.note,
      'autoPost': payment.autoPost,
      'isActive': payment.isActive,
      'nextRunAtMs': payment.nextRunAtMs,
      'nextNotifyAtMs': payment.nextNotifyAtMs,
      'lastGeneratedPeriod': payment.lastGeneratedPeriod,
      'createdAtMs': payment.createdAtMs,
      'updatedAtMs': payment.updatedAtMs,
    }..removeWhere((String key, Object? value) => value == null);
  }

  UpcomingPayment _fromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final Map<String, dynamic> data = doc.data();
    return UpcomingPayment(
      id: data['id'] as String? ?? doc.id,
      title: data['title'] as String? ?? '',
      accountId: data['accountId'] as String? ?? '',
      categoryId: data['categoryId'] as String? ?? '',
      amountMinor: _readBigInt(data['amountMinor']),
      amountScale: _readInt(data['amountScale']),
      dayOfMonth: (data['dayOfMonth'] as num?)?.toInt() ?? 1,
      notifyDaysBefore: (data['notifyDaysBefore'] as num?)?.toInt() ?? 0,
      notifyTimeHhmm: data['notifyTimeHhmm'] as String? ?? '12:00',
      note: data['note'] as String?,
      autoPost: data['autoPost'] as bool? ?? false,
      isActive: data['isActive'] as bool? ?? true,
      nextRunAtMs: (data['nextRunAtMs'] as num?)?.toInt(),
      nextNotifyAtMs: (data['nextNotifyAtMs'] as num?)?.toInt(),
      lastGeneratedPeriod: data['lastGeneratedPeriod'] as String?,
      createdAtMs: (data['createdAtMs'] as num?)?.toInt() ?? 0,
      updatedAtMs: (data['updatedAtMs'] as num?)?.toInt() ?? 0,
    );
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
}
