import 'package:flutter/material.dart';
import 'package:kopim/core/config/theme_extensions.dart';
import 'home_transaction_list_item.dart';

class HomeTransactionTileSkeleton extends StatelessWidget {
  const HomeTransactionTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: HomeSkeletonContainer(),
    );
  }
}

class HomeTransactionsSkeletonList extends StatelessWidget {
  const HomeTransactionsSkeletonList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      itemBuilder: (BuildContext context, int index) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 6),
          child: HomeSkeletonContainer(),
        );
      },
    );
  }
}

class HomeSkeletonContainer extends StatelessWidget {
  const HomeSkeletonContainer({super.key});

  static const double _height = HomeTransactionListItem.extent - 10;

  @override
  Widget build(BuildContext context) {
    final Color base = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Container(
      height: _height,
      decoration: BoxDecoration(
        color: base.withValues(alpha: 0.5),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
    );
  }
}

class HomeTransactionsSectionLoading extends StatelessWidget {
  const HomeTransactionsSectionLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeTransactionsContainer(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class HomeTransactionsContainer extends StatelessWidget {
  const HomeTransactionsContainer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final double containerRadius = context.kopimLayout.radius.xxl;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(containerRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: child,
      ),
    );
  }
}
