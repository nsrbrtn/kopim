import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uuid/uuid.dart';

import 'package:kopim/core/config/app_config.dart';
import 'package:kopim/core/services/ai_assistant_service.dart';
import 'package:kopim/core/services/analytics_service.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/features/ai/data/repositories/ai_assistant_repository_impl.dart';
import 'package:kopim/features/ai/data/tools/ai_assistant_tool_router.dart';
import 'package:kopim/features/ai/data/tools/ai_assistant_tools.dart';
import 'package:kopim/features/ai/domain/entities/ai_financial_overview_entity.dart';
import 'package:kopim/features/ai/domain/entities/ai_user_query_entity.dart';
import 'package:kopim/features/ai/domain/repositories/ai_financial_data_repository.dart';

class _MockAiAssistantService extends Mock implements AiAssistantService {}

class _MockAiFinancialDataRepository extends Mock
    implements AiFinancialDataRepository {}

class _MockAnalyticsService extends Mock implements AnalyticsService {}

class _MockLoggerService extends Mock implements LoggerService {}

class _MockAiAssistantToolRouter extends Mock
    implements AiAssistantToolRouter {}

void main() {
  late _MockAiAssistantService assistantService;
  late _MockAiFinancialDataRepository financialRepository;
  late _MockAnalyticsService analyticsService;
  late _MockLoggerService loggerService;
  late _MockAiAssistantToolRouter toolRouter;
  late AiAssistantRepositoryImpl repository;
  const AiAssistantToolsRegistry toolsRegistry = AiAssistantToolsRegistry();

  final DateTime fixedNow = DateTime(2024, 5, 15, 12, 0, 0);

  setUpAll(() {
    registerFallbackValue(<AiAssistantMessage>[]);
    registerFallbackValue(
      const AiToolCall(id: 'fallback', name: 'tool', arguments: '{}'),
    );
    registerFallbackValue(const AiDataFilter());
  });

  setUp(() {
    assistantService = _MockAiAssistantService();
    financialRepository = _MockAiFinancialDataRepository();
    analyticsService = _MockAnalyticsService();
    loggerService = _MockLoggerService();
    toolRouter = _MockAiAssistantToolRouter();

    repository = AiAssistantRepositoryImpl(
      service: assistantService,
      financialDataRepository: financialRepository,
      toolRouter: toolRouter,
      toolsRegistry: toolsRegistry,
      analyticsService: analyticsService,
      loggerService: loggerService,
      uuid: const Uuid(),
      nowProvider: () => fixedNow,
    );
  });

  AiAssistantServiceResult buildServiceResult({String content = 'ok'}) {
    return AiAssistantServiceResult(
      response: AiCompletionResponse(
        id: 'response-1',
        choices: <AiCompletionChoice>[
          AiCompletionChoice(
            message: AiCompletionMessage(role: 'assistant', content: content),
          ),
        ],
        raw: const <String, dynamic>{},
      ),
      config: const GenerativeAiConfig(
        model: 'test-model',
        baseUrl: 'https://example.com',
        requestTimeout: Duration(seconds: 1),
        throttleInterval: Duration.zero,
        isEnabled: true,
        maxRetries: 0,
        retryBaseDelay: Duration(seconds: 1),
        retryMultiplier: 1,
      ),
      elapsed: const Duration(milliseconds: 10),
    );
  }

  test('buildFilter учитывает timeframe:month_to_date', () async {
    AiDataFilter? capturedFilter;
    when(
      () => financialRepository.loadOverview(filter: any(named: 'filter')),
    ).thenAnswer((Invocation invocation) async {
      capturedFilter =
          invocation.namedArguments[#filter] as AiDataFilter? ?? capturedFilter;
      return AiFinancialOverview(
        monthlyExpenses: const <MonthlyExpenseInsight>[],
        monthlyIncomes: const <MonthlyIncomeInsight>[],
        topCategories: const <CategoryExpenseInsight>[],
        topIncomeCategories: const <CategoryIncomeInsight>[],
        budgetForecasts: const <BudgetForecastInsight>[],
        generatedAt: fixedNow,
      );
    });
    int answerCalls = 0;
    when(
      () => assistantService.generateAnswer(
        messages: any(named: 'messages'),
        requestOptions: any(named: 'requestOptions'),
      ),
    ).thenAnswer((_) async {
      answerCalls++;
      return answerCalls == 1
          ? buildServiceResult(content: '')
          : buildServiceResult();
    });
    when(() => toolRouter.runToolCalls(any())).thenAnswer(
      (_) async => const AiAssistantToolExecutionResult(
        messages: <AiAssistantMessage>[],
        logs: <AiAssistantToolCallLog>[],
      ),
    );
    when(
      () => analyticsService.logEvent(any(), any()),
    ).thenAnswer((_) async {});

    final AiUserQueryEntity query = AiUserQueryEntity(
      id: 'q1',
      userId: 'u1',
      content: 'Сводка расходов за месяц',
      contextSignals: const <String>['timeframe:month_to_date'],
      intent: AiQueryIntent.analytics,
      createdAt: fixedNow,
    );

    await repository.sendUserQuery(query);

    expect(capturedFilter, isNotNull);
    expect(capturedFilter!.startDate, DateTime(2024, 5, 1));
    expect(capturedFilter!.endDate, DateTime(2024, 5, 31, 23, 59, 59));
  });

  test('buildFilter учитывает period:last_30_days', () async {
    AiDataFilter? capturedFilter;
    when(
      () => financialRepository.loadOverview(filter: any(named: 'filter')),
    ).thenAnswer((Invocation invocation) async {
      capturedFilter =
          invocation.namedArguments[#filter] as AiDataFilter? ?? capturedFilter;
      return AiFinancialOverview(
        monthlyExpenses: const <MonthlyExpenseInsight>[],
        monthlyIncomes: const <MonthlyIncomeInsight>[],
        topCategories: const <CategoryExpenseInsight>[],
        topIncomeCategories: const <CategoryIncomeInsight>[],
        budgetForecasts: const <BudgetForecastInsight>[],
        generatedAt: fixedNow,
      );
    });
    int answerCalls = 0;
    when(
      () => assistantService.generateAnswer(
        messages: any(named: 'messages'),
        requestOptions: any(named: 'requestOptions'),
      ),
    ).thenAnswer((_) async {
      answerCalls++;
      return answerCalls == 1
          ? buildServiceResult(content: '')
          : buildServiceResult();
    });
    when(() => toolRouter.runToolCalls(any())).thenAnswer(
      (_) async => const AiAssistantToolExecutionResult(
        messages: <AiAssistantMessage>[],
        logs: <AiAssistantToolCallLog>[],
      ),
    );
    when(
      () => analyticsService.logEvent(any(), any()),
    ).thenAnswer((_) async {});

    final AiUserQueryEntity query = AiUserQueryEntity(
      id: 'q2',
      userId: 'u1',
      content: 'Расходы за последние 30 дней',
      contextSignals: const <String>['period:last_30_days'],
      intent: AiQueryIntent.analytics,
      createdAt: fixedNow,
    );

    await repository.sendUserQuery(query);

    expect(capturedFilter, isNotNull);
    expect(
      capturedFilter!.startDate,
      fixedNow.subtract(const Duration(days: 30)),
    );
    expect(capturedFilter!.endDate, fixedNow);
  });
}
