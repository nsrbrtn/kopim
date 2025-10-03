import 'package:kopim/features/recurring_transactions/domain/entities/recurring_occurrence.dart';
import 'package:kopim/features/recurring_transactions/domain/repositories/recurring_transactions_repository.dart';

class WatchUpcomingOccurrencesUseCase {
  const WatchUpcomingOccurrencesUseCase(this._repository);

  final RecurringTransactionsRepository _repository;

  Stream<List<RecurringOccurrence>> call({
    required DateTime from,
    required DateTime to,
  }) {
    return _repository.watchUpcomingOccurrences(from: from, to: to);
  }
}
