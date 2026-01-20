import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kopim/core/money/money.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';

class CreditRemoteDataSource {
  CreditRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore.collection('users').doc(userId).collection('credits');
  }

  DocumentReference<Map<String, dynamic>> _doc(String userId, String id) {
    return _collection(userId).doc(id);
  }

  Future<void> upsert(String userId, CreditEntity credit) async {
    await _doc(
      userId,
      credit.id,
    ).set(_mapCredit(credit), SetOptions(merge: true));
  }

  Future<void> delete(String userId, CreditEntity credit) async {
    await _doc(userId, credit.id).set(
      _mapCredit(credit.copyWith(isDeleted: true)),
      SetOptions(merge: true),
    );
  }

  void upsertInTransaction(
    Transaction transaction,
    String userId,
    CreditEntity credit,
  ) {
    transaction.set(
      _doc(userId, credit.id),
      _mapCredit(credit),
      SetOptions(merge: true),
    );
  }

  void deleteInTransaction(
    Transaction transaction,
    String userId,
    CreditEntity credit,
  ) {
    transaction.set(
      _doc(userId, credit.id),
      _mapCredit(credit.copyWith(isDeleted: true)),
      SetOptions(merge: true),
    );
  }

  Future<List<CreditEntity>> fetchAll(String userId) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _collection(
      userId,
    ).get();
    return snapshot.docs.map(_fromDocument).toList(growable: false);
  }

  Map<String, dynamic> _mapCredit(CreditEntity credit) {
    final MoneyAmount totalAmount = credit.totalAmountValue;
    return <String, dynamic>{
      'id': credit.id,
      'accountId': credit.accountId,
      'categoryId': credit.categoryId,
      'totalAmount': totalAmount.toDouble(),
      'totalAmountMinor': totalAmount.minor.toString(),
      'totalAmountScale': totalAmount.scale,
      'interestRate': credit.interestRate,
      'termMonths': credit.termMonths,
      'startDate': Timestamp.fromDate(credit.startDate.toUtc()),
      'paymentDay': credit.paymentDay,
      'createdAt': Timestamp.fromDate(credit.createdAt.toUtc()),
      'updatedAt': Timestamp.fromDate(credit.updatedAt.toUtc()),
      'isDeleted': credit.isDeleted,
    }..removeWhere((String key, Object? value) => value == null);
  }

  CreditEntity _fromDocument(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> data = doc.data();
    final int scale = _readInt(data['totalAmountScale']) ?? 2;
    final double legacyTotal = (data['totalAmount'] as num?)?.toDouble() ?? 0;
    final BigInt? minor = _readBigInt(data['totalAmountMinor']);
    final BigInt resolvedMinor =
        minor ?? Money.fromDouble(legacyTotal, currency: 'XXX', scale: scale).minor;
    return CreditEntity(
      id: data['id'] as String? ?? doc.id,
      accountId: data['accountId'] as String? ?? '',
      categoryId: data['categoryId'] as String?,
      totalAmountMinor: resolvedMinor,
      totalAmountScale: scale,
      interestRate: (data['interestRate'] as num?)?.toDouble() ?? 0,
      termMonths: (data['termMonths'] as num?)?.toInt() ?? 0,
      startDate: _parseTimestamp(data['startDate']),
      paymentDay: (data['paymentDay'] as num?)?.toInt() ?? 1,
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
