import 'package:freezed_annotation/freezed_annotation.dart';

part 'upcoming_item.freezed.dart';

enum UpcomingItemType { paymentRule, reminder }

@freezed
abstract class UpcomingItem with _$UpcomingItem {
  const factory UpcomingItem({
    required UpcomingItemType type,
    required String id,
    required String title,
    required double amount,
    required int whenMs,
    String? note,
  }) = _UpcomingItem;
}
