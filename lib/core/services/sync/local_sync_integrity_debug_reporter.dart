import 'package:flutter/foundation.dart';
import 'package:kopim/core/config/app_runtime.dart';
import 'package:kopim/core/services/logger_service.dart';
import 'package:kopim/core/services/sync/local_sync_integrity_diagnostics_service.dart';

class LocalSyncIntegrityDebugReporter {
  LocalSyncIntegrityDebugReporter({
    required LocalSyncIntegrityDiagnosticsService diagnosticsService,
    required LocalSyncIntegrityReportFormatter formatter,
    required LoggerService logger,
  }) : _diagnosticsService = diagnosticsService,
       _formatter = formatter,
       _logger = logger;

  final LocalSyncIntegrityDiagnosticsService _diagnosticsService;
  final LocalSyncIntegrityReportFormatter _formatter;
  final LoggerService _logger;

  bool get _enabled =>
      kDebugMode ||
      AppRuntimeConfig.flavor != AppRuntimeFlavor.storeProdLocalFirst;

  Future<void> runAndLog({required String context}) async {
    if (!_enabled) {
      return;
    }
    final LocalSyncIntegrityReport report = await _diagnosticsService.run();
    logReport(context: context, report: report);
  }

  void logReport({
    required String context,
    required LocalSyncIntegrityReport report,
  }) {
    if (!_enabled) {
      return;
    }
    final String formatted = _formatter.format(report);
    _logger.logInfo('Local sync integrity debug report [$context]\n$formatted');
  }
}
