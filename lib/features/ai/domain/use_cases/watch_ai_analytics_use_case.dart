import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:kopim/features/ai/domain/repositories/ai_assistant_repository.dart';

part 'watch_ai_analytics_use_case.g.dart';

/// Use case для получения аналитических метрик, рассчитанных ИИ.
class WatchAiAnalyticsUseCase {
  WatchAiAnalyticsUseCase(this._repository);

  final AiAssistantRepository _repository;

  Stream<Map<String, dynamic>> execute({required String userId}) {
    return _repository.watchAnalytics(userId: userId);
  }
}

/// Провайдер use-case для внедрения зависимостей через Riverpod.
@riverpod
WatchAiAnalyticsUseCase watchAiAnalyticsUseCase(Ref ref) {
  return WatchAiAnalyticsUseCase(ref.watch(aiAssistantRepositoryProvider));
}
