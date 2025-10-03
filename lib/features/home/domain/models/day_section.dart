import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';

part 'day_section.freezed.dart';

@freezed
abstract class DaySection with _$DaySection {
  const factory DaySection({
    required DateTime date,
    required List<TransactionEntity> transactions,
  }) = _DaySection;
}
