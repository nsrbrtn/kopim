import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kopim/core/money/currency_scale.dart';
import 'package:kopim/core/money/money.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';

class AccountRemoteDataSource {
  AccountRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore.collection('users').doc(userId).collection('accounts');
  }

  DocumentReference<Map<String, dynamic>> _doc(String userId, String id) {
    return _collection(userId).doc(id);
  }

  Future<void> upsert(String userId, AccountEntity account) async {
    await _doc(
      userId,
      account.id,
    ).set(mapAccount(account), SetOptions(merge: true));
  }

  Future<void> delete(String userId, AccountEntity account) async {
    await _doc(userId, account.id).set(
      mapAccount(account.copyWith(isDeleted: true)),
      SetOptions(merge: true),
    );
  }

  void upsertInTransaction(
    Transaction transaction,
    String userId,
    AccountEntity account,
  ) {
    transaction.set(
      _doc(userId, account.id),
      mapAccount(account),
      SetOptions(merge: true),
    );
  }

  void deleteInTransaction(
    Transaction transaction,
    String userId,
    AccountEntity account,
  ) {
    transaction.set(
      _doc(userId, account.id),
      mapAccount(account.copyWith(isDeleted: true)),
      SetOptions(merge: true),
    );
  }

  Future<List<AccountEntity>> fetchAll(String userId) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _collection(
      userId,
    ).get();
    return snapshot.docs.map(_fromDocument).toList();
  }

  Map<String, dynamic> mapAccount(AccountEntity account) {
    final MoneyAmount balance = account.balanceAmount;
    final MoneyAmount openingBalance = account.openingBalanceAmount;
    return <String, dynamic>{
      'id': account.id,
      'name': account.name,
      'currency': account.currency,
      'type': account.type,
      'createdAt': Timestamp.fromDate(account.createdAt.toUtc()),
      'updatedAt': Timestamp.fromDate(account.updatedAt.toUtc()),
      'isDeleted': account.isDeleted,
      'balance': balance.toDouble(),
      'balanceMinor': balance.minor.toString(),
      'openingBalance': openingBalance.toDouble(),
      'openingBalanceMinor': openingBalance.minor.toString(),
      'currencyScale': account.currencyScale,
      'isPrimary': account.isPrimary,
      'isHidden': account.isHidden,
      'color': account.color,
      'gradientId': account.gradientId,
      'iconName': account.iconName,
      'iconStyle': account.iconStyle,
    };
  }

  AccountEntity _fromDocument(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> data = doc.data();
    final String currency = data['currency'] as String? ?? 'RUB';
    final int scale =
        _readInt(data['currencyScale']) ?? resolveCurrencyScale(currency);
    final double legacyBalance = (data['balance'] as num?)?.toDouble() ?? 0;
    final double legacyOpening =
        (data['openingBalance'] as num?)?.toDouble() ?? 0;
    final BigInt? balanceMinor = _readBigInt(data['balanceMinor']);
    final BigInt? openingMinor = _readBigInt(data['openingBalanceMinor']);
    final BigInt resolvedBalanceMinor =
        balanceMinor ??
        Money.fromDouble(legacyBalance, currency: currency, scale: scale).minor;
    final BigInt resolvedOpeningMinor =
        openingMinor ??
        Money.fromDouble(legacyOpening, currency: currency, scale: scale).minor;
    return AccountEntity(
      id: data['id'] as String? ?? doc.id,
      name: data['name'] as String? ?? '',
      balanceMinor: resolvedBalanceMinor,
      openingBalanceMinor: resolvedOpeningMinor,
      currency: currency,
      currencyScale: scale,
      type: data['type'] as String? ?? 'unknown',
      createdAt: _parseTimestamp(data['createdAt']),
      updatedAt: _parseTimestamp(data['updatedAt']),
      isDeleted: data['isDeleted'] as bool? ?? false,
      isPrimary: data['isPrimary'] as bool? ?? false,
      isHidden: data['isHidden'] as bool? ?? false,
      color: data['color'] as String?,
      gradientId: data['gradientId'] as String?,
      iconName: data['iconName'] as String?,
      iconStyle: data['iconStyle'] as String?,
    );
  }

  DateTime _parseTimestamp(dynamic value) {
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
