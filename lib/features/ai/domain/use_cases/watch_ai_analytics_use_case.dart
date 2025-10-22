import 'package:kopim/features/ai/domain/repositories/ai_assistant_repository.dart';

/// Use case для получения аналитических метрик, рассчитанных ИИ.
class WatchAiAnalyticsUseCase {
  WatchAiAnalyticsUseCase(this._repository);

  final AiAssistantRepository _repository;

  Stream<Map<String, dynamic>> execute({required String userId}) {
    return _repository.watchAnalytics(userId: userId);
  }
}
