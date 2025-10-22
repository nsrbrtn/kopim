import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/ai/domain/entities/ai_financial_overview_entity.dart';
import 'package:kopim/features/ai/domain/use_cases/get_ai_financial_overview_use_case.dart';
import 'package:kopim/features/ai/domain/use_cases/watch_ai_financial_overview_use_case.dart';

part 'ai_financial_overview_providers.g.dart';

void _cacheFor(Ref ref, Duration duration) {
  // ignore: always_specify_types
  final link = ref.keepAlive();
  Timer? timer;
  ref.onCancel(() {
    timer = Timer(duration, link.close);
  });
  ref.onResume(() {
    timer?.cancel();
  });
  ref.onDispose(() {
    timer?.cancel();
  });
}

@Riverpod(keepAlive: true)
Stream<AiFinancialOverview> aiFinancialOverviewStream(
  Ref ref,
  AiDataFilter filter,
) {
  _cacheFor(ref, const Duration(minutes: 5));
  final WatchAiFinancialOverviewUseCase useCase = ref.watch(
    watchAiFinancialOverviewUseCaseProvider,
  );
  return useCase.execute(filter: filter);
}

@Riverpod(keepAlive: true)
Future<AiFinancialOverview> aiFinancialOverviewSnapshot(
  Ref ref,
  AiDataFilter filter,
) async {
  _cacheFor(ref, const Duration(minutes: 5));
  final GetAiFinancialOverviewUseCase useCase = ref.watch(
    getAiFinancialOverviewUseCaseProvider,
  );
  return useCase.execute(filter: filter);
}
