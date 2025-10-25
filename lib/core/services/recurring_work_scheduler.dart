import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/features/recurring_transactions/data/services/recurring_window_service.dart';
import 'package:workmanager/workmanager.dart';

import 'recurring_work_scheduler_mobile.dart'
    if (dart.library.js) 'recurring_work_scheduler_web.dart'
    as implementation;

abstract class RecurringWorkScheduler {
  const RecurringWorkScheduler();

  Future<void> initialize();

  Future<void> scheduleDailyWindowGeneration();

  Future<void> scheduleMaintenance();

  Future<void> scheduleApplyRecurringRules();
}

RecurringWorkScheduler createRecurringWorkScheduler({
  Workmanager? workmanager,
  LoggerService? logger,
  RecurringWindowService? recurringWindowService,
}) {
  return implementation.createRecurringWorkScheduler(
    workmanager: workmanager,
    logger: logger,
    recurringWindowService: recurringWindowService,
  );
}
