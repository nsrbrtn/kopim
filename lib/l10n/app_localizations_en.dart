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
  String get profileRegisterCta => 'Register';

  @override
  String get profileRegisterHint =>
      'Create an account to keep your data safe and enable synchronization across devices.';

  @override
  String get profileSectionAccount => 'Account';

  @override
  String get profileAppearanceSection => 'Appearance';

  @override
  String get profileGeneralSettingsTitle => 'General settings';

  @override
  String get profileGeneralSettingsTooltip => 'General settings';

  @override
  String get profileGeneralSettingsManagementSection => 'Data management';

  @override
  String get profileManageCategoriesCta => 'Manage categories';

  @override
  String get profileUpcomingPaymentsCta => 'Upcoming payments';

  @override
  String get settingsNotificationsExactTitle => 'Exact reminders';

  @override
  String get settingsNotificationsExactSubtitle =>
      'Deliver notifications exactly at the scheduled time.';

  @override
  String settingsNotificationsExactError(String error) {
    return 'Failed to read status: $error';
  }

  @override
  String get settingsNotificationsRetryTooltip => 'Retry status check';

  @override
  String get settingsNotificationsTestCta => 'Send test notification';

  @override
  String get settingsHomeSectionTitle => 'Home screen';

  @override
  String get settingsHomeGamificationTitle => 'Gamification widget';

  @override
  String get settingsHomeGamificationSubtitle =>
      'Show level progress on the home screen.';

  @override
  String get settingsHomeBudgetTitle => 'Budget widget';

  @override
  String get settingsHomeBudgetSubtitle =>
      'Track a selected budget without leaving the home screen.';

  @override
  String get settingsHomeRecurringTitle => 'Recurring widget';

  @override
  String get settingsHomeRecurringSubtitle =>
      'Show upcoming recurring operations on the home screen.';

  @override
  String get settingsHomeSavingsTitle => 'Savings widget';

  @override
  String get settingsHomeSavingsSubtitle =>
      'Keep track of your saving goals without leaving the home screen.';

  @override
  String get settingsHomeBudgetSelectedLabel => 'Selected budget';

  @override
  String get settingsHomeBudgetNoBudgets =>
      'Create a budget to enable this widget.';

  @override
  String get settingsHomeBudgetSelectedNone => 'No budget selected';

  @override
  String settingsHomeBudgetError(String error) {
    return 'Can\'t load budgets: $error';
  }

  @override
  String get settingsHomeBudgetPickerTitle => 'Choose budget';

  @override
  String settingsHomeBudgetPickerSubtitle(String spent, String limit) {
    return '$spent of $limit used';
  }

  @override
  String get settingsHomeBudgetPickerHint =>
      'You can also disable the widget in the list above.';

  @override
  String get settingsHomeBudgetPickerClear => 'Clear selection';

  @override
  String get profileManageCategoriesTitle => 'Manage categories';

  @override
  String get manageCategoriesAddAction => 'Add category';

  @override
  String get manageCategoriesCreateSubAction => 'Create subcategory';

  @override
  String get manageCategoriesAddSubcategoryAction => 'Add subcategory';

  @override
  String get manageCategoriesAddSubcategorySaveFirst =>
      'Save the category before adding subcategories.';

  @override
  String get dialogCancel => 'Cancel';

  @override
  String get dialogConfirm => 'Confirm';

  @override
  String get commonUndo => 'Undo';

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
  String get manageCategoriesIconGroupBeauty => 'Beauty & care';

  @override
  String get manageCategoriesIconGroupHealth => 'Health';

  @override
  String get manageCategoriesIconGroupSports => 'Sports';

  @override
  String get manageCategoriesIconGroupMaintenance => 'Repairs & chores';

  @override
  String get manageCategoriesIconGroupTech => 'Tech & gadgets';

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
  String get manageCategoriesFavoriteLabel => 'Add to favorites';

  @override
  String get manageCategoriesFavoriteSubtitle =>
      'Favorite categories appear at the top when creating transactions.';

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
  String get profileDarkModeLabel => 'Dark mode';

  @override
  String get profileDarkModeDescription => 'Override the app theme.';

  @override
  String get profileThemeHeader => 'Theme';

  @override
  String get profileThemeOptionSystem => 'System default';

  @override
  String get profileThemeOptionLight => 'Light';

  @override
  String get profileThemeOptionDark => 'Dark';

  @override
  String get profileThemeLightDescription => 'Use a bright interface.';

  @override
  String get profileThemeDarkDescription => 'Use a dimmed interface.';

  @override
  String get profileDarkModeSystemCta => 'Use system setting';

  @override
  String get profileDarkModeSystemActive => 'Following system theme';

  @override
  String profileLoadError(String error) {
    return 'Unable to load profile: $error';
  }

  @override
  String get profileUnnamed => 'Explorer';

  @override
  String get profileChangeAvatar => 'Change avatar';

  @override
  String get profileChangeAvatarGallery => 'Choose from gallery';

  @override
  String get profileChangeAvatarCamera => 'Take a photo';

  @override
  String get profileAvatarUploadError =>
      'Couldn\'t update avatar. Please try again.';

  @override
  String get profileAvatarUploadSuccess => 'Avatar updated';

  @override
  String profileLevelBadge(int level, String title) {
    return 'Level $level — $title';
  }

  @override
  String profileXp(int current, int next) {
    return 'XP: $current / $next';
  }

  @override
  String profileXpMax(int current) {
    return 'XP: $current';
  }

  @override
  String profileXpToNext(int count) {
    return '$count XP to the next level';
  }

  @override
  String get profileLevelMaxReached => 'You have reached the highest rank!';

  @override
  String profileProgressError(String error) {
    return 'Unable to load progress: $error';
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
  String get recurringTransactionsEditAction => 'Edit';

  @override
  String get recurringTransactionsDeleteAction => 'Delete';

  @override
  String get recurringTransactionsDeleteDialogTitle => 'Delete recurring rule';

  @override
  String get recurringTransactionsDeleteConfirmation =>
      'Are you sure you want to delete this recurring rule? This action cannot be undone.';

  @override
  String get recurringTransactionsDeleteSuccess => 'Recurring rule deleted.';

  @override
  String get recurringExactAlarmPromptTitle => 'Precise reminders';

  @override
  String get recurringExactAlarmPromptSubtitle =>
      'To trigger auto-posting exactly at 00:01 local time, allow exact alarms for Kopim in Android system settings under \"Alarms & reminders\".';

  @override
  String get recurringExactAlarmPromptCta => 'Open settings';

  @override
  String get recurringExactAlarmEnabledTitle => 'Precise mode is active';

  @override
  String get recurringExactAlarmEnabledSubtitle =>
      'Reminders and auto-posting will run exactly on schedule even in power saving modes.';

  @override
  String get recurringExactAlarmErrorTitle => 'Permission check failed';

  @override
  String recurringExactAlarmErrorSubtitle(String error) {
    return 'Try again: $error';
  }

  @override
  String get recurringExactAlarmRetryCta => 'Retry';

  @override
  String get addRecurringRuleTitle => 'New recurring transaction';

  @override
  String get editRecurringRuleTitle => 'Edit recurring transaction';

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
  String get addRecurringRuleNoteLabel => 'Note';

  @override
  String get addRecurringRuleNoteHint => 'Optional comment';

  @override
  String get addRecurringRuleAccountLabel => 'Account';

  @override
  String get addRecurringRuleAccountRequired => 'Select an account';

  @override
  String get addRecurringRuleCategoryLabel => 'Category';

  @override
  String get addRecurringRuleCategoryRequired => 'Select a category';

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
  String get addRecurringRuleReminderLabel => 'Reminder';

  @override
  String get addRecurringRuleReminderNone => 'No reminder';

  @override
  String get addRecurringRuleReminderAtTime => 'At due time';

  @override
  String addRecurringRuleReminderMinutes(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '# minutes before',
      one: '# minute before',
    );
    return '$_temp0';
  }

  @override
  String addRecurringRuleReminderHours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '# hours before',
      one: '# hour before',
    );
    return '$_temp0';
  }

  @override
  String addRecurringRuleReminderDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '# days before',
      one: '# day before',
    );
    return '$_temp0';
  }

  @override
  String get addRecurringRuleRemindOnceLabel => 'Only once';

  @override
  String get addRecurringRuleRemindOnceSubtitle =>
      'Schedule a single reminder and skip future repeats.';

  @override
  String get addRecurringRuleAutoPostLabel => 'Post automatically';

  @override
  String get addRecurringRuleAutoPostDisabled =>
      'Automatic posting is disabled for one-time reminders.';

  @override
  String get addRecurringRuleNextDuePreviewLabel => 'Next due';

  @override
  String get addRecurringRuleNextDuePreviewUnknown => '—';

  @override
  String get addRecurringRuleSubmit => 'Save rule';

  @override
  String get editRecurringRuleSubmit => 'Save changes';

  @override
  String get addRecurringRuleNoAccounts =>
      'Add an account before creating a recurring rule.';

  @override
  String get addRecurringRuleNoCategories =>
      'Add a category before creating a recurring rule.';

  @override
  String get addRecurringRuleSuccess => 'Recurring transaction saved';

  @override
  String get editRecurringRuleSuccess => 'Recurring rule updated.';

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
  String get signInOfflineCta => 'Work offline';

  @override
  String get signInError => 'Could not sign in. Please try again.';

  @override
  String get signInLoading => 'Signing in...';

  @override
  String get signInOfflineNotice =>
      'You appear to be offline. We will sync your data once you reconnect.';

  @override
  String get signInNoAccountCta => 'Create an account';

  @override
  String get signInAlreadyHaveAccountCta => 'Back to sign in';

  @override
  String get signUpTitle => 'Create your Kopim account';

  @override
  String get signUpSubtitle =>
      'Register to sync your finances securely across devices.';

  @override
  String get signUpSubmitCta => 'Sign up';

  @override
  String get signUpLoading => 'Creating account...';

  @override
  String get signUpError => 'Could not create account. Please try again.';

  @override
  String get signUpConfirmPasswordLabel => 'Confirm password';

  @override
  String get signUpDisplayNameLabel => 'Name (optional)';

  @override
  String get homeTitle => 'Home';

  @override
  String get homeProfileTooltip => 'Profile';

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
  String get homeTransactionsFilterAll => 'All';

  @override
  String get homeTransactionsFilterIncome => 'Income';

  @override
  String get homeTransactionsFilterExpense => 'Expenses';

  @override
  String get homeTransactionsSeeAll => 'All transactions';

  @override
  String get homeTransactionsEmpty => 'No transactions recorded yet.';

  @override
  String homeTransactionsError(String error) {
    return 'Unable to load transactions: $error';
  }

  @override
  String get homeTransactionsUncategorized => 'Uncategorized';

  @override
  String get homeUpcomingPaymentsTitle => 'Upcoming payments';

  @override
  String get homeUpcomingPaymentsEmpty => 'Nothing here.';

  @override
  String get homeUpcomingPaymentsEmptyHeader => 'No upcoming payments';

  @override
  String homeUpcomingPaymentsCollapsedSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'List hidden · $count payments',
      one: 'List hidden · $count payment',
      zero: 'List hidden · no payments',
    );
    return '$_temp0';
  }

  @override
  String get homeUpcomingPaymentsExpand => 'Show list';

  @override
  String get homeUpcomingPaymentsCollapse => 'Hide list';

  @override
  String homeUpcomingPaymentsNextDate(String date) {
    return 'Next due: $date';
  }

  @override
  String homeUpcomingPaymentsError(String error) {
    return 'Couldn\'t load upcoming payments: $error';
  }

  @override
  String get homeUpcomingPaymentsMissingRule =>
      'This recurring rule has been removed.';

  @override
  String homeUpcomingPaymentsDueDate(String date) {
    return 'Due $date';
  }

  @override
  String homeUpcomingPaymentsCountSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# upcoming payments',
      one: '# upcoming payment',
      zero: 'No scheduled payments',
    );
    return '$_temp0';
  }

  @override
  String get homeUpcomingPaymentsMore => 'More';

  @override
  String get homeUpcomingPaymentsBadgePaymentsLabel => 'Payments';

  @override
  String get homeUpcomingPaymentsBadgeRemindersLabel => 'Reminders';

  @override
  String homeUpcomingPaymentsBadgePaymentsSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# upcoming payments',
      one: '# upcoming payment',
      zero: 'No upcoming payments',
    );
    return '$_temp0';
  }

  @override
  String homeUpcomingPaymentsBadgeRemindersSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# reminders',
      one: '# reminder',
      zero: 'No reminders',
    );
    return '$_temp0';
  }

  @override
  String get upcomingPaymentsTitle => 'Upcoming payments';

  @override
  String get upcomingPaymentsTabPayments => 'Payments';

  @override
  String get upcomingPaymentsTabReminders => 'Reminders';

  @override
  String get upcomingPaymentsEmptyPaymentsTitle => 'No payment rules yet';

  @override
  String get upcomingPaymentsEmptyPaymentsDescription =>
      'Create automated payment rules to keep bills under control.';

  @override
  String get upcomingPaymentsEmptyRemindersTitle => 'No reminders yet';

  @override
  String get upcomingPaymentsEmptyRemindersDescription =>
      'Set reminders so you never miss a manual payment.';

  @override
  String get upcomingPaymentsAddPayment => 'Add payment';

  @override
  String get upcomingPaymentsAddReminder => 'Add reminder';

  @override
  String get upcomingPaymentsNewPaymentTitle => 'New payment';

  @override
  String get upcomingPaymentsEditPaymentTitle => 'Edit payment';

  @override
  String get upcomingPaymentsNewReminderTitle => 'New reminder';

  @override
  String get upcomingPaymentsEditReminderTitle => 'Edit reminder';

  @override
  String get upcomingPaymentsFieldTitle => 'Name';

  @override
  String get upcomingPaymentsFieldAccount => 'Account';

  @override
  String get upcomingPaymentsFieldCategory => 'Category';

  @override
  String get upcomingPaymentsFieldAmount => 'Amount';

  @override
  String get upcomingPaymentsFieldDayOfMonth => 'Day of month';

  @override
  String get upcomingPaymentsFieldNotifyDaysBefore => 'Notify days before';

  @override
  String get upcomingPaymentsFieldNotifyTime => 'Notification time';

  @override
  String get upcomingPaymentsFieldAutoPost => 'Post automatically';

  @override
  String get upcomingPaymentsFieldNote => 'Note';

  @override
  String get upcomingPaymentsFieldReminderWhen => 'Date and time';

  @override
  String get upcomingPaymentsSubmit => 'Save';

  @override
  String get upcomingPaymentsCancel => 'Cancel';

  @override
  String get upcomingPaymentsSaveSuccess => 'Upcoming payment saved';

  @override
  String get upcomingPaymentsReminderSaveSuccess => 'Reminder saved';

  @override
  String upcomingPaymentsSaveError(String error) {
    return 'Failed to save payment: $error';
  }

  @override
  String upcomingPaymentsReminderSaveError(String error) {
    return 'Failed to save reminder: $error';
  }

  @override
  String get upcomingPaymentsReminderMarkPaidAction => 'Paid';

  @override
  String get upcomingPaymentsReminderMarkPaidTooltip => 'Mark reminder as paid';

  @override
  String get upcomingPaymentsReminderMarkPaidSuccess =>
      'Reminder marked as paid.';

  @override
  String upcomingPaymentsReminderMarkPaidError(String error) {
    return 'Failed to mark reminder: $error';
  }

  @override
  String get upcomingPaymentsReminderEditAction => 'Edit';

  @override
  String get upcomingPaymentsReminderDeleteAction => 'Delete';

  @override
  String get upcomingPaymentsReminderDeleteTitle => 'Delete reminder?';

  @override
  String upcomingPaymentsReminderDeleteMessage(String title) {
    return 'Delete reminder \"$title\"? This action cannot be undone.';
  }

  @override
  String get upcomingPaymentsReminderDeleteSuccess => 'Reminder deleted.';

  @override
  String upcomingPaymentsReminderDeleteError(String error) {
    return 'Failed to delete reminder: $error';
  }

  @override
  String get upcomingPaymentsEditAction => 'Edit';

  @override
  String get upcomingPaymentsDeleteAction => 'Delete';

  @override
  String get upcomingPaymentsDeleteTitle => 'Delete recurring payment?';

  @override
  String upcomingPaymentsDeleteMessage(String title) {
    return 'Delete \"$title\"? This action cannot be undone.';
  }

  @override
  String get upcomingPaymentsDeleteSuccess => 'Recurring payment deleted.';

  @override
  String upcomingPaymentsDeleteError(String error) {
    return 'Failed to delete recurring payment: $error';
  }

  @override
  String get upcomingPaymentsValidationTitle => 'Enter a name';

  @override
  String get upcomingPaymentsValidationAmount => 'Enter a positive amount';

  @override
  String get upcomingPaymentsValidationDay => 'Day must be between 1 and 31';

  @override
  String get upcomingPaymentsValidationNotifyDays =>
      'Notify days must be zero or greater';

  @override
  String get upcomingPaymentsNoAccounts =>
      'Add an account to schedule payments.';

  @override
  String get upcomingPaymentsNoCategories =>
      'Create a category to schedule payments.';

  @override
  String upcomingPaymentsMonthlySummary(int day) {
    return 'Every month on day $day';
  }

  @override
  String upcomingPaymentsNotifySummary(int days, String time) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days before at $time',
      one: '$days day before at $time',
      zero: 'on the day at $time',
    );
    return 'Notify $_temp0';
  }

  @override
  String upcomingPaymentsReminderDue(String date) {
    return 'Due $date';
  }

  @override
  String upcomingPaymentsListError(String error) {
    return 'Couldn\'t load items: $error';
  }

  @override
  String get upcomingPaymentsNotificationPermissionDenied =>
      'Notifications are disabled. Enable them to receive reminders.';

  @override
  String get upcomingPaymentsScheduleTriggered => 'Background worker queued';

  @override
  String get homeSavingsWidgetTitle => 'Saving goals';

  @override
  String get homeSavingsWidgetEmpty =>
      'Create your first goal to start tracking progress.';

  @override
  String get homeSavingsWidgetViewAll => 'Open savings';

  @override
  String get homeGamificationTitle => 'Level progress';

  @override
  String get homeGamificationSubtitle =>
      'Complete transactions to earn XP and unlock new levels.';

  @override
  String homeGamificationError(String error) {
    return 'Can\'t load progress: $error';
  }

  @override
  String get homeBudgetWidgetTitle => 'Budget overview';

  @override
  String get homeBudgetWidgetEmpty =>
      'Select a budget in settings to track it here.';

  @override
  String get homeBudgetWidgetMissing =>
      'The selected budget is no longer available.';

  @override
  String get homeBudgetWidgetCategoriesEmpty => 'No category breakdown yet.';

  @override
  String get homeBudgetWidgetConfigureCta => 'Open settings';

  @override
  String homeDashboardPreferencesError(String error) {
    return 'Couldn\'t load home widgets: $error';
  }

  @override
  String get homeNavHome => 'Home';

  @override
  String get homeNavAnalytics => 'Analytics';

  @override
  String get homeNavAssistant => 'Assistant';

  @override
  String get homeNavSavings => 'Savings';

  @override
  String get homeNavSettings => 'Settings';

  @override
  String get mainNavigationExitTitle => 'Exit Kopim?';

  @override
  String get mainNavigationExitMessage => 'Do you want to close the app?';

  @override
  String get mainNavigationExitConfirm => 'Exit';

  @override
  String get mainNavigationExitCancel => 'Stay';

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
  String get analyticsTopCategoriesTitle => 'Top categories';

  @override
  String get analyticsTopCategoriesExpensesTab => 'Expenses';

  @override
  String get analyticsTopCategoriesIncomeTab => 'Income';

  @override
  String get analyticsTopCategoriesOthers => 'Others';

  @override
  String get analyticsChartTypeLabel => 'Chart type';

  @override
  String get analyticsChartTypeDonut => 'Donut';

  @override
  String get analyticsChartTypeBar => 'Bar';

  @override
  String get analyticsTopCategoriesEmpty =>
      'Not enough data to show category trends yet.';

  @override
  String analyticsTopCategoriesTapHint(String amount) {
    return 'Tap a category to view totals · Total $amount';
  }

  @override
  String get analyticsCategoryUncategorized => 'Uncategorized';

  @override
  String analyticsOverviewRangeTitle(String range) {
    return 'Overview for $range';
  }

  @override
  String get analyticsFiltersButtonLabel => 'Filters';

  @override
  String analyticsFiltersBadgeSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# active filters',
      one: '# active filter',
      zero: 'No active filters',
    );
    return '$_temp0';
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
  String get transactionXpGained => '+1 XP';

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
  String get addTransactionUndoSuccess => 'Transaction removed.';

  @override
  String get addTransactionUndoError => 'Couldn\'t undo the transaction.';

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
  String get addAccountTypeCustom => 'Custom type';

  @override
  String get addAccountCustomTypeLabel => 'Custom account type';

  @override
  String get addAccountTypeRequired => 'Please specify the account type.';

  @override
  String get accountPrimaryToggleLabel => 'Set as primary account';

  @override
  String get accountPrimaryToggleSubtitle =>
      'This account will be selected by default for new transactions.';

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
  String get editAccountTypeCustom => 'Custom type';

  @override
  String get editAccountCustomTypeLabel => 'Custom account type';

  @override
  String get editAccountTypeRequired => 'Please specify the account type.';

  @override
  String get editAccountSaveCta => 'Save changes';

  @override
  String get editAccountNameRequired => 'Please enter the account name.';

  @override
  String get editAccountBalanceInvalid => 'Enter a valid amount.';

  @override
  String get editAccountGenericError =>
      'Could not update account. Please try again.';

  @override
  String get editAccountDeleteCta => 'Delete account';

  @override
  String get editAccountDeleteLoading => 'Deleting...';

  @override
  String get editAccountDeleteConfirmationTitle => 'Delete account?';

  @override
  String get editAccountDeleteConfirmationMessage =>
      'This account and its data will be removed. This action cannot be undone.';

  @override
  String get editAccountDeleteConfirmationCancel => 'Cancel';

  @override
  String get editAccountDeleteConfirmationConfirm => 'Delete';

  @override
  String get editAccountDeleteError =>
      'Failed to delete the account. Please try again.';

  @override
  String get homeNavBudgets => 'Budgets';

  @override
  String get budgetsTitle => 'Budgets';

  @override
  String get budgetsCategoryChartTitle => 'Spending by category';

  @override
  String get budgetsCategoryBreakdownTitle => 'Budget categories';

  @override
  String get budgetsEmptyTitle => 'No budgets yet';

  @override
  String get budgetsEmptyMessage =>
      'Create your first budget to track spending and stay on target.';

  @override
  String get budgetsErrorTitle => 'Couldn\'t load budgets';

  @override
  String get budgetsSpentLabel => 'Spent';

  @override
  String get budgetsLimitLabel => 'Limit';

  @override
  String get budgetsRemainingLabel => 'Remaining';

  @override
  String get budgetsExceededLabel => 'Over';

  @override
  String get budgetDetailTitle => 'Budget details';

  @override
  String get budgetDeleteTitle => 'Delete budget?';

  @override
  String get budgetDeleteMessage =>
      'This budget and its history will be removed. This action cannot be undone.';

  @override
  String budgetPeriodLabel(String start, String end) {
    return 'Period: $start – $end';
  }

  @override
  String get budgetTransactionsTitle => 'Transactions';

  @override
  String get budgetTransactionsEmpty =>
      'No transactions match this budget yet.';

  @override
  String get budgetCreateTitle => 'Create budget';

  @override
  String get budgetEditTitle => 'Edit budget';

  @override
  String get budgetTitleLabel => 'Budget title';

  @override
  String get budgetAmountLabel => 'Limit amount';

  @override
  String get budgetAmountAutoHelper =>
      'Total is calculated from category limits.';

  @override
  String get budgetPeriodLabelShort => 'Period';

  @override
  String get budgetScopeLabel => 'Scope';

  @override
  String get budgetStartDateLabel => 'Start date';

  @override
  String get budgetEndDateLabel => 'End date';

  @override
  String get budgetCategoriesLabel => 'Categories';

  @override
  String get budgetCategoryAllocationsTitle => 'Category limits';

  @override
  String budgetCategoryLimitLabel(String category) {
    return '$category limit';
  }

  @override
  String get budgetAccountsLabel => 'Accounts';

  @override
  String get budgetPeriodMonthly => 'Monthly';

  @override
  String get budgetPeriodWeekly => 'Weekly';

  @override
  String get budgetPeriodCustom => 'Custom range';

  @override
  String get budgetScopeAll => 'All transactions';

  @override
  String get budgetScopeByCategory => 'Selected categories';

  @override
  String get budgetScopeByAccount => 'Selected accounts';

  @override
  String get budgetErrorInvalidAmount => 'Enter a positive amount.';

  @override
  String get budgetErrorInvalidCategoryAmount =>
      'Enter a positive limit for each selected category.';

  @override
  String get budgetErrorMissingTitle => 'Enter a title for the budget.';

  @override
  String get budgetNoEndDateLabel => 'No end date';

  @override
  String get editButtonLabel => 'Edit';

  @override
  String get deleteButtonLabel => 'Delete';

  @override
  String get cancelButtonLabel => 'Cancel';

  @override
  String get saveButtonLabel => 'Save';

  @override
  String get savingsTitle => 'Savings goals';

  @override
  String get savingsAddGoalTitle => 'New goal';

  @override
  String get savingsEditGoalTitle => 'Edit goal';

  @override
  String get savingsNameLabel => 'Name';

  @override
  String get savingsTargetLabel => 'Target amount';

  @override
  String get savingsTargetHelper => 'Enter the desired total amount';

  @override
  String get savingsNoteLabel => 'Note';

  @override
  String get savingsSaveGoalButton => 'Save goal';

  @override
  String get savingsGoalSavedMessage => 'Goal saved';

  @override
  String get savingsAddGoalButton => 'Create goal';

  @override
  String get savingsEmptyTitle => 'Create your first savings goal';

  @override
  String get savingsEmptyMessage =>
      'Track progress towards your targets and stay motivated.';

  @override
  String get savingsErrorTitle => 'Unable to load savings goals';

  @override
  String get savingsRetryButton => 'Try again';

  @override
  String get savingsContributeAction => 'Contribute';

  @override
  String get savingsEditAction => 'Edit';

  @override
  String get savingsArchiveAction => 'Archive';

  @override
  String savingsGoalArchivedMessage(String goal) {
    return 'Goal \"$goal\" archived';
  }

  @override
  String get savingsArchivedBadge => 'Archived';

  @override
  String savingsRemainingLabel(String amount) {
    return 'Remaining $amount';
  }

  @override
  String get savingsShowArchivedToggle => 'Show archived goals';

  @override
  String savingsContributeTitle(String goal) {
    return 'Contribute to $goal';
  }

  @override
  String get savingsAmountLabel => 'Amount';

  @override
  String get savingsSourceAccountLabel => 'Source account';

  @override
  String get savingsNoAccountOption => 'No account';

  @override
  String get savingsContributionNoteLabel => 'Note (optional)';

  @override
  String get savingsSubmitContributionButton => 'Add contribution';

  @override
  String get savingsContributionSuccess => 'Contribution added';

  @override
  String get savingsGoalDetailsTitle => 'Savings goal';

  @override
  String get savingsGoalDetailsEditTooltip => 'Edit goal';

  @override
  String get savingsGoalDetailsNotFound => 'This savings goal is unavailable.';

  @override
  String get savingsGoalDetailsSummaryTitle => 'Progress overview';

  @override
  String savingsGoalDetailsCurrentLabel(String amount) {
    return 'Current: $amount';
  }

  @override
  String savingsGoalDetailsTargetLabel(String amount) {
    return 'Target: $amount';
  }

  @override
  String get savingsGoalDetailsNoContributions => 'No contributions yet';

  @override
  String savingsGoalDetailsLastContribution(String date) {
    return 'Last contribution on $date';
  }

  @override
  String savingsGoalDetailsTransactionsCount(int count) {
    return 'Transactions linked: $count';
  }

  @override
  String get savingsGoalDetailsAnalyticsTitle => 'Account analytics';

  @override
  String get savingsGoalDetailsAnalyticsEmpty =>
      'Link transactions to this goal to see category analytics.';

  @override
  String savingsGoalDetailsAnalyticsTotal(String amount) {
    return 'Total contributions: $amount';
  }

  @override
  String get transactionDefaultTitle => 'Transaction';

  @override
  String get allTransactionsTitle => 'All transactions';

  @override
  String get allTransactionsFiltersTitle => 'Transaction filters';

  @override
  String get allTransactionsFiltersDate => 'Period';

  @override
  String get allTransactionsFiltersDateAny => 'Any date';

  @override
  String get allTransactionsFiltersAccount => 'Account';

  @override
  String get allTransactionsFiltersAccountAny => 'All accounts';

  @override
  String get allTransactionsFiltersCategory => 'Category';

  @override
  String get allTransactionsFiltersCategoryAny => 'All categories';

  @override
  String get allTransactionsFiltersLoading => 'Loading…';

  @override
  String get allTransactionsFiltersClear => 'Reset filters';

  @override
  String get allTransactionsEmpty =>
      'No transactions match the selected filters.';

  @override
  String allTransactionsError(String error) {
    return 'Failed to load transactions: $error';
  }

  @override
  String get assistantScreenTitle => 'AI Assistant';

  @override
  String get assistantInputHint => 'Ask about your finances…';

  @override
  String get assistantQuickActionsTitle => 'Quick requests';

  @override
  String get assistantQuickActionSpendingLabel => 'Spending summary';

  @override
  String get assistantQuickActionSpendingPrompt =>
      'Give me a spending summary for this month.';

  @override
  String get assistantQuickActionBudgetLabel => 'Budget health';

  @override
  String get assistantQuickActionBudgetPrompt =>
      'Do I stay within my budgets this month?';

  @override
  String get assistantQuickActionSavingsLabel => 'Savings trends';

  @override
  String get assistantQuickActionSavingsPrompt =>
      'How are my savings growing lately?';

  @override
  String get assistantFiltersTitle => 'Focus';

  @override
  String get assistantFilterCurrentMonth => 'This month';

  @override
  String get assistantFilterLast30Days => 'Last 30 days';

  @override
  String get assistantFilterBudgets => 'Budgets';

  @override
  String get assistantEmptyStateTitle => 'Start a conversation';

  @override
  String get assistantEmptyStateSubtitle =>
      'Use quick requests or ask your own question.';

  @override
  String get assistantOfflineBanner =>
      'You\'re offline. We\'ll send your questions once the connection is back.';

  @override
  String get assistantRetryButton => 'Retry now';

  @override
  String get assistantPendingMessageHint =>
      'Will send when you\'re back online.';

  @override
  String get assistantSendingMessageHint => 'Sending…';

  @override
  String get assistantFailedMessageHint => 'Not delivered. Tap retry.';

  @override
  String get assistantGenericError =>
      'We couldn\'t reach the assistant. Try again soon.';

  @override
  String get assistantNetworkError =>
      'Connection lost. We\'ll retry automatically.';

  @override
  String get assistantTimeoutError =>
      'The assistant is taking longer than expected. Try again.';

  @override
  String get assistantRateLimitError =>
      'You\'ve hit the OpenRouter request limit. Wait a moment and try again.';

  @override
  String get assistantServerError =>
      'OpenRouter (DeepSeek) is temporarily unavailable. Your message stays here so you can retry soon.';

  @override
  String get assistantDisabledError =>
      'The assistant is currently disabled by the team. Please try again later.';

  @override
  String get assistantConfigurationError =>
      'Assistant configuration is missing. Refresh the app or contact support.';

  @override
  String get assistantStreamingPlaceholder =>
      'Assistant is preparing a response…';

  @override
  String get assistantMessageCopied => 'Message copied';

  @override
  String get assistantOnboardingTitle => 'Get started with the assistant';

  @override
  String get assistantOnboardingDescription =>
      'Ask about budgets, spending trends, or savings goals to get tailored insights.';

  @override
  String get assistantOnboardingFeatureInsights =>
      'Break down spending by category and period in seconds.';

  @override
  String get assistantOnboardingFeatureBudgets =>
      'Check how close you are to each budget and get warnings before overspending.';

  @override
  String get assistantOnboardingFeatureSavings =>
      'Discover opportunities to accelerate your savings plans.';

  @override
  String get assistantOnboardingLimitationsTitle => 'Keep in mind';

  @override
  String get assistantOnboardingLimitationDataFreshness =>
      'Works with the latest synced data—sync offline transactions to include them.';

  @override
  String get assistantOnboardingLimitationSecurity =>
      'Stays inside Kopim: no data is shared outside your account.';

  @override
  String get assistantOnboardingLimitationAccuracy =>
      'Treat answers as guidance and double-check totals in detailed reports.';

  @override
  String get assistantFaqTitle => 'FAQ';

  @override
  String get assistantFaqQuestionDataSources =>
      'Where does the assistant get its data?';

  @override
  String get assistantFaqAnswerDataSources =>
      'It uses the same Drift database and Firebase sync as the app, so answers reflect your real accounts, budgets, and transactions.';

  @override
  String get assistantFaqQuestionLimits =>
      'Why do I see rate limit or temporary errors?';

  @override
  String get assistantFaqAnswerLimits =>
      'OpenRouter occasionally limits traffic. Wait a little before retrying or send a more focused request to stay within the quota.';

  @override
  String get assistantFaqQuestionImproveResults =>
      'How do I get better answers?';

  @override
  String get assistantFaqAnswerImproveResults =>
      'Be specific—mention time ranges, accounts, or categories. Combine quick filters above the chat for extra context.';
}
