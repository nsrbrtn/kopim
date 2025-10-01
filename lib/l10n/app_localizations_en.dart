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
  String get profileSignInPrompt => 'Please sign in to manage your profile.';

  @override
  String get profileSectionAccount => 'Account';

  @override
  String get profileManageCategoriesCta => 'Manage categories';

  @override
  String get profileManageCategoriesTitle => 'Manage categories';

  @override
  String get manageCategoriesAddAction => 'Add category';

  @override
  String get manageCategoriesCreateRootAction => 'Create parent category';

  @override
  String get manageCategoriesCreateSubAction => 'Create subcategory';

  @override
  String get manageCategoriesCreateSubDisabled =>
      'Add a parent category first to create subcategories.';

  @override
  String get manageCategoriesSelectParentTitle => 'Select parent category';

  @override
  String get dialogCancel => 'Cancel';

  @override
  String get dialogConfirm => 'Confirm';

  @override
  String get manageCategoriesParentLabel => 'Parent category';

  @override
  String get manageCategoriesParentNone => 'No parent';

  @override
  String get manageCategoriesNoSubcategories => 'No subcategories yet';

  @override
  String get manageCategoriesEditAction => 'Edit';

  @override
  String get manageCategoriesEmpty =>
      'No categories yet. Create one to get started.';

  @override
  String manageCategoriesListError(String error) {
    return 'Unable to load categories: $error';
  }

  @override
  String get manageCategoriesCreateTitle => 'New category';

  @override
  String get manageCategoriesEditTitle => 'Edit category';

  @override
  String get manageCategoriesNameLabel => 'Name';

  @override
  String get manageCategoriesNameRequired => 'Please enter a name.';

  @override
  String get manageCategoriesTypeLabel => 'Type';

  @override
  String get manageCategoriesTypeExpense => 'Expense';

  @override
  String get manageCategoriesTypeIncome => 'Income';

  @override
  String get manageCategoriesIconLabel => 'Icon';

  @override
  String get manageCategoriesIconNone => 'No icon selected';

  @override
  String get manageCategoriesIconSelected => 'Icon selected';

  @override
  String get manageCategoriesIconSelect => 'Choose icon';

  @override
  String get manageCategoriesIconPickerTitle => 'Pick a category icon';

  @override
  String get manageCategoriesIconSearchHint => 'Search icons';

  @override
  String get manageCategoriesIconClear => 'Clear selection';

  @override
  String get manageCategoriesIconEmpty => 'No icons match your search.';

  @override
  String get manageCategoriesIconStyleThin => 'Thin';

  @override
  String get manageCategoriesIconStyleLight => 'Light';

  @override
  String get manageCategoriesIconStyleRegular => 'Regular';

  @override
  String get manageCategoriesIconStyleBold => 'Bold';

  @override
  String get manageCategoriesIconStyleFill => 'Fill';

  @override
  String get manageCategoriesColorLabel => 'Color';

  @override
  String get manageCategoriesColorNone => 'No color selected';

  @override
  String get manageCategoriesColorSelected => 'Color selected';

  @override
  String get manageCategoriesColorSelect => 'Choose color';

  @override
  String get manageCategoriesColorClear => 'Clear color';

  @override
  String get manageCategoriesColorPickerTitle => 'Pick a category color';

  @override
  String get manageCategoriesSaveCta => 'Save category';

  @override
  String manageCategoriesSaveError(String error) {
    return 'Unable to save category: $error';
  }

  @override
  String get manageCategoriesSuccessCreate => 'Category created successfully.';

  @override
  String get manageCategoriesSuccessUpdate => 'Category updated successfully.';

  @override
  String get manageCategoriesDeleteAction => 'Delete';

  @override
  String get manageCategoriesDeleteConfirmTitle => 'Delete category';

  @override
  String manageCategoriesDeleteConfirmMessage(String name) {
    return 'Are you sure you want to delete the category "$name"? All subcategories will also be removed.';
  }

  @override
  String get manageCategoriesDeleteSuccess => 'Category deleted successfully.';

  @override
  String manageCategoriesDeleteError(String error) {
    return 'Unable to delete category: $error';
  }

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
  String get profileSignOutCta => 'Sign out';

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
  String addTransactionAccountsError(String error) {
    return 'Unable to load accounts: $error';
  }

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
  String addTransactionCategoriesError(String error) {
    return 'Unable to load categories: $error';
  }

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
