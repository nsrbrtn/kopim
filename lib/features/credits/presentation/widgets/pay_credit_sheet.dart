import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/core/money/money.dart';
import 'package:kopim/core/utils/context_extensions.dart';
import 'package:kopim/features/accounts/domain/entities/account_entity.dart';
import 'package:kopim/features/credits/domain/entities/credit_entity.dart';
import 'package:kopim/features/credits/domain/entities/credit_payment_group.dart';
import 'package:kopim/features/credits/domain/entities/credit_payment_schedule.dart';
import 'package:kopim/features/credits/domain/utils/credit_payment_amounts.dart';
import 'package:kopim/features/credits/domain/use_cases/make_credit_payment_use_case.dart';
import 'package:kopim/features/credits/domain/use_cases/update_credit_payment_case.dart';

class PayCreditSheet extends ConsumerStatefulWidget {
  const PayCreditSheet({
    required this.credit,
    this.scheduleItem,
    this.paymentGroup,
    super.key,
  });

  final CreditEntity credit;
  final CreditPaymentScheduleEntity? scheduleItem;
  final CreditPaymentGroupEntity? paymentGroup;

  static Future<void> show(
    BuildContext context, {
    required CreditEntity credit,
    CreditPaymentScheduleEntity? scheduleItem,
    CreditPaymentGroupEntity? paymentGroup,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PayCreditSheet(
        credit: credit,
        scheduleItem: scheduleItem,
        paymentGroup: paymentGroup,
      ),
    );
  }

  @override
  ConsumerState<PayCreditSheet> createState() => _PayCreditSheetState();
}

class _PayCreditSheetState extends ConsumerState<PayCreditSheet> {
  late final TextEditingController _principalController;
  late final TextEditingController _interestController;
  late final TextEditingController _feesController;
  late final TextEditingController _noteController;

  AccountEntity? _sourceAccount;
  bool _isSubmitting = false;

  bool get _isEditing => widget.paymentGroup != null;

  @override
  void initState() {
    super.initState();
    final CreditPaymentGroupEntity? group = widget.paymentGroup;
    final CreditPaymentScheduleEntity? item = widget.scheduleItem;
    final String principalText = group != null
        ? group.principalPaid.toDecimalString()
        : item == null
        ? '0'
        : remainingPrincipalAmount(item).toDecimalString();
    final String interestText = group != null
        ? group.interestPaid.toDecimalString()
        : item == null
        ? '0'
        : remainingInterestAmount(item).toDecimalString();
    final String feesText = group?.feesPaid.toDecimalString() ?? '0';
    _principalController = TextEditingController(text: principalText);
    _interestController = TextEditingController(text: interestText);
    _feesController = TextEditingController(text: feesText);
    _noteController = TextEditingController(text: group?.note ?? '');
  }

  @override
  void dispose() {
    _principalController.dispose();
    _interestController.dispose();
    _feesController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Stream<List<AccountEntity>> accountsAsync = ref
        .watch(watchAccountsUseCaseProvider)
        .call();

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 16,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _isEditing
                    ? context.loc.creditsEditTitle
                    : context.loc.creditDetailsPayAction,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.loc.creditsTitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              _AmountField(
                controller: _principalController,
                label: context.loc.creditPaymentDetailsPrincipalLabel,
                icon: Icons.account_balance_wallet,
              ),
              const SizedBox(height: 16),
              _AmountField(
                controller: _interestController,
                label: context.loc.creditDetailsInterestLabel,
                icon: Icons.percent,
              ),
              const SizedBox(height: 16),
              _AmountField(
                controller: _feesController,
                label: context.loc.creditPaymentDetailsFeesLabel,
                icon: Icons.receipt_long,
              ),
              const SizedBox(height: 24),
              _AmountField(
                controller: _noteController,
                label: context.loc.addTransactionNoteLabel,
                icon: Icons.sticky_note_2_outlined,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 24),

              Text(
                context.loc.allTransactionsFiltersAccount,
                style: theme.textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              StreamBuilder<List<AccountEntity>>(
                stream: accountsAsync,
                builder:
                    (
                      BuildContext context,
                      AsyncSnapshot<List<AccountEntity>> snapshot,
                    ) {
                      final List<AccountEntity> accounts =
                          snapshot.data ?? <AccountEntity>[];
                      if (accounts.isEmpty) return const SizedBox.shrink();

                      final Map<String, AccountEntity> uniqueById =
                          <String, AccountEntity>{};
                      for (final AccountEntity account in accounts) {
                        uniqueById.putIfAbsent(account.id, () => account);
                      }
                      final List<AccountEntity> uniqueAccounts = uniqueById
                          .values
                          .toList(growable: false);

                      if (_sourceAccount == null && uniqueAccounts.isNotEmpty) {
                        final String? preferredId =
                            widget.paymentGroup?.sourceAccountId;
                        if (preferredId != null) {
                          _sourceAccount = uniqueAccounts
                              .cast<AccountEntity?>()
                              .firstWhere(
                                (AccountEntity? a) => a?.id == preferredId,
                                orElse: () => null,
                              );
                        }
                        _sourceAccount = uniqueAccounts.firstWhere(
                          (AccountEntity a) =>
                              a.id == _sourceAccount?.id ||
                              a.id != widget.credit.accountId,
                          orElse: () => uniqueAccounts.first,
                        );
                      } else if (_sourceAccount != null) {
                        final AccountEntity? matched = uniqueAccounts
                            .cast<AccountEntity?>()
                            .firstWhere(
                              (AccountEntity? a) => a?.id == _sourceAccount!.id,
                              orElse: () => null,
                            );
                        if (matched != null) {
                          _sourceAccount = matched;
                        } else {
                          _sourceAccount = uniqueAccounts.firstWhere(
                            (AccountEntity a) =>
                                a.id != widget.credit.accountId,
                            orElse: () => uniqueAccounts.first,
                          );
                        }
                      }

                      return DropdownButtonFormField<AccountEntity>(
                        key: ValueKey<String?>(_sourceAccount?.id),
                        initialValue: _sourceAccount,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                        ),
                        items: uniqueAccounts
                            .map(
                              (AccountEntity acc) =>
                                  DropdownMenuItem<AccountEntity>(
                                    value: acc,
                                    child: Text(acc.name),
                                  ),
                            )
                            .toList(),
                        onChanged: _isEditing
                            ? null
                            : (AccountEntity? val) =>
                                  setState(() => _sourceAccount = val),
                      );
                    },
              ),

              const SizedBox(height: 32),
              FilledButton(
                onPressed: _isSubmitting ? null : _submit,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(context.loc.dialogConfirm),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_sourceAccount == null) return;

    setState(() => _isSubmitting = true);

    try {
      final AccountEntity? creditAccount = await ref
          .read(accountRepositoryProvider)
          .findById(widget.credit.accountId);
      if (creditAccount == null) {
        throw StateError('Кредитный счет не найден');
      }
      if (creditAccount.currency != _sourceAccount!.currency) {
        throw StateError(
          'Валюта счета списания должна совпадать с валютой кредитного счета',
        );
      }

      final String currency = creditAccount.currency;
      final int scale =
          widget.credit.totalAmountScale ?? creditAccount.currencyScale ?? 2;

      final Money principal = _principalController.text.isEmpty
          ? Money.fromMinor(BigInt.zero, currency: currency, scale: scale)
          : Money.fromDecimalString(
              _principalController.text,
              currency: currency,
              scale: scale,
            );
      final Money interest = _interestController.text.isEmpty
          ? Money.fromMinor(BigInt.zero, currency: currency, scale: scale)
          : Money.fromDecimalString(
              _interestController.text,
              currency: currency,
              scale: scale,
            );
      final Money fees = _feesController.text.isEmpty
          ? Money.fromMinor(BigInt.zero, currency: currency, scale: scale)
          : Money.fromDecimalString(
              _feesController.text,
              currency: currency,
              scale: scale,
            );

      final Money totalOutflow = Money.fromMinor(
        principal.minor + interest.minor + fees.minor,
        currency: currency,
        scale: scale,
      );
      final String? note = _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim();

      if (totalOutflow.minor <= BigInt.zero) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Введите сумму платежа больше нуля')),
          );
        }
        return;
      }

      if (_isEditing) {
        final UpdateCreditPaymentUseCase updatePayment = ref.read(
          updateCreditPaymentUseCaseProvider,
        );
        await updatePayment(
          groupId: widget.paymentGroup!.id,
          principalPaid: principal,
          interestPaid: interest,
          feesPaid: fees,
          totalOutflow: totalOutflow,
          note: note,
        );
      } else {
        final MakeCreditPaymentUseCase makePayment = ref.read(
          makeCreditPaymentUseCaseProvider,
        );
        await makePayment(
          creditId: widget.credit.id,
          periodKey: widget.scheduleItem?.periodKey,
          sourceAccountId: _sourceAccount!.id,
          principalPaid: principal,
          interestPaid: interest,
          feesPaid: fees,
          totalOutflow: totalOutflow,
          paidAt: DateTime.now(),
          note: note,
        );
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не удалось провести платёж: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}

class _AmountField extends StatelessWidget {
  const _AmountField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType = const TextInputType.numberWithOptions(decimal: true),
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerLow,
      ),
    );
  }
}
