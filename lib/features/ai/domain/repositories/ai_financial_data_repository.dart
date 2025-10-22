import 'package:kopim/features/ai/domain/entities/ai_financial_overview_entity.dart';

/// Контракт для получения агрегированных данных, используемых ИИ-ассистентом.
abstract class AiFinancialDataRepository {
  Future<AiFinancialOverview> loadOverview({required AiDataFilter filter});
  Stream<AiFinancialOverview> watchOverview({required AiDataFilter filter});
}
