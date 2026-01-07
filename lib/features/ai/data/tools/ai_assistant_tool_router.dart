import 'dart:convert';

import 'package:kopim/core/services/ai_assistant_service.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/features/ai/data/local/ai_assistant_tool_dao.dart';
import 'package:kopim/features/ai/data/local/ai_analytics_dao.dart';
import 'package:kopim/features/ai/domain/entities/ai_financial_overview_entity.dart';
import 'package:kopim/features/budgets/domain/entities/budget.dart';
import 'package:kopim/features/budgets/domain/entities/budget_category_allocation.dart';
import 'package:kopim/features/budgets/domain/entities/budget_instance_status.dart';
import 'package:kopim/features/budgets/domain/entities/budget_period.dart';
import 'package:kopim/features/budgets/domain/entities/budget_scope.dart';
import 'package:kopim/features/budgets/domain/services/budget_schedule.dart';
import 'package:kopim/features/transactions/domain/entities/transaction_type.dart';

class AiAssistantToolExecutionResult {
  const AiAssistantToolExecutionResult({
    required this.messages,
    required this.logs,
  });

  final List<AiAssistantMessage> messages;
  final List<AiAssistantToolCallLog> logs;
}

class AiAssistantToolCallLog {
  const AiAssistantToolCallLog({
    required this.name,
    required this.callId,
    required this.durationMs,
    required this.success,
    this.errorMessage,
  });

  final String name;
  final String callId;
  final int durationMs;
  final bool success;
  final String? errorMessage;
}

class AiAssistantToolRouter {
  AiAssistantToolRouter({
    required AiAssistantToolDao toolDao,
    required AiAnalyticsDao analyticsDao,
    required LoggerService loggerService,
    BudgetSchedule budgetSchedule = const BudgetSchedule(),
    DateTime Function()? nowProvider,
  }) : _toolDao = toolDao,
       _analyticsDao = analyticsDao,
       _loggerService = loggerService,
       _budgetSchedule = budgetSchedule,
       _nowProvider = nowProvider ?? DateTime.now;

  static const int _maxTransactions = 200;
  static const int _maxTopCategories = 10;
  static const int _maxMatches = 20;
  static const int _maxRangeDays = 180;
  static const int _defaultTransactionsLimit = 50;
  static const int _defaultTopCategoriesLimit = 5;
  static const int _maxBudgetCategories = 50;
  static const int _defaultBudgetCategoriesLimit = 50;

  final AiAssistantToolDao _toolDao;
  final AiAnalyticsDao _analyticsDao;
  final LoggerService _loggerService;
  final BudgetSchedule _budgetSchedule;
  final DateTime Function() _nowProvider;

  Future<AiAssistantToolExecutionResult> runToolCalls(
    List<AiToolCall> toolCalls,
  ) async {
    final List<AiAssistantMessage> messages = <AiAssistantMessage>[];
    final List<AiAssistantToolCallLog> logs = <AiAssistantToolCallLog>[];

    for (final AiToolCall toolCall in toolCalls) {
      final Stopwatch stopwatch = Stopwatch()..start();
      try {
        final Map<String, dynamic> args = _decodeArguments(toolCall.arguments);
        _loggerService.logInfo(
          'AI ассистент: запуск инструмента ${toolCall.name} '
          '(call_id=${toolCall.id}) с аргументами $args',
        );
        final Map<String, Object?> payload = await _executeTool(
          name: toolCall.name,
          args: args,
        );
        _loggerService.logInfo(
          'AI ассистент: инструмент ${toolCall.name} '
          '(call_id=${toolCall.id}) выполнен успешно',
        );
        messages.add(
          AiAssistantMessage.tool(
            toolCallId: toolCall.id,
            content: jsonEncode(payload),
          ),
        );
        logs.add(
          AiAssistantToolCallLog(
            name: toolCall.name,
            callId: toolCall.id,
            durationMs: stopwatch.elapsedMilliseconds,
            success: true,
          ),
        );
      } catch (error) {
        final Map<String, Object?> payload = <String, Object?>{
          'error': 'Не удалось выполнить инструмент.',
          'details': error.toString(),
        };
        _loggerService.logError(
          'AI ассистент: ошибка инструмента ${toolCall.name} '
          '(call_id=${toolCall.id})',
          error,
        );
        messages.add(
          AiAssistantMessage.tool(
            toolCallId: toolCall.id,
            content: jsonEncode(payload),
          ),
        );
        logs.add(
          AiAssistantToolCallLog(
            name: toolCall.name,
            callId: toolCall.id,
            durationMs: stopwatch.elapsedMilliseconds,
            success: false,
            errorMessage: error.toString(),
          ),
        );
      } finally {
        stopwatch.stop();
      }
    }

    return AiAssistantToolExecutionResult(messages: messages, logs: logs);
  }

  Future<Map<String, Object?>> _executeTool({
    required String name,
    required Map<String, dynamic> args,
  }) async {
    switch (name) {
      case 'get_spending_summary':
        return _getSummary(
          args: args,
          transactionType: TransactionType.expense.storageValue,
        );
      case 'get_income_summary':
        return _getSummary(
          args: args,
          transactionType: TransactionType.income.storageValue,
        );
      case 'get_top_categories':
        return _getTopCategories(args);
      case 'get_transactions':
        return _getTransactions(args);
      case 'find_categories':
        return _findCategories(args);
      case 'find_accounts':
        return _findAccounts(args);
      case 'get_budgets':
        return _getBudgets(args);
      default:
        return <String, Object?>{
          'error': 'Неизвестный инструмент.',
          'tool': name,
        };
    }
  }

  Future<Map<String, Object?>> _getSummary({
    required Map<String, dynamic> args,
    required String transactionType,
  }) async {
    final _ResolvedRange range = _resolveRange(args);
    final List<String> categoryIds = await _resolveCategoryIds(args);
    final List<String> accountIds = _readStringList(args, 'account_ids');
    final List<AiToolCurrencyTotal> totals = await _toolDao.getTotalsByCurrency(
      transactionType: transactionType,
      startDate: range.start,
      endDate: range.end,
      accountIds: accountIds,
      categoryIds: categoryIds,
    );
    final int totalCount = totals.fold<int>(
      0,
      (int sum, AiToolCurrencyTotal item) => sum + item.count,
    );
    return <String, Object?>{
      'start_date': range.start.toIso8601String(),
      'end_date': range.end.toIso8601String(),
      'range_days': range.rangeDays,
      'range_clamped': range.clamped,
      'total_count': totalCount,
      'totals': totals
          .map(
            (AiToolCurrencyTotal item) => <String, Object?>{
              'currency': item.currency,
              'total': item.total,
              'count': item.count,
            },
          )
          .toList(growable: false),
    };
  }

  Future<Map<String, Object?>> _getTopCategories(
    Map<String, dynamic> args,
  ) async {
    final _ResolvedRange range = _resolveRange(args);
    final int requestedLimit = _readInt(
      args,
      'limit',
      _defaultTopCategoriesLimit,
    );
    final int limit = requestedLimit.clamp(1, _maxTopCategories);
    final String type = _readString(args, 'type', 'expense');
    final List<String> accountIds = _readStringList(args, 'account_ids');
    final AiDataFilter filter = AiDataFilter(
      startDate: range.start,
      endDate: range.end,
      accountIds: accountIds,
      topCategoriesLimit: limit,
    );

    if (type == 'income') {
      final List<CategoryIncomeAggregate> items = await _analyticsDao
          .getTopIncomeCategories(filter);
      return <String, Object?>{
        'type': 'income',
        'start_date': range.start.toIso8601String(),
        'end_date': range.end.toIso8601String(),
        'range_days': range.rangeDays,
        'range_clamped': range.clamped,
        'items': items
            .map(
              (CategoryIncomeAggregate item) => <String, Object?>{
                'category_id': item.categoryId,
                'name': item.displayName,
                'total': item.totalIncome,
                'color': item.color,
              },
            )
            .toList(growable: false),
      };
    }

    final List<CategoryExpenseAggregate> items = await _analyticsDao
        .getTopCategories(filter);
    return <String, Object?>{
      'type': 'expense',
      'start_date': range.start.toIso8601String(),
      'end_date': range.end.toIso8601String(),
      'range_days': range.rangeDays,
      'range_clamped': range.clamped,
      'items': items
          .map(
            (CategoryExpenseAggregate item) => <String, Object?>{
              'category_id': item.categoryId,
              'name': item.displayName,
              'total': item.totalExpense,
              'color': item.color,
            },
          )
          .toList(growable: false),
    };
  }

  Future<Map<String, Object?>> _getTransactions(
    Map<String, dynamic> args,
  ) async {
    final _ResolvedRange range = _resolveRange(args);
    final int requestedLimit = _readInt(
      args,
      'limit',
      _defaultTransactionsLimit,
    );
    final int limit = requestedLimit.clamp(1, _maxTransactions);
    final List<String> categoryIds = await _resolveCategoryIds(args);
    final List<String> accountIds = _readStringList(args, 'account_ids');
    final String? rawType = _readOptionalString(args, 'transaction_type');
    final String? transactionType = rawType == null
        ? null
        : _toolDao.toTransactionType(rawType);

    final List<AiToolTransactionRow> rows = await _toolDao.getTransactions(
      startDate: range.start,
      endDate: range.end,
      accountIds: accountIds,
      categoryIds: categoryIds,
      transactionType: transactionType,
      limit: limit,
    );

    return <String, Object?>{
      'start_date': range.start.toIso8601String(),
      'end_date': range.end.toIso8601String(),
      'range_days': range.rangeDays,
      'range_clamped': range.clamped,
      'limit': limit,
      'items': rows
          .map(
            (AiToolTransactionRow row) => <String, Object?>{
              'id': row.id,
              'amount': row.amount,
              'currency': row.currency,
              'type': row.type,
              'date': row.date.toIso8601String(),
              'account': <String, Object?>{
                'id': row.accountId,
                'name': row.accountName,
              },
              'category': row.categoryId == null
                  ? null
                  : <String, Object?>{
                      'id': row.categoryId,
                      'name': row.categoryName ?? '',
                    },
              'note': row.note,
            },
          )
          .toList(growable: false),
    };
  }

  Future<Map<String, Object?>> _findCategories(
    Map<String, dynamic> args,
  ) async {
    final String query = _readString(args, 'query', '');
    final int requestedLimit = _readInt(args, 'limit', _maxMatches);
    final int limit = requestedLimit.clamp(1, _maxMatches);
    final List<AiToolCategoryMatch> items = await _toolDao.findCategories(
      query: query,
      limit: limit,
    );
    return <String, Object?>{
      'query': query,
      'items': items
          .map(
            (AiToolCategoryMatch item) => <String, Object?>{
              'id': item.id,
              'name': item.name,
              'type': item.type,
              'color': item.color,
            },
          )
          .toList(growable: false),
    };
  }

  Future<Map<String, Object?>> _findAccounts(Map<String, dynamic> args) async {
    final String query = _readString(args, 'query', '');
    final int requestedLimit = _readInt(args, 'limit', _maxMatches);
    final int limit = requestedLimit.clamp(1, _maxMatches);
    final List<AiToolAccountMatch> items = await _toolDao.findAccounts(
      query: query,
      limit: limit,
    );
    return <String, Object?>{
      'query': query,
      'items': items
          .map(
            (AiToolAccountMatch item) => <String, Object?>{
              'id': item.id,
              'name': item.name,
              'currency': item.currency,
              'type': item.type,
            },
          )
          .toList(growable: false),
    };
  }

  Future<Map<String, Object?>> _getBudgets(Map<String, dynamic> args) async {
    final String? rawBudgetId = _readOptionalString(args, 'budget_id');
    final String? budgetId = _normalizeBudgetId(rawBudgetId);
    final int requestedLimit = _readInt(
      args,
      'category_limit',
      _defaultBudgetCategoriesLimit,
    );
    final int categoryLimit = requestedLimit.clamp(1, _maxBudgetCategories);
    final DateTime now = _nowProvider();
    final List<Budget> budgets = await _toolDao.getBudgets(budgetId: budgetId);
    if (budgets.isEmpty) {
      return <String, Object?>{
        'budget_id': budgetId,
        'generated_at': now.toIso8601String(),
        'items': const <Object?>[],
      };
    }

    final List<Map<String, Object?>> items = <Map<String, Object?>>[];
    for (final Budget budget in budgets) {
      final ({DateTime start, DateTime end}) period = _budgetSchedule.periodFor(
        budget: budget,
        reference: _nowProvider(),
      );
      final DateTime endExclusive = period.end.subtract(
        const Duration(microseconds: 1),
      );
      final List<String> accountIds = budget.scope == BudgetScope.byAccount
          ? budget.accounts
          : <String>[];
      final List<String> scopeCategoryIds =
          budget.scope == BudgetScope.byCategory
          ? budget.categories
          : <String>[];

      final double spent = await _toolDao.getBudgetTotalSpent(
        startDate: period.start,
        endDate: endExclusive,
        accountIds: accountIds,
        categoryIds: scopeCategoryIds,
      );

      final List<AiToolBudgetCategorySpend> categorySpending = await _toolDao
          .getBudgetCategorySpending(
            startDate: period.start,
            endDate: endExclusive,
            accountIds: accountIds,
            categoryIds: scopeCategoryIds,
          );
      final Map<String?, AiToolBudgetCategorySpend> spendingByCategory =
          <String?, AiToolBudgetCategorySpend>{
            for (final AiToolBudgetCategorySpend item in categorySpending)
              item.categoryId: item,
          };

      final Set<String> plannedCategoryIds = <String>{};
      if (budget.categoryAllocations.isNotEmpty) {
        plannedCategoryIds.addAll(
          budget.categoryAllocations.map(
            (BudgetCategoryAllocation allocation) => allocation.categoryId,
          ),
        );
      } else if (budget.scope == BudgetScope.byCategory &&
          budget.categories.isNotEmpty) {
        plannedCategoryIds.addAll(budget.categories);
      }

      final Set<String> categoryIds = <String>{
        ...plannedCategoryIds,
        ...spendingByCategory.keys.whereType<String>(),
      };
      final Map<String, String> categoryNames = await _analyticsDao
          .getCategoryNames(categoryIds.toList(growable: false));

      final List<Map<String, Object?>> categoryItems =
          _buildBudgetCategoryItems(
            budget: budget,
            plannedCategoryIds: plannedCategoryIds,
            spendingByCategory: spendingByCategory,
            categoryNames: categoryNames,
          );

      categoryItems.sort((Map<String, Object?> a, Map<String, Object?> b) {
        final double spentA = (a['spent'] as num).toDouble();
        final double spentB = (b['spent'] as num).toDouble();
        final int spentComparison = spentB.compareTo(spentA);
        if (spentComparison != 0) {
          return spentComparison;
        }
        final String nameA = (a['name'] as String?) ?? '';
        final String nameB = (b['name'] as String?) ?? '';
        return nameA.compareTo(nameB);
      });

      final List<Map<String, Object?>> limitedCategories = categoryItems
          .take(categoryLimit)
          .toList(growable: false);

      final double remaining = budget.amount - spent;
      final double utilization = budget.amount <= 0
          ? (spent > 0 ? double.infinity : 0)
          : spent / budget.amount;
      final BudgetInstanceStatus status = _budgetSchedule.statusFor(
        clock: now,
        start: period.start,
        end: period.end,
      );

      items.add(<String, Object?>{
        'id': budget.id,
        'title': budget.title,
        'period': budget.period.storageValue,
        'scope': budget.scope.storageValue,
        'amount': budget.amount,
        'spent': spent,
        'remaining': remaining,
        'utilization': utilization.isFinite ? utilization : null,
        'is_exceeded': spent > budget.amount,
        'status': status.storageValue,
        'period_start': period.start.toIso8601String(),
        'period_end': period.end.toIso8601String(),
        'accounts': budget.accounts,
        'categories': limitedCategories,
        'categories_total': categoryItems.length,
        'has_allocations': budget.categoryAllocations.isNotEmpty,
      });
    }

    return <String, Object?>{
      'budget_id': budgetId,
      'generated_at': now.toIso8601String(),
      'items': items,
    };
  }

  List<Map<String, Object?>> _buildBudgetCategoryItems({
    required Budget budget,
    required Set<String> plannedCategoryIds,
    required Map<String?, AiToolBudgetCategorySpend> spendingByCategory,
    required Map<String, String> categoryNames,
  }) {
    final Set<String?> categoryIds = <String?>{
      ...plannedCategoryIds,
      ...spendingByCategory.keys,
    };
    final List<Map<String, Object?>> items = <Map<String, Object?>>[];
    for (final String? categoryId in categoryIds) {
      final AiToolBudgetCategorySpend? spending =
          spendingByCategory[categoryId];
      final double spent = spending?.spent ?? 0;
      final String name = categoryId == null
          ? (spending?.name ?? 'Без категории')
          : (categoryNames[categoryId] ?? spending?.name ?? 'Категория');
      final double? limit = categoryId == null
          ? null
          : _resolveBudgetCategoryLimit(budget, categoryId);
      final double? remaining = limit == null ? null : limit - spent;
      items.add(<String, Object?>{
        'id': categoryId,
        'name': name,
        'planned': plannedCategoryIds.contains(categoryId),
        'spent': spent,
        'limit': limit,
        'remaining': remaining,
      });
    }
    return items;
  }

  double? _resolveBudgetCategoryLimit(Budget budget, String categoryId) {
    final Iterable<BudgetCategoryAllocation> allocations = budget
        .categoryAllocations
        .where(
          (BudgetCategoryAllocation allocation) =>
              allocation.categoryId == categoryId,
        );
    if (allocations.isNotEmpty) {
      return allocations.fold<double>(
        0,
        (double previous, BudgetCategoryAllocation allocation) =>
            previous + allocation.limit,
      );
    }
    if (budget.scope == BudgetScope.byCategory &&
        budget.categories.length == 1 &&
        budget.categories.first == categoryId) {
      return budget.amount;
    }
    return null;
  }

  String? _normalizeBudgetId(String? raw) {
    if (raw == null) {
      return null;
    }
    final String normalized = raw.trim().toLowerCase();
    if (normalized.isEmpty || normalized == 'all') {
      return null;
    }
    return raw.trim();
  }

  Future<List<String>> _resolveCategoryIds(Map<String, dynamic> args) async {
    final List<String> categoryIds = _readStringList(args, 'category_ids');
    if (categoryIds.isEmpty) {
      return categoryIds;
    }
    return _toolDao.expandCategoryIds(categoryIds);
  }

  _ResolvedRange _resolveRange(Map<String, dynamic> args) {
    final DateTime now = _nowProvider();
    final String? startRaw = _readOptionalString(args, 'start_date');
    final String? endRaw = _readOptionalString(args, 'end_date');
    DateTime? start = _parseDate(startRaw);
    DateTime? end = _parseDate(endRaw);

    if (start != null && end == null) {
      end = now;
    } else if (end != null && start == null) {
      start = end.subtract(const Duration(days: 30));
    }

    if (start == null || end == null) {
      final String period = _readString(args, 'period', 'last_30_days');
      final _ResolvedRange range = _rangeForPeriod(now, period);
      start ??= range.start;
      end ??= range.end;
    }

    if (start.isAfter(end)) {
      final DateTime swap = start;
      start = end;
      end = swap;
    }

    final int rangeDays = end.difference(start).inDays.abs();
    if (rangeDays > _maxRangeDays) {
      final DateTime clampedStart = end.subtract(
        const Duration(days: _maxRangeDays),
      );
      return _ResolvedRange(
        start: clampedStart,
        end: end,
        clamped: true,
        rangeDays: _maxRangeDays,
      );
    }

    return _ResolvedRange(
      start: start,
      end: end,
      clamped: false,
      rangeDays: rangeDays,
    );
  }

  _ResolvedRange _rangeForPeriod(DateTime now, String period) {
    switch (period) {
      case 'current_month':
      case 'month_to_date':
        return _ResolvedRange(
          start: DateTime(now.year, now.month, 1),
          end: now,
          clamped: false,
          rangeDays: now.difference(DateTime(now.year, now.month, 1)).inDays,
        );
      case 'last_month':
        final DateTime start = DateTime(now.year, now.month - 1, 1);
        final DateTime end = DateTime(now.year, now.month, 0, 23, 59, 59);
        return _ResolvedRange(
          start: start,
          end: end,
          clamped: false,
          rangeDays: end.difference(start).inDays.abs(),
        );
      case 'last_90_days':
        final DateTime start = now.subtract(const Duration(days: 90));
        return _ResolvedRange(
          start: start,
          end: now,
          clamped: false,
          rangeDays: 90,
        );
      case 'last_week':
        final DateTime start = now.subtract(const Duration(days: 7));
        return _ResolvedRange(
          start: start,
          end: now,
          clamped: false,
          rangeDays: 7,
        );
      case 'week_to_date':
        final DateTime start = _startOfWeek(now);
        return _ResolvedRange(
          start: start,
          end: now,
          clamped: false,
          rangeDays: now.difference(start).inDays,
        );
      case 'year_to_date':
        final DateTime start = DateTime(now.year, 1, 1);
        return _ResolvedRange(
          start: start,
          end: now,
          clamped: false,
          rangeDays: now.difference(start).inDays,
        );
      case 'last_30_days':
      default:
        final DateTime start = now.subtract(const Duration(days: 30));
        return _ResolvedRange(
          start: start,
          end: now,
          clamped: false,
          rangeDays: 30,
        );
    }
  }

  DateTime _startOfWeek(DateTime value) {
    final int diff = value.weekday - DateTime.monday;
    final DateTime start = DateTime(
      value.year,
      value.month,
      value.day,
    ).subtract(Duration(days: diff));
    return start;
  }

  Map<String, dynamic> _decodeArguments(String raw) {
    if (raw.trim().isEmpty) {
      return <String, dynamic>{};
    }
    final Object decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw const FormatException('Ожидался объект аргументов инструмента.');
  }

  DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }

  String _readString(Map<String, dynamic> args, String key, String fallback) {
    final Object? value = args[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return fallback;
  }

  String? _readOptionalString(Map<String, dynamic> args, String key) {
    final Object? value = args[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return null;
  }

  int _readInt(Map<String, dynamic> args, String key, int fallback) {
    final Object? value = args[key];
    if (value is int) {
      return value;
    }
    if (value is String) {
      final int? parsed = int.tryParse(value);
      if (parsed != null) {
        return parsed;
      }
    }
    return fallback;
  }

  List<String> _readStringList(Map<String, dynamic> args, String key) {
    final Object? value = args[key];
    if (value is List<dynamic>) {
      return value
          .whereType<String>()
          .map((String item) => item.trim())
          .where((String item) => item.isNotEmpty)
          .toList(growable: false);
    }
    return const <String>[];
  }
}

class _ResolvedRange {
  const _ResolvedRange({
    required this.start,
    required this.end,
    required this.clamped,
    required this.rangeDays,
  });

  final DateTime start;
  final DateTime end;
  final bool clamped;
  final int rangeDays;
}
