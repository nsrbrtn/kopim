import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:kopim/core/data/database.dart';
import 'package:kopim/core/data/outbox/outbox_dao.dart';
import 'package:kopim/core/services/analytics_service.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/core/services/sync_service.dart';
import 'package:kopim/features/accounts/data/repositories/account_repository_impl.dart';
import 'package:kopim/features/accounts/data/sources/local/account_dao.dart';
import 'package:kopim/features/accounts/data/sources/remote/account_remote_data_source.dart';
import 'package:kopim/features/accounts/domain/repositories/account_repository.dart';
import 'package:kopim/features/categories/data/repositories/category_repository_impl.dart';
import 'package:kopim/features/categories/data/sources/local/category_dao.dart';
import 'package:kopim/features/categories/data/sources/remote/category_remote_data_source.dart';
import 'package:kopim/features/categories/domain/repositories/category_repository.dart';
import 'package:kopim/features/profile/data/auth_repository_impl.dart';
import 'package:kopim/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:kopim/features/transactions/data/sources/local/transaction_dao.dart';
import 'package:kopim/features/transactions/data/sources/remote/transaction_remote_data_source.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';

part 'injectors.g.dart';

@riverpod
LoggerService loggerService(Ref ref) => LoggerService();

@riverpod
AnalyticsService analyticsService(Ref ref) => AnalyticsService();

@riverpod
FirebaseFirestore firestore(Ref ref) => FirebaseFirestore.instance;

@riverpod
FirebaseAuth firebaseAuth(Ref ref) => FirebaseAuth.instance;

@riverpod
Connectivity connectivity(Ref ref) => Connectivity();

@riverpod
AppDatabase appDatabase(Ref ref) => AppDatabase();

@riverpod
OutboxDao outboxDao(Ref ref) => OutboxDao(ref.watch(appDatabaseProvider));

@riverpod
AccountDao accountDao(Ref ref) => AccountDao(ref.watch(appDatabaseProvider));

@riverpod
CategoryDao categoryDao(Ref ref) => CategoryDao(ref.watch(appDatabaseProvider));

@riverpod
TransactionDao transactionDao(Ref ref) =>
    TransactionDao(ref.watch(appDatabaseProvider));

@riverpod
AccountRemoteDataSource accountRemoteDataSource(Ref ref) =>
    AccountRemoteDataSource(ref.watch(firestoreProvider));

@riverpod
CategoryRemoteDataSource categoryRemoteDataSource(Ref ref) =>
    CategoryRemoteDataSource(ref.watch(firestoreProvider));

@riverpod
TransactionRemoteDataSource transactionRemoteDataSource(Ref ref) =>
    TransactionRemoteDataSource(ref.watch(firestoreProvider));

@riverpod
AccountRepository accountRepository(Ref ref) => AccountRepositoryImpl(
  database: ref.watch(appDatabaseProvider),
  accountDao: ref.watch(accountDaoProvider),
  outboxDao: ref.watch(outboxDaoProvider),
);

@riverpod
CategoryRepository categoryRepository(Ref ref) => CategoryRepositoryImpl(
  database: ref.watch(appDatabaseProvider),
  categoryDao: ref.watch(categoryDaoProvider),
  outboxDao: ref.watch(outboxDaoProvider),
);

@riverpod
TransactionRepository transactionRepository(Ref ref) =>
    TransactionRepositoryImpl(
      database: ref.watch(appDatabaseProvider),
      transactionDao: ref.watch(transactionDaoProvider),
      outboxDao: ref.watch(outboxDaoProvider),
    );

@riverpod
SyncService syncService(Ref ref) {
  final service = SyncService(
    outboxDao: ref.watch(outboxDaoProvider),
    accountRemoteDataSource: ref.watch(accountRemoteDataSourceProvider),
    categoryRemoteDataSource: ref.watch(categoryRemoteDataSourceProvider),
    transactionRemoteDataSource: ref.watch(transactionRemoteDataSourceProvider),
    firebaseAuth: ref.watch(firebaseAuthProvider),
    connectivity: ref.watch(connectivityProvider),
  );
  unawaited(service.initialize());
  ref.onDispose(service.dispose);
  return service;
}

@riverpod
AuthRepository authRepository(Ref ref) => AuthRepositoryImpl();
