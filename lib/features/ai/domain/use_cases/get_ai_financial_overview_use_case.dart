import 'package:kopim/features/ai/domain/entities/ai_financial_overview_entity.dart';
import 'package:kopim/features/ai/domain/repositories/ai_financial_data_repository.dart';

class GetAiFinancialOverviewUseCase {
  GetAiFinancialOverviewUseCase(this._repository);

  final AiFinancialDataRepository _repository;

  Future<AiFinancialOverview> execute({required AiDataFilter filter}) {
    return _repository.loadOverview(filter: filter);
  }
}
