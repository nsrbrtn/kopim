import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_transactions_filter_controller.g.dart';

enum HomeTransactionsFilter { all, income, expense }

@riverpod
class HomeTransactionsFilterController
    extends _$HomeTransactionsFilterController {
  @override
  HomeTransactionsFilter build() => HomeTransactionsFilter.all;

  void update(HomeTransactionsFilter filter) {
    if (state == filter) {
      return;
    }
    state = filter;
  }
}
