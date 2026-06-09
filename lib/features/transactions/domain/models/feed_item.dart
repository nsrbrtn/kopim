import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kopim/core/money/money_utils.dart';
import 'package:kopim/features/transactions/domain/entities/transaction.dart';

part 'feed_item.freezed.dart';

@freezed
sealed class FeedItem with _$FeedItem {
  const factory FeedItem.transaction(TransactionEntity transaction) =
      TransactionFeedItem;

  const factory FeedItem.groupedCreditPayment({
    required String groupId,
    required List<TransactionEntity> transactions,
    required MoneyAmount totalOutflow,
    required DateTime date,
    String? note,
  }) = GroupedCreditPaymentFeedItem;
}
