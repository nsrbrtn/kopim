import 'dart:async';
import 'package:collection/collection.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'package:kopim/core/services/ai_assistant_service.dart';
import 'package:kopim/core/services/analytics_service.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/features/ai/data/tools/ai_assistant_tool_router.dart';
import 'package:kopim/features/ai/data/tools/ai_assistant_tools.dart';
import 'package:kopim/features/ai/domain/entities/ai_financial_overview_entity.dart';
import 'package:kopim/features/ai/domain/entities/ai_llm_result_entity.dart';
import 'package:kopim/features/ai/domain/entities/ai_recommendation_entity.dart';
import 'package:kopim/features/ai/domain/entities/ai_user_query_entity.dart';
import 'package:kopim/features/ai/domain/repositories/ai_assistant_repository.dart';
import 'package:kopim/features/ai/domain/repositories/ai_financial_data_repository.dart';

class AiAssistantRepositoryImpl implements AiAssistantRepository {
  AiAssistantRepositoryImpl({
    required AiAssistantService service,
    required AiFinancialDataRepository financialDataRepository,
    required AiAssistantToolRouter toolRouter,
    required AiAssistantToolsRegistry toolsRegistry,
    required AnalyticsService analyticsService,
    required LoggerService loggerService,
    required Uuid uuid,
    DateTime Function()? nowProvider,
  }) : _service = service,
       _financialDataRepository = financialDataRepository,
       _toolRouter = toolRouter,
       _toolsRegistry = toolsRegistry,
       _analyticsService = analyticsService,
       _loggerService = loggerService,
       _uuid = uuid,
       _nowProvider = nowProvider ?? DateTime.now;

  final AiAssistantService _service;
  final AiFinancialDataRepository _financialDataRepository;
  final AiAssistantToolRouter _toolRouter;
  final AiAssistantToolsRegistry _toolsRegistry;
  final AnalyticsService _analyticsService;
  final LoggerService _loggerService;
  final Uuid _uuid;
  final DateTime Function() _nowProvider;

  @override
  Future<AiLlmResultEntity> sendUserQuery(AiUserQueryEntity query) async {
    final Stopwatch stopwatch = Stopwatch()..start();
    try {
      final _ToolWorkflowOutcome? toolOutcome = await _tryToolWorkflow(query);
      if (toolOutcome != null) {
        stopwatch.stop();
        final String answer = _extractAnswer(toolOutcome.result.response);
        final List<String> sources = _extractSources(
          toolOutcome.result.response,
        );
        final double confidence = _estimateConfidence(
          toolOutcome.result.response,
        );
        final AiLlmResultEntity entity = AiLlmResultEntity(
          id: _uuid.v4(),
          queryId: query.id,
          content: answer,
          citedSources: sources,
          confidence: confidence,
          metadata: _composeMetadata(
            query: query,
            filter: null,
            overview: null,
            result: toolOutcome.result,
            duration: stopwatch.elapsed,
            toolLogs: toolOutcome.toolLogs,
            usedTools: toolOutcome.usedTools,
          ),
          createdAt: _nowProvider(),
          model: toolOutcome.result.config.model,
          promptTokens: toolOutcome.result.response.usage?.promptTokens,
          completionTokens: toolOutcome.result.response.usage?.completionTokens,
          totalTokens: toolOutcome.result.response.usage?.totalTokens,
        );
        await _analyticsService.logEvent(
          'ai_assistant_answer',
          <String, Object?>{
            'intent': query.intent.name,
            'model': toolOutcome.result.config.model,
            'duration_ms': stopwatch.elapsedMilliseconds,
            'confidence': confidence,
            'tools_used': toolOutcome.usedTools,
          },
        );
        return entity;
      }

      final AiDataFilter filter = _buildFilter(query);
      final AiFinancialOverview overview = await _financialDataRepository
          .loadOverview(filter: filter);
      final List<AiAssistantMessage> prompt = _buildOverviewPrompt(
        query: query,
        overview: overview,
        filter: filter,
      );
      final AiAssistantServiceResult result = await _service.generateAnswer(
        messages: prompt,
      );
      stopwatch.stop();

      final String answer = _extractAnswer(result.response);
      final List<String> sources = _extractSources(result.response);
      final double confidence = _estimateConfidence(result.response);

      final AiLlmResultEntity entity = AiLlmResultEntity(
        id: _uuid.v4(),
        queryId: query.id,
        content: answer,
        citedSources: sources,
        confidence: confidence,
        metadata: _composeMetadata(
          query: query,
          filter: filter,
          overview: overview,
          result: result,
          duration: stopwatch.elapsed,
          toolLogs: const <AiAssistantToolCallLog>[],
          usedTools: false,
        ),
        createdAt: _nowProvider(),
        model: result.config.model,
        promptTokens: result.response.usage?.promptTokens,
        completionTokens: result.response.usage?.completionTokens,
        totalTokens: result.response.usage?.totalTokens,
      );

      await _analyticsService.logEvent('ai_assistant_answer', <String, Object?>{
        'intent': query.intent.name,
        'model': result.config.model,
        'duration_ms': stopwatch.elapsedMilliseconds,
        'confidence': confidence,
        'tools_used': false,
      });

      return entity;
    } catch (error, stackTrace) {
      _loggerService.logError('Не удалось получить ответ OpenRouter', error);
      if (error is AiAssistantException && error.cause != null) {
        unawaited(
          FirebaseCrashlytics.instance.setCustomKey(
            'openrouter_error_body',
            error.cause.toString(),
          ),
        );
      }
      _analyticsService.reportError(error, stackTrace);
      rethrow;
    }
  }

  @override
  Stream<List<AiRecommendationEntity>> watchRecommendations({
    required String userId,
  }) {
    final AiDataFilter filter = _defaultFilter();
    return _financialDataRepository
        .watchOverview(filter: filter)
        .map((AiFinancialOverview overview) {
          final List<AiRecommendationEntity> items = _buildRecommendations(
            overview: overview,
            userId: userId,
          );
          return items;
        })
        .handleError((Object error, StackTrace stackTrace) {
          _loggerService.logError('Ошибка наблюдения рекомендаций ИИ', error);
          _analyticsService.reportError(error, stackTrace);
        });
  }

  @override
  Stream<Map<String, dynamic>> watchAnalytics({required String userId}) {
    final AiDataFilter filter = _defaultFilter();
    return _financialDataRepository
        .watchOverview(filter: filter)
        .map((AiFinancialOverview overview) {
          return _buildAnalyticsSnapshot(
            overview: overview,
            userId: userId,
            filter: filter,
          );
        })
        .handleError((Object error, StackTrace stackTrace) {
          _loggerService.logError('Ошибка наблюдения аналитики ИИ', error);
          _analyticsService.reportError(error, stackTrace);
        });
  }

  AiDataFilter _buildFilter(AiUserQueryEntity query) {
    final DateTime now = _nowProvider();
    DateTime? startDate;
    DateTime? endDate;
    int? topLimit;
    final List<String> accountIds = <String>[];
    final List<String> categoryIds = <String>[];

    for (final String signal in query.contextSignals) {
      if (signal.startsWith('period:') || signal.startsWith('timeframe:')) {
        final String value = signal.contains(':')
            ? signal.substring(signal.indexOf(':') + 1)
            : '';
        switch (value) {
          case 'current_month':
          case 'month_to_date':
            startDate = DateTime(now.year, now.month, 1);
            endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
            break;
          case 'last_month':
            final DateTime previous = DateTime(now.year, now.month - 1, 1);
            startDate = previous;
            endDate = DateTime(
              previous.year,
              previous.month + 1,
              0,
              23,
              59,
              59,
            );
            break;
          case 'last_30_days':
            startDate = now.subtract(const Duration(days: 30));
            endDate = now;
            break;
          case 'last_90_days':
            startDate = now.subtract(const Duration(days: 90));
            endDate = now;
            break;
          case 'year_to_date':
            startDate = DateTime(now.year, 1, 1);
            endDate = now;
            break;
          default:
            break;
        }
      } else if (signal.startsWith('account:')) {
        final String accountId = signal.substring('account:'.length);
        if (accountId.isNotEmpty) {
          accountIds.add(accountId);
        }
      } else if (signal.startsWith('category:')) {
        final String categoryId = signal.substring('category:'.length);
        if (categoryId.isNotEmpty) {
          categoryIds.add(categoryId);
        }
      } else if (signal.startsWith('top_categories:')) {
        final String raw = signal.substring('top_categories:'.length);
        final int? parsed = int.tryParse(raw);
        if (parsed != null && parsed > 0) {
          topLimit = parsed;
        }
      }
    }

    startDate ??= DateTime(now.year, now.month - 3, 1);
    endDate ??= now;

    return AiDataFilter(
      startDate: startDate,
      endDate: endDate,
      accountIds: accountIds,
      categoryIds: categoryIds,
      topCategoriesLimit: topLimit ?? 5,
    );
  }

  AiDataFilter _defaultFilter() {
    final DateTime now = _nowProvider();
    return AiDataFilter(
      startDate: DateTime(now.year, now.month - 3, 1),
      endDate: now,
      topCategoriesLimit: 5,
    );
  }

  List<AiAssistantMessage> _buildOverviewPrompt({
    required AiUserQueryEntity query,
    required AiFinancialOverview overview,
    required AiDataFilter filter,
  }) {
    final String locale = query.locale ?? 'ru_RU';
    final NumberFormat currency = NumberFormat.simpleCurrency(locale: locale);
    final NumberFormat percent = NumberFormat.percentPattern(locale);

    const String systemPrompt =
        'Ты — умный финансовый помощник в приложении "Копим". '
        'Твоя цель — помогать пользователю управлять деньгами осознанно. '
        'Правила: '
        '1. Отвечай на русском языке, используй Markdown (выделяй суммы **жирным**). '
        '2. Ссылайся на предоставленные данные (бюджеты, категории). Не выдумывай цифры. '
        '3. Если бюджет превышен или есть негативный тренд, вежливо предупреди и предложи решение. '
        '4. Будь кратким, дружелюбным и конкретным.';

    final StringBuffer userBuffer = StringBuffer()
      ..writeln(
        'Дата формирования сводки: ${overview.generatedAt.toIso8601String()}',
      )
      ..writeln('Фильтр: ${_describeFilter(filter)}')
      ..writeln('--- Траты по месяцам ---');

    for (final MonthlyExpenseInsight insight
        in overview.monthlyExpenses.sortedBy(
          (MonthlyExpenseInsight item) => item.normalizedMonth,
        )) {
      userBuffer.writeln(
        '${DateFormat.yMMMM(locale).format(insight.normalizedMonth)}: '
        '${currency.format(insight.totalExpense)}',
      );
    }

    userBuffer.writeln('--- Доходы по месяцам ---');
    for (final MonthlyIncomeInsight insight
        in overview.monthlyIncomes.sortedBy(
          (MonthlyIncomeInsight item) => item.normalizedMonth,
        )) {
      userBuffer.writeln(
        '${DateFormat.yMMMM(locale).format(insight.normalizedMonth)}: '
        '${currency.format(insight.totalIncome)}',
      );
    }

    userBuffer.writeln('--- Топ категории расходов ---');
    for (final CategoryExpenseInsight category in overview.topCategories) {
      userBuffer.writeln(
        '${category.displayName}: ${currency.format(category.totalExpense)}',
      );
    }

    userBuffer.writeln('--- Топ категории доходов ---');
    for (final CategoryIncomeInsight category in overview.topIncomeCategories) {
      userBuffer.writeln(
        '${category.displayName}: ${currency.format(category.totalIncome)}',
      );
    }

    if (overview.budgetForecasts.isNotEmpty) {
      userBuffer.writeln('--- Прогнозы по бюджетам ---');
      for (final BudgetForecastInsight forecast in overview.budgetForecasts) {
        final String completion = percent.format(forecast.completionRate);
        userBuffer.write(
          '${forecast.title}: потрачено ${currency.format(forecast.spent)} '
          'из ${currency.format(forecast.allocated)} '
          '($completion), статус: ${forecast.status.name}',
        );
        if (forecast.categoryNames.isNotEmpty) {
          userBuffer.write('. Категории: ${forecast.categoryNames.join(', ')}');
        }
        userBuffer.writeln();
      }
    }

    if (query.contextSignals.isNotEmpty) {
      userBuffer
        ..writeln('--- Контекстные сигналы ---')
        ..writeln(query.contextSignals.join(', '));
    }

    userBuffer.writeln('Вопрос пользователя: ${query.content}');

    return <AiAssistantMessage>[
      AiAssistantMessage.system(systemPrompt),
      AiAssistantMessage.user(userBuffer.toString()),
    ];
  }

  List<AiAssistantMessage> _buildToolPrompt({
    required AiUserQueryEntity query,
  }) {
    const String systemPrompt =
        'Ты — финансовый помощник в приложении "Копим". '
        'Если нужно получить данные, используй инструменты. '
        'Если вопрос про бюджеты, лимиты или остатки — используй get_budgets. '
        'Не выдумывай суммы и факты. '
        'Отвечай на русском языке, используй Markdown (суммы выделяй **жирным**).';

    final StringBuffer userBuffer = StringBuffer()
      ..writeln('Текущая дата: ${_nowProvider().toIso8601String()}')
      ..writeln('Вопрос пользователя: ${query.content}');
    if (query.contextSignals.isNotEmpty) {
      userBuffer
        ..writeln('Контекстные сигналы:')
        ..writeln(query.contextSignals.join(', '));
    }

    return <AiAssistantMessage>[
      AiAssistantMessage.system(systemPrompt),
      AiAssistantMessage.user(userBuffer.toString()),
    ];
  }

  String _describeFilter(AiDataFilter filter) {
    final StringBuffer buffer = StringBuffer();
    if (filter.startDate != null) {
      buffer.write('с ${filter.startDate!.toIso8601String()} ');
    }
    if (filter.endDate != null) {
      buffer.write('по ${filter.endDate!.toIso8601String()} ');
    }
    if (filter.accountIds.isNotEmpty) {
      buffer.write('счета: ${filter.accountIds.join(', ')} ');
    }
    if (filter.categoryIds.isNotEmpty) {
      buffer.write('категории: ${filter.categoryIds.join(', ')} ');
    }
    return buffer.toString().trim();
  }

  String _extractAnswer(AiCompletionResponse response) {
    for (final AiCompletionChoice choice in response.choices) {
      final String text = choice.message?.content.trim() ?? '';
      if (text.isNotEmpty) {
        return text;
      }
    }
    _loggerService.logError('OpenRouter вернул пустой ответ', response.raw);
    return 'Модель не смогла сформировать ответ на основании предоставленных данных.';
  }

  List<String> _extractSources(AiCompletionResponse response) {
    return const <String>[];
  }

  double _estimateConfidence(AiCompletionResponse response) {
    final bool hasMeaningfulText = response.choices.any(
      (AiCompletionChoice choice) =>
          (choice.message?.content.trim() ?? '').isNotEmpty,
    );
    if (!hasMeaningfulText) {
      return 0;
    }
    return 1.0;
  }

  Map<String, dynamic> _composeMetadata({
    required AiUserQueryEntity query,
    required AiDataFilter? filter,
    required AiFinancialOverview? overview,
    required AiAssistantServiceResult result,
    required Duration duration,
    required List<AiAssistantToolCallLog> toolLogs,
    required bool usedTools,
  }) {
    return <String, dynamic>{
      'query': <String, Object?>{
        'intent': query.intent.name,
        'locale': query.locale,
        'context_signals': query.contextSignals,
      },
      'filter': filter == null
          ? null
          : <String, Object?>{
              'start': filter.startDate?.toIso8601String(),
              'end': filter.endDate?.toIso8601String(),
              'accounts': filter.accountIds,
              'categories': filter.categoryIds,
              'top_limit': filter.topCategoriesLimit,
            },
      'overview': overview == null
          ? null
          : <String, Object?>{
              'has_budgets': overview.hasBudgetSignals,
              'has_categories': overview.hasCategoryBreakdown,
              'generated_at': overview.generatedAt.toIso8601String(),
            },
      'model': <String, Object?>{
        'name': result.config.model,
        'timeout_ms': result.config.requestTimeout.inMilliseconds,
        'throttle_ms': result.config.throttleInterval.inMilliseconds,
      },
      'service': <String, Object?>{
        'latency_ms': duration.inMilliseconds,
        'call_latency_ms': result.elapsed.inMilliseconds,
      },
      'tools': <String, Object?>{
        'used': usedTools,
        'calls': toolLogs
            .map(
              (AiAssistantToolCallLog log) => <String, Object?>{
                'name': log.name,
                'call_id': log.callId,
                'duration_ms': log.durationMs,
                'success': log.success,
                'error': log.errorMessage,
              },
            )
            .toList(growable: false),
      },
    };
  }

  Future<_ToolWorkflowOutcome?> _tryToolWorkflow(
    AiUserQueryEntity query,
  ) async {
    final List<AiAssistantMessage> prompt = _buildToolPrompt(query: query);
    final AiAssistantServiceResult firstResult = await _service.generateAnswer(
      messages: prompt,
      requestOptions: _toolsRegistry.buildRequestOptions(),
    );
    final AiCompletionMessage? firstMessage = _firstAssistantMessage(
      firstResult.response,
    );
    if (firstMessage == null) {
      return null;
    }
    if (firstMessage.toolCalls.isEmpty) {
      return null;
    }

    final AiAssistantToolExecutionResult toolResult = await _toolRouter
        .runToolCalls(firstMessage.toolCalls);
    for (final AiAssistantToolCallLog log in toolResult.logs) {
      unawaited(
        _analyticsService.logEvent('ai_tool_call', <String, Object?>{
          'tool': log.name,
          'duration_ms': log.durationMs,
          'success': log.success,
        }),
      );
    }
    final List<AiAssistantMessage> followUp = <AiAssistantMessage>[
      ...prompt,
      AiAssistantMessage.assistantWithToolCalls(firstMessage.toolCalls),
      ...toolResult.messages,
    ];
    final AiAssistantServiceResult finalResult = await _service.generateAnswer(
      messages: followUp,
      requestOptions: _toolsRegistry.buildRequestOptions(allowTools: false),
    );

    return _ToolWorkflowOutcome(
      result: finalResult,
      toolLogs: toolResult.logs,
      usedTools: true,
    );
  }

  AiCompletionMessage? _firstAssistantMessage(AiCompletionResponse response) {
    for (final AiCompletionChoice choice in response.choices) {
      final AiCompletionMessage? message = choice.message;
      if (message != null) {
        return message;
      }
    }
    return null;
  }

  List<AiRecommendationEntity> _buildRecommendations({
    required AiFinancialOverview overview,
    required String userId,
  }) {
    final List<AiRecommendationEntity> items = <AiRecommendationEntity>[];
    final DateTime now = _nowProvider();

    for (final BudgetForecastInsight forecast in overview.budgetForecasts) {
      if (forecast.status == BudgetForecastStatus.warning ||
          forecast.status == BudgetForecastStatus.exceeded) {
        final String id = _uuid.v4();
        final String description =
            forecast.status == BudgetForecastStatus.exceeded
            ? 'Бюджет уже превышен на ${forecast.projectedVariance.toStringAsFixed(2)} '
                  '— пересмотрите лимит или перенесите траты.'
            : 'Текущий темп трат выведет бюджет в красную зону. '
                  'Рекомендуется сократить расходы или увеличить лимит.';
        items.add(
          AiRecommendationEntity(
            id: id,
            queryId: userId,
            title: 'Контроль бюджета: ${forecast.title}',
            description: description,
            type: AiRecommendationType.alert,
            tags: <String>['budget', forecast.status.name],
            impact: AiRecommendationImpact(
              narrative:
                  'Прогноз расходов ${forecast.projectedSpent.toStringAsFixed(2)} '
                  'при лимите ${forecast.allocated.toStringAsFixed(2)}.',
              riskScore: forecast.status == BudgetForecastStatus.exceeded
                  ? 1
                  : 0.6,
            ),
            createdAt: now,
            validUntil: forecast.periodEnd,
          ),
        );
      }
    }

    if (overview.monthlyExpenses.length >= 2) {
      final List<MonthlyExpenseInsight> sorted = overview.monthlyExpenses
          .sortedBy((MonthlyExpenseInsight value) => value.normalizedMonth);
      final MonthlyExpenseInsight last = sorted.last;
      final MonthlyExpenseInsight previous = sorted[sorted.length - 2];
      if (previous.totalExpense > 0) {
        final double growth =
            (last.totalExpense - previous.totalExpense) / previous.totalExpense;
        if (growth > 0.1) {
          items.add(
            AiRecommendationEntity(
              id: _uuid.v4(),
              queryId: userId,
              title:
                  'Рост расходов на ${DateFormat.yMMMM('ru_RU').format(last.month)}',
              description:
                  'Расходы выросли на ${(growth * 100).toStringAsFixed(1)}% '
                  'по сравнению с прошлым месяцем. '
                  'Рассмотрите автоматизацию накоплений или лимиты на тратные категории.',
              type: AiRecommendationType.insight,
              tags: <String>['trend', 'expenses'],
              createdAt: now,
            ),
          );
        }
      }
    }

    if (overview.topCategories.isNotEmpty) {
      final double totalExpenses = overview.topCategories
          .map((CategoryExpenseInsight value) => value.totalExpense)
          .fold<double>(0, (double acc, double value) => acc + value);
      if (totalExpenses > 0) {
        final CategoryExpenseInsight leader = overview.topCategories.first;
        final double share = leader.totalExpense / totalExpenses;
        if (share >= 0.3) {
          items.add(
            AiRecommendationEntity(
              id: _uuid.v4(),
              queryId: userId,
              title: 'Фокус на категории ${leader.displayName}',
              description:
                  'Категория занимает ${(share * 100).toStringAsFixed(1)}% '
                  'от ключевых расходов. Установите цели или бюджет для контроля.',
              type: AiRecommendationType.reminder,
              tags: <String>['category', leader.displayName],
              createdAt: now,
            ),
          );
        }
      }
    }

    return items;
  }

  Map<String, dynamic> _buildAnalyticsSnapshot({
    required AiFinancialOverview overview,
    required String userId,
    required AiDataFilter filter,
  }) {
    final List<MonthlyExpenseInsight> ordered = overview.monthlyExpenses
        .sortedBy((MonthlyExpenseInsight item) => item.normalizedMonth);
    final double lastMonthExpense = ordered.isNotEmpty
        ? ordered.last.totalExpense
        : 0;
    final double averageExpense = ordered.isEmpty
        ? 0
        : ordered
                  .map((MonthlyExpenseInsight value) => value.totalExpense)
                  .fold<double>(0, (double acc, double value) => acc + value) /
              ordered.length;
    final double budgetAlerts = overview.budgetForecasts
        .where(
          (BudgetForecastInsight forecast) =>
              forecast.status != BudgetForecastStatus.onTrack,
        )
        .length
        .toDouble();

    return <String, dynamic>{
      'user_id': userId,
      'generated_at': _nowProvider().toIso8601String(),
      'filter': <String, Object?>{
        'start': filter.startDate?.toIso8601String(),
        'end': filter.endDate?.toIso8601String(),
      },
      'metrics': <String, Object?>{
        'last_month_expense': lastMonthExpense,
        'average_expense': averageExpense,
        'budget_alerts': budgetAlerts,
        'top_categories_count': overview.topCategories.length,
      },
    };
  }
}

class _ToolWorkflowOutcome {
  const _ToolWorkflowOutcome({
    required this.result,
    required this.toolLogs,
    required this.usedTools,
  });

  final AiAssistantServiceResult result;
  final List<AiAssistantToolCallLog> toolLogs;
  final bool usedTools;
}
