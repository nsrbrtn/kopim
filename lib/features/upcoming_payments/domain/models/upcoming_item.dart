import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kopim/core/money/money_utils.dart';

part 'upcoming_item.freezed.dart';

enum UpcomingItemType { paymentRule, reminder }

@freezed
abstract class UpcomingItem with _$UpcomingItem {
  const factory UpcomingItem({
    required UpcomingItemType type,
    required String id,
    required String title,
    required MoneyAmount amount,
    required int whenMs,
    String? categoryId,
    String? note,
  }) = _UpcomingItem;
}
