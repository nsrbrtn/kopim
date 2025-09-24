// lib/core/di/injectors.dart (исправленный)
// Создайте placeholders в отдельных файлах, например:

// lib/core/services/sync_service.dart (новый placeholder)
class SyncService {
  final Logger logger;
  final FirebaseAnalytics analytics;

  SyncService({required this.logger, required this.analytics});
}

// lib/features/accounts/data/accounts_repository.dart (новый placeholder)
abstract class AccountsRepository {}
class AccountsRepositoryImpl implements AccountsRepository {
  final SyncService syncService;
  AccountsRepositoryImpl({required this.syncService});
}

// lib/features/accounts/domain/get_accounts_use_case.dart (новый placeholder)
class GetAccountsUseCase {
  final AccountsRepository repository;
  GetAccountsUseCase(this.repository);
}

// Теперь injectors.dart:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart'; // Импорт из зависимости logger
import 'package:firebase_analytics/firebase_analytics.dart'; // Импорт из firebase_analytics
import '../services/sync_service.dart'; // Импорт placeholder
import '../../features/accounts/data/accounts_repository.dart'; // Импорт placeholder
import '../../features/accounts/domain/get_accounts_use_case.dart'; // Импорт placeholder

// Provider для logger (глобальный сервис логирования)
final Provider<Logger> loggerProvider = Provider<Logger>((Ref ref) { // Типы
  return Logger(
    level: Level.debug, // Настройте по необходимости
  );
});

// Provider для analytics (Firebase Analytics)
final Provider<FirebaseAnalytics> analyticsProvider = Provider<FirebaseAnalytics>((Ref ref) { // Типы
  return FirebaseAnalytics.instance; // Инстанс из Firebase
});

// Provider для sync service (сервис синхронизации, offline-first)
final Provider<SyncService> syncServiceProvider = Provider<SyncService>((Ref ref) { // Типы
  // Инжекция зависимостей: logger и analytics
  final Logger logger = ref.read(loggerProvider);
  final FirebaseAnalytics analytics = ref.read(analyticsProvider);
  return SyncService(logger: logger, analytics: analytics); // Теперь определён
});

// Placeholders для репозиториев (расширьте в фичах)
// Например, для accounts:
final Provider<AccountsRepository> accountsRepositoryProvider = Provider<AccountsRepository>((Ref ref) { // Типы
  // Инжекция: syncService, drift DB и т.д.
  final SyncService syncService = ref.read(syncServiceProvider);
  return AccountsRepositoryImpl(syncService: syncService); // Теперь определён
});

// Placeholders для use cases (business logic в domain)
// Например, для accounts:
final Provider<GetAccountsUseCase> getAccountsUseCaseProvider = Provider<GetAccountsUseCase>((Ref ref) { // Типы
  final AccountsRepository repository = ref.read(accountsRepositoryProvider);
  return GetAccountsUseCase(repository); // Теперь определён
});