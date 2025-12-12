import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kopim/features/transactions/presentation/controllers/transaction_form_controller.dart';
import 'package:kopim/features/transactions/presentation/widgets/transaction_form_view.dart';
import 'package:kopim/l10n/app_localizations.dart';

const Color _kFabBackgroundColor = Color(0xFFAEF75F);
const Color _kFabForegroundColor = Color(0xFF1D3700);

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({
    super.key,
    this.formArgs = const TransactionFormArgs(),
  });

  static const String routeName = '/transactions/add';
  final TransactionFormArgs formArgs;

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final TransactionFormProvider formProvider =
        transactionFormControllerProvider(widget.formArgs);
    final bool isSubmitting = ref.watch(
      formProvider.select(
        (TransactionDraftState state) => state.isSubmitting,
      ),
    );
    final bool isEditing = widget.formArgs.initialTransaction != null;
    final String submitLabel = isEditing
        ? strings.editTransactionSubmit
        : strings.addTransactionSubmit;
    final String title = isEditing
        ? strings.editTransactionSubmit
        : strings.addTransactionTitle;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: TransactionFormView(
          formKey: _formKey,
          formArgs: widget.formArgs,
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
                    .read(formProvider.notifier)
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
