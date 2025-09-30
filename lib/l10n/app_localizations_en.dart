// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileSignInPrompt => 'Sign in to manage your profile.';

  @override
  String get profileSectionAccount => 'Account';

  @override
  String get profileNameLabel => 'Name';

  @override
  String get profileCurrencyLabel => 'Default currency';

  @override
  String get profileLocaleLabel => 'Preferred locale';

  @override
  String profileLoadError(String error) {
    return 'Unable to load profile: $error';
  }

  @override
  String get profileSaveCta => 'Save changes';

  @override
  String get signInTitle => 'Welcome to Kopim';

  @override
  String get signInSubtitle => 'Sign in to sync your finances across devices.';

  @override
  String get signInEmailLabel => 'Email';

  @override
  String get signInPasswordLabel => 'Password';

  @override
  String get signInSubmitCta => 'Sign in';

  @override
  String get signInGoogleCta => 'Continue with Google';

  @override
  String get signInError => 'Could not sign in. Please try again.';

  @override
  String get signInLoading => 'Signing in...';

  @override
  String get signInOfflineNotice =>
      'You appear to be offline. We will sync your data once you reconnect.';

  @override
  String get homeTitle => 'Home';

  @override
  String homeTotalBalance(String amount) {
    return 'Total balance: $amount';
  }

  @override
  String homeAuthError(String error) {
    return 'Authentication error: $error';
  }

  @override
  String get homeAccountsSection => 'Accounts';

  @override
  String get homeAccountsEmpty =>
      'No accounts yet. Add your first account to track balance.';

  @override
  String homeAccountsError(String error) {
    return 'Unable to load accounts: $error';
  }

  @override
  String homeAccountType(String type) {
    return 'Type: $type';
  }

  @override
  String get homeTransactionsSection => 'Recent transactions';

  @override
  String get homeTransactionsEmpty => 'No transactions recorded yet.';

  @override
  String homeTransactionsError(String error) {
    return 'Unable to load transactions: $error';
  }

  @override
  String get homeTransactionsUncategorized => 'Uncategorized';

  @override
  String homeTransactionsCategory(String category) {
    return 'Category: $category';
  }

  @override
  String get homeTransactionSymbolPositive => '+';

  @override
  String get homeTransactionSymbolNegative => '-';

  @override
  String get homeNavHome => 'Home';

  @override
  String get homeNavAnalytics => 'Analytics';

  @override
  String get homeNavSettings => 'Settings';

  @override
  String get analyticsTitle => 'Analytics';

  @override
  String get analyticsComingSoon => 'Detailed analytics are coming soon.';

  @override
  String get addTransactionTitle => 'Add transaction';

  @override
  String get addTransactionComingSoon =>
      'Transaction creation will be available shortly.';

  @override
  String get addTransactionAccountLabel => 'Account';

  @override
  String get addTransactionAccountRequired => 'Please choose an account';

  @override
  String addTransactionAccountsError(String error) =>
      'Unable to load accounts: $error';

  @override
  String get addTransactionNoAccounts =>
      'Create an account first to add transactions.';

  @override
  String get addTransactionAmountLabel => 'Amount';

  @override
  String get addTransactionAmountHint => '0.00';

  @override
  String get addTransactionAmountInvalid =>
      'Enter a valid amount greater than zero';

  @override
  String get addTransactionTypeLabel => 'Type';

  @override
  String get addTransactionTypeExpense => 'Expense';

  @override
  String get addTransactionTypeIncome => 'Income';

  @override
  String get addTransactionCategoryLabel => 'Category';

  @override
  String get addTransactionCategoryNone => 'No category';

  @override
  String get addTransactionCategoriesLoading => 'Loading categories…';

  @override
  String addTransactionCategoriesError(String error) =>
      'Unable to load categories: $error';

  @override
  String get addTransactionDateLabel => 'Date';

  @override
  String get addTransactionNoteLabel => 'Note';

  @override
  String get addTransactionSubmit => 'Save transaction';

  @override
  String get addTransactionAccountMissingError =>
      'Selected account is no longer available.';

  @override
  String get addTransactionUnknownError =>
      'Unable to save the transaction. Try again.';

  @override
  String get addTransactionSuccess => 'Transaction saved';
}
