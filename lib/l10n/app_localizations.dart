import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// Title for the profile screen app bar
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// Shown when user must sign in to access profile
  ///
  /// In en, this message translates to:
  /// **'Please sign in to manage your profile.'**
  String get profileSignInPrompt;

  /// Section header for account information
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profileSectionAccount;

  /// Button label that opens the category management screen from the profile settings
  ///
  /// In en, this message translates to:
  /// **'Manage categories'**
  String get profileManageCategoriesCta;

  /// Title for the category management screen
  ///
  /// In en, this message translates to:
  /// **'Manage categories'**
  String get profileManageCategoriesTitle;

  /// Tooltip for the button that starts creating a new category
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get manageCategoriesAddAction;

  /// Action label to create a subcategory from the manage categories menu
  ///
  /// In en, this message translates to:
  /// **'Create subcategory'**
  String get manageCategoriesCreateSubAction;

  /// Generic cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dialogCancel;

  /// Generic confirmation button label
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get dialogConfirm;

  /// Label for the dropdown that selects a parent category
  ///
  /// In en, this message translates to:
  /// **'Parent category'**
  String get manageCategoriesParentLabel;

  /// Dropdown option representing no parent category
  ///
  /// In en, this message translates to:
  /// **'No parent'**
  String get manageCategoriesParentNone;

  /// Placeholder text shown when a category has no subcategories
  ///
  /// In en, this message translates to:
  /// **'No subcategories yet'**
  String get manageCategoriesNoSubcategories;

  /// Tooltip for the button that edits an existing category
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get manageCategoriesEditAction;

  /// Empty state message when there are no categories
  ///
  /// In en, this message translates to:
  /// **'No categories yet. Create one to get started.'**
  String get manageCategoriesEmpty;

  /// Error message shown when categories stream fails
  ///
  /// In en, this message translates to:
  /// **'Unable to load categories: {error}'**
  String manageCategoriesListError(String error);

  /// Title for the sheet used to create a new category
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get manageCategoriesCreateTitle;

  /// Title for the sheet used to edit an existing category
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get manageCategoriesEditTitle;

  /// Label for the category name field
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get manageCategoriesNameLabel;

  /// Validation error when the category name is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter a name.'**
  String get manageCategoriesNameRequired;

  /// Label for the category type selector
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get manageCategoriesTypeLabel;

  /// Label for expense category type
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get manageCategoriesTypeExpense;

  /// Label for income category type
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get manageCategoriesTypeIncome;

  /// Label for the icon input
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get manageCategoriesIconLabel;

  /// Subtitle shown when no icon has been selected
  ///
  /// In en, this message translates to:
  /// **'No icon selected'**
  String get manageCategoriesIconNone;

  /// Subtitle shown when an icon has been selected
  ///
  /// In en, this message translates to:
  /// **'Icon selected'**
  String get manageCategoriesIconSelected;

  /// Tooltip for the action that opens the icon picker
  ///
  /// In en, this message translates to:
  /// **'Choose icon'**
  String get manageCategoriesIconSelect;

  /// Title for the bottom sheet that lists available icons
  ///
  /// In en, this message translates to:
  /// **'Pick a category icon'**
  String get manageCategoriesIconPickerTitle;

  /// Label for the button that clears the selected icon
  ///
  /// In en, this message translates to:
  /// **'Clear selection'**
  String get manageCategoriesIconClear;

  /// Empty state shown when the selected icon group has no items
  ///
  /// In en, this message translates to:
  /// **'No icons available.'**
  String get manageCategoriesIconEmpty;

  /// Label for the thin icon style filter
  ///
  /// In en, this message translates to:
  /// **'Thin'**
  String get manageCategoriesIconStyleThin;

  /// Label for the light icon style filter
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get manageCategoriesIconStyleLight;

  /// Label for the regular icon style filter
  ///
  /// In en, this message translates to:
  /// **'Regular'**
  String get manageCategoriesIconStyleRegular;

  /// Label for the bold icon style filter
  ///
  /// In en, this message translates to:
  /// **'Bold'**
  String get manageCategoriesIconStyleBold;

  /// Label for the fill icon style filter
  ///
  /// In en, this message translates to:
  /// **'Fill'**
  String get manageCategoriesIconStyleFill;

  /// Tab label for finance-related icons
  ///
  /// In en, this message translates to:
  /// **'Finance & work'**
  String get manageCategoriesIconGroupFinance;

  /// Tab label for shopping and clothing icons
  ///
  /// In en, this message translates to:
  /// **'Shopping & clothing'**
  String get manageCategoriesIconGroupShopping;

  /// Tab label for food-related icons
  ///
  /// In en, this message translates to:
  /// **'Food & dining'**
  String get manageCategoriesIconGroupFood;

  /// Tab label for transport icons
  ///
  /// In en, this message translates to:
  /// **'Transport & travel'**
  String get manageCategoriesIconGroupTransport;

  /// Tab label for home and utility icons
  ///
  /// In en, this message translates to:
  /// **'Home & utilities'**
  String get manageCategoriesIconGroupHome;

  /// Tab label for leisure icons
  ///
  /// In en, this message translates to:
  /// **'Leisure & sports'**
  String get manageCategoriesIconGroupLeisure;

  /// Label for the color input
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get manageCategoriesColorLabel;

  /// Subtitle shown when no color has been selected
  ///
  /// In en, this message translates to:
  /// **'No color selected'**
  String get manageCategoriesColorNone;

  /// Subtitle shown when a color has been selected
  ///
  /// In en, this message translates to:
  /// **'Color selected'**
  String get manageCategoriesColorSelected;

  /// Tooltip for the action that opens the color picker
  ///
  /// In en, this message translates to:
  /// **'Choose color'**
  String get manageCategoriesColorSelect;

  /// Tooltip for the action that clears the selected color
  ///
  /// In en, this message translates to:
  /// **'Clear color'**
  String get manageCategoriesColorClear;

  /// Title for the dialog that lets the user choose a category color
  ///
  /// In en, this message translates to:
  /// **'Pick a category color'**
  String get manageCategoriesColorPickerTitle;

  /// Button label for saving a category
  ///
  /// In en, this message translates to:
  /// **'Save category'**
  String get manageCategoriesSaveCta;

  /// Error message shown when saving a category fails
  ///
  /// In en, this message translates to:
  /// **'Unable to save category: {error}'**
  String manageCategoriesSaveError(String error);

  /// Snackbar message shown when a category is created
  ///
  /// In en, this message translates to:
  /// **'Category created successfully.'**
  String get manageCategoriesSuccessCreate;

  /// Snackbar message shown when a category is updated
  ///
  /// In en, this message translates to:
  /// **'Category updated successfully.'**
  String get manageCategoriesSuccessUpdate;

  /// Label for the delete category action
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get manageCategoriesDeleteAction;

  /// Title for the delete category confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete category'**
  String get manageCategoriesDeleteConfirmTitle;

  /// Confirmation message shown before deleting a category
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the category \"{name}\"? All subcategories will also be removed.'**
  String manageCategoriesDeleteConfirmMessage(String name);

  /// Snackbar message shown when a category is deleted
  ///
  /// In en, this message translates to:
  /// **'Category deleted successfully.'**
  String get manageCategoriesDeleteSuccess;

  /// Error message shown when deleting a category fails
  ///
  /// In en, this message translates to:
  /// **'Unable to delete category: {error}'**
  String manageCategoriesDeleteError(String error);

  /// Label for the profile name input
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get profileNameLabel;

  /// Label for the currency selector
  ///
  /// In en, this message translates to:
  /// **'Default currency'**
  String get profileCurrencyLabel;

  /// Label for the locale selector
  ///
  /// In en, this message translates to:
  /// **'Preferred locale'**
  String get profileLocaleLabel;

  /// Shown when profile loading failed
  ///
  /// In en, this message translates to:
  /// **'Unable to load profile: {error}'**
  String profileLoadError(String error);

  /// Label for the save button on profile form
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get profileSaveCta;

  /// Button label to sign out from the profile settings
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profileSignOutCta;

  /// Main heading on the sign-in screen
  ///
  /// In en, this message translates to:
  /// **'Welcome to Kopim'**
  String get signInTitle;

  /// Subtitle explaining the benefit of signing in
  ///
  /// In en, this message translates to:
  /// **'Sign in to sync your finances across devices.'**
  String get signInSubtitle;

  /// Label for email field
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get signInEmailLabel;

  /// Label for password field
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get signInPasswordLabel;

  /// Primary call to action button for email/password sign-in
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInSubmitCta;

  /// Button label for Google sign in
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get signInGoogleCta;

  /// Fallback message when sign in fails
  ///
  /// In en, this message translates to:
  /// **'Could not sign in. Please try again.'**
  String get signInError;

  /// Accessibility label when a sign in request is in progress
  ///
  /// In en, this message translates to:
  /// **'Signing in...'**
  String get signInLoading;

  /// Message shown when connectivity provider reports offline state
  ///
  /// In en, this message translates to:
  /// **'You appear to be offline. We will sync your data once you reconnect.'**
  String get signInOfflineNotice;

  /// Title for the home screen
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// App bar title showing the aggregated balance
  ///
  /// In en, this message translates to:
  /// **'Total balance: {amount}'**
  String homeTotalBalance(String amount);

  /// Shown when auth controller returns an error
  ///
  /// In en, this message translates to:
  /// **'Authentication error: {error}'**
  String homeAuthError(String error);

  /// Section header for the accounts list
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get homeAccountsSection;

  /// Empty state for accounts list
  ///
  /// In en, this message translates to:
  /// **'No accounts yet. Add your first account to track balance.'**
  String get homeAccountsEmpty;

  /// Error shown when accounts stream fails
  ///
  /// In en, this message translates to:
  /// **'Unable to load accounts: {error}'**
  String homeAccountsError(String error);

  /// Label describing the account type
  ///
  /// In en, this message translates to:
  /// **'Type: {type}'**
  String homeAccountType(String type);

  /// Section header for transactions list
  ///
  /// In en, this message translates to:
  /// **'Recent transactions'**
  String get homeTransactionsSection;

  /// Empty state for transactions list
  ///
  /// In en, this message translates to:
  /// **'No transactions recorded yet.'**
  String get homeTransactionsEmpty;

  /// Error shown when transactions stream fails
  ///
  /// In en, this message translates to:
  /// **'Unable to load transactions: {error}'**
  String homeTransactionsError(String error);

  /// Fallback text when a transaction has no category
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get homeTransactionsUncategorized;

  /// Bottom navigation label for home
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeNavHome;

  /// Bottom navigation label for analytics
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get homeNavAnalytics;

  /// Bottom navigation label for settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get homeNavSettings;

  /// Title for analytics screen
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analyticsTitle;

  /// Placeholder message for analytics screen
  ///
  /// In en, this message translates to:
  /// **'Detailed analytics are coming soon.'**
  String get analyticsComingSoon;

  /// Title for add transaction screen
  ///
  /// In en, this message translates to:
  /// **'Add transaction'**
  String get addTransactionTitle;

  /// Placeholder message for add transaction screen
  ///
  /// In en, this message translates to:
  /// **'Transaction creation will be available shortly.'**
  String get addTransactionComingSoon;

  /// Label for account selector on add transaction form
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get addTransactionAccountLabel;

  /// Validation message when no account is selected
  ///
  /// In en, this message translates to:
  /// **'Please choose an account'**
  String get addTransactionAccountRequired;

  /// Error message shown when account stream fails
  ///
  /// In en, this message translates to:
  /// **'Unable to load accounts: {error}'**
  String addTransactionAccountsError(String error);

  /// Message shown when there are no accounts available
  ///
  /// In en, this message translates to:
  /// **'Create an account first to add transactions.'**
  String get addTransactionNoAccounts;

  /// Label for transaction amount field
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get addTransactionAmountLabel;

  /// Hint text for transaction amount field
  ///
  /// In en, this message translates to:
  /// **'0.00'**
  String get addTransactionAmountHint;

  /// Validation message for invalid transaction amount
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount greater than zero'**
  String get addTransactionAmountInvalid;

  /// Label for transaction type selector
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get addTransactionTypeLabel;

  /// Label for selecting expense type
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get addTransactionTypeExpense;

  /// Label for selecting income type
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get addTransactionTypeIncome;

  /// Label for category selector
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get addTransactionCategoryLabel;

  /// Option label when no category is selected
  ///
  /// In en, this message translates to:
  /// **'No category'**
  String get addTransactionCategoryNone;

  /// Helper text while categories are loading
  ///
  /// In en, this message translates to:
  /// **'Loading categories…'**
  String get addTransactionCategoriesLoading;

  /// Error shown when categories stream fails
  ///
  /// In en, this message translates to:
  /// **'Unable to load categories: {error}'**
  String addTransactionCategoriesError(String error);

  /// Label for the date picker
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get addTransactionDateLabel;

  /// Label for optional note field
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get addTransactionNoteLabel;

  /// Button label for saving a transaction
  ///
  /// In en, this message translates to:
  /// **'Save transaction'**
  String get addTransactionSubmit;

  /// Error when the selected account was deleted
  ///
  /// In en, this message translates to:
  /// **'Selected account is no longer available.'**
  String get addTransactionAccountMissingError;

  /// Generic error when saving a transaction fails
  ///
  /// In en, this message translates to:
  /// **'Unable to save the transaction. Try again.'**
  String get addTransactionUnknownError;

  /// Confirmation message shown after creating a transaction
  ///
  /// In en, this message translates to:
  /// **'Transaction saved'**
  String get addTransactionSuccess;

  /// Tooltip for the add account button on the home screen
  ///
  /// In en, this message translates to:
  /// **'Add account'**
  String get homeAccountsAddTooltip;

  /// Title for the add account screen
  ///
  /// In en, this message translates to:
  /// **'Add account'**
  String get addAccountTitle;

  /// Label for the account name input field
  ///
  /// In en, this message translates to:
  /// **'Account name'**
  String get addAccountNameLabel;

  /// Label for the starting balance input field
  ///
  /// In en, this message translates to:
  /// **'Starting balance'**
  String get addAccountBalanceLabel;

  /// Label for the currency selector
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get addAccountCurrencyLabel;

  /// Label for the account type selector
  ///
  /// In en, this message translates to:
  /// **'Account type'**
  String get addAccountTypeLabel;

  /// Primary action button label for saving an account
  ///
  /// In en, this message translates to:
  /// **'Save account'**
  String get addAccountSaveCta;

  /// Validation error shown when the account name is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter the account name.'**
  String get addAccountNameRequired;

  /// Validation error shown when the balance input cannot be parsed
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount.'**
  String get addAccountBalanceInvalid;

  /// Generic error shown when the add account request fails
  ///
  /// In en, this message translates to:
  /// **'Could not save account. Please try again.'**
  String get addAccountError;

  /// Option label for cash accounts
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get addAccountTypeCash;

  /// Option label for card accounts
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get addAccountTypeCard;

  /// Option label for bank accounts
  ///
  /// In en, this message translates to:
  /// **'Bank account'**
  String get addAccountTypeBank;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
