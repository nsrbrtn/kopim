import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kopim/features/transactions/presentation/controllers/transaction_form_controller.dart';
import 'package:kopim/features/transactions/presentation/widgets/transaction_form_view.dart';
import 'package:kopim/l10n/app_localizations.dart';

const Color _kFabBackgroundColor = Color(0xFFAEF75F);
const Color _kFabForegroundColor = Color(0xFF1D3700);

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  static const String routeName = '/transactions/add';

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TransactionFormArgs _formArgs = const TransactionFormArgs();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final TransactionFormControllerProvider transactionProvider =
        transactionFormControllerProvider(_formArgs);
    final bool isSubmitting = ref.watch(
      transactionProvider.select(
        (TransactionFormState state) => state.isSubmitting,
      ),
    );
    final bool isEditing = _formArgs.initialTransaction != null;
    final String submitLabel = isEditing
        ? strings.editTransactionSubmit
        : strings.addTransactionSubmit;

    return Scaffold(
      appBar: AppBar(title: Text(strings.addTransactionTitle)),
      body: SafeArea(
        child: TransactionFormView(
          formKey: _formKey,
          formArgs: _formArgs,
          onSuccess: (TransactionFormResult result) {
            if (!context.mounted) return;
            Navigator.of(context).pop(result);
          },
          showSubmitButton: false,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: '${AddTransactionScreen.routeName}_save_fab',
        tooltip: submitLabel,
        backgroundColor: _kFabBackgroundColor,
        foregroundColor: _kFabForegroundColor,
        onPressed: isSubmitting
            ? null
            : () async {
                FocusManager.instance.primaryFocus?.unfocus();
                await Future<void>.delayed(Duration.zero);
                if (!(_formKey.currentState?.validate() ?? false)) {
                  return;
                }
                await ref
                    .read(transactionProvider.notifier)
                    .submit();
              },
        child: isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _kFabForegroundColor,
                ),
              )
            : const Icon(Icons.save_rounded),
      ),
    );
  }
}
