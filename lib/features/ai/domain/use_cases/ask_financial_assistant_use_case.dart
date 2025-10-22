import 'package:kopim/features/ai/domain/entities/ai_llm_result_entity.dart';
import 'package:kopim/features/ai/domain/entities/ai_user_query_entity.dart';
import 'package:kopim/features/ai/domain/repositories/ai_assistant_repository.dart';

/// Use case для отправки запроса в финансового ассистента.
class AskFinancialAssistantUseCase {
  AskFinancialAssistantUseCase(this._repository);

  final AiAssistantRepository _repository;

  Future<AiLlmResultEntity> execute(AiUserQueryEntity query) {
    return _repository.sendUserQuery(query);
  }
}
