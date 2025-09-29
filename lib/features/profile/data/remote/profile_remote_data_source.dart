import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kopim/features/profile/domain/entities/profile.dart';

/// Firestore access for the `/users/{uid}/profile/profile` profile document.
class ProfileRemoteDataSource {
  ProfileRemoteDataSource(this._firestore);

  static const String _profileCollection = 'profile';
  static const String _profileDocId = 'profile';

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _doc(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection(_profileCollection)
        .doc(_profileDocId);
  }

  Future<Profile?> fetch(String uid) async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot = await _doc(
      uid,
    ).get();
    if (!snapshot.exists) {
      return null;
    }
    return _fromDocument(uid, snapshot.data()!);
  }

  Future<void> upsert(String uid, Profile profile) async {
    await _doc(uid).set(_mapProfile(profile), SetOptions(merge: true));
  }

  void upsertInTransaction(
    Transaction transaction,
    String uid,
    Profile profile,
  ) {
    transaction.set(_doc(uid), _mapProfile(profile), SetOptions(merge: true));
  }

  Map<String, dynamic> _mapProfile(Profile profile) {
    return <String, dynamic>{
      'uid': profile.uid,
      'name': profile.name,
      'currency': profile.currency.name.toUpperCase(),
      'locale': profile.locale,
      'updatedAt': Timestamp.fromDate(profile.updatedAt.toUtc()),
    };
  }

  Profile _fromDocument(String uid, Map<String, dynamic> data) {
    return Profile(
      uid: uid,
      name: (data['name'] as String?) ?? '',
      currency: _parseCurrency(data['currency'] as String?),
      locale: (data['locale'] as String?) ?? 'en',
      updatedAt: _parseTimestamp(data['updatedAt']),
    );
  }

  ProfileCurrency _parseCurrency(String? raw) {
    if (raw == null) return ProfileCurrency.usd;
    final String upper = raw.toUpperCase();
    return ProfileCurrency.values.firstWhere(
      (ProfileCurrency value) => value.name.toUpperCase() == upper,
      orElse: () => ProfileCurrency.usd,
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
}
