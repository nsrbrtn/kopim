import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kopim/core/utils/context_extensions.dart';
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/features/credits/presentation/widgets/credit_card.dart';
import 'package:kopim/core/di/injectors.dart';

class CreditsScreen extends ConsumerWidget {
  const CreditsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Stream<List<CreditEntity>> creditsAsync = ref
        .watch(watchCreditsUseCaseProvider)
        .call();

    return Scaffold(
      appBar: AppBar(title: Text(context.loc.creditsTitle)),
      body: StreamBuilder<List<CreditEntity>>(
        stream: creditsAsync,
        builder:
            (BuildContext context, AsyncSnapshot<List<CreditEntity>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final List<CreditEntity> credits =
                  snapshot.data ?? <CreditEntity>[];
              if (credits.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.account_balance_outlined,
                        size: 64,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        context.loc.creditsEmptyList,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: credits.length,
                itemBuilder: (BuildContext context, int index) {
                  final CreditEntity credit = credits[index];
                  return Dismissible(
                    key: Key(credit.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                      ),
                    ),
                    onDismissed: (DismissDirection direction) {
                      ref.read(deleteCreditUseCaseProvider).call(credit);
                    },
                    child: CreditCard(
                      credit: credit,
                      onTap: () {
                        context.push('/credits/edit', extra: credit);
                      },
                    ),
                  );
                },
              );
            },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/credits/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
