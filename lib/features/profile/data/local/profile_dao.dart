import 'package:drift/drift.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/features/profile/domain/entities/profile.dart';

class ProfileDao {
  ProfileDao(this._db);

  final db.AppDatabase _db;

  Stream<Profile?> watchProfile(String uid) {
    final SimpleSelectStatement<db.$ProfilesTable, db.ProfileRow> query =
        _db.select(_db.profiles)
          ..where((db.$ProfilesTable tbl) => tbl.uid.equals(uid));
    return query.watchSingleOrNull().map(_mapRowToProfile);
  }

  Future<Profile?> getProfile(String uid) async {
    final db.ProfileRow? row = await (_db.select(
      _db.profiles,
    )..where((db.$ProfilesTable tbl) => tbl.uid.equals(uid))).getSingleOrNull();
    return _mapRowToProfile(row);
  }

  Future<void> upsert(Profile profile) {
    return _db
        .into(_db.profiles)
        .insertOnConflictUpdate(_mapProfileToCompanion(profile));
  }

  Future<void> upsertInTransaction(Profile profile) async {
    await _db
        .into(_db.profiles)
        .insertOnConflictUpdate(_mapProfileToCompanion(profile));
  }

  Profile? _mapRowToProfile(db.ProfileRow? row) {
    if (row == null) return null;
    return Profile(
      uid: row.uid,
      name: row.name ?? '',
      currency: _parseCurrency(row.currency),
      locale: row.locale ?? 'en',
      updatedAt: row.updatedAt,
    );
  }

  db.ProfilesCompanion _mapProfileToCompanion(Profile profile) {
    return db.ProfilesCompanion(
      uid: Value<String>(profile.uid),
      name: Value<String>(profile.name),
      currency: Value<String>(profile.currency.name.toUpperCase()),
      locale: Value<String>(profile.locale),
      updatedAt: Value<DateTime>(profile.updatedAt),
    );
  }

  ProfileCurrency _parseCurrency(String? value) {
    if (value == null) {
      return ProfileCurrency.usd;
    }
    final ProfileCurrency match = ProfileCurrency.values.firstWhere(
      (ProfileCurrency currency) =>
          currency.name.toUpperCase() == value.toUpperCase(),
      orElse: () => ProfileCurrency.usd,
    );
    return match;
  }
}
