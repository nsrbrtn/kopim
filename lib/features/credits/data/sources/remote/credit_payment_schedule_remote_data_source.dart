import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kopim/core/money/money.dart';
import 'package:kopim/features/credits/domain/entities/credit_payment_schedule.dart';

class CreditPaymentScheduleRemoteDataSource {
  CreditPaymentScheduleRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('credit_payment_schedules');
  }

  DocumentReference<Map<String, dynamic>> _doc(String userId, String id) {
    return _collection(userId).doc(id);
  }

  Future<void> upsert(
    String userId,
    CreditPaymentScheduleEntity schedule,
  ) async {
    await _doc(
      userId,
      schedule.id,
    ).set(_mapSchedule(schedule), SetOptions(merge: true));
  }

  Future<void> delete(
    String userId,
    CreditPaymentScheduleEntity schedule,
  ) async {
    await _doc(userId, schedule.id).set(
      _mapSchedule(schedule.copyWith(isDeleted: true)),
      SetOptions(merge: true),
    );
  }

  void upsertInTransaction(
    Transaction transaction,
    String userId,
    CreditPaymentScheduleEntity schedule,
  ) {
    transaction.set(
      _doc(userId, schedule.id),
      _mapSchedule(schedule),
      SetOptions(merge: true),
    );
  }

  void deleteInTransaction(
    Transaction transaction,
    String userId,
    CreditPaymentScheduleEntity schedule,
  ) {
    transaction.set(
      _doc(userId, schedule.id),
      _mapSchedule(schedule.copyWith(isDeleted: true)),
      SetOptions(merge: true),
    );
  }

  Future<List<CreditPaymentScheduleEntity>> fetchAll(String userId) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _collection(
      userId,
    ).get();
    return snapshot.docs.map(fromDocument).toList(growable: false);
  }

  Map<String, dynamic> toFirestorePayload(
    CreditPaymentScheduleEntity schedule,
  ) => _mapSchedule(schedule);

  Map<String, dynamic> _mapSchedule(CreditPaymentScheduleEntity schedule) {
    final Money totalAmount = schedule.totalAmount;
    final Money principalAmount = schedule.principalAmount;
    final Money interestAmount = schedule.interestAmount;
    final Money principalPaid = schedule.principalPaid;
    final Money interestPaid = schedule.interestPaid;
    return <String, dynamic>{
      'id': schedule.id,
      'creditId': schedule.creditId,
      'periodKey': schedule.periodKey,
      'dueDate': Timestamp.fromDate(schedule.dueDate.toUtc()),
      'status': schedule.status.name,
      'principalAmountMinor': principalAmount.minor.toString(),
      'interestAmountMinor': interestAmount.minor.toString(),
      'totalAmountMinor': totalAmount.minor.toString(),
      'amountScale': totalAmount.scale,
      'principalPaidMinor': principalPaid.minor.toString(),
      'interestPaidMinor': interestPaid.minor.toString(),
      'paidAt': schedule.paidAt == null
          ? null
          : Timestamp.fromDate(schedule.paidAt!.toUtc()),
      'createdAt': Timestamp.fromDate(
        (schedule.createdAt ?? schedule.updatedAt ?? schedule.dueDate).toUtc(),
      ),
      'updatedAt': Timestamp.fromDate(
        (schedule.updatedAt ?? schedule.createdAt ?? schedule.dueDate).toUtc(),
      ),
      'isDeleted': schedule.isDeleted,
    }..removeWhere((String key, Object? value) => value == null);
  }

  CreditPaymentScheduleEntity fromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final Map<String, dynamic> data = doc.data();
    final int scale = _readInt(data['amountScale']) ?? 2;
    return CreditPaymentScheduleEntity(
      id: data['id'] as String? ?? doc.id,
      creditId: data['creditId'] as String? ?? '',
      periodKey: data['periodKey'] as String? ?? '',
      dueDate: _parseTimestamp(data['dueDate']),
      status: CreditPaymentStatus.values.byName(
        data['status'] as String? ?? CreditPaymentStatus.planned.name,
      ),
      principalAmount: Money.fromMinor(
        _readBigInt(data['principalAmountMinor']) ?? BigInt.zero,
        currency: 'XXX',
        scale: scale,
      ),
      interestAmount: Money.fromMinor(
        _readBigInt(data['interestAmountMinor']) ?? BigInt.zero,
        currency: 'XXX',
        scale: scale,
      ),
      totalAmount: Money.fromMinor(
        _readBigInt(data['totalAmountMinor']) ?? BigInt.zero,
        currency: 'XXX',
        scale: scale,
      ),
      principalPaid: Money.fromMinor(
        _readBigInt(data['principalPaidMinor']) ?? BigInt.zero,
        currency: 'XXX',
        scale: scale,
      ),
      interestPaid: Money.fromMinor(
        _readBigInt(data['interestPaidMinor']) ?? BigInt.zero,
        currency: 'XXX',
        scale: scale,
      ),
      paidAt: data['paidAt'] == null ? null : _parseTimestamp(data['paidAt']),
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
}
