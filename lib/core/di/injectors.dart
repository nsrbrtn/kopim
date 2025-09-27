import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/core/services/analytics_service.dart';
import 'package:kopim/core/data/database.dart';
import 'package:kopim/core/services/sync_service.dart';
import 'package:kopim/features/profile/data/auth_repository_impl.dart';

part 'injectors.g.dart';  // Для генерации providers

@riverpod
LoggerService loggerService(Ref ref) => LoggerService();

@riverpod
AnalyticsService analyticsService(Ref ref) => AnalyticsService();

@riverpod
AppDatabase appDatabase(Ref ref) => AppDatabase();

@riverpod
SyncService syncService(Ref ref) {
  final AppDatabase db = ref.watch(appDatabaseProvider);  // Генерируется build_runner'ом
  return SyncService(db);
}

@riverpod
AuthRepository authRepository(Ref ref) => AuthRepositoryImpl();