import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kopim/features/transactions/domain/models/feed_item.dart';

part 'day_section.freezed.dart';

@freezed
abstract class DaySection with _$DaySection {
  const factory DaySection({
    required DateTime date,
    required List<FeedItem> items,
  }) = _DaySection;
}
