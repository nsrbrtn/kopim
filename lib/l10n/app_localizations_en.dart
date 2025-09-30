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
  String get homeAccountsAddTooltip => 'Add account';

  @override
  String get addAccountTitle => 'Add account';

  @override
  String get addAccountNameLabel => 'Account name';

  @override
  String get addAccountBalanceLabel => 'Starting balance';

  @override
  String get addAccountCurrencyLabel => 'Currency';

  @override
  String get addAccountTypeLabel => 'Account type';

  @override
  String get addAccountSaveCta => 'Save account';

  @override
  String get addAccountNameRequired => 'Please enter the account name.';

  @override
  String get addAccountBalanceInvalid => 'Enter a valid amount.';

  @override
  String get addAccountError => 'Could not save account. Please try again.';

  @override
  String get addAccountTypeCash => 'Cash';

  @override
  String get addAccountTypeCard => 'Card';

  @override
  String get addAccountTypeBank => 'Bank account';
}
