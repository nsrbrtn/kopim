import 'dart:async';

import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/features/recurring_transactions/data/services/recurring_window_service.dart';
import 'package:workmanager/workmanager.dart';

import 'recurring_work_scheduler.dart';

RecurringWorkScheduler createRecurringWorkScheduler({
  Workmanager? workmanager,
  LoggerService? logger,
  RecurringWindowService? recurringWindowService,
}) {
  return WebRecurringWorkScheduler(
    logger: logger ?? LoggerService(),
    recurringWindowService: recurringWindowService,
  );
}

class WebRecurringWorkScheduler implements RecurringWorkScheduler {
  WebRecurringWorkScheduler({
    required LoggerService logger,
    RecurringWindowService? recurringWindowService,
  }) : _logger = logger,
       _recurringWindowService = recurringWindowService;

  final LoggerService _logger;
  final RecurringWindowService? _recurringWindowService;
  final Map<String, Timer> _timers = <String, Timer>{};

  @override
  Future<void> initialize() async {
    _logger.logInfo('Web recurring scheduler initialized (in-app timers)');
  }

  @override
  Future<void> scheduleDailyWindowGeneration() async {
    _schedule('daily_window', const Duration(hours: 24), () async {
      await _recurringWindowService?.rebuildWindow();
      _logger.logInfo('Web recurring window rebuild executed');
    });
  }

  @override
  Future<void> scheduleMaintenance() async {
    _schedule('maintenance', const Duration(hours: 24), () async {
      await _recurringWindowService?.rebuildWindow();
      _logger.logInfo('Web recurring maintenance executed');
    });
  }

  @override
  Future<void> scheduleApplyRecurringRules() async {
    _logger.logInfo('Recurring rule application disabled on web');
  }

  void _schedule(String key, Duration interval, Future<void> Function() task) {
    _timers[key]?.cancel();
    _timers[key] = Timer(interval, () async {
      await task();
      _timers.remove(key);
    });
  }
}
