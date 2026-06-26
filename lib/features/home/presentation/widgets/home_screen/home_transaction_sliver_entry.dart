import 'package:kopim/features/transactions/domain/models/feed_item.dart';

sealed class HomeTransactionSliverEntry {
  const HomeTransactionSliverEntry();
}

class HomeTransactionHeaderEntry extends HomeTransactionSliverEntry {
  const HomeTransactionHeaderEntry({
    required this.title,
    required this.netAmount,
  });

  final String title;
  final double netAmount;
}

class HomeTransactionItemEntry extends HomeTransactionSliverEntry {
  const HomeTransactionItemEntry({required this.transactionId});

  final String transactionId;
}

class HomeTransactionGroupEntry extends HomeTransactionSliverEntry {
  const HomeTransactionGroupEntry({required this.item});

  final GroupedCreditPaymentFeedItem item;
}
