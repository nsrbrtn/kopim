import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kopim/core/data/database.dart' as db;
import 'package:kopim/features/profile/domain/repositories/profile_avatar_repository.dart';
import 'package:kopim/features/profile/domain/repositories/user_account_cleanup_repository.dart';

class UserAccountCleanupRepositoryImpl implements UserAccountCleanupRepository {
  UserAccountCleanupRepositoryImpl({
    required FirebaseFirestore firestore,
    required db.AppDatabase database,
    required ProfileAvatarRepository profileAvatarRepository,
  }) : _firestore = firestore,
       _database = database,
       _profileAvatarRepository = profileAvatarRepository;

  static const List<String> _userCollections = <String>[
    'accounts',
    'categories',
    'tags',
    'transaction_tags',
    'transactions',
    'credits',
    'credit_cards',
    'debts',
    'profile',
    'progress',
    'budgets',
    'budget_instances',
    'saving_goals',
    'recurring_payments',
    'reminders',
  ];

  final FirebaseFirestore _firestore;
  final db.AppDatabase _database;
  final ProfileAvatarRepository _profileAvatarRepository;

  @override
  Future<void> deleteRemoteUserData(String uid) async {
    for (final String collectionName in _userCollections) {
      final CollectionReference<Map<String, dynamic>> collection = _firestore
          .collection('users')
          .doc(uid)
          .collection(collectionName);
      await _deleteCollection(collection);
    }

    try {
      await _profileAvatarRepository.delete(uid);
    } catch (_) {
      // Отсутствующий аватар не должен блокировать удаление аккаунта.
    }

    await _firestore.collection('users').doc(uid).delete();
  }

  Future<void> _deleteCollection(
    CollectionReference<Map<String, dynamic>> collection,
  ) async {
    while (true) {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await collection
          .limit(400)
          .get();
      if (snapshot.docs.isEmpty) {
        return;
      }

      final WriteBatch batch = _firestore.batch();
      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
          in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }

  @override
  Future<void> deleteLocalUserData() async {
    await _database.transaction(() async {
      await (_database.delete(_database.transactionTags)).go();
      await (_database.delete(_database.goalContributions)).go();
      await (_database.delete(_database.paymentReminders)).go();
      await (_database.delete(_database.upcomingPayments)).go();
      await (_database.delete(_database.creditPaymentGroups)).go();
      await (_database.delete(_database.creditPaymentSchedules)).go();
      await (_database.delete(_database.budgetInstances)).go();
      await (_database.delete(_database.debts)).go();
      await (_database.delete(_database.creditCards)).go();
      await (_database.delete(_database.credits)).go();
      await (_database.delete(_database.savingGoals)).go();
      await (_database.delete(_database.transactions)).go();
      await (_database.delete(_database.tags)).go();
      await (_database.delete(_database.categories)).go();
      await (_database.delete(_database.budgets)).go();
      await (_database.delete(_database.accounts)).go();
      await (_database.delete(_database.profiles)).go();
      await (_database.delete(_database.outboxEntries)).go();
    });
  }
}
