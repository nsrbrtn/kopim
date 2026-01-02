import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kopim/core/widgets/kopim_segmented_control.dart';
import 'package:kopim/core/utils/context_extensions.dart';
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/features/credits/domain/entities/debt_entity.dart';
import 'package:kopim/features/credits/presentation/widgets/credit_card.dart';
import 'package:kopim/features/credits/presentation/widgets/debt_card.dart';
import 'package:kopim/core/di/injectors.dart';

enum _CreditsTab { credits, debts }

class CreditsScreen extends ConsumerStatefulWidget {
  const CreditsScreen({super.key});

  @override
  ConsumerState<CreditsScreen> createState() => _CreditsScreenState();
}

class _CreditsScreenState extends ConsumerState<CreditsScreen> {
  _CreditsTab _selectedTab = _CreditsTab.credits;

  @override
  Widget build(BuildContext context) {
    final Stream<List<CreditEntity>> creditsAsync = ref
        .watch(watchCreditsUseCaseProvider)
        .call();
    final Stream<List<DebtEntity>> debtsAsync = ref
        .watch(watchDebtsUseCaseProvider)
        .call();

    return Scaffold(
      appBar: AppBar(title: Text(context.loc.creditsTitle)),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: KopimSegmentedControl<_CreditsTab>(
              options: <KopimSegmentedOption<_CreditsTab>>[
                KopimSegmentedOption<_CreditsTab>(
                  value: _CreditsTab.credits,
                  label: context.loc.creditsSegmentCredits,
                  icon: Icons.account_balance_outlined,
                ),
                KopimSegmentedOption<_CreditsTab>(
                  value: _CreditsTab.debts,
                  label: context.loc.creditsSegmentDebts,
                  icon: Icons.payments_outlined,
                ),
              ],
              selectedValue: _selectedTab,
              onChanged: (_CreditsTab value) {
                setState(() => _selectedTab = value);
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _selectedTab == _CreditsTab.credits
                ? _CreditsList(creditsAsync: creditsAsync)
                : _DebtsList(debtsAsync: debtsAsync),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(
          _selectedTab == _CreditsTab.credits
              ? '/credits/add'
              : '/credits/debts/add',
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CreditsList extends ConsumerWidget {
  const _CreditsList({required this.creditsAsync});

  final Stream<List<CreditEntity>> creditsAsync;

  Future<bool> _confirmDelete(BuildContext context) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(context.loc.creditsDeleteTitle),
          content: Text(context.loc.creditsDeleteMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(context.loc.cancelButtonLabel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(context.loc.deleteButtonLabel),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<List<CreditEntity>>(
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
                  confirmDismiss: (_) => _confirmDelete(context),
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
    );
  }
}

class _DebtsList extends ConsumerWidget {
  const _DebtsList({required this.debtsAsync});

  final Stream<List<DebtEntity>> debtsAsync;

  Future<bool> _confirmDelete(BuildContext context) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(context.loc.debtsDeleteTitle),
          content: Text(context.loc.debtsDeleteMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(context.loc.cancelButtonLabel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(context.loc.deleteButtonLabel),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<List<DebtEntity>>(
      stream: debtsAsync,
      builder:
          (BuildContext context, AsyncSnapshot<List<DebtEntity>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final List<DebtEntity> debts = snapshot.data ?? <DebtEntity>[];
            if (debts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.payments_outlined,
                      size: 64,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.loc.debtsEmptyList,
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
              itemCount: debts.length,
              itemBuilder: (BuildContext context, int index) {
                final DebtEntity debt = debts[index];
                return Dismissible(
                  key: Key(debt.id),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (_) => _confirmDelete(context),
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
                    ref.read(deleteDebtUseCaseProvider).call(debt);
                  },
                  child: DebtCard(
                    debt: debt,
                    onTap: () {
                      context.push('/credits/debts/edit', extra: debt);
                    },
                  ),
                );
              },
            );
          },
    );
  }
}
