import 'package:kopim/features/transactions/domain/models/account_monthly_totals.dart';
import 'package:kopim/features/transactions/domain/repositories/transaction_repository.dart';

class WatchAccountMonthlyTotalsUseCase {
  WatchAccountMonthlyTotalsUseCase(this._repository);

  final TransactionRepository _repository;

  Stream<List<AccountMonthlyTotals>> call({DateTime? reference}) {
    final DateTime effectiveReference = reference ?? DateTime.now();
    final DateTime start = DateTime(
      effectiveReference.year,
      effectiveReference.month,
    );
    final DateTime end = DateTime(
      effectiveReference.year,
      effectiveReference.month + 1,
    );
    return _repository.watchAccountMonthlyTotals(start: start, end: end);
  }
}
