import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';

class AccountRemoteDataSource {
  AccountRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore.collection('users').doc(userId).collection('accounts');
  }

  Future<void> upsert(String userId, AccountEntity account) async {
    final doc = _collection(userId).doc(account.id);
    await doc.set(_mapAccount(account), SetOptions(merge: true));
  }

  Future<void> delete(String userId, AccountEntity account) async {
    final doc = _collection(userId).doc(account.id);
    await doc.set(
      _mapAccount(account.copyWith(isDeleted: true)),
      SetOptions(merge: true),
    );
  }

  Map<String, dynamic> _mapAccount(AccountEntity account) {
    return {
      'id': account.id,
      'name': account.name,
      'currency': account.currency,
      'type': account.type,
      'createdAt': Timestamp.fromDate(account.createdAt.toUtc()),
      'updatedAt': Timestamp.fromDate(account.updatedAt.toUtc()),
      'isDeleted': account.isDeleted,
    };
  }
}
