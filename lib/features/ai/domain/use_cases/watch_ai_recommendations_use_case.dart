import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:kopim/features/ai/domain/entities/ai_recommendation_entity.dart';
import 'package:kopim/features/ai/domain/repositories/ai_assistant_repository.dart';

part 'watch_ai_recommendations_use_case.g.dart';

/// Use case для подписки на рекомендации ИИ.
class WatchAiRecommendationsUseCase {
  WatchAiRecommendationsUseCase(this._repository);

  final AiAssistantRepository _repository;

  Stream<List<AiRecommendationEntity>> execute({required String userId}) {
    return _repository.watchRecommendations(userId: userId);
  }
}

/// Riverpod-провайдер use-case с внедрением репозитория.
@riverpod
WatchAiRecommendationsUseCase watchAiRecommendationsUseCase(Ref ref) {
  return WatchAiRecommendationsUseCase(
    ref.watch(aiAssistantRepositoryProvider),
  );
}
