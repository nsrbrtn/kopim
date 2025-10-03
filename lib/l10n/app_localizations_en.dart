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
  String get profileRecurringTransactionsCta => 'Recurring transactions';

  @override
  String get profileManageCategoriesTitle => 'Manage categories';

  @override
  String get manageCategoriesAddAction => 'Add category';

  @override
  String get manageCategoriesCreateSubAction => 'Create subcategory';

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
  String get manageCategoriesIconClear => 'Clear selection';

  @override
  String get manageCategoriesIconEmpty => 'No icons available.';

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
  String get manageCategoriesIconGroupFinance => 'Finance & work';

  @override
  String get manageCategoriesIconGroupShopping => 'Shopping & clothing';

  @override
  String get manageCategoriesIconGroupFood => 'Food & dining';

  @override
  String get manageCategoriesIconGroupTransport => 'Transport & travel';

  @override
  String get manageCategoriesIconGroupHome => 'Home & utilities';

  @override
  String get manageCategoriesIconGroupLeisure => 'Leisure & sports';

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
    return 'Are you sure you want to delete the category \"$name\"? All subcategories will also be removed.';
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
  String get recurringTransactionsTitle => 'Recurring transactions';

  @override
  String get recurringTransactionsEmpty =>
      'No recurring transactions yet. Create one to automate your cash flow.';

  @override
  String get recurringTransactionsNextDue => 'Next due';

  @override
  String get recurringTransactionsNoUpcoming => 'No upcoming occurrences';

  @override
  String get addRecurringRuleTitle => 'New recurring transaction';

  @override
  String get addRecurringRuleNameLabel => 'Title';

  @override
  String get addRecurringRuleTitleRequired => 'Enter a title';

  @override
  String get addRecurringRuleAmountLabel => 'Amount';

  @override
  String get addRecurringRuleAmountHint => '0.00';

  @override
  String get addRecurringRuleAmountInvalid => 'Enter a valid positive amount';

  @override
  String get addRecurringRuleAccountLabel => 'Account';

  @override
  String get addRecurringRuleAccountRequired => 'Select an account';

  @override
  String get addRecurringRuleTypeLabel => 'Type';

  @override
  String get addRecurringRuleTypeExpense => 'Expense';

  @override
  String get addRecurringRuleTypeIncome => 'Income';

  @override
  String get addRecurringRuleStartDateLabel => 'Start date';

  @override
  String get addRecurringRuleStartTimeLabel => 'Execution time';

  @override
  String get addRecurringRuleAutoPostLabel => 'Post automatically';

  @override
  String get addRecurringRuleSubmit => 'Save rule';

  @override
  String get addRecurringRuleNoAccounts =>
      'Add an account before creating a recurring rule.';

  @override
  String get addRecurringRuleSuccess => 'Recurring transaction saved';

  @override
  String get commonComingSoon => 'Coming soon';

  @override
  String get genericErrorMessage =>
      'Something went wrong. Please try again later.';

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
  String get homeAccountMonthlyIncomeLabel => 'Income this month';

  @override
  String get homeAccountMonthlyExpenseLabel => 'Expense this month';

  @override
  String get homeTransactionsTodayLabel => 'Today';

  @override
  String get homeTransactionsYesterdayLabel => 'Yesterday';

  @override
  String get accountTypeCash => 'Cash';

  @override
  String get accountTypeCard => 'Card';

  @override
  String get accountTypeBank => 'Bank account';

  @override
  String get accountTypeOther => 'Other';

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
  String get analyticsCurrentMonthTitle => 'Current month overview';

  @override
  String get analyticsSummaryIncomeLabel => 'Income';

  @override
  String get analyticsSummaryExpenseLabel => 'Expenses';

  @override
  String get analyticsSummaryNetLabel => 'Net';

  @override
  String get analyticsTopCategoriesTitle => 'Top expense categories';

  @override
  String get analyticsTopCategoriesEmpty =>
      'Not enough expense data to show category trends yet.';

  @override
  String get analyticsCategoryUncategorized => 'Uncategorized';

  @override
  String analyticsOverviewRangeTitle(String range) {
    return 'Overview for $range';
  }

  @override
  String get analyticsFilterDateLabel => 'Date';

  @override
  String analyticsFilterDateValue(String start, String end) {
    return '$start – $end';
  }

  @override
  String get analyticsFilterAccountLabel => 'Account';

  @override
  String get analyticsFilterAccountAll => 'All accounts';

  @override
  String get analyticsFilterCategoryLabel => 'Category';

  @override
  String get analyticsFilterCategoryAll => 'All categories';

  @override
  String get analyticsEmptyState =>
      'No analytics available for the selected filters yet.';

  @override
  String analyticsLoadError(String error) {
    return 'Unable to load analytics: $error';
  }

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
  String get addTransactionTimeLabel => 'Time';

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
  String get transactionFormMissingError =>
      'The transaction could not be found. Refresh and try again.';

  @override
  String get editTransactionSubmit => 'Save changes';

  @override
  String get transactionDeleteSuccess => 'Transaction deleted.';

  @override
  String get transactionDeleteConfirmTitle => 'Delete transaction';

  @override
  String get transactionDeleteConfirmMessage =>
      'Are you sure you want to delete this transaction? This action cannot be undone.';

  @override
  String get transactionDeleteError => 'Unable to delete the transaction.';

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

  @override
  String get accountDetailsTitle => 'Account details';

  @override
  String get accountDetailsEditTooltip => 'Edit account';

  @override
  String accountDetailsError(String error) {
    return 'Unable to load account: $error';
  }

  @override
  String get accountDetailsMissing => 'This account is no longer available.';

  @override
  String accountDetailsSummaryError(String error) {
    return 'Unable to load summary: $error';
  }

  @override
  String accountDetailsCategoriesError(String error) {
    return 'Unable to load categories: $error';
  }

  @override
  String accountDetailsTransactionsError(String error) {
    return 'Unable to load transactions: $error';
  }

  @override
  String get accountDetailsTransactionsEmpty =>
      'No transactions for this account yet.';

  @override
  String accountDetailsBalanceLabel(String balance) {
    return 'Balance: $balance';
  }

  @override
  String get accountDetailsIncomeLabel => 'Total income';

  @override
  String get accountDetailsExpenseLabel => 'Total expenses';

  @override
  String get accountDetailsFiltersTitle => 'Filters';

  @override
  String get accountDetailsFiltersButtonActive => 'Filters (active)';

  @override
  String get accountDetailsFiltersClear => 'Clear filters';

  @override
  String get accountDetailsFiltersDateLabel => 'Date';

  @override
  String get accountDetailsFiltersDateAny => 'Any dates';

  @override
  String get accountDetailsFiltersDateClear => 'Clear date range';

  @override
  String accountDetailsFiltersDateValue(String start, String end) {
    return '$start – $end';
  }

  @override
  String get accountDetailsFiltersTypeLabel => 'Type';

  @override
  String get accountDetailsFiltersTypeAll => 'All types';

  @override
  String get accountDetailsFiltersTypeIncome => 'Income';

  @override
  String get accountDetailsFiltersTypeExpense => 'Expense';

  @override
  String get accountDetailsFiltersCategoryLabel => 'Category';

  @override
  String get accountDetailsFiltersCategoryAll => 'All categories';

  @override
  String get accountDetailsTransactionsUncategorized => 'Uncategorized';

  @override
  String get accountDetailsTypeIncome => 'Income';

  @override
  String get accountDetailsTypeExpense => 'Expense';

  @override
  String get editAccountTitle => 'Edit account';

  @override
  String get editAccountNameLabel => 'Account name';

  @override
  String get editAccountBalanceLabel => 'Balance';

  @override
  String get editAccountCurrencyLabel => 'Currency';

  @override
  String get editAccountTypeLabel => 'Account type';

  @override
  String get editAccountSaveCta => 'Save changes';

  @override
  String get editAccountNameRequired => 'Please enter the account name.';

  @override
  String get editAccountBalanceInvalid => 'Enter a valid amount.';

  @override
  String get editAccountGenericError =>
      'Could not update account. Please try again.';
}
