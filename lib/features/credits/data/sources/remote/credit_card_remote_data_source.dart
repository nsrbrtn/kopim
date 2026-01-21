import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kopim/core/money/money.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/credits/domain/entities/credit_card_entity.dart';

class CreditCardRemoteDataSource {
  CreditCardRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('credit_cards');
  }

  DocumentReference<Map<String, dynamic>> _doc(String userId, String id) {
    return _collection(userId).doc(id);
  }

  Future<void> upsert(String userId, CreditCardEntity creditCard) async {
    await _doc(
      userId,
      creditCard.id,
    ).set(_mapCreditCard(creditCard), SetOptions(merge: true));
  }

  Future<void> delete(String userId, CreditCardEntity creditCard) async {
    await _doc(userId, creditCard.id).set(
      _mapCreditCard(creditCard.copyWith(isDeleted: true)),
      SetOptions(merge: true),
    );
  }

  void upsertInTransaction(
    Transaction transaction,
    String userId,
    CreditCardEntity creditCard,
  ) {
    transaction.set(
      _doc(userId, creditCard.id),
      _mapCreditCard(creditCard),
      SetOptions(merge: true),
    );
  }

  void deleteInTransaction(
    Transaction transaction,
    String userId,
    CreditCardEntity creditCard,
  ) {
    transaction.set(
      _doc(userId, creditCard.id),
      _mapCreditCard(creditCard.copyWith(isDeleted: true)),
      SetOptions(merge: true),
    );
  }

  Future<List<CreditCardEntity>> fetchAll(String userId) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _collection(
      userId,
    ).get();
    return snapshot.docs.map(_fromDocument).toList(growable: false);
  }

  Map<String, dynamic> _mapCreditCard(CreditCardEntity creditCard) {
    final MoneyAmount limit = creditCard.creditLimitValue;
    return <String, dynamic>{
      'id': creditCard.id,
      'accountId': creditCard.accountId,
      'creditLimit': limit.toDouble(),
      'creditLimitMinor': limit.minor.toString(),
      'creditLimitScale': limit.scale,
      'statementDay': creditCard.statementDay,
      'paymentDueDays': creditCard.paymentDueDays,
      'interestRateAnnual': creditCard.interestRateAnnual,
      'createdAt': Timestamp.fromDate(creditCard.createdAt.toUtc()),
      'updatedAt': Timestamp.fromDate(creditCard.updatedAt.toUtc()),
      'isDeleted': creditCard.isDeleted,
    };
  }

  CreditCardEntity _fromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final Map<String, dynamic> data = doc.data();
    final int scale = _readInt(data['creditLimitScale']) ?? 2;
    final double legacyLimit = (data['creditLimit'] as num?)?.toDouble() ?? 0;
    final BigInt? minor = _readBigInt(data['creditLimitMinor']);
    final BigInt resolvedMinor =
        minor ??
        Money.fromDouble(legacyLimit, currency: 'XXX', scale: scale).minor;
    return CreditCardEntity(
      id: data['id'] as String? ?? doc.id,
      accountId: data['accountId'] as String? ?? '',
      creditLimitMinor: resolvedMinor,
      creditLimitScale: scale,
      statementDay: (data['statementDay'] as num?)?.toInt() ?? 1,
      paymentDueDays: (data['paymentDueDays'] as num?)?.toInt() ?? 0,
      interestRateAnnual: (data['interestRateAnnual'] as num?)?.toDouble() ?? 0,
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
