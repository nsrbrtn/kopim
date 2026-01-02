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

  /// Call to action that opens the registration screen from profile settings
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get profileRegisterCta;

  /// Message shown above the register button for anonymous users
  ///
  /// In en, this message translates to:
  /// **'Create an account to keep your data safe and enable synchronization across devices.'**
  String get profileRegisterHint;

  /// Section header for account information
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profileSectionAccount;

  /// Section title for appearance settings in profile management
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get profileAppearanceSection;

  /// Title for the general settings screen
  ///
  /// In en, this message translates to:
  /// **'General settings'**
  String get profileGeneralSettingsTitle;

  /// Tooltip for opening the general settings screen
  ///
  /// In en, this message translates to:
  /// **'General settings'**
  String get profileGeneralSettingsTooltip;

  /// App bar title for the menu screen
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get profileMenuTitle;

  /// No description provided for @creditsTitle.
  ///
  /// In en, this message translates to:
  /// **'Loans & Debts'**
  String get creditsTitle;

  /// No description provided for @creditsAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add loan'**
  String get creditsAddTitle;

  /// No description provided for @creditsEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit loan'**
  String get creditsEditTitle;

  /// No description provided for @creditsNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get creditsNameLabel;

  /// No description provided for @creditsAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Loan amount'**
  String get creditsAmountLabel;

  /// No description provided for @creditsInterestRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Interest rate (%)'**
  String get creditsInterestRateLabel;

  /// No description provided for @creditsTermMonthsLabel.
  ///
  /// In en, this message translates to:
  /// **'Term (months)'**
  String get creditsTermMonthsLabel;

  /// No description provided for @creditsStartDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get creditsStartDateLabel;

  /// No description provided for @creditsHiddenOnDashboardLabel.
  ///
  /// In en, this message translates to:
  /// **'Hide account on home screen'**
  String get creditsHiddenOnDashboardLabel;

  /// No description provided for @creditsRemainingAmount.
  ///
  /// In en, this message translates to:
  /// **'Remaining to pay'**
  String get creditsRemainingAmount;

  /// No description provided for @creditsTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'Of {total}'**
  String creditsTotalAmount(String total);

  /// No description provided for @creditsEmptyList.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any active loans yet'**
  String get creditsEmptyList;

  /// No description provided for @creditsSaveAction.
  ///
  /// In en, this message translates to:
  /// **'Save loan'**
  String get creditsSaveAction;

  /// No description provided for @creditsPaymentDayLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment day (1-31)'**
  String get creditsPaymentDayLabel;

  /// No description provided for @creditsNextPaymentLabel.
  ///
  /// In en, this message translates to:
  /// **'Next payment'**
  String get creditsNextPaymentLabel;

  /// No description provided for @creditsRemainingPaymentsLabel.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get creditsRemainingPaymentsLabel;

  /// No description provided for @creditsSegmentCredits.
  ///
  /// In en, this message translates to:
  /// **'Loans'**
  String get creditsSegmentCredits;

  /// No description provided for @creditsSegmentDebts.
  ///
  /// In en, this message translates to:
  /// **'Debts'**
  String get creditsSegmentDebts;

  /// No description provided for @debtsAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add debt'**
  String get debtsAddTitle;

  /// No description provided for @debtsEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit debt'**
  String get debtsEditTitle;

  /// No description provided for @debtsNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Debt name'**
  String get debtsNameLabel;

  /// No description provided for @debtsAccountLabel.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get debtsAccountLabel;

  /// No description provided for @debtsAccountHint.
  ///
  /// In en, this message translates to:
  /// **'Select account'**
  String get debtsAccountHint;

  /// No description provided for @debtsAccountError.
  ///
  /// In en, this message translates to:
  /// **'Choose an account for the debt'**
  String get debtsAccountError;

  /// No description provided for @debtsAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Debt amount'**
  String get debtsAmountLabel;

  /// No description provided for @debtsDueDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment date'**
  String get debtsDueDateLabel;

  /// No description provided for @debtsNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get debtsNoteLabel;

  /// No description provided for @debtsSaveAction.
  ///
  /// In en, this message translates to:
  /// **'Save debt'**
  String get debtsSaveAction;

  /// No description provided for @debtsSaveAndScheduleAction.
  ///
  /// In en, this message translates to:
  /// **'Save and remind'**
  String get debtsSaveAndScheduleAction;

  /// No description provided for @debtsEmptyList.
  ///
  /// In en, this message translates to:
  /// **'You have no debts yet'**
  String get debtsEmptyList;

  /// No description provided for @debtsDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Debt'**
  String get debtsDefaultTitle;

  /// Section title for category and recurring actions on general settings
  ///
  /// In en, this message translates to:
  /// **'Data management'**
  String get profileGeneralSettingsManagementSection;

  /// Button label that opens the category management screen from the profile settings
  ///
  /// In en, this message translates to:
  /// **'Manage categories'**
  String get profileManageCategoriesCta;

  /// Button label that opens the upcoming payments screen from the profile settings
  ///
  /// In en, this message translates to:
  /// **'Recurring payments'**
  String get profileUpcomingPaymentsCta;

  /// Button that starts the user data export flow
  ///
  /// In en, this message translates to:
  /// **'Export data'**
  String get profileExportDataCta;

  /// Label for selecting the import/export file format
  ///
  /// In en, this message translates to:
  /// **'File format'**
  String get profileDataTransferFormatLabel;

  /// CSV format label
  ///
  /// In en, this message translates to:
  /// **'CSV'**
  String get profileDataTransferFormatCsv;

  /// JSON format label
  ///
  /// In en, this message translates to:
  /// **'JSON'**
  String get profileDataTransferFormatJson;

  /// Shown when export finishes without a target path
  ///
  /// In en, this message translates to:
  /// **'Data exported successfully.'**
  String get profileExportDataSuccess;

  /// Shown when export finishes with a known file path or URL
  ///
  /// In en, this message translates to:
  /// **'Data exported to {target}'**
  String profileExportDataSuccessWithPath(String target);

  /// Shown when export fails
  ///
  /// In en, this message translates to:
  /// **'Failed to export data: {error}'**
  String profileExportDataFailure(String error);

  /// Label describing the destination folder for exported data
  ///
  /// In en, this message translates to:
  /// **'Export destination'**
  String get profileExportDataDestinationLabel;

  /// List item text shown when no custom folder has been chosen
  ///
  /// In en, this message translates to:
  /// **'Default downloads folder'**
  String get profileExportDataDefaultDestination;

  /// Summary line showing the folder picked by the user
  ///
  /// In en, this message translates to:
  /// **'Folder: {path}'**
  String profileExportDataSelectedFolder(String path);

  /// Button label that opens the native folder picker
  ///
  /// In en, this message translates to:
  /// **'Choose folder'**
  String get profileExportDataSelectFolderCta;

  /// Dialog title when requesting a custom export destination
  ///
  /// In en, this message translates to:
  /// **'Select a folder to save exported data'**
  String get profileExportDataDirectoryPickerTitle;

  /// Button that opens the import flow
  ///
  /// In en, this message translates to:
  /// **'Import data'**
  String get profileImportDataCta;

  /// Shown when data import finishes successfully
  ///
  /// In en, this message translates to:
  /// **'Data imported successfully.'**
  String get profileImportDataSuccess;

  /// Detailed import success message with entity counts
  ///
  /// In en, this message translates to:
  /// **'Imported {accounts} accounts, {categories} categories, and {transactions} transactions.'**
  String profileImportDataSuccessWithStats(
    int accounts,
    int categories,
    int transactions,
  );

  /// Shown when the user cancels the import dialog
  ///
  /// In en, this message translates to:
  /// **'Import cancelled by user.'**
  String get profileImportDataCancelled;

  /// Shown when data import fails
  ///
  /// In en, this message translates to:
  /// **'Failed to import data: {error}'**
  String profileImportDataFailure(String error);

  /// Title for the exact alarm reminders toggle in settings
  ///
  /// In en, this message translates to:
  /// **'Exact reminders'**
  String get settingsNotificationsExactTitle;

  /// Subtitle explaining what exact reminders do
  ///
  /// In en, this message translates to:
  /// **'Deliver notifications exactly at the scheduled time.'**
  String get settingsNotificationsExactSubtitle;

  /// Error shown when the exact alarm permission cannot be resolved
  ///
  /// In en, this message translates to:
  /// **'Failed to read status: {error}'**
  String settingsNotificationsExactError(String error);

  /// Tooltip for refreshing the exact alarm permission status
  ///
  /// In en, this message translates to:
  /// **'Update status'**
  String get settingsNotificationsRetryTooltip;

  /// Button label that triggers a test notification from settings
  ///
  /// In en, this message translates to:
  /// **'Send test notification'**
  String get settingsNotificationsTestCta;

  /// Section header for home screen configuration
  ///
  /// In en, this message translates to:
  /// **'Home screen'**
  String get settingsHomeSectionTitle;

  /// Switch label for enabling the gamification widget
  ///
  /// In en, this message translates to:
  /// **'Gamification widget'**
  String get settingsHomeGamificationTitle;

  /// Helper text for the gamification toggle
  ///
  /// In en, this message translates to:
  /// **'Show level progress on the home screen.'**
  String get settingsHomeGamificationSubtitle;

  /// Switch label for enabling the budget widget
  ///
  /// In en, this message translates to:
  /// **'Budget widget'**
  String get settingsHomeBudgetTitle;

  /// Helper text for the budget widget toggle
  ///
  /// In en, this message translates to:
  /// **'Track a selected budget without leaving the home screen.'**
  String get settingsHomeBudgetSubtitle;

  /// Toggle title for the recurring operations widget
  ///
  /// In en, this message translates to:
  /// **'Recurring widget'**
  String get settingsHomeRecurringTitle;

  /// Helper text for the recurring operations widget toggle
  ///
  /// In en, this message translates to:
  /// **'Show upcoming recurring operations on the home screen.'**
  String get settingsHomeRecurringSubtitle;

  /// Toggle title for enabling the savings widget on the home screen
  ///
  /// In en, this message translates to:
  /// **'Savings widget'**
  String get settingsHomeSavingsTitle;

  /// Helper text for the savings widget toggle
  ///
  /// In en, this message translates to:
  /// **'Keep track of your saving goals without leaving the home screen.'**
  String get settingsHomeSavingsSubtitle;

  /// Title for the list tile showing the currently selected budget
  ///
  /// In en, this message translates to:
  /// **'Selected budget'**
  String get settingsHomeBudgetSelectedLabel;

  /// Message displayed when no budgets exist
  ///
  /// In en, this message translates to:
  /// **'Create a budget to enable this widget.'**
  String get settingsHomeBudgetNoBudgets;

  /// Subtitle shown when no budget is selected
  ///
  /// In en, this message translates to:
  /// **'No budget selected'**
  String get settingsHomeBudgetSelectedNone;

  /// Error displayed when the budgets stream fails
  ///
  /// In en, this message translates to:
  /// **'Can\'t load budgets: {error}'**
  String settingsHomeBudgetError(String error);

  /// Title for the bottom sheet where the user selects a budget
  ///
  /// In en, this message translates to:
  /// **'Choose budget'**
  String get settingsHomeBudgetPickerTitle;

  /// Subtitle summarizing budget usage in the picker
  ///
  /// In en, this message translates to:
  /// **'{spent} of {limit} used'**
  String settingsHomeBudgetPickerSubtitle(String spent, String limit);

  /// Helper text shown under the clear selection action
  ///
  /// In en, this message translates to:
  /// **'You can also disable the widget in the list above.'**
  String get settingsHomeBudgetPickerHint;

  /// Action label for removing the selected budget
  ///
  /// In en, this message translates to:
  /// **'Clear selection'**
  String get settingsHomeBudgetPickerClear;

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

  /// Button inside the category form for creating a subcategory
  ///
  /// In en, this message translates to:
  /// **'Add subcategory'**
  String get manageCategoriesAddSubcategoryAction;

  /// Hint shown when the user tries to add a subcategory before saving
  ///
  /// In en, this message translates to:
  /// **'Save the category before adding subcategories.'**
  String get manageCategoriesAddSubcategorySaveFirst;

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

  /// Generic undo action label
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get commonUndo;

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

  /// Tab label for grocery icons
  ///
  /// In en, this message translates to:
  /// **'Groceries'**
  String get manageCategoriesIconGroupGroceries;

  /// Tab label for dining and cafe icons
  ///
  /// In en, this message translates to:
  /// **'Dining Out'**
  String get manageCategoriesIconGroupDining;

  /// Tab label for clothing and beauty icons
  ///
  /// In en, this message translates to:
  /// **'Clothing & Care'**
  String get manageCategoriesIconGroupClothing;

  /// Tab label for home icons
  ///
  /// In en, this message translates to:
  /// **'Home & Furniture'**
  String get manageCategoriesIconGroupHome;

  /// Tab label for utility icons
  ///
  /// In en, this message translates to:
  /// **'Utilities'**
  String get manageCategoriesIconGroupUtilities;

  /// Tab label for communication icons
  ///
  /// In en, this message translates to:
  /// **'Comm & Gadgets'**
  String get manageCategoriesIconGroupCommunication;

  /// Tab label for subscription icons
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get manageCategoriesIconGroupSubscriptions;

  /// Tab label for public transport icons
  ///
  /// In en, this message translates to:
  /// **'Public Transit'**
  String get manageCategoriesIconGroupPublicTransport;

  /// Tab label for car icons
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get manageCategoriesIconGroupCar;

  /// Tab label for taxi icons
  ///
  /// In en, this message translates to:
  /// **'Taxi & Parking'**
  String get manageCategoriesIconGroupTaxi;

  /// Tab label for travel icons
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get manageCategoriesIconGroupTravel;

  /// Tab label for health icons
  ///
  /// In en, this message translates to:
  /// **'Health & Med'**
  String get manageCategoriesIconGroupHealth;

  /// Tab label for security icons
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get manageCategoriesIconGroupSecurity;

  /// Tab label for education icons
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get manageCategoriesIconGroupEducation;

  /// Tab label for family icons
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get manageCategoriesIconGroupFamily;

  /// Tab label for pet icons
  ///
  /// In en, this message translates to:
  /// **'Pets'**
  String get manageCategoriesIconGroupPets;

  /// Tab label for maintenance icons
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get manageCategoriesIconGroupMaintenance;

  /// Tab label for entertainment icons
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get manageCategoriesIconGroupEntertainment;

  /// Tab label for sports icons
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get manageCategoriesIconGroupSports;

  /// Tab label for finance icons
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get manageCategoriesIconGroupFinance;

  /// Tab label for loan icons
  ///
  /// In en, this message translates to:
  /// **'Loans & Debts'**
  String get manageCategoriesIconGroupLoans;

  /// Tab label for document icons
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get manageCategoriesIconGroupDocuments;

  /// Tab label for system setting icons
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get manageCategoriesIconGroupSettings;

  /// Tab label for transaction types icons
  ///
  /// In en, this message translates to:
  /// **'Transaction Types'**
  String get manageCategoriesIconGroupTransactionTypes;

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

  /// Label for the switch that marks a category as favorite
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get manageCategoriesFavoriteLabel;

  /// Helper text explaining how favorite categories are used
  ///
  /// In en, this message translates to:
  /// **'Favorite categories appear at the top when creating transactions.'**
  String get manageCategoriesFavoriteSubtitle;

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

  /// Label for the dark mode toggle in profile management
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get profileDarkModeLabel;

  /// Subtitle explaining how the dark mode toggle behaves
  ///
  /// In en, this message translates to:
  /// **'Override the app theme.'**
  String get profileDarkModeDescription;

  /// Title for the theme preferences section header
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get profileThemeHeader;

  /// Label for selecting the system-controlled theme mode
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get profileThemeOptionSystem;

  /// Label for selecting the light theme mode
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get profileThemeOptionLight;

  /// Label for selecting the dark theme mode
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get profileThemeOptionDark;

  /// Description shown for the light theme option
  ///
  /// In en, this message translates to:
  /// **'Use a bright interface.'**
  String get profileThemeLightDescription;

  /// Description shown for the dark theme option
  ///
  /// In en, this message translates to:
  /// **'Use a dimmed interface.'**
  String get profileThemeDarkDescription;

  /// Button label to restore system-controlled theme mode
  ///
  /// In en, this message translates to:
  /// **'Use system setting'**
  String get profileDarkModeSystemCta;

  /// Subtitle shown when the app follows the system theme
  ///
  /// In en, this message translates to:
  /// **'Following system theme'**
  String get profileDarkModeSystemActive;

  /// Shown when profile loading failed
  ///
  /// In en, this message translates to:
  /// **'Unable to load profile: {error}'**
  String profileLoadError(String error);

  /// Placeholder name when the user has not specified one
  ///
  /// In en, this message translates to:
  /// **'Explorer'**
  String get profileUnnamed;

  /// Menu item and button label for changing the avatar
  ///
  /// In en, this message translates to:
  /// **'Change avatar'**
  String get profileChangeAvatar;

  /// Action label for selecting an avatar from the gallery
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get profileChangeAvatarGallery;

  /// Action label for capturing an avatar with the camera
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get profileChangeAvatarCamera;

  /// Label for the button that opens the preset avatar picker
  ///
  /// In en, this message translates to:
  /// **'Choose built-in avatar'**
  String get profilePresetAvatarButton;

  /// Title shown at the top of the preset avatar picker sheet
  ///
  /// In en, this message translates to:
  /// **'Pick an avatar'**
  String get profilePresetAvatarTitle;

  /// Helper text describing the preset avatar picker
  ///
  /// In en, this message translates to:
  /// **'Use one of the curated illustrations bundled with the app.'**
  String get profilePresetAvatarSubtitle;

  /// Short label under each preset avatar used for accessibility
  ///
  /// In en, this message translates to:
  /// **'Avatar {index}'**
  String profilePresetAvatarLabel(int index);

  /// Snackbar shown when the avatar upload fails
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t update avatar. Please try again.'**
  String get profileAvatarUploadError;

  /// Snackbar shown when the avatar upload succeeds
  ///
  /// In en, this message translates to:
  /// **'Avatar updated'**
  String get profileAvatarUploadSuccess;

  /// Badge text combining the numeric level and the title
  ///
  /// In en, this message translates to:
  /// **'Level {level} — {title}'**
  String profileLevelBadge(int level, String title);

  /// Label showing the current XP relative to the next threshold
  ///
  /// In en, this message translates to:
  /// **'XP: {current} / {next}'**
  String profileXp(int current, int next);

  /// Label when the user reached the highest level
  ///
  /// In en, this message translates to:
  /// **'XP: {current}'**
  String profileXpMax(int current);

  /// Caption indicating remaining XP to reach the next level
  ///
  /// In en, this message translates to:
  /// **'{count} XP to the next level'**
  String profileXpToNext(int count);

  /// Caption shown when the user is at the highest level
  ///
  /// In en, this message translates to:
  /// **'You have reached the highest rank!'**
  String get profileLevelMaxReached;

  /// Error message displayed when progress cannot be loaded
  ///
  /// In en, this message translates to:
  /// **'Unable to load progress: {error}'**
  String profileProgressError(String error);

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

  /// Title for the recurring transactions screen
  ///
  /// In en, this message translates to:
  /// **'Recurring transactions'**
  String get recurringTransactionsTitle;

  /// Placeholder shown when there are no recurring transactions configured
  ///
  /// In en, this message translates to:
  /// **'No recurring transactions yet. Create one to automate your cash flow.'**
  String get recurringTransactionsEmpty;

  /// Label prefix for the next due date of a recurring rule
  ///
  /// In en, this message translates to:
  /// **'Next due'**
  String get recurringTransactionsNextDue;

  /// Shown when a recurring rule has no future occurrences
  ///
  /// In en, this message translates to:
  /// **'No upcoming occurrences'**
  String get recurringTransactionsNoUpcoming;

  /// Popup menu action to edit a recurring rule
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get recurringTransactionsEditAction;

  /// Popup menu action to delete a recurring rule
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get recurringTransactionsDeleteAction;

  /// Title for the dialog confirming deletion of a recurring rule
  ///
  /// In en, this message translates to:
  /// **'Delete recurring rule'**
  String get recurringTransactionsDeleteDialogTitle;

  /// Confirmation message shown before deleting a recurring rule
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this recurring rule? This action cannot be undone.'**
  String get recurringTransactionsDeleteConfirmation;

  /// Snackbar message after deleting a recurring rule
  ///
  /// In en, this message translates to:
  /// **'Recurring rule deleted.'**
  String get recurringTransactionsDeleteSuccess;

  /// Title for the exact alarm permission explanation card
  ///
  /// In en, this message translates to:
  /// **'Precise reminders'**
  String get recurringExactAlarmPromptTitle;

  /// Body copy describing why exact alarm permission is needed
  ///
  /// In en, this message translates to:
  /// **'To trigger auto-posting exactly at 00:01 local time, allow exact alarms for Kopim in Android system settings under \"Alarms & reminders\".'**
  String get recurringExactAlarmPromptSubtitle;

  /// Call-to-action button for opening the exact alarm settings screen
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get recurringExactAlarmPromptCta;

  /// Title shown when the exact alarm permission is granted
  ///
  /// In en, this message translates to:
  /// **'Precise mode is active'**
  String get recurringExactAlarmEnabledTitle;

  /// Subtitle shown when exact alarms are allowed
  ///
  /// In en, this message translates to:
  /// **'Reminders and auto-posting will run exactly on schedule even in power saving modes.'**
  String get recurringExactAlarmEnabledSubtitle;

  /// Error card title when the permission check throws
  ///
  /// In en, this message translates to:
  /// **'Permission check failed'**
  String get recurringExactAlarmErrorTitle;

  /// Sign in error: user not found
  ///
  /// In en, this message translates to:
  /// **'User not found associated with this email.'**
  String get authErrorUserNotFound;

  /// Sign in error: wrong password
  ///
  /// In en, this message translates to:
  /// **'Wrong password. Please try again.'**
  String get authErrorWrongPassword;

  /// Sign in error: invalid credentials
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password. Please try again.'**
  String get authErrorInvalidCredentials;

  /// Sign in error: invalid email format
  ///
  /// In en, this message translates to:
  /// **'Invalid email format.'**
  String get authErrorInvalidEmail;

  /// Sign up error: email already in use
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists.'**
  String get authErrorEmailAlreadyInUse;

  /// Sign up error: weak password
  ///
  /// In en, this message translates to:
  /// **'Password is too weak. Use at least 6 characters.'**
  String get authErrorWeakPassword;

  /// Sign in error: user disabled
  ///
  /// In en, this message translates to:
  /// **'This user account has been disabled.'**
  String get authErrorUserDisabled;

  /// Sign in error: too many requests
  ///
  /// In en, this message translates to:
  /// **'Too many unsuccessful attempts. Please try again later.'**
  String get authErrorTooManyRequests;

  /// Sign in error: network failure
  ///
  /// In en, this message translates to:
  /// **'Network connection error. Please check your connection.'**
  String get authErrorNetworkFailed;

  /// Generic sign in error
  ///
  /// In en, this message translates to:
  /// **'Sign in failed. Please try again later.'**
  String get authErrorDefault;

  /// Error subtitle with the thrown message
  ///
  /// In en, this message translates to:
  /// **'Try again: {error}'**
  String recurringExactAlarmErrorSubtitle(String error);

  /// Retry button label for the error state of the exact alarm card
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get recurringExactAlarmRetryCta;

  /// Title for the add recurring rule screen
  ///
  /// In en, this message translates to:
  /// **'New recurring transaction'**
  String get addRecurringRuleTitle;

  /// Title for the edit recurring rule screen
  ///
  /// In en, this message translates to:
  /// **'Edit recurring transaction'**
  String get editRecurringRuleTitle;

  /// Label for the recurring rule title field
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get addRecurringRuleNameLabel;

  /// Validation error when title is empty
  ///
  /// In en, this message translates to:
  /// **'Enter a title'**
  String get addRecurringRuleTitleRequired;

  /// Label for the recurring rule amount field
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get addRecurringRuleAmountLabel;

  /// Hint for the recurring rule amount field
  ///
  /// In en, this message translates to:
  /// **'0.00'**
  String get addRecurringRuleAmountHint;

  /// Validation error when amount is invalid
  ///
  /// In en, this message translates to:
  /// **'Enter a valid positive amount'**
  String get addRecurringRuleAmountInvalid;

  /// Label for the optional note field
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get addRecurringRuleNoteLabel;

  /// Hint text for the optional note field
  ///
  /// In en, this message translates to:
  /// **'Optional comment'**
  String get addRecurringRuleNoteHint;

  /// Label for the account dropdown
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get addRecurringRuleAccountLabel;

  /// Validation error when no account selected
  ///
  /// In en, this message translates to:
  /// **'Select an account'**
  String get addRecurringRuleAccountRequired;

  /// Label for the category dropdown
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get addRecurringRuleCategoryLabel;

  /// Validation error when no category selected
  ///
  /// In en, this message translates to:
  /// **'Select a category'**
  String get addRecurringRuleCategoryRequired;

  /// Label for the transaction type selector
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get addRecurringRuleTypeLabel;

  /// Label for expense option
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get addRecurringRuleTypeExpense;

  /// Label for income option
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get addRecurringRuleTypeIncome;

  /// Label for the start date picker
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get addRecurringRuleStartDateLabel;

  /// Label for the time picker
  ///
  /// In en, this message translates to:
  /// **'Execution time'**
  String get addRecurringRuleStartTimeLabel;

  /// Label for reminder selection in the recurring rule form
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get addRecurringRuleReminderLabel;

  /// Dropdown option meaning no reminder
  ///
  /// In en, this message translates to:
  /// **'No reminder'**
  String get addRecurringRuleReminderNone;

  /// Dropdown option for reminder exactly at due time
  ///
  /// In en, this message translates to:
  /// **'At due time'**
  String get addRecurringRuleReminderAtTime;

  /// Dropdown option for reminder in minutes before due time
  ///
  /// In en, this message translates to:
  /// **'{minutes, plural, one {# minute before} other {# minutes before}}'**
  String addRecurringRuleReminderMinutes(int minutes);

  /// Dropdown option for reminder in hours before due time
  ///
  /// In en, this message translates to:
  /// **'{hours, plural, one {# hour before} other {# hours before}}'**
  String addRecurringRuleReminderHours(int hours);

  /// Dropdown option for reminder in days before due date
  ///
  /// In en, this message translates to:
  /// **'{days, plural, one {# day before} other {# days before}}'**
  String addRecurringRuleReminderDays(int days);

  /// Label for the one-time reminder toggle
  ///
  /// In en, this message translates to:
  /// **'Only once'**
  String get addRecurringRuleRemindOnceLabel;

  /// Helper text explaining the one-time reminder behaviour
  ///
  /// In en, this message translates to:
  /// **'Schedule a single reminder and skip future repeats.'**
  String get addRecurringRuleRemindOnceSubtitle;

  /// Label for the auto-post toggle
  ///
  /// In en, this message translates to:
  /// **'Post automatically'**
  String get addRecurringRuleAutoPostLabel;

  /// Helper text shown when auto-post is unavailable due to one-time reminder
  ///
  /// In en, this message translates to:
  /// **'Automatic posting is disabled for one-time reminders.'**
  String get addRecurringRuleAutoPostDisabled;

  /// Label for the next due preview
  ///
  /// In en, this message translates to:
  /// **'Next due'**
  String get addRecurringRuleNextDuePreviewLabel;

  /// Placeholder when next due preview is unavailable
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get addRecurringRuleNextDuePreviewUnknown;

  /// Label for the submit button
  ///
  /// In en, this message translates to:
  /// **'Save rule'**
  String get addRecurringRuleSubmit;

  /// Label for the submit button when editing a recurring rule
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get editRecurringRuleSubmit;

  /// Message shown when there are no accounts
  ///
  /// In en, this message translates to:
  /// **'Add an account before creating a recurring rule.'**
  String get addRecurringRuleNoAccounts;

  /// Message shown when there are no categories
  ///
  /// In en, this message translates to:
  /// **'Add a category before creating a recurring rule.'**
  String get addRecurringRuleNoCategories;

  /// Snackbar message when recurring rule saved
  ///
  /// In en, this message translates to:
  /// **'Recurring transaction saved'**
  String get addRecurringRuleSuccess;

  /// Snackbar message when a recurring rule is edited
  ///
  /// In en, this message translates to:
  /// **'Recurring rule updated.'**
  String get editRecurringRuleSuccess;

  /// Generic copy when a feature is not yet available
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get commonComingSoon;

  /// Fallback error message for unexpected failures
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again later.'**
  String get genericErrorMessage;

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

  /// Button label for starting the app without an account
  ///
  /// In en, this message translates to:
  /// **'Work offline'**
  String get signInOfflineCta;

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

  /// Link that switches the form into sign-up mode
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get signInNoAccountCta;

  /// Link that switches the form back to sign-in mode
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get signInAlreadyHaveAccountCta;

  /// Main heading on the sign-up form
  ///
  /// In en, this message translates to:
  /// **'Create your Kopim account'**
  String get signUpTitle;

  /// Subtitle describing the benefit of registration
  ///
  /// In en, this message translates to:
  /// **'Register to sync your finances securely across devices.'**
  String get signUpSubtitle;

  /// Primary call to action for sign-up form
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUpSubmitCta;

  /// Status text when sign-up request is running
  ///
  /// In en, this message translates to:
  /// **'Creating account...'**
  String get signUpLoading;

  /// Fallback message shown when sign-up fails
  ///
  /// In en, this message translates to:
  /// **'Could not create account. Please try again.'**
  String get signUpError;

  /// Label for the confirm password field
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get signUpConfirmPasswordLabel;

  /// Label for display name field during registration
  ///
  /// In en, this message translates to:
  /// **'Name (optional)'**
  String get signUpDisplayNameLabel;

  /// Title for the home screen
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// Tooltip for the profile action in the home app bar
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get homeProfileTooltip;

  /// Shown after manual sync completes successfully
  ///
  /// In en, this message translates to:
  /// **'Sync complete.'**
  String get homeSyncStatusSuccess;

  /// Shown when sync is requested while offline
  ///
  /// In en, this message translates to:
  /// **'You are offline. Sync is unavailable.'**
  String get homeSyncStatusOffline;

  /// Shown when sync is already running
  ///
  /// In en, this message translates to:
  /// **'Sync is already running.'**
  String get homeSyncStatusInProgress;

  /// Shown when there are no pending changes to sync
  ///
  /// In en, this message translates to:
  /// **'Nothing to sync.'**
  String get homeSyncStatusNoChanges;

  /// Shown when user is not authenticated for sync
  ///
  /// In en, this message translates to:
  /// **'Sign in to sync your data.'**
  String get homeSyncStatusAuthRequired;

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

  /// Label for monthly income shown on the home screen account card
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get homeAccountMonthlyIncomeLabel;

  /// Label for monthly expenses shown on the home screen account card
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get homeAccountMonthlyExpenseLabel;

  /// Section header label for transactions happening today
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get homeTransactionsTodayLabel;

  /// Section header label for transactions happening yesterday
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get homeTransactionsYesterdayLabel;

  /// Localized name for the cash account type
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get accountTypeCash;

  /// Localized name for the card account type
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get accountTypeCard;

  /// Localized name for the bank account type
  ///
  /// In en, this message translates to:
  /// **'Bank account'**
  String get accountTypeBank;

  /// Fallback label when account type is unknown
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get accountTypeOther;

  /// Section header for transactions list
  ///
  /// In en, this message translates to:
  /// **'Recent transactions'**
  String get homeTransactionsSection;

  /// Label for the all transactions filter on the home screen
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get homeTransactionsFilterAll;

  /// Label for the income-only filter on the home screen
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get homeTransactionsFilterIncome;

  /// Label for the expense-only filter on the home screen
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get homeTransactionsFilterExpense;

  /// Button label that opens the all transactions screen
  ///
  /// In en, this message translates to:
  /// **'All transactions'**
  String get homeTransactionsSeeAll;

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

  /// Header for the upcoming payments widget
  ///
  /// In en, this message translates to:
  /// **'Recurring payments'**
  String get homeUpcomingPaymentsTitle;

  /// Empty state when there are no upcoming payments
  ///
  /// In en, this message translates to:
  /// **'Nothing here.'**
  String get homeUpcomingPaymentsEmpty;

  /// Subtitle shown when no upcoming payment is scheduled
  ///
  /// In en, this message translates to:
  /// **'No recurring payments'**
  String get homeUpcomingPaymentsEmptyHeader;

  /// Summary shown while the upcoming payments list is collapsed
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0 {List hidden · no payments} one {List hidden · {count} payment} other {List hidden · {count} payments}}'**
  String homeUpcomingPaymentsCollapsedSummary(int count);

  /// Button label that expands the upcoming payments list
  ///
  /// In en, this message translates to:
  /// **'Show list'**
  String get homeUpcomingPaymentsExpand;

  /// Button label that collapses the upcoming payments list
  ///
  /// In en, this message translates to:
  /// **'Hide list'**
  String get homeUpcomingPaymentsCollapse;

  /// Subtitle with the nearest upcoming payment date
  ///
  /// In en, this message translates to:
  /// **'Next due: {date}'**
  String homeUpcomingPaymentsNextDate(String date);

  /// Error shown when loading upcoming payments fails
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load recurring payments: {error}'**
  String homeUpcomingPaymentsError(String error);

  /// Snackbar message when the source recurring rule is missing
  ///
  /// In en, this message translates to:
  /// **'This recurring rule has been removed.'**
  String get homeUpcomingPaymentsMissingRule;

  /// Subtitle for individual upcoming payment entries
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String homeUpcomingPaymentsDueDate(String date);

  /// Accessibility label for the upcoming payments badge
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0 {No recurring payments} one {# recurring payment} other {# recurring payments}}'**
  String homeUpcomingPaymentsCountSemantics(int count);

  /// Button label that opens the upcoming payments screen from the home widget
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get homeUpcomingPaymentsMore;

  /// Label for the upcoming payments badge
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get homeUpcomingPaymentsBadgePaymentsLabel;

  /// Label for the reminders badge
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get homeUpcomingPaymentsBadgeRemindersLabel;

  /// Accessibility label for the number of upcoming payments
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0 {No recurring payments} one {# recurring payment} other {# recurring payments}}'**
  String homeUpcomingPaymentsBadgePaymentsSemantics(int count);

  /// Accessibility label for the number of reminders
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0 {No reminders} one {# reminder} other {# reminders}}'**
  String homeUpcomingPaymentsBadgeRemindersSemantics(int count);

  /// Title for the upcoming payments screen
  ///
  /// In en, this message translates to:
  /// **'Recurring payments'**
  String get upcomingPaymentsTitle;

  /// Tab label for recurring payment rules
  ///
  /// In en, this message translates to:
  /// **'Recurring'**
  String get upcomingPaymentsTabPayments;

  /// Tab label for manual payment reminders
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get upcomingPaymentsTabReminders;

  /// Headline for empty state of the payment rules list
  ///
  /// In en, this message translates to:
  /// **'No recurring payments yet'**
  String get upcomingPaymentsEmptyPaymentsTitle;

  /// Description for empty state of the payment rules list
  ///
  /// In en, this message translates to:
  /// **'Set up recurring payments to stay on top of your bills.'**
  String get upcomingPaymentsEmptyPaymentsDescription;

  /// Headline for empty state of the reminders list
  ///
  /// In en, this message translates to:
  /// **'No reminders yet'**
  String get upcomingPaymentsEmptyRemindersTitle;

  /// Description for empty state of the reminders list
  ///
  /// In en, this message translates to:
  /// **'Set reminders so you never miss a manual payment.'**
  String get upcomingPaymentsEmptyRemindersDescription;

  /// Action label for creating a new upcoming payment
  ///
  /// In en, this message translates to:
  /// **'Add recurring payment'**
  String get upcomingPaymentsAddPayment;

  /// Action label for creating a new payment reminder
  ///
  /// In en, this message translates to:
  /// **'Add reminder'**
  String get upcomingPaymentsAddReminder;

  /// Title for the create payment form
  ///
  /// In en, this message translates to:
  /// **'New recurring payment'**
  String get upcomingPaymentsNewPaymentTitle;

  /// Title for the edit payment form
  ///
  /// In en, this message translates to:
  /// **'Edit recurring payment'**
  String get upcomingPaymentsEditPaymentTitle;

  /// Title for the create reminder form
  ///
  /// In en, this message translates to:
  /// **'New reminder'**
  String get upcomingPaymentsNewReminderTitle;

  /// Title for the edit reminder form
  ///
  /// In en, this message translates to:
  /// **'Edit reminder'**
  String get upcomingPaymentsEditReminderTitle;

  /// Label for the payment or reminder title field
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get upcomingPaymentsFieldTitle;

  /// Label for selecting an account
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get upcomingPaymentsFieldAccount;

  /// Label for selecting a category
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get upcomingPaymentsFieldCategory;

  /// Label for the amount input
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get upcomingPaymentsFieldAmount;

  /// Label for selecting the recurring day of month
  ///
  /// In en, this message translates to:
  /// **'Day of month'**
  String get upcomingPaymentsFieldDayOfMonth;

  /// Label for the notify days input
  ///
  /// In en, this message translates to:
  /// **'Notify days before'**
  String get upcomingPaymentsFieldNotifyDaysBefore;

  /// Label for the notification time picker
  ///
  /// In en, this message translates to:
  /// **'Notification time'**
  String get upcomingPaymentsFieldNotifyTime;

  /// Label for the auto post switch
  ///
  /// In en, this message translates to:
  /// **'Post automatically'**
  String get upcomingPaymentsFieldAutoPost;

  /// Label for the optional note field
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get upcomingPaymentsFieldNote;

  /// Label for selecting reminder date and time
  ///
  /// In en, this message translates to:
  /// **'Date and time'**
  String get upcomingPaymentsFieldReminderWhen;

  /// Primary action button for saving a form
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get upcomingPaymentsSubmit;

  /// Secondary action for dismissing a form
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get upcomingPaymentsCancel;

  /// Snackbar message shown when a payment rule is saved
  ///
  /// In en, this message translates to:
  /// **'Recurring payment saved'**
  String get upcomingPaymentsSaveSuccess;

  /// Snackbar message shown when a reminder is saved
  ///
  /// In en, this message translates to:
  /// **'Reminder saved'**
  String get upcomingPaymentsReminderSaveSuccess;

  /// Error message shown when saving a payment rule fails
  ///
  /// In en, this message translates to:
  /// **'Failed to save recurring payment: {error}'**
  String upcomingPaymentsSaveError(String error);

  /// Error message shown when saving a reminder fails
  ///
  /// In en, this message translates to:
  /// **'Failed to save reminder: {error}'**
  String upcomingPaymentsReminderSaveError(String error);

  /// Action label for marking a reminder as paid
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get upcomingPaymentsReminderMarkPaidAction;

  /// Tooltip for the paid action on reminder cards
  ///
  /// In en, this message translates to:
  /// **'Mark reminder as paid'**
  String get upcomingPaymentsReminderMarkPaidTooltip;

  /// Snackbar message when a reminder is marked as paid
  ///
  /// In en, this message translates to:
  /// **'Reminder marked as paid.'**
  String get upcomingPaymentsReminderMarkPaidSuccess;

  /// Error message when marking a reminder as paid fails
  ///
  /// In en, this message translates to:
  /// **'Failed to mark reminder: {error}'**
  String upcomingPaymentsReminderMarkPaidError(String error);

  /// Menu option label for editing a reminder
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get upcomingPaymentsReminderEditAction;

  /// Menu option label for deleting a reminder
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get upcomingPaymentsReminderDeleteAction;

  /// Confirmation dialog title for deleting a reminder
  ///
  /// In en, this message translates to:
  /// **'Delete reminder?'**
  String get upcomingPaymentsReminderDeleteTitle;

  /// Confirmation dialog message for deleting a reminder
  ///
  /// In en, this message translates to:
  /// **'Delete reminder \"{title}\"? This action cannot be undone.'**
  String upcomingPaymentsReminderDeleteMessage(String title);

  /// Snackbar message when a reminder is deleted
  ///
  /// In en, this message translates to:
  /// **'Reminder deleted.'**
  String get upcomingPaymentsReminderDeleteSuccess;

  /// Error message shown when reminder deletion fails
  ///
  /// In en, this message translates to:
  /// **'Failed to delete reminder: {error}'**
  String upcomingPaymentsReminderDeleteError(String error);

  /// Menu option label for editing a recurring payment
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get upcomingPaymentsEditAction;

  /// Menu option label for deleting a recurring payment
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get upcomingPaymentsDeleteAction;

  /// Confirmation dialog title for deleting a recurring payment
  ///
  /// In en, this message translates to:
  /// **'Delete recurring payment?'**
  String get upcomingPaymentsDeleteTitle;

  /// Confirmation dialog message for deleting a recurring payment
  ///
  /// In en, this message translates to:
  /// **'Delete \"{title}\"? This action cannot be undone.'**
  String upcomingPaymentsDeleteMessage(String title);

  /// Snackbar message when a recurring payment is deleted
  ///
  /// In en, this message translates to:
  /// **'Recurring payment deleted.'**
  String get upcomingPaymentsDeleteSuccess;

  /// Error message shown when deleting a recurring payment fails
  ///
  /// In en, this message translates to:
  /// **'Failed to delete recurring payment: {error}'**
  String upcomingPaymentsDeleteError(String error);

  /// Validation error shown when title is empty
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get upcomingPaymentsValidationTitle;

  /// Validation error for amount
  ///
  /// In en, this message translates to:
  /// **'Enter a positive amount'**
  String get upcomingPaymentsValidationAmount;

  /// Validation error for day of month
  ///
  /// In en, this message translates to:
  /// **'Day must be between 1 and 31'**
  String get upcomingPaymentsValidationDay;

  /// Validation error for notify days
  ///
  /// In en, this message translates to:
  /// **'Notify days must be zero or greater'**
  String get upcomingPaymentsValidationNotifyDays;

  /// Message shown when there are no accounts available
  ///
  /// In en, this message translates to:
  /// **'Add an account before creating a recurring payment.'**
  String get upcomingPaymentsNoAccounts;

  /// Message shown when there are no categories available
  ///
  /// In en, this message translates to:
  /// **'Create a category to use it for a recurring payment.'**
  String get upcomingPaymentsNoCategories;

  /// Summary text describing the recurring schedule
  ///
  /// In en, this message translates to:
  /// **'Every month on day {day}'**
  String upcomingPaymentsMonthlySummary(int day);

  /// Summary describing when notifications are sent
  ///
  /// In en, this message translates to:
  /// **'Notify {days, plural, =0 {on the day at {time}} one {{days} day before at {time}} other {{days} days before at {time}}}'**
  String upcomingPaymentsNotifySummary(int days, String time);

  /// Label showing reminder due date
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String upcomingPaymentsReminderDue(String date);

  /// Error shown when stream loading fails
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load items: {error}'**
  String upcomingPaymentsListError(String error);

  /// Message shown when scheduling notifications fails because permission is denied
  ///
  /// In en, this message translates to:
  /// **'Notifications are disabled. Enable them to receive reminders.'**
  String get upcomingPaymentsNotificationPermissionDenied;

  /// Message shown when the background worker is scheduled
  ///
  /// In en, this message translates to:
  /// **'Background worker queued'**
  String get upcomingPaymentsScheduleTriggered;

  /// Title for the savings overview widget on the home screen
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get homeSavingsWidgetTitle;

  /// Empty state message for the savings widget
  ///
  /// In en, this message translates to:
  /// **'Create your first goal to start tracking progress.'**
  String get homeSavingsWidgetEmpty;

  /// CTA label that opens the savings screen from the home widget
  ///
  /// In en, this message translates to:
  /// **'Open savings'**
  String get homeSavingsWidgetViewAll;

  /// Title for the gamification widget on the home screen
  ///
  /// In en, this message translates to:
  /// **'Level progress'**
  String get homeGamificationTitle;

  /// Subtitle explaining how to gain experience
  ///
  /// In en, this message translates to:
  /// **'Complete transactions to earn XP and unlock new levels.'**
  String get homeGamificationSubtitle;

  /// Error message shown when gamification data fails to load
  ///
  /// In en, this message translates to:
  /// **'Can\'t load progress: {error}'**
  String homeGamificationError(String error);

  /// Title for the selected budget card on the home screen
  ///
  /// In en, this message translates to:
  /// **'Budget overview'**
  String get homeBudgetWidgetTitle;

  /// Message shown when no budget is selected for the home widget
  ///
  /// In en, this message translates to:
  /// **'Select a budget in settings to track it here.'**
  String get homeBudgetWidgetEmpty;

  /// Error shown when the configured budget was deleted
  ///
  /// In en, this message translates to:
  /// **'The selected budget is no longer available.'**
  String get homeBudgetWidgetMissing;

  /// Message shown when there are no categories to display in the budget widget
  ///
  /// In en, this message translates to:
  /// **'No category breakdown yet.'**
  String get homeBudgetWidgetCategoriesEmpty;

  /// Button label that opens settings to configure the budget widget
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get homeBudgetWidgetConfigureCta;

  /// Error shown when dashboard preferences fail to load
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load home widgets: {error}'**
  String homeDashboardPreferencesError(String error);

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

  /// Bottom navigation label for the AI assistant tab
  ///
  /// In en, this message translates to:
  /// **'Assistant'**
  String get homeNavAssistant;

  /// Bottom navigation label for savings
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get homeNavSavings;

  /// Bottom navigation label for settings
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get homeNavSettings;

  /// Dialog title asking the user to confirm app exit from the home screen
  ///
  /// In en, this message translates to:
  /// **'Exit Kopim?'**
  String get mainNavigationExitTitle;

  /// Dialog message asking whether the user wants to close the app
  ///
  /// In en, this message translates to:
  /// **'Do you want to close the app?'**
  String get mainNavigationExitMessage;

  /// Confirmation button label that closes the app
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get mainNavigationExitConfirm;

  /// Cancellation button label that keeps the user inside the app
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get mainNavigationExitCancel;

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

  /// Heading for the monthly analytics summary
  ///
  /// In en, this message translates to:
  /// **'Current month overview'**
  String get analyticsCurrentMonthTitle;

  /// Label for total income in analytics summary
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get analyticsSummaryIncomeLabel;

  /// Label for total expenses in analytics summary
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get analyticsSummaryExpenseLabel;

  /// Label for net balance in analytics summary
  ///
  /// In en, this message translates to:
  /// **'Net'**
  String get analyticsSummaryNetLabel;

  /// Heading for the list of top categories
  ///
  /// In en, this message translates to:
  /// **'Top categories'**
  String get analyticsTopCategoriesTitle;

  /// Tab label for expense categories
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get analyticsTopCategoriesExpensesTab;

  /// Tab label for income categories
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get analyticsTopCategoriesIncomeTab;

  /// Legend label for remaining categories not shown individually
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get analyticsTopCategoriesOthers;

  /// Label for the toggle that switches the chart visualization
  ///
  /// In en, this message translates to:
  /// **'Chart type'**
  String get analyticsChartTypeLabel;

  /// Option that selects the donut chart
  ///
  /// In en, this message translates to:
  /// **'Donut'**
  String get analyticsChartTypeDonut;

  /// Option that selects the bar chart
  ///
  /// In en, this message translates to:
  /// **'Bar'**
  String get analyticsChartTypeBar;

  /// Message displayed when there are no categories to show
  ///
  /// In en, this message translates to:
  /// **'Not enough data to show category trends yet.'**
  String get analyticsTopCategoriesEmpty;

  /// Hint instructing the user to tap categories in the donut chart
  ///
  /// In en, this message translates to:
  /// **'Tap a category to view totals · Total {amount}'**
  String analyticsTopCategoriesTapHint(String amount);

  /// Label for expenses without a category
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get analyticsCategoryUncategorized;

  /// Label for transactions recorded directly in the parent category
  ///
  /// In en, this message translates to:
  /// **'In this category'**
  String get analyticsCategoryDirectLabel;

  /// Title for the transaction list by selected category in analytics
  ///
  /// In en, this message translates to:
  /// **'Transactions: {category}'**
  String analyticsCategoryTransactionsTitle(String category);

  /// Empty state for category transactions list in analytics
  ///
  /// In en, this message translates to:
  /// **'No transactions for this category in the selected period.'**
  String get analyticsCategoryTransactionsEmpty;

  /// Heading for analytics overview showing selected range
  ///
  /// In en, this message translates to:
  /// **'Overview for {range}'**
  String analyticsOverviewRangeTitle(String range);

  /// Label for the filters expansion tile
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get analyticsFiltersButtonLabel;

  /// Accessibility label for the filters badge
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0 {No active filters} one {# active filter} other {# active filters}}'**
  String analyticsFiltersBadgeSemantics(int count);

  /// Label for the analytics date filter button
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get analyticsFilterDateLabel;

  /// Formatted range used for analytics date filter
  ///
  /// In en, this message translates to:
  /// **'{start} – {end}'**
  String analyticsFilterDateValue(String start, String end);

  /// Label for the analytics account filter
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get analyticsFilterAccountLabel;

  /// Option for selecting all accounts in analytics filters
  ///
  /// In en, this message translates to:
  /// **'All accounts'**
  String get analyticsFilterAccountAll;

  /// Label for the analytics category filter
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get analyticsFilterCategoryLabel;

  /// Option for selecting all categories in analytics filters
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get analyticsFilterCategoryAll;

  /// Message shown when there are no transactions matching selected filters
  ///
  /// In en, this message translates to:
  /// **'No analytics available for the selected filters yet.'**
  String get analyticsEmptyState;

  /// Error shown when analytics stream fails
  ///
  /// In en, this message translates to:
  /// **'Unable to load analytics: {error}'**
  String analyticsLoadError(String error);

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

  /// Supporting text shown above the account selector
  ///
  /// In en, this message translates to:
  /// **'Pick an account to start this transaction'**
  String get addTransactionAccountHint;

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

  /// Supporting text shown above the category selector
  ///
  /// In en, this message translates to:
  /// **'Assign a category so your analytics stay accurate'**
  String get addTransactionCategoryHint;

  /// Placeholder text inside the category search field
  ///
  /// In en, this message translates to:
  /// **'Search categories'**
  String get addTransactionCategorySearchHint;

  /// Button label to expand the full category list
  ///
  /// In en, this message translates to:
  /// **'Show all categories'**
  String get addTransactionShowAllCategories;

  /// Button label to collapse the full category list
  ///
  /// In en, this message translates to:
  /// **'Hide all categories'**
  String get addTransactionHideCategories;

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

  /// Label for the time picker
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get addTransactionTimeLabel;

  /// Hint text shown above the date/time controls
  ///
  /// In en, this message translates to:
  /// **'Change date and time'**
  String get addTransactionChangeDateTimeHint;

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

  /// Shown when the transaction being edited is missing from the local store
  ///
  /// In en, this message translates to:
  /// **'The transaction could not be found. Refresh and try again.'**
  String get transactionFormMissingError;

  /// Label for the submit button when editing a transaction
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get editTransactionSubmit;

  /// Shown when a transaction is deleted successfully
  ///
  /// In en, this message translates to:
  /// **'Transaction deleted.'**
  String get transactionDeleteSuccess;

  /// Snackbar text shown after creating a new transaction
  ///
  /// In en, this message translates to:
  /// **'+1 XP'**
  String get transactionXpGained;

  /// Title for the transaction deletion confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete transaction'**
  String get transactionDeleteConfirmTitle;

  /// Message shown when asking the user to confirm deleting a transaction
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this transaction? This action cannot be undone.'**
  String get transactionDeleteConfirmMessage;

  /// Shown when deleting a transaction fails
  ///
  /// In en, this message translates to:
  /// **'Unable to delete the transaction.'**
  String get transactionDeleteError;

  /// Confirmation message shown after creating a transaction
  ///
  /// In en, this message translates to:
  /// **'Transaction saved'**
  String get addTransactionSuccess;

  /// Snackbar message shown after undoing a newly created transaction
  ///
  /// In en, this message translates to:
  /// **'Transaction removed.'**
  String get addTransactionUndoSuccess;

  /// Snackbar message shown when undoing a transaction fails
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t undo the transaction.'**
  String get addTransactionUndoError;

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

  /// Option label for custom account types
  ///
  /// In en, this message translates to:
  /// **'Custom type'**
  String get addAccountTypeCustom;

  /// Label for the custom account type text field
  ///
  /// In en, this message translates to:
  /// **'Custom account type'**
  String get addAccountCustomTypeLabel;

  /// Validation error shown when the account type is missing
  ///
  /// In en, this message translates to:
  /// **'Please specify the account type.'**
  String get addAccountTypeRequired;

  /// Label for the account card color selector
  ///
  /// In en, this message translates to:
  /// **'Card color'**
  String get accountColorLabel;

  /// Label shown when the default card color is used
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get accountColorDefault;

  /// Label shown when a gradient is selected for the account card
  ///
  /// In en, this message translates to:
  /// **'Gradient'**
  String get accountColorGradient;

  /// Title shown on the account color picker dialog
  ///
  /// In en, this message translates to:
  /// **'Pick card color'**
  String get accountColorPickerTitle;

  /// Button label for confirming a color choice
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get accountColorSelect;

  /// Tooltip for clearing the selected card color
  ///
  /// In en, this message translates to:
  /// **'Clear color'**
  String get accountColorClear;

  /// Label for the account icon selector
  ///
  /// In en, this message translates to:
  /// **'Account icon'**
  String get accountIconLabel;

  /// Subtitle shown when no account icon has been selected
  ///
  /// In en, this message translates to:
  /// **'No icon selected'**
  String get accountIconNone;

  /// Subtitle shown when an account icon has been selected
  ///
  /// In en, this message translates to:
  /// **'Icon selected'**
  String get accountIconSelected;

  /// Tooltip for the action that opens the account icon picker
  ///
  /// In en, this message translates to:
  /// **'Choose icon'**
  String get accountIconSelect;

  /// Tooltip for clearing the selected account icon
  ///
  /// In en, this message translates to:
  /// **'Clear icon'**
  String get accountIconClear;

  /// Title for the account icon picker dialog
  ///
  /// In en, this message translates to:
  /// **'Pick an account icon'**
  String get accountIconPickerTitle;

  /// Label for the switch that marks an account as primary
  ///
  /// In en, this message translates to:
  /// **'Set as primary account'**
  String get accountPrimaryToggleLabel;

  /// Helper text explaining what the primary account setting does
  ///
  /// In en, this message translates to:
  /// **'This account will be selected by default for new transactions.'**
  String get accountPrimaryToggleSubtitle;

  /// Title for the account details screen
  ///
  /// In en, this message translates to:
  /// **'Account details'**
  String get accountDetailsTitle;

  /// Tooltip for the settings icon on the account details screen
  ///
  /// In en, this message translates to:
  /// **'Edit account'**
  String get accountDetailsEditTooltip;

  /// Error shown when loading the account fails
  ///
  /// In en, this message translates to:
  /// **'Unable to load account: {error}'**
  String accountDetailsError(String error);

  /// Shown when the requested account cannot be found
  ///
  /// In en, this message translates to:
  /// **'This account is no longer available.'**
  String get accountDetailsMissing;

  /// Error shown when computing income/expense summary fails
  ///
  /// In en, this message translates to:
  /// **'Unable to load summary: {error}'**
  String accountDetailsSummaryError(String error);

  /// Error shown when category stream fails on the account details screen
  ///
  /// In en, this message translates to:
  /// **'Unable to load categories: {error}'**
  String accountDetailsCategoriesError(String error);

  /// Error shown when account transactions fail to load
  ///
  /// In en, this message translates to:
  /// **'Unable to load transactions: {error}'**
  String accountDetailsTransactionsError(String error);

  /// Empty state shown when the account has no transactions
  ///
  /// In en, this message translates to:
  /// **'No transactions for this account yet.'**
  String get accountDetailsTransactionsEmpty;

  /// Label showing the current balance
  ///
  /// In en, this message translates to:
  /// **'Balance: {balance}'**
  String accountDetailsBalanceLabel(String balance);

  /// Label for the total income value
  ///
  /// In en, this message translates to:
  /// **'Total income'**
  String get accountDetailsIncomeLabel;

  /// Label for the total expense value
  ///
  /// In en, this message translates to:
  /// **'Total expenses'**
  String get accountDetailsExpenseLabel;

  /// Section title for the filter card
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get accountDetailsFiltersTitle;

  /// Label for the filters button when filters are active
  ///
  /// In en, this message translates to:
  /// **'Filters (active)'**
  String get accountDetailsFiltersButtonActive;

  /// Button label that clears all active filters
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get accountDetailsFiltersClear;

  /// Label for the date range filter
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get accountDetailsFiltersDateLabel;

  /// Label shown when no date range filter is applied
  ///
  /// In en, this message translates to:
  /// **'Any dates'**
  String get accountDetailsFiltersDateAny;

  /// Tooltip for the action that clears the date range filter
  ///
  /// In en, this message translates to:
  /// **'Clear date range'**
  String get accountDetailsFiltersDateClear;

  /// Label showing the selected date range
  ///
  /// In en, this message translates to:
  /// **'{start} – {end}'**
  String accountDetailsFiltersDateValue(String start, String end);

  /// Label for the type dropdown filter
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get accountDetailsFiltersTypeLabel;

  /// Dropdown option for no type filter
  ///
  /// In en, this message translates to:
  /// **'All types'**
  String get accountDetailsFiltersTypeAll;

  /// Dropdown option to filter income transactions
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get accountDetailsFiltersTypeIncome;

  /// Dropdown option to filter expense transactions
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get accountDetailsFiltersTypeExpense;

  /// Label for the category dropdown
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get accountDetailsFiltersCategoryLabel;

  /// Dropdown option for no category filter
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get accountDetailsFiltersCategoryAll;

  /// Label for transactions without a category
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get accountDetailsTransactionsUncategorized;

  /// Label for income transaction type
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get accountDetailsTypeIncome;

  /// Label for expense transaction type
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get accountDetailsTypeExpense;

  /// Title for the edit account screen
  ///
  /// In en, this message translates to:
  /// **'Edit account'**
  String get editAccountTitle;

  /// Label for the account name field on edit screen
  ///
  /// In en, this message translates to:
  /// **'Account name'**
  String get editAccountNameLabel;

  /// Label for the balance field on edit screen
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get editAccountBalanceLabel;

  /// Label for the currency dropdown on edit screen
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get editAccountCurrencyLabel;

  /// Label for the account type row on edit screen
  ///
  /// In en, this message translates to:
  /// **'Account type'**
  String get editAccountTypeLabel;

  /// Option label for selecting a custom account type
  ///
  /// In en, this message translates to:
  /// **'Custom type'**
  String get editAccountTypeCustom;

  /// Label for the custom account type input
  ///
  /// In en, this message translates to:
  /// **'Custom account type'**
  String get editAccountCustomTypeLabel;

  /// Validation error when the account type is missing
  ///
  /// In en, this message translates to:
  /// **'Please specify the account type.'**
  String get editAccountTypeRequired;

  /// Button label for saving account edits
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get editAccountSaveCta;

  /// Validation message when the account name is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter the account name.'**
  String get editAccountNameRequired;

  /// Validation message when the balance is invalid
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount.'**
  String get editAccountBalanceInvalid;

  /// Generic error shown when updating the account fails
  ///
  /// In en, this message translates to:
  /// **'Could not update account. Please try again.'**
  String get editAccountGenericError;

  /// Button label for deleting the account
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get editAccountDeleteCta;

  /// Button label shown while the account is being deleted
  ///
  /// In en, this message translates to:
  /// **'Deleting...'**
  String get editAccountDeleteLoading;

  /// Confirmation dialog title before deleting an account
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get editAccountDeleteConfirmationTitle;

  /// Confirmation dialog message before deleting an account
  ///
  /// In en, this message translates to:
  /// **'This account and its data will be removed. This action cannot be undone.'**
  String get editAccountDeleteConfirmationMessage;

  /// Cancel button label in the delete confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get editAccountDeleteConfirmationCancel;

  /// Confirm button label in the delete confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get editAccountDeleteConfirmationConfirm;

  /// Error message shown when deleting an account fails
  ///
  /// In en, this message translates to:
  /// **'Failed to delete the account. Please try again.'**
  String get editAccountDeleteError;

  /// Label for the budgets tab in the bottom navigation
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get homeNavBudgets;

  /// Title for the budgets list screen
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get budgetsTitle;

  /// Title for the category spending chart on the budgets screen
  ///
  /// In en, this message translates to:
  /// **'Spending by category'**
  String get budgetsCategoryChartTitle;

  /// Title for the collapsible list with budget categories
  ///
  /// In en, this message translates to:
  /// **'Budget categories'**
  String get budgetsCategoryBreakdownTitle;

  /// Headline shown when the user has not created budgets
  ///
  /// In en, this message translates to:
  /// **'No budgets yet'**
  String get budgetsEmptyTitle;

  /// Supporting copy for the empty budgets state
  ///
  /// In en, this message translates to:
  /// **'Create your first budget to track spending and stay on target.'**
  String get budgetsEmptyMessage;

  /// Error headline shown when budgets stream fails
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load budgets'**
  String get budgetsErrorTitle;

  /// Label for the spent amount metric on a budget card
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get budgetsSpentLabel;

  /// Label for the budget limit metric
  ///
  /// In en, this message translates to:
  /// **'Limit'**
  String get budgetsLimitLabel;

  /// Label for the remaining amount metric
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get budgetsRemainingLabel;

  /// Button to open budget transactions
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get budgetsDetailsButton;

  /// Label used when a budget is exceeded
  ///
  /// In en, this message translates to:
  /// **'Over'**
  String get budgetsExceededLabel;

  /// Title for the budget detail screen
  ///
  /// In en, this message translates to:
  /// **'Budget details'**
  String get budgetDetailTitle;

  /// Title for the delete budget confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete budget?'**
  String get budgetDeleteTitle;

  /// Body text for the delete budget confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'This budget and its history will be removed. This action cannot be undone.'**
  String get budgetDeleteMessage;

  /// Label describing the time range covered by a budget instance
  ///
  /// In en, this message translates to:
  /// **'Period: {start} – {end}'**
  String budgetPeriodLabel(String start, String end);

  /// Section title for transactions inside the budget detail screen
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get budgetTransactionsTitle;

  /// Message shown when no transactions are associated with the budget
  ///
  /// In en, this message translates to:
  /// **'No transactions match this budget yet.'**
  String get budgetTransactionsEmpty;

  /// Title for the budget creation screen
  ///
  /// In en, this message translates to:
  /// **'Create budget'**
  String get budgetCreateTitle;

  /// Title for the budget editing screen
  ///
  /// In en, this message translates to:
  /// **'Edit budget'**
  String get budgetEditTitle;

  /// Label for the budget title text field
  ///
  /// In en, this message translates to:
  /// **'Budget title'**
  String get budgetTitleLabel;

  /// Label for the budget amount input
  ///
  /// In en, this message translates to:
  /// **'Limit amount'**
  String get budgetAmountLabel;

  /// Helper text shown when the budget amount is computed from category allocations.
  ///
  /// In en, this message translates to:
  /// **'Total is calculated from category limits.'**
  String get budgetAmountAutoHelper;

  /// Label for the budget period dropdown
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get budgetPeriodLabelShort;

  /// Label for the budget scope dropdown
  ///
  /// In en, this message translates to:
  /// **'Scope'**
  String get budgetScopeLabel;

  /// Label for the start date picker
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get budgetStartDateLabel;

  /// Label for the end date picker
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get budgetEndDateLabel;

  /// Label for the selected categories chips
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get budgetCategoriesLabel;

  /// Section title for configuring per-category budget limits.
  ///
  /// In en, this message translates to:
  /// **'Category limits'**
  String get budgetCategoryAllocationsTitle;

  /// Label for the input that captures a budget limit for a specific category.
  ///
  /// In en, this message translates to:
  /// **'{category} limit'**
  String budgetCategoryLimitLabel(String category);

  /// Label for the selected accounts chips
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get budgetAccountsLabel;

  /// Option label for monthly budgets
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get budgetPeriodMonthly;

  /// Option label for weekly budgets
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get budgetPeriodWeekly;

  /// Option label for custom budgets
  ///
  /// In en, this message translates to:
  /// **'Custom range'**
  String get budgetPeriodCustom;

  /// Option label for a budget covering all transactions
  ///
  /// In en, this message translates to:
  /// **'All transactions'**
  String get budgetScopeAll;

  /// Option label for category-scoped budgets
  ///
  /// In en, this message translates to:
  /// **'Selected categories'**
  String get budgetScopeByCategory;

  /// Option label for account-scoped budgets
  ///
  /// In en, this message translates to:
  /// **'Selected accounts'**
  String get budgetScopeByAccount;

  /// Validation error shown when the amount is invalid
  ///
  /// In en, this message translates to:
  /// **'Enter a positive amount.'**
  String get budgetErrorInvalidAmount;

  /// Validation error shown when category allocations are invalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a positive limit for each selected category.'**
  String get budgetErrorInvalidCategoryAmount;

  /// Validation error shown when the title is missing
  ///
  /// In en, this message translates to:
  /// **'Enter a title for the budget.'**
  String get budgetErrorMissingTitle;

  /// Placeholder shown when no end date is selected
  ///
  /// In en, this message translates to:
  /// **'No end date'**
  String get budgetNoEndDateLabel;

  /// Generic label for edit actions
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editButtonLabel;

  /// Generic label for delete actions
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButtonLabel;

  /// Generic label for cancel actions
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButtonLabel;

  /// Generic label for save buttons
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButtonLabel;

  /// Title for the savings goals screen
  ///
  /// In en, this message translates to:
  /// **'Savings goals'**
  String get savingsTitle;

  /// Title for the add savings goal screen
  ///
  /// In en, this message translates to:
  /// **'New goal'**
  String get savingsAddGoalTitle;

  /// Title for the edit savings goal screen
  ///
  /// In en, this message translates to:
  /// **'Edit goal'**
  String get savingsEditGoalTitle;

  /// Label for the savings goal name field
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get savingsNameLabel;

  /// Label for the target amount field
  ///
  /// In en, this message translates to:
  /// **'Target amount'**
  String get savingsTargetLabel;

  /// Helper text for the target amount field
  ///
  /// In en, this message translates to:
  /// **'Enter the desired total amount'**
  String get savingsTargetHelper;

  /// Label for the optional goal note
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get savingsNoteLabel;

  /// Primary action button for saving goal forms
  ///
  /// In en, this message translates to:
  /// **'Save goal'**
  String get savingsSaveGoalButton;

  /// Snackbar message when a goal is saved
  ///
  /// In en, this message translates to:
  /// **'Goal saved'**
  String get savingsGoalSavedMessage;

  /// Call to action button on the empty state
  ///
  /// In en, this message translates to:
  /// **'Create goal'**
  String get savingsAddGoalButton;

  /// Headline for the empty savings state
  ///
  /// In en, this message translates to:
  /// **'Create your first savings goal'**
  String get savingsEmptyTitle;

  /// Supporting text for the empty savings state
  ///
  /// In en, this message translates to:
  /// **'Track progress towards your targets and stay motivated.'**
  String get savingsEmptyMessage;

  /// Title for the savings error state
  ///
  /// In en, this message translates to:
  /// **'Unable to load savings goals'**
  String get savingsErrorTitle;

  /// Retry button label for savings error state
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get savingsRetryButton;

  /// Label for contribute action button
  ///
  /// In en, this message translates to:
  /// **'Contribute'**
  String get savingsContributeAction;

  /// Label for edit goal action
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get savingsEditAction;

  /// Label for archive goal action
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get savingsArchiveAction;

  /// Snackbar message shown after archiving a savings goal
  ///
  /// In en, this message translates to:
  /// **'Goal \"{goal}\" archived'**
  String savingsGoalArchivedMessage(String goal);

  /// Badge label for archived goals
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get savingsArchivedBadge;

  /// Text showing remaining amount to reach target
  ///
  /// In en, this message translates to:
  /// **'Remaining {amount}'**
  String savingsRemainingLabel(String amount);

  /// Toggle label to show archived goals
  ///
  /// In en, this message translates to:
  /// **'Show archived goals'**
  String get savingsShowArchivedToggle;

  /// Title for the contribute screen
  ///
  /// In en, this message translates to:
  /// **'Contribute to {goal}'**
  String savingsContributeTitle(String goal);

  /// Label for contribution amount field
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get savingsAmountLabel;

  /// Label for the contribution account picker
  ///
  /// In en, this message translates to:
  /// **'Source account'**
  String get savingsSourceAccountLabel;

  /// Dropdown option when no account is selected
  ///
  /// In en, this message translates to:
  /// **'No account'**
  String get savingsNoAccountOption;

  /// Label for the optional contribution note
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get savingsContributionNoteLabel;

  /// Primary action button on contribute screen
  ///
  /// In en, this message translates to:
  /// **'Add contribution'**
  String get savingsSubmitContributionButton;

  /// Snackbar after adding a contribution
  ///
  /// In en, this message translates to:
  /// **'Contribution added'**
  String get savingsContributionSuccess;

  /// Fallback title for the savings goal details screen
  ///
  /// In en, this message translates to:
  /// **'Savings goal'**
  String get savingsGoalDetailsTitle;

  /// Tooltip for the edit action on the goal details screen
  ///
  /// In en, this message translates to:
  /// **'Edit goal'**
  String get savingsGoalDetailsEditTooltip;

  /// Message shown when a goal cannot be found
  ///
  /// In en, this message translates to:
  /// **'This savings goal is unavailable.'**
  String get savingsGoalDetailsNotFound;

  /// Section title for the goal progress summary
  ///
  /// In en, this message translates to:
  /// **'Progress overview'**
  String get savingsGoalDetailsSummaryTitle;

  /// Label showing the current amount saved
  ///
  /// In en, this message translates to:
  /// **'Current: {amount}'**
  String savingsGoalDetailsCurrentLabel(String amount);

  /// Label showing the target amount
  ///
  /// In en, this message translates to:
  /// **'Target: {amount}'**
  String savingsGoalDetailsTargetLabel(String amount);

  /// Shown when the goal has no contributions
  ///
  /// In en, this message translates to:
  /// **'No contributions yet'**
  String get savingsGoalDetailsNoContributions;

  /// Displays the date of the most recent contribution
  ///
  /// In en, this message translates to:
  /// **'Last contribution on {date}'**
  String savingsGoalDetailsLastContribution(String date);

  /// Shows how many transactions reference the goal
  ///
  /// In en, this message translates to:
  /// **'Transactions linked: {count}'**
  String savingsGoalDetailsTransactionsCount(int count);

  /// Section title for goal analytics
  ///
  /// In en, this message translates to:
  /// **'Account analytics'**
  String get savingsGoalDetailsAnalyticsTitle;

  /// Message shown when there is no analytics data yet
  ///
  /// In en, this message translates to:
  /// **'Link transactions to this goal to see category analytics.'**
  String get savingsGoalDetailsAnalyticsEmpty;

  /// Summary of the total contributed amount
  ///
  /// In en, this message translates to:
  /// **'Total contributions: {amount}'**
  String savingsGoalDetailsAnalyticsTotal(String amount);

  /// Fallback title for transactions without a note
  ///
  /// In en, this message translates to:
  /// **'Transaction'**
  String get transactionDefaultTitle;

  /// Title for the screen listing all transactions
  ///
  /// In en, this message translates to:
  /// **'All transactions'**
  String get allTransactionsTitle;

  /// Header for the collapsible filters panel
  ///
  /// In en, this message translates to:
  /// **'Transaction filters'**
  String get allTransactionsFiltersTitle;

  /// Label for the date range picker
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get allTransactionsFiltersDate;

  /// Helper text when no date range is selected
  ///
  /// In en, this message translates to:
  /// **'Any date'**
  String get allTransactionsFiltersDateAny;

  /// Label for the account filter
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get allTransactionsFiltersAccount;

  /// Helper text when no account is selected
  ///
  /// In en, this message translates to:
  /// **'All accounts'**
  String get allTransactionsFiltersAccountAny;

  /// Label for the category filter
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get allTransactionsFiltersCategory;

  /// Helper text when no category is selected
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get allTransactionsFiltersCategoryAny;

  /// Subtitle shown while filter data is loading
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get allTransactionsFiltersLoading;

  /// Button label for clearing all filters
  ///
  /// In en, this message translates to:
  /// **'Reset filters'**
  String get allTransactionsFiltersClear;

  /// Empty state message for the all transactions screen
  ///
  /// In en, this message translates to:
  /// **'No transactions match the selected filters.'**
  String get allTransactionsEmpty;

  /// Error message shown when fetching transactions fails
  ///
  /// In en, this message translates to:
  /// **'Failed to load transactions: {error}'**
  String allTransactionsError(String error);

  /// Title for the AI assistant screen
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get assistantScreenTitle;

  /// Placeholder text inside the assistant input field
  ///
  /// In en, this message translates to:
  /// **'Ask about your finances…'**
  String get assistantInputHint;

  /// Section title for quick action buttons on the assistant screen
  ///
  /// In en, this message translates to:
  /// **'Quick requests'**
  String get assistantQuickActionsTitle;

  /// Label for the spending summary quick action
  ///
  /// In en, this message translates to:
  /// **'Spending summary'**
  String get assistantQuickActionSpendingLabel;

  /// Prompt text sent when the spending summary quick action is tapped
  ///
  /// In en, this message translates to:
  /// **'Give me a spending summary for this month.'**
  String get assistantQuickActionSpendingPrompt;

  /// Label for the budget health quick action
  ///
  /// In en, this message translates to:
  /// **'Budget health'**
  String get assistantQuickActionBudgetLabel;

  /// Prompt text sent when the budget health quick action is tapped
  ///
  /// In en, this message translates to:
  /// **'Do I stay within my budgets this month?'**
  String get assistantQuickActionBudgetPrompt;

  /// Label for the savings trends quick action
  ///
  /// In en, this message translates to:
  /// **'Savings trends'**
  String get assistantQuickActionSavingsLabel;

  /// Prompt text sent when the savings trends quick action is tapped
  ///
  /// In en, this message translates to:
  /// **'How are my savings growing lately?'**
  String get assistantQuickActionSavingsPrompt;

  /// Section title for assistant filter chips
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get assistantFiltersTitle;

  /// Label for the current month assistant filter
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get assistantFilterCurrentMonth;

  /// Label for the last 30 days assistant filter
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get assistantFilterLast30Days;

  /// Label for the budgets-focused assistant filter
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get assistantFilterBudgets;

  /// Headline for the assistant empty state
  ///
  /// In en, this message translates to:
  /// **'Start a conversation'**
  String get assistantEmptyStateTitle;

  /// Subtitle for the assistant empty state
  ///
  /// In en, this message translates to:
  /// **'Use quick requests or ask your own question.'**
  String get assistantEmptyStateSubtitle;

  /// Banner message shown on the assistant screen when offline
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. We\'ll send your questions once the connection is back.'**
  String get assistantOfflineBanner;

  /// Button label for retrying assistant requests
  ///
  /// In en, this message translates to:
  /// **'Retry now'**
  String get assistantRetryButton;

  /// Status hint shown under queued assistant messages
  ///
  /// In en, this message translates to:
  /// **'Will send when you\'re back online.'**
  String get assistantPendingMessageHint;

  /// Status hint shown while an assistant request is in flight
  ///
  /// In en, this message translates to:
  /// **'Sending…'**
  String get assistantSendingMessageHint;

  /// Status hint shown when an assistant message fails
  ///
  /// In en, this message translates to:
  /// **'Not delivered. Tap retry.'**
  String get assistantFailedMessageHint;

  /// Generic error shown when the assistant fails
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t reach the assistant. Try again soon.'**
  String get assistantGenericError;

  /// Error shown when the assistant detects a network issue
  ///
  /// In en, this message translates to:
  /// **'Connection lost. We\'ll retry automatically.'**
  String get assistantNetworkError;

  /// Error shown when the assistant request times out
  ///
  /// In en, this message translates to:
  /// **'The assistant is taking longer than expected. Try again.'**
  String get assistantTimeoutError;

  /// Message shown when OpenRouter responds with a rate limit error
  ///
  /// In en, this message translates to:
  /// **'You\'ve hit the OpenRouter request limit. Wait a moment and try again.'**
  String get assistantRateLimitError;

  /// Message shown when OpenRouter returns a 5xx server error
  ///
  /// In en, this message translates to:
  /// **'OpenRouter (DeepSeek) is temporarily unavailable. Your message stays here so you can retry soon.'**
  String get assistantServerError;

  /// Message shown when the assistant feature flag is turned off
  ///
  /// In en, this message translates to:
  /// **'The assistant is currently disabled by the team. Please try again later.'**
  String get assistantDisabledError;

  /// Message shown when the assistant cannot read configuration
  ///
  /// In en, this message translates to:
  /// **'Assistant configuration is missing. Refresh the app or contact support.'**
  String get assistantConfigurationError;

  /// Placeholder shown while the assistant response is streaming
  ///
  /// In en, this message translates to:
  /// **'Assistant is preparing a response…'**
  String get assistantStreamingPlaceholder;

  /// Snack bar message shown after copying an assistant message
  ///
  /// In en, this message translates to:
  /// **'Message copied'**
  String get assistantMessageCopied;

  /// Card title explaining the assistant capabilities
  ///
  /// In en, this message translates to:
  /// **'Get started with the assistant'**
  String get assistantOnboardingTitle;

  /// Short description encouraging users to try the assistant
  ///
  /// In en, this message translates to:
  /// **'Ask about budgets, spending trends, or savings goals to get tailored insights.'**
  String get assistantOnboardingDescription;

  /// Checklist item describing analytics capabilities
  ///
  /// In en, this message translates to:
  /// **'Break down spending by category and period in seconds.'**
  String get assistantOnboardingFeatureInsights;

  /// Checklist item describing budget tracking
  ///
  /// In en, this message translates to:
  /// **'Check how close you are to each budget and get warnings before overspending.'**
  String get assistantOnboardingFeatureBudgets;

  /// Checklist item describing savings insights
  ///
  /// In en, this message translates to:
  /// **'Discover opportunities to accelerate your savings plans.'**
  String get assistantOnboardingFeatureSavings;

  /// Section title for assistant limitations
  ///
  /// In en, this message translates to:
  /// **'Keep in mind'**
  String get assistantOnboardingLimitationsTitle;

  /// Limitation reminding users about data freshness
  ///
  /// In en, this message translates to:
  /// **'Works with the latest synced data—sync offline transactions to include them.'**
  String get assistantOnboardingLimitationDataFreshness;

  /// Limitation about privacy and security
  ///
  /// In en, this message translates to:
  /// **'Stays inside Kopim: no data is shared outside your account.'**
  String get assistantOnboardingLimitationSecurity;

  /// Limitation encouraging verification of results
  ///
  /// In en, this message translates to:
  /// **'Treat answers as guidance and double-check totals in detailed reports.'**
  String get assistantOnboardingLimitationAccuracy;

  /// Section title for assistant FAQ
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get assistantFaqTitle;

  /// FAQ question about data sources
  ///
  /// In en, this message translates to:
  /// **'Where does the assistant get its data?'**
  String get assistantFaqQuestionDataSources;

  /// FAQ answer describing assistant data sources
  ///
  /// In en, this message translates to:
  /// **'It uses the same Drift database and Firebase sync as the app, so answers reflect your real accounts, budgets, and transactions.'**
  String get assistantFaqAnswerDataSources;

  /// FAQ question about rate limits
  ///
  /// In en, this message translates to:
  /// **'Why do I see rate limit or temporary errors?'**
  String get assistantFaqQuestionLimits;

  /// FAQ answer explaining rate limits
  ///
  /// In en, this message translates to:
  /// **'OpenRouter occasionally limits traffic. Wait a little before retrying or send a more focused request to stay within the quota.'**
  String get assistantFaqAnswerLimits;

  /// FAQ question about improving assistant responses
  ///
  /// In en, this message translates to:
  /// **'How do I get better answers?'**
  String get assistantFaqQuestionImproveResults;

  /// FAQ answer with tips for better assistant queries
  ///
  /// In en, this message translates to:
  /// **'Be specific—mention time ranges, accounts, or categories. Combine quick filters above the chat for extra context.'**
  String get assistantFaqAnswerImproveResults;
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
