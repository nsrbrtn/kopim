import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:kopim/features/ai/domain/entities/ai_llm_result_entity.dart';
import 'package:kopim/features/ai/domain/entities/ai_recommendation_entity.dart';
import 'package:kopim/features/ai/domain/entities/ai_user_query_entity.dart';

part 'ai_assistant_repository.g.dart';

/// Контракт взаимодействия с ИИ-финансовым ассистентом.
abstract class AiAssistantRepository {
  /// Отправляет запрос пользователя в LLM и возвращает ответ модели.
  Future<AiLlmResultEntity> sendUserQuery(AiUserQueryEntity query);

  /// Получает поток рекомендаций, связанных с последними запросами пользователя.
  Stream<List<AiRecommendationEntity>> watchRecommendations({
    required String userId,
  });

  /// Возвращает поток аналитики ИИ по финансовому поведению пользователя.
  Stream<Map<String, dynamic>> watchAnalytics({required String userId});
}

/// Провайдер, который должен быть переопределён конкретной реализацией репозитория.
@Riverpod(keepAlive: true)
AiAssistantRepository aiAssistantRepository(Ref ref) {
  throw UnimplementedError('AiAssistantRepository не сконфигурирован.');
}
