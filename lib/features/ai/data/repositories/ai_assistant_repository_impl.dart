import 'dart:async';
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'package:kopim/core/services/ai_assistant_service.dart';
import 'package:kopim/core/services/analytics_service.dart';
import 'package:kopim/core/services/logger_service.dart';
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
    required AnalyticsService analyticsService,
    required LoggerService loggerService,
    required Uuid uuid,
    DateTime Function()? nowProvider,
  }) : _service = service,
       _financialDataRepository = financialDataRepository,
       _analyticsService = analyticsService,
       _loggerService = loggerService,
       _uuid = uuid,
       _nowProvider = nowProvider ?? DateTime.now;

  final AiAssistantService _service;
  final AiFinancialDataRepository _financialDataRepository;
  final AnalyticsService _analyticsService;
  final LoggerService _loggerService;
  final Uuid _uuid;
  final DateTime Function() _nowProvider;

  @override
  Future<AiLlmResultEntity> sendUserQuery(AiUserQueryEntity query) async {
    final Stopwatch stopwatch = Stopwatch()..start();
    try {
      final AiDataFilter filter = _buildFilter(query);
      final AiFinancialOverview overview = await _financialDataRepository
          .loadOverview(filter: filter);
      final List<Content> prompt = _buildPrompt(
        query: query,
        overview: overview,
        filter: filter,
      );
      final AiAssistantServiceResult result = await _service.generateAnswer(
        prompt: prompt,
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
        ),
        createdAt: _nowProvider(),
        model: result.config.model,
        promptTokens: result.response.usageMetadata?.promptTokenCount,
        completionTokens: result.response.usageMetadata?.candidatesTokenCount,
        totalTokens: result.response.usageMetadata?.totalTokenCount,
      );

      await _analyticsService.logEvent('ai_assistant_answer', <String, Object?>{
        'intent': query.intent.name,
        'model': result.config.model,
        'duration_ms': stopwatch.elapsedMilliseconds,
        'confidence': confidence,
      });

      return entity;
    } catch (error, stackTrace) {
      _loggerService.logError('Не удалось получить ответ Gemini', error);
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
      if (signal.startsWith('period:')) {
        final String value = signal.substring('period:'.length);
        switch (value) {
          case 'current_month':
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

  List<Content> _buildPrompt({
    required AiUserQueryEntity query,
    required AiFinancialOverview overview,
    required AiDataFilter filter,
  }) {
    final String locale = query.locale ?? 'ru_RU';
    final NumberFormat currency = NumberFormat.simpleCurrency(locale: locale);
    final NumberFormat percent = NumberFormat.percentPattern(locale);

    final StringBuffer buffer = StringBuffer()
      ..writeln(
        'Ты — финансовый ассиент финтех-приложения Kopim. '
        'Отвечай профессионально и на русском языке, ссылайся на предоставленные данные. '
        'Если данных недостаточно, укажи, какие метрики нужны пользователю.',
      )
      ..writeln(
        'Дата формирования сводки: ${overview.generatedAt.toIso8601String()}',
      )
      ..writeln('Фильтр: ${_describeFilter(filter)}')
      ..writeln('--- Траты по месяцам ---');

    for (final MonthlyExpenseInsight insight
        in overview.monthlyExpenses.sortedBy(
          (MonthlyExpenseInsight item) => item.normalizedMonth,
        )) {
      buffer.writeln(
        '${DateFormat.yMMMM(locale).format(insight.normalizedMonth)}: '
        '${currency.format(insight.totalExpense)}',
      );
    }

    buffer.writeln('--- Топ категории расходов ---');
    for (final CategoryExpenseInsight category in overview.topCategories) {
      buffer.writeln(
        '${category.displayName}: ${currency.format(category.totalExpense)}',
      );
    }

    if (overview.budgetForecasts.isNotEmpty) {
      buffer.writeln('--- Прогнозы по бюджетам ---');
      for (final BudgetForecastInsight forecast in overview.budgetForecasts) {
        final String completion = percent.format(forecast.completionRate);
        buffer.writeln(
          '${forecast.title}: потрачено ${currency.format(forecast.spent)} '
          'из ${currency.format(forecast.allocated)} '
          '($completion), статус: ${forecast.status.name}',
        );
      }
    }

    if (query.contextSignals.isNotEmpty) {
      buffer
        ..writeln('--- Контекстные сигналы ---')
        ..writeln(query.contextSignals.join(', '));
    }

    buffer.writeln('Вопрос пользователя: ${query.content}');


    return <Content>[
      Content.text(buffer.toString()),
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

  String _extractAnswer(GenerateContentResponse response) {
    try {
      final String? text = response.text;
      if (text != null && text.trim().isNotEmpty) {
        return text.trim();
      }
    } catch (error) {
      _loggerService.logError('Gemini вернул пустой ответ', error);
    }
    for (final Candidate candidate in response.candidates) {
      final String candidateText = candidate.content.parts
          .whereType<TextPart>()
          .map((TextPart part) => part.text)
          .join(' ')
          .trim();
      if (candidateText.isNotEmpty) {
        return candidateText;
      }
    }
    return 'Модель не смогла сформировать ответ на основании предоставленных данных.';
  }

  List<String> _extractSources(GenerateContentResponse response) {
    final Set<String> sources = <String>{};
    for (final Candidate candidate in response.candidates) {
      final Iterable<CitationSource> citations =
          candidate.citationMetadata?.citationSources ??
          const <CitationSource>[];
      for (final CitationSource citation in citations) {
        if (citation.uri != null) {
          sources.add(citation.uri.toString());
        }
      }
    }
    return sources.toList(growable: false);
  }

  double _estimateConfidence(GenerateContentResponse response) {
    if (response.candidates.isEmpty) {
      return 0;
    }
    final Candidate candidate = response.candidates.first;
    final List<SafetyRating>? ratings = candidate.safetyRatings;
    if (ratings == null || ratings.isEmpty) {
      return 1.0;
    }
    final double maxProbability = ratings
        .map((SafetyRating rating) => _probabilityWeight(rating.probability))
        .fold<double>(0, math.max);
    final double confidence = (1 - maxProbability).clamp(0.0, 1.0);
    return double.parse(confidence.toStringAsFixed(3));
  }

  double _probabilityWeight(HarmProbability probability) {
    switch (probability) {
      case HarmProbability.high:
        return 1.0;
      case HarmProbability.medium:
        return 0.7;
      case HarmProbability.low:
        return 0.4;
      case HarmProbability.negligible:
        return 0.2;
      case HarmProbability.unspecified:
        return 0.0;
    }
  }

  Map<String, dynamic> _composeMetadata({
    required AiUserQueryEntity query,
    required AiDataFilter filter,
    required AiFinancialOverview overview,
    required AiAssistantServiceResult result,
    required Duration duration,
  }) {
    return <String, dynamic>{
      'query': <String, Object?>{
        'intent': query.intent.name,
        'locale': query.locale,
        'context_signals': query.contextSignals,
      },
      'filter': <String, Object?>{
        'start': filter.startDate?.toIso8601String(),
        'end': filter.endDate?.toIso8601String(),
        'accounts': filter.accountIds,
        'categories': filter.categoryIds,
        'top_limit': filter.topCategoriesLimit,
      },
      'overview': <String, Object?>{
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
    };
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
