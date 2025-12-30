import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kopim/features/upcoming_payments/domain/entities/payment_reminder.dart';

class PaymentReminderRemoteDataSource {
  PaymentReminderRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore.collection('users').doc(userId).collection('reminders');
  }

  DocumentReference<Map<String, dynamic>> _doc(String userId, String id) {
    return _collection(userId).doc(id);
  }

  Future<void> upsert(String userId, PaymentReminder reminder) async {
    await _doc(userId, reminder.id).set(
      _mapReminder(reminder),
      SetOptions(merge: true),
    );
  }

  Future<void> delete(String userId, PaymentReminder reminder) async {
    await _doc(userId, reminder.id).set(
      _mapReminder(reminder.copyWith(isDone: true)),
      SetOptions(merge: true),
    );
  }

  void upsertInTransaction(
    Transaction transaction,
    String userId,
    PaymentReminder reminder,
  ) {
    transaction.set(_doc(userId, reminder.id), _mapReminder(reminder));
  }

  void deleteInTransaction(
    Transaction transaction,
    String userId,
    PaymentReminder reminder,
  ) {
    transaction.set(
      _doc(userId, reminder.id),
      _mapReminder(reminder.copyWith(isDone: true)),
    );
  }

  Future<List<PaymentReminder>> fetchAll(String userId) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _collection(
      userId,
    ).get();
    return snapshot.docs.map(_fromDocument).toList(growable: false);
  }

  Map<String, dynamic> _mapReminder(PaymentReminder reminder) {
    return <String, dynamic>{
      'id': reminder.id,
      'title': reminder.title,
      'amount': reminder.amount,
      'whenAtMs': reminder.whenAtMs,
      'note': reminder.note,
      'isDone': reminder.isDone,
      'lastNotifiedAtMs': reminder.lastNotifiedAtMs,
      'createdAtMs': reminder.createdAtMs,
      'updatedAtMs': reminder.updatedAtMs,
    }..removeWhere((String key, Object? value) => value == null);
  }

  PaymentReminder _fromDocument(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> data = doc.data();
    return PaymentReminder(
      id: data['id'] as String? ?? doc.id,
      title: data['title'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      whenAtMs: (data['whenAtMs'] as num?)?.toInt() ?? 0,
      note: data['note'] as String?,
      isDone: data['isDone'] as bool? ?? false,
      lastNotifiedAtMs: (data['lastNotifiedAtMs'] as num?)?.toInt(),
      createdAtMs: (data['createdAtMs'] as num?)?.toInt() ?? 0,
      updatedAtMs: (data['updatedAtMs'] as num?)?.toInt() ?? 0,
    );
  }
}
