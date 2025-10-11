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
  /// **'Upcoming payments'**
  String get profileUpcomingPaymentsCta;

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

  /// Tab label for beauty-related icons
  ///
  /// In en, this message translates to:
  /// **'Beauty & care'**
  String get manageCategoriesIconGroupBeauty;

  /// Tab label for health and wellness icons
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get manageCategoriesIconGroupHealth;

  /// Tab label for dedicated sports icons
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get manageCategoriesIconGroupSports;

  /// Tab label for maintenance and household icons
  ///
  /// In en, this message translates to:
  /// **'Repairs & chores'**
  String get manageCategoriesIconGroupMaintenance;

  /// Tab label for electronics and gadget icons
  ///
  /// In en, this message translates to:
  /// **'Tech & gadgets'**
  String get manageCategoriesIconGroupTech;

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
  /// **'Income this month'**
  String get homeAccountMonthlyIncomeLabel;

  /// Label for monthly expenses shown on the home screen account card
  ///
  /// In en, this message translates to:
  /// **'Expense this month'**
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
  /// **'Upcoming payments'**
  String get homeUpcomingPaymentsTitle;

  /// Empty state when there are no upcoming payments
  ///
  /// In en, this message translates to:
  /// **'Nothing here.'**
  String get homeUpcomingPaymentsEmpty;

  /// Subtitle shown when no upcoming payment is scheduled
  ///
  /// In en, this message translates to:
  /// **'No upcoming payments'**
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
  /// **'Couldn\'t load upcoming payments: {error}'**
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
  /// **'{count, plural, =0 {No scheduled payments} one {# upcoming payment} other {# upcoming payments}}'**
  String homeUpcomingPaymentsCountSemantics(int count);

  /// Button label that opens the upcoming payments screen from the home widget
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get homeUpcomingPaymentsMore;

  /// Title for the upcoming payments screen
  ///
  /// In en, this message translates to:
  /// **'Upcoming payments'**
  String get upcomingPaymentsTitle;

  /// Tab label for recurring payment rules
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get upcomingPaymentsTabPayments;

  /// Tab label for manual payment reminders
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get upcomingPaymentsTabReminders;

  /// Headline for empty state of the payment rules list
  ///
  /// In en, this message translates to:
  /// **'No payment rules yet'**
  String get upcomingPaymentsEmptyPaymentsTitle;

  /// Description for empty state of the payment rules list
  ///
  /// In en, this message translates to:
  /// **'Create automated payment rules to keep bills under control.'**
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
  /// **'Add payment'**
  String get upcomingPaymentsAddPayment;

  /// Action label for creating a new payment reminder
  ///
  /// In en, this message translates to:
  /// **'Add reminder'**
  String get upcomingPaymentsAddReminder;

  /// Title for the create payment form
  ///
  /// In en, this message translates to:
  /// **'New payment'**
  String get upcomingPaymentsNewPaymentTitle;

  /// Title for the edit payment form
  ///
  /// In en, this message translates to:
  /// **'Edit payment'**
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

  /// Label for reminder completion switch
  ///
  /// In en, this message translates to:
  /// **'Mark as done'**
  String get upcomingPaymentsFieldReminderCompleted;

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
  /// **'Upcoming payment saved'**
  String get upcomingPaymentsSaveSuccess;

  /// Snackbar message shown when a reminder is saved
  ///
  /// In en, this message translates to:
  /// **'Reminder saved'**
  String get upcomingPaymentsReminderSaveSuccess;

  /// Error message shown when saving a payment rule fails
  ///
  /// In en, this message translates to:
  /// **'Failed to save payment: {error}'**
  String upcomingPaymentsSaveError(String error);

  /// Error message shown when saving a reminder fails
  ///
  /// In en, this message translates to:
  /// **'Failed to save reminder: {error}'**
  String upcomingPaymentsReminderSaveError(String error);

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
  /// **'Add an account to schedule payments.'**
  String get upcomingPaymentsNoAccounts;

  /// Message shown when there are no categories available
  ///
  /// In en, this message translates to:
  /// **'Create a category to schedule payments.'**
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
  /// **'Saving goals'**
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

  /// Bottom navigation label for savings
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get homeNavSavings;

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

  /// Label for the time picker
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get addTransactionTimeLabel;

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
