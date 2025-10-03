import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/analytics/domain/models/analytics_overview.dart';
import 'package:kopim/features/analytics/presentation/controllers/analytics_filter_controller.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'analytics_providers.g.dart';

@riverpod
Stream<AnalyticsOverview> analyticsOverview(
  Ref ref, {
  int topCategoriesLimit = 5,
}) {
  final AnalyticsFilterState filters = ref.watch(
    analyticsFilterControllerProvider,
  );
  return ref
      .watch(watchMonthlyAnalyticsUseCaseProvider)
      .call(topCategoriesLimit: topCategoriesLimit, filter: filters.toDomain());
}

@riverpod
Stream<List<Category>> analyticsCategories(Ref ref) {
  return ref.watch(watchCategoriesUseCaseProvider).call();
}

@riverpod
Stream<List<AccountEntity>> analyticsAccounts(Ref ref) {
  return ref.watch(watchAccountsUseCaseProvider).call();
}
