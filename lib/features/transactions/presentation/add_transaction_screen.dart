import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kopim/features/transactions/presentation/controllers/transaction_form_controller.dart';
import 'package:kopim/features/transactions/presentation/widgets/transaction_form_view.dart';
import 'package:kopim/l10n/app_localizations.dart';

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
        ),
      ),
    );
  }
}
