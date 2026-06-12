import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kopim/core/money/money.dart';
import 'package:kopim/features/credits/domain/entities/credit_payment_group.dart';

class CreditPaymentGroupRemoteDataSource {
  CreditPaymentGroupRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('credit_payment_groups');
  }

  DocumentReference<Map<String, dynamic>> _doc(String userId, String id) {
    return _collection(userId).doc(id);
  }

  Future<void> upsert(String userId, CreditPaymentGroupEntity group) async {
    await _doc(userId, group.id).set(_mapGroup(group), SetOptions(merge: true));
  }

  Future<void> delete(String userId, CreditPaymentGroupEntity group) async {
    await _doc(
      userId,
      group.id,
    ).set(_mapGroup(group.copyWith(isDeleted: true)), SetOptions(merge: true));
  }

  void upsertInTransaction(
    Transaction transaction,
    String userId,
    CreditPaymentGroupEntity group,
  ) {
    transaction.set(
      _doc(userId, group.id),
      _mapGroup(group),
      SetOptions(merge: true),
    );
  }

  void deleteInTransaction(
    Transaction transaction,
    String userId,
    CreditPaymentGroupEntity group,
  ) {
    transaction.set(
      _doc(userId, group.id),
      _mapGroup(group.copyWith(isDeleted: true)),
      SetOptions(merge: true),
    );
  }

  Future<List<CreditPaymentGroupEntity>> fetchAll(String userId) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _collection(
      userId,
    ).get();
    return snapshot.docs.map(_fromDocument).toList(growable: false);
  }

  Map<String, dynamic> _mapGroup(CreditPaymentGroupEntity group) {
    final Money totalOutflow = group.totalOutflow;
    final Money principalPaid = group.principalPaid;
    final Money interestPaid = group.interestPaid;
    final Money feesPaid = group.feesPaid;
    return <String, dynamic>{
      'id': group.id,
      'creditId': group.creditId,
      'sourceAccountId': group.sourceAccountId,
      'scheduleItemId': group.scheduleItemId,
      'paidAt': Timestamp.fromDate(group.paidAt.toUtc()),
      'totalOutflowMinor': totalOutflow.minor.toString(),
      'totalOutflowScale': totalOutflow.scale,
      'principalPaidMinor': principalPaid.minor.toString(),
      'interestPaidMinor': interestPaid.minor.toString(),
      'feesPaidMinor': feesPaid.minor.toString(),
      'note': group.note,
      'idempotencyKey': group.idempotencyKey,
      'createdAt': Timestamp.fromDate(
        (group.createdAt ?? group.updatedAt ?? group.paidAt).toUtc(),
      ),
      'updatedAt': Timestamp.fromDate(
        (group.updatedAt ?? group.createdAt ?? group.paidAt).toUtc(),
      ),
      'isDeleted': group.isDeleted,
    }..removeWhere((String key, Object? value) => value == null);
  }

  CreditPaymentGroupEntity _fromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final Map<String, dynamic> data = doc.data();
    final int scale = _readInt(data['totalOutflowScale']) ?? 2;
    return CreditPaymentGroupEntity(
      id: data['id'] as String? ?? doc.id,
      creditId: data['creditId'] as String? ?? '',
      sourceAccountId: data['sourceAccountId'] as String? ?? '',
      scheduleItemId: data['scheduleItemId'] as String?,
      paidAt: _parseTimestamp(data['paidAt']),
      totalOutflow: Money.fromMinor(
        _readBigInt(data['totalOutflowMinor']) ?? BigInt.zero,
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
      feesPaid: Money.fromMinor(
        _readBigInt(data['feesPaidMinor']) ?? BigInt.zero,
        currency: 'XXX',
        scale: scale,
      ),
      note: data['note'] as String?,
      idempotencyKey: data['idempotencyKey'] as String?,
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
