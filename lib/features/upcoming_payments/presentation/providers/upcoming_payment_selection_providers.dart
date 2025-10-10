import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';

part 'upcoming_payment_selection_providers.g.dart';

@riverpod
Stream<List<AccountEntity>> upcomingPaymentAccounts(Ref ref) {
  return ref.watch(watchAccountsUseCaseProvider).call();
}

@riverpod
Stream<List<Category>> upcomingPaymentCategories(Ref ref) {
  return ref.watch(watchCategoriesUseCaseProvider).call();
}
