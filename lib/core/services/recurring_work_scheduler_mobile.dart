import 'package:workmanager/workmanager.dart';

import 'package:kopim/features/upcoming_payments/data/services/upcoming_payments_work_scheduler.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((String task, Map<String, dynamic>? inputData) {
    return runUpcomingPaymentsBackgroundTask(task);
  });
}

void ensureRecurringWorkSchedulerLinked() {}
