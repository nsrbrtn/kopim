// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get profileTitle => 'Профиль';

  @override
  String get profileSignInPrompt =>
      'Пожалуйста, войдите, чтобы управлять профилем.';

  @override
  String get profileSectionAccount => 'Учетная запись';

  @override
  String get profileAppearanceSection => 'Внешний вид';

  @override
  String get profileGeneralSettingsTitle => 'Общие настройки';

  @override
  String get profileGeneralSettingsTooltip => 'Общие настройки';

  @override
  String get profileGeneralSettingsManagementSection => 'Управление данными';

  @override
  String get profileManageCategoriesCta => 'Управлять категориями';

  @override
  String get profileRecurringTransactionsCta => 'Повторяющиеся операции';

  @override
  String get settingsHomeSectionTitle => 'Домашний экран';

  @override
  String get settingsHomeGamificationTitle => 'Виджет геймификации';

  @override
  String get settingsHomeGamificationSubtitle =>
      'Показывать прогресс уровня на главном экране.';

  @override
  String get settingsHomeBudgetTitle => 'Виджет бюджета';

  @override
  String get settingsHomeBudgetSubtitle =>
      'Отслеживайте выбранный бюджет прямо на главном экране.';

  @override
  String get settingsHomeRecurringTitle => 'Виджет повторяющихся операций';

  @override
  String get settingsHomeRecurringSubtitle =>
      'Показывать ближайшие повторяющиеся операции на главном экране.';

  @override
  String get settingsHomeSavingsTitle => 'Виджет накоплений';

  @override
  String get settingsHomeSavingsSubtitle =>
      'Следите за целями накоплений прямо с домашнего экрана.';

  @override
  String get settingsHomeBudgetSelectedLabel => 'Выбранный бюджет';

  @override
  String get settingsHomeBudgetNoBudgets =>
      'Создайте бюджет, чтобы включить виджет.';

  @override
  String get settingsHomeBudgetSelectedNone => 'Бюджет не выбран';

  @override
  String settingsHomeBudgetError(String error) {
    return 'Не удалось загрузить бюджеты: $error';
  }

  @override
  String get settingsHomeBudgetPickerTitle => 'Выберите бюджет';

  @override
  String settingsHomeBudgetPickerSubtitle(String spent, String limit) {
    return 'Использовано $spent из $limit';
  }

  @override
  String get settingsHomeBudgetPickerHint =>
      'Виджет можно отключить переключателем выше.';

  @override
  String get settingsHomeBudgetPickerClear => 'Сбросить выбор';

  @override
  String get profileManageCategoriesTitle => 'Управление категориями';

  @override
  String get manageCategoriesAddAction => 'Добавить категорию';

  @override
  String get manageCategoriesCreateSubAction => 'Создать подкатегорию';

  @override
  String get dialogCancel => 'Отмена';

  @override
  String get dialogConfirm => 'Готово';

  @override
  String get manageCategoriesParentLabel => 'Родительская категория';

  @override
  String get manageCategoriesParentNone => 'Без родителя';

  @override
  String get manageCategoriesNoSubcategories => 'Подкатегорий пока нет';

  @override
  String get manageCategoriesEditAction => 'Редактировать';

  @override
  String get manageCategoriesEmpty =>
      'Категории пока не созданы. Добавьте первую.';

  @override
  String manageCategoriesListError(String error) {
    return 'Не удалось загрузить категории: $error';
  }

  @override
  String get manageCategoriesCreateTitle => 'Новая категория';

  @override
  String get manageCategoriesEditTitle => 'Редактирование категории';

  @override
  String get manageCategoriesNameLabel => 'Название';

  @override
  String get manageCategoriesNameRequired => 'Введите название.';

  @override
  String get manageCategoriesTypeLabel => 'Тип';

  @override
  String get manageCategoriesTypeExpense => 'Расход';

  @override
  String get manageCategoriesTypeIncome => 'Доход';

  @override
  String get manageCategoriesIconLabel => 'Иконка';

  @override
  String get manageCategoriesIconNone => 'Иконка не выбрана';

  @override
  String get manageCategoriesIconSelected => 'Иконка выбрана';

  @override
  String get manageCategoriesIconSelect => 'Выбрать иконку';

  @override
  String get manageCategoriesIconPickerTitle => 'Выбор иконки категории';

  @override
  String get manageCategoriesIconClear => 'Очистить выбор';

  @override
  String get manageCategoriesIconEmpty => 'Доступные иконки отсутствуют.';

  @override
  String get manageCategoriesIconStyleThin => 'Тонкая';

  @override
  String get manageCategoriesIconStyleLight => 'Легкая';

  @override
  String get manageCategoriesIconStyleRegular => 'Обычная';

  @override
  String get manageCategoriesIconStyleBold => 'Жирная';

  @override
  String get manageCategoriesIconStyleFill => 'Заливка';

  @override
  String get manageCategoriesIconGroupFinance => 'Финансы и работа';

  @override
  String get manageCategoriesIconGroupShopping => 'Покупки и одежда';

  @override
  String get manageCategoriesIconGroupFood => 'Еда и кафе';

  @override
  String get manageCategoriesIconGroupTransport => 'Транспорт и поездки';

  @override
  String get manageCategoriesIconGroupHome => 'Дом и быт';

  @override
  String get manageCategoriesIconGroupLeisure => 'Развлечения и спорт';

  @override
  String get manageCategoriesColorLabel => 'Цвет';

  @override
  String get manageCategoriesColorNone => 'Цвет не выбран';

  @override
  String get manageCategoriesColorSelected => 'Цвет выбран';

  @override
  String get manageCategoriesColorSelect => 'Выбрать цвет';

  @override
  String get manageCategoriesColorClear => 'Очистить цвет';

  @override
  String get manageCategoriesColorPickerTitle => 'Выберите цвет категории';

  @override
  String get manageCategoriesSaveCta => 'Сохранить категорию';

  @override
  String manageCategoriesSaveError(String error) {
    return 'Не удалось сохранить категорию: $error';
  }

  @override
  String get manageCategoriesSuccessCreate => 'Категория успешно создана.';

  @override
  String get manageCategoriesSuccessUpdate => 'Категория обновлена.';

  @override
  String get manageCategoriesDeleteAction => 'Удалить';

  @override
  String get manageCategoriesDeleteConfirmTitle => 'Удалить категорию';

  @override
  String manageCategoriesDeleteConfirmMessage(String name) {
    return 'Вы действительно хотите удалить категорию «$name»? Все подкатегории также будут удалены.';
  }

  @override
  String get manageCategoriesDeleteSuccess => 'Категория удалена.';

  @override
  String manageCategoriesDeleteError(String error) {
    return 'Не удалось удалить категорию: $error';
  }

  @override
  String get profileNameLabel => 'Имя';

  @override
  String get profileCurrencyLabel => 'Валюта по умолчанию';

  @override
  String get profileLocaleLabel => 'Предпочитаемый язык';

  @override
  String get profileDarkModeLabel => 'Тёмная тема';

  @override
  String get profileDarkModeDescription =>
      'Переключите, чтобы управлять темой приложения вручную.';

  @override
  String get profileThemeHeader => 'Оформление';

  @override
  String get profileThemeOptionSystem => 'Системная';

  @override
  String get profileThemeOptionLight => 'Светлая';

  @override
  String get profileThemeOptionDark => 'Тёмная';

  @override
  String get profileThemeLightDescription => 'Использовать светлое оформление.';

  @override
  String get profileThemeDarkDescription => 'Использовать тёмное оформление.';

  @override
  String get profileDarkModeSystemCta => 'Использовать системную настройку';

  @override
  String get profileDarkModeSystemActive => 'Следуем системной теме';

  @override
  String profileLoadError(String error) {
    return 'Не удалось загрузить профиль: $error';
  }

  @override
  String get profileUnnamed => 'Исследователь';

  @override
  String get profileChangeAvatar => 'Сменить аватар';

  @override
  String get profileChangeAvatarGallery => 'Выбрать из галереи';

  @override
  String get profileChangeAvatarCamera => 'Сделать фото';

  @override
  String get profileAvatarUploadError =>
      'Не удалось обновить аватар. Попробуйте ещё раз.';

  @override
  String get profileAvatarUploadSuccess => 'Аватар обновлён';

  @override
  String profileLevelBadge(int level, String title) {
    return 'Уровень $level — $title';
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
    return 'До следующего уровня: $count XP';
  }

  @override
  String get profileLevelMaxReached => 'Вы достигли максимального ранга!';

  @override
  String profileProgressError(String error) {
    return 'Не удалось загрузить прогресс: $error';
  }

  @override
  String get profileSaveCta => 'Сохранить изменения';

  @override
  String get profileSignOutCta => 'Выйти из аккаунта';

  @override
  String get recurringTransactionsTitle => 'Повторяющиеся операции';

  @override
  String get recurringTransactionsEmpty =>
      'Пока нет повторяющихся операций. Создайте правило, чтобы автоматизировать движение средств.';

  @override
  String get recurringTransactionsNextDue => 'Ближайшая дата';

  @override
  String get recurringTransactionsNoUpcoming => 'Нет предстоящих операций';

  @override
  String get recurringTransactionsEditAction => 'Редактировать';

  @override
  String get recurringTransactionsDeleteAction => 'Удалить';

  @override
  String get recurringTransactionsDeleteDialogTitle => 'Удалить правило';

  @override
  String get recurringTransactionsDeleteConfirmation =>
      'Вы уверены, что хотите удалить это правило повторяющейся операции? Это действие нельзя отменить.';

  @override
  String get recurringTransactionsDeleteSuccess => 'Правило удалено.';

  @override
  String get recurringExactAlarmPromptTitle => 'Точный режим напоминаний';

  @override
  String get recurringExactAlarmPromptSubtitle =>
      'Чтобы автосписания запускались ровно в 00:01 по локальному времени, разрешите приложению точные будильники в системном разделе \"Будильники и напоминания\".';

  @override
  String get recurringExactAlarmPromptCta => 'Открыть настройки';

  @override
  String get recurringExactAlarmEnabledTitle => 'Точный режим включён';

  @override
  String get recurringExactAlarmEnabledSubtitle =>
      'Напоминания и автосписания выполнятся ровно по расписанию даже в режиме энергосбережения.';

  @override
  String get recurringExactAlarmErrorTitle => 'Не удалось проверить разрешение';

  @override
  String recurringExactAlarmErrorSubtitle(String error) {
    return 'Повторите попытку: $error';
  }

  @override
  String get recurringExactAlarmRetryCta => 'Повторить';

  @override
  String get addRecurringRuleTitle => 'Новая повторяющаяся операция';

  @override
  String get editRecurringRuleTitle => 'Редактирование повторяющейся операции';

  @override
  String get addRecurringRuleNameLabel => 'Название';

  @override
  String get addRecurringRuleTitleRequired => 'Введите название';

  @override
  String get addRecurringRuleAmountLabel => 'Сумма';

  @override
  String get addRecurringRuleAmountHint => '0,00';

  @override
  String get addRecurringRuleAmountInvalid => 'Введите положительную сумму';

  @override
  String get addRecurringRuleNoteLabel => 'Заметка';

  @override
  String get addRecurringRuleNoteHint => 'Например: напомнить себе';

  @override
  String get addRecurringRuleAccountLabel => 'Счёт';

  @override
  String get addRecurringRuleAccountRequired => 'Выберите счёт';

  @override
  String get addRecurringRuleCategoryLabel => 'Категория';

  @override
  String get addRecurringRuleCategoryRequired => 'Выберите категорию';

  @override
  String get addRecurringRuleTypeLabel => 'Тип';

  @override
  String get addRecurringRuleTypeExpense => 'Расход';

  @override
  String get addRecurringRuleTypeIncome => 'Доход';

  @override
  String get addRecurringRuleStartDateLabel => 'Дата начала';

  @override
  String get addRecurringRuleStartTimeLabel => 'Время выполнения';

  @override
  String get addRecurringRuleReminderLabel => 'Напоминание';

  @override
  String get addRecurringRuleReminderNone => 'Без напоминания';

  @override
  String get addRecurringRuleReminderAtTime => 'В момент платежа';

  @override
  String addRecurringRuleReminderMinutes(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'За # минуты до',
      many: 'За # минут до',
      few: 'За # минуты до',
      one: 'За # минуту до',
    );
    return '$_temp0';
  }

  @override
  String addRecurringRuleReminderHours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: 'За # часа до',
      many: 'За # часов до',
      few: 'За # часа до',
      one: 'За # час до',
    );
    return '$_temp0';
  }

  @override
  String addRecurringRuleReminderDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'За # дня до',
      many: 'За # дней до',
      few: 'За # дня до',
      one: 'За # день до',
    );
    return '$_temp0';
  }

  @override
  String get addRecurringRuleRemindOnceLabel => 'Только один раз';

  @override
  String get addRecurringRuleRemindOnceSubtitle =>
      'Создать одно напоминание и не повторять автоматически.';

  @override
  String get addRecurringRuleAutoPostLabel => 'Проводить автоматически';

  @override
  String get addRecurringRuleAutoPostDisabled =>
      'Автопроведение недоступно для одноразовых напоминаний.';

  @override
  String get addRecurringRuleNextDuePreviewLabel => 'Ближайшая дата';

  @override
  String get addRecurringRuleNextDuePreviewUnknown => '—';

  @override
  String get addRecurringRuleSubmit => 'Сохранить правило';

  @override
  String get editRecurringRuleSubmit => 'Сохранить изменения';

  @override
  String get addRecurringRuleNoAccounts =>
      'Сначала добавьте счёт, чтобы создать повторяющееся правило.';

  @override
  String get addRecurringRuleNoCategories =>
      'Сначала добавьте категорию, чтобы создать повторяющееся правило.';

  @override
  String get addRecurringRuleSuccess => 'Повторяющаяся операция сохранена';

  @override
  String get editRecurringRuleSuccess => 'Правило обновлено.';

  @override
  String get commonComingSoon => 'Скоро появится';

  @override
  String get genericErrorMessage => 'Что-то пошло не так. Попробуйте позже.';

  @override
  String get signInTitle => 'Добро пожаловать в Kopim';

  @override
  String get signInSubtitle =>
      'Войдите, чтобы синхронизировать финансы на всех устройствах.';

  @override
  String get signInEmailLabel => 'Email';

  @override
  String get signInPasswordLabel => 'Пароль';

  @override
  String get signInSubmitCta => 'Войти';

  @override
  String get signInGoogleCta => 'Продолжить с Google';

  @override
  String get signInOfflineCta => 'Войти без учетной записи';

  @override
  String get signInError => 'Не удалось выполнить вход. Попробуйте еще раз.';

  @override
  String get signInLoading => 'Выполняется вход...';

  @override
  String get signInOfflineNotice =>
      'Похоже, что вы офлайн. Мы синхронизируем данные, как только подключитесь.';

  @override
  String get homeTitle => 'Домашний экран';

  @override
  String get homeProfileTooltip => 'Профиль';

  @override
  String homeTotalBalance(String amount) {
    return 'Суммарный баланс: $amount';
  }

  @override
  String homeAuthError(String error) {
    return 'Ошибка авторизации: $error';
  }

  @override
  String get homeAccountsSection => 'Счета';

  @override
  String get homeAccountsEmpty =>
      'Счета еще не добавлены. Создайте первый счет, чтобы отслеживать баланс.';

  @override
  String homeAccountsError(String error) {
    return 'Не удалось загрузить счета: $error';
  }

  @override
  String homeAccountType(String type) {
    return 'Тип: $type';
  }

  @override
  String get homeAccountMonthlyIncomeLabel => 'Доход за месяц';

  @override
  String get homeAccountMonthlyExpenseLabel => 'Расход за месяц';

  @override
  String get homeTransactionsTodayLabel => 'Сегодня';

  @override
  String get homeTransactionsYesterdayLabel => 'Вчера';

  @override
  String get accountTypeCash => 'Наличные';

  @override
  String get accountTypeCard => 'Карта';

  @override
  String get accountTypeBank => 'Банковский счёт';

  @override
  String get accountTypeOther => 'Другое';

  @override
  String get homeTransactionsSection => 'Последние транзакции';

  @override
  String get homeTransactionsFilterAll => 'Все';

  @override
  String get homeTransactionsFilterIncome => 'Доходы';

  @override
  String get homeTransactionsFilterExpense => 'Расходы';

  @override
  String get homeTransactionsSeeAll => 'Все транзакции';

  @override
  String get homeTransactionsEmpty => 'Транзакций пока нет.';

  @override
  String homeTransactionsError(String error) {
    return 'Не удалось загрузить транзакции: $error';
  }

  @override
  String get homeTransactionsUncategorized => 'Без категории';

  @override
  String get homeUpcomingPaymentsTitle => 'Ближайшие платежи';

  @override
  String get homeUpcomingPaymentsEmpty => 'Ничего нет.';

  @override
  String get homeUpcomingPaymentsEmptyHeader => 'Нет ближайших платежей';

  @override
  String homeUpcomingPaymentsNextDate(String date) {
    return 'Ближайшая дата: $date';
  }

  @override
  String homeUpcomingPaymentsError(String error) {
    return 'Не удалось загрузить ближайшие платежи: $error';
  }

  @override
  String get homeUpcomingPaymentsMissingRule => 'Правило удалено.';

  @override
  String homeUpcomingPaymentsDueDate(String date) {
    return 'Срок $date';
  }

  @override
  String homeUpcomingPaymentsCountSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# запланированных платежей',
      many: '# запланированных платежей',
      few: '# запланированных платежа',
      one: '# запланированный платеж',
      zero: 'Нет запланированных платежей',
    );
    return '$_temp0';
  }

  @override
  String get homeSavingsWidgetTitle => 'Цели накоплений';

  @override
  String get homeSavingsWidgetEmpty =>
      'Создайте первую цель, чтобы отслеживать прогресс.';

  @override
  String get homeSavingsWidgetViewAll => 'Открыть накопления';

  @override
  String get homeGamificationTitle => 'Прогресс уровня';

  @override
  String get homeGamificationSubtitle =>
      'Совершайте операции, чтобы получать опыт и повышать уровень.';

  @override
  String homeGamificationError(String error) {
    return 'Не удалось загрузить прогресс: $error';
  }

  @override
  String get homeBudgetWidgetTitle => 'Сводка бюджета';

  @override
  String get homeBudgetWidgetEmpty =>
      'Выберите бюджет в настройках, чтобы отслеживать его здесь.';

  @override
  String get homeBudgetWidgetMissing => 'Выбранный бюджет недоступен.';

  @override
  String get homeBudgetWidgetCategoriesEmpty =>
      'Категорий для анализа пока нет.';

  @override
  String get homeBudgetWidgetConfigureCta => 'Открыть настройки';

  @override
  String homeDashboardPreferencesError(String error) {
    return 'Не удалось загрузить виджеты: $error';
  }

  @override
  String get homeNavHome => 'Главная';

  @override
  String get homeNavAnalytics => 'Аналитика';

  @override
  String get homeNavSavings => 'Накопления';

  @override
  String get homeNavSettings => 'Настройки';

  @override
  String get analyticsTitle => 'Аналитика';

  @override
  String get analyticsComingSoon => 'Скоро здесь появится подробная аналитика.';

  @override
  String get analyticsCurrentMonthTitle => 'Текущий месяц';

  @override
  String get analyticsSummaryIncomeLabel => 'Доходы';

  @override
  String get analyticsSummaryExpenseLabel => 'Расходы';

  @override
  String get analyticsSummaryNetLabel => 'Баланс';

  @override
  String get analyticsTopCategoriesTitle => 'Топ категорий';

  @override
  String get analyticsTopCategoriesExpensesTab => 'Расходы';

  @override
  String get analyticsTopCategoriesIncomeTab => 'Доходы';

  @override
  String get analyticsTopCategoriesOthers => 'Остальные';

  @override
  String get analyticsTopCategoriesEmpty =>
      'Недостаточно данных для анализа категорий.';

  @override
  String get analyticsCategoryUncategorized => 'Без категории';

  @override
  String analyticsOverviewRangeTitle(String range) {
    return 'Обзор за $range';
  }

  @override
  String get analyticsFiltersButtonLabel => 'Фильтры';

  @override
  String analyticsFiltersBadgeSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# активных фильтров',
      many: '# активных фильтров',
      few: '# активных фильтра',
      one: '# активный фильтр',
      zero: 'Нет активных фильтров',
    );
    return '$_temp0';
  }

  @override
  String get analyticsFilterDateLabel => 'Дата';

  @override
  String analyticsFilterDateValue(String start, String end) {
    return '$start – $end';
  }

  @override
  String get analyticsFilterAccountLabel => 'Счёт';

  @override
  String get analyticsFilterAccountAll => 'Все счета';

  @override
  String get analyticsFilterCategoryLabel => 'Категория';

  @override
  String get analyticsFilterCategoryAll => 'Все категории';

  @override
  String get analyticsEmptyState => 'Для выбранных фильтров пока нет данных.';

  @override
  String analyticsLoadError(String error) {
    return 'Не удалось загрузить аналитику: $error';
  }

  @override
  String get addTransactionTitle => 'Новая транзакция';

  @override
  String get addTransactionComingSoon =>
      'Создание транзакции скоро будет доступно.';

  @override
  String get addTransactionAccountLabel => 'Счёт';

  @override
  String get addTransactionAccountRequired => 'Выберите счёт';

  @override
  String addTransactionAccountsError(String error) {
    return 'Не удалось загрузить счета: $error';
  }

  @override
  String get addTransactionNoAccounts =>
      'Сначала создайте счёт, чтобы добавить транзакцию.';

  @override
  String get addTransactionAmountLabel => 'Сумма';

  @override
  String get addTransactionAmountHint => '0,00';

  @override
  String get addTransactionAmountInvalid => 'Введите сумму больше нуля';

  @override
  String get addTransactionTypeLabel => 'Тип';

  @override
  String get addTransactionTypeExpense => 'Расход';

  @override
  String get addTransactionTypeIncome => 'Доход';

  @override
  String get addTransactionCategoryLabel => 'Категория';

  @override
  String get addTransactionCategoryNone => 'Без категории';

  @override
  String get addTransactionCategoriesLoading => 'Загружаем категории…';

  @override
  String addTransactionCategoriesError(String error) {
    return 'Не удалось загрузить категории: $error';
  }

  @override
  String get addTransactionDateLabel => 'Дата';

  @override
  String get addTransactionTimeLabel => 'Время';

  @override
  String get addTransactionNoteLabel => 'Заметка';

  @override
  String get addTransactionSubmit => 'Сохранить';

  @override
  String get addTransactionAccountMissingError =>
      'Выбранный счёт больше не доступен.';

  @override
  String get addTransactionUnknownError =>
      'Не удалось сохранить транзакцию. Попробуйте ещё раз.';

  @override
  String get transactionFormMissingError =>
      'Не удалось найти транзакцию. Обновите данные и попробуйте снова.';

  @override
  String get editTransactionSubmit => 'Сохранить изменения';

  @override
  String get transactionDeleteSuccess => 'Транзакция удалена.';

  @override
  String get transactionXpGained => '+1 XP';

  @override
  String get transactionDeleteConfirmTitle => 'Удалить операцию';

  @override
  String get transactionDeleteConfirmMessage =>
      'Вы уверены, что хотите удалить эту операцию? Действие нельзя отменить.';

  @override
  String get transactionDeleteError => 'Не удалось удалить транзакцию.';

  @override
  String get addTransactionSuccess => 'Транзакция сохранена';

  @override
  String get homeAccountsAddTooltip => 'Добавить счёт';

  @override
  String get addAccountTitle => 'Добавление счёта';

  @override
  String get addAccountNameLabel => 'Название счёта';

  @override
  String get addAccountBalanceLabel => 'Начальный баланс';

  @override
  String get addAccountCurrencyLabel => 'Валюта';

  @override
  String get addAccountTypeLabel => 'Тип счёта';

  @override
  String get addAccountSaveCta => 'Сохранить';

  @override
  String get addAccountNameRequired => 'Введите название счёта.';

  @override
  String get addAccountBalanceInvalid => 'Введите корректную сумму.';

  @override
  String get addAccountError => 'Не удалось сохранить счёт. Повторите попытку.';

  @override
  String get addAccountTypeCash => 'Наличные';

  @override
  String get addAccountTypeCard => 'Карта';

  @override
  String get addAccountTypeBank => 'Банковский счёт';

  @override
  String get addAccountTypeCustom => 'Другой тип';

  @override
  String get addAccountCustomTypeLabel => 'Собственный тип счёта';

  @override
  String get addAccountTypeRequired => 'Укажите тип счёта.';

  @override
  String get accountDetailsTitle => 'Счёт';

  @override
  String get accountDetailsEditTooltip => 'Настройки счёта';

  @override
  String accountDetailsError(String error) {
    return 'Не удалось загрузить счёт: $error';
  }

  @override
  String get accountDetailsMissing => 'Счёт не найден или был удалён.';

  @override
  String accountDetailsSummaryError(String error) {
    return 'Не удалось загрузить сводку: $error';
  }

  @override
  String accountDetailsCategoriesError(String error) {
    return 'Не удалось загрузить категории: $error';
  }

  @override
  String accountDetailsTransactionsError(String error) {
    return 'Не удалось загрузить транзакции: $error';
  }

  @override
  String get accountDetailsTransactionsEmpty =>
      'Для этого счёта ещё нет транзакций.';

  @override
  String accountDetailsBalanceLabel(String balance) {
    return 'Баланс: $balance';
  }

  @override
  String get accountDetailsIncomeLabel => 'Доходы';

  @override
  String get accountDetailsExpenseLabel => 'Расходы';

  @override
  String get accountDetailsFiltersTitle => 'Фильтры';

  @override
  String get accountDetailsFiltersButtonActive => 'Фильтры (активны)';

  @override
  String get accountDetailsFiltersClear => 'Сбросить фильтры';

  @override
  String get accountDetailsFiltersDateLabel => 'Дата';

  @override
  String get accountDetailsFiltersDateAny => 'Любые даты';

  @override
  String get accountDetailsFiltersDateClear => 'Очистить диапазон';

  @override
  String accountDetailsFiltersDateValue(String start, String end) {
    return '$start — $end';
  }

  @override
  String get accountDetailsFiltersTypeLabel => 'Тип';

  @override
  String get accountDetailsFiltersTypeAll => 'Все типы';

  @override
  String get accountDetailsFiltersTypeIncome => 'Доход';

  @override
  String get accountDetailsFiltersTypeExpense => 'Расход';

  @override
  String get accountDetailsFiltersCategoryLabel => 'Категория';

  @override
  String get accountDetailsFiltersCategoryAll => 'Все категории';

  @override
  String get accountDetailsTransactionsUncategorized => 'Без категории';

  @override
  String get accountDetailsTypeIncome => 'Доход';

  @override
  String get accountDetailsTypeExpense => 'Расход';

  @override
  String get editAccountTitle => 'Редактирование счёта';

  @override
  String get editAccountNameLabel => 'Название счёта';

  @override
  String get editAccountBalanceLabel => 'Баланс';

  @override
  String get editAccountCurrencyLabel => 'Валюта';

  @override
  String get editAccountTypeLabel => 'Тип счёта';

  @override
  String get editAccountTypeCustom => 'Другой тип';

  @override
  String get editAccountCustomTypeLabel => 'Собственный тип счёта';

  @override
  String get editAccountTypeRequired => 'Укажите тип счёта.';

  @override
  String get editAccountSaveCta => 'Сохранить изменения';

  @override
  String get editAccountNameRequired => 'Введите название счёта.';

  @override
  String get editAccountBalanceInvalid => 'Введите корректную сумму.';

  @override
  String get editAccountGenericError =>
      'Не удалось обновить счёт. Повторите попытку.';

  @override
  String get editAccountDeleteCta => 'Удалить счёт';

  @override
  String get editAccountDeleteLoading => 'Удаляем...';

  @override
  String get editAccountDeleteConfirmationTitle => 'Удалить счёт?';

  @override
  String get editAccountDeleteConfirmationMessage =>
      'Счёт и связанные данные будут удалены. Это действие невозможно отменить.';

  @override
  String get editAccountDeleteConfirmationCancel => 'Отмена';

  @override
  String get editAccountDeleteConfirmationConfirm => 'Удалить';

  @override
  String get editAccountDeleteError =>
      'Не удалось удалить счёт. Попробуйте ещё раз.';

  @override
  String get homeNavBudgets => 'Бюджеты';

  @override
  String get budgetsTitle => 'Бюджеты';

  @override
  String get budgetsEmptyTitle => 'Пока нет бюджетов';

  @override
  String get budgetsEmptyMessage =>
      'Создайте первый бюджет, чтобы контролировать расходы.';

  @override
  String get budgetsErrorTitle => 'Не удалось загрузить бюджеты';

  @override
  String get budgetsSpentLabel => 'Потрачено';

  @override
  String get budgetsLimitLabel => 'Лимит';

  @override
  String get budgetsRemainingLabel => 'Осталось';

  @override
  String get budgetsExceededLabel => 'Перерасход';

  @override
  String get budgetDetailTitle => 'Детали бюджета';

  @override
  String get budgetDeleteTitle => 'Удалить бюджет?';

  @override
  String get budgetDeleteMessage =>
      'Бюджет и его история будут удалены. Отменить действие нельзя.';

  @override
  String budgetPeriodLabel(String start, String end) {
    return 'Период: $start – $end';
  }

  @override
  String get budgetTransactionsTitle => 'Транзакции';

  @override
  String get budgetTransactionsEmpty =>
      'Для этого бюджета пока нет транзакций.';

  @override
  String get budgetCreateTitle => 'Новый бюджет';

  @override
  String get budgetEditTitle => 'Редактирование бюджета';

  @override
  String get budgetTitleLabel => 'Название бюджета';

  @override
  String get budgetAmountLabel => 'Сумма лимита';

  @override
  String get budgetPeriodLabelShort => 'Период';

  @override
  String get budgetScopeLabel => 'Область';

  @override
  String get budgetStartDateLabel => 'Дата начала';

  @override
  String get budgetEndDateLabel => 'Дата окончания';

  @override
  String get budgetCategoriesLabel => 'Категории';

  @override
  String get budgetAccountsLabel => 'Счета';

  @override
  String get budgetPeriodMonthly => 'Ежемесячно';

  @override
  String get budgetPeriodWeekly => 'Еженедельно';

  @override
  String get budgetPeriodCustom => 'Произвольный период';

  @override
  String get budgetScopeAll => 'Все транзакции';

  @override
  String get budgetScopeByCategory => 'Выбранные категории';

  @override
  String get budgetScopeByAccount => 'Выбранные счета';

  @override
  String get budgetErrorInvalidAmount => 'Введите положительную сумму.';

  @override
  String get budgetErrorMissingTitle => 'Введите название бюджета.';

  @override
  String get budgetNoEndDateLabel => 'Без даты окончания';

  @override
  String get editButtonLabel => 'Редактировать';

  @override
  String get deleteButtonLabel => 'Удалить';

  @override
  String get cancelButtonLabel => 'Отмена';

  @override
  String get saveButtonLabel => 'Сохранить';

  @override
  String get savingsTitle => 'Цели по накоплениям';

  @override
  String get savingsAddGoalTitle => 'Новая цель';

  @override
  String get savingsEditGoalTitle => 'Редактирование цели';

  @override
  String get savingsNameLabel => 'Название';

  @override
  String get savingsTargetLabel => 'Целевая сумма';

  @override
  String get savingsTargetHelper => 'Введите желаемую сумму';

  @override
  String get savingsNoteLabel => 'Заметка';

  @override
  String get savingsSaveGoalButton => 'Сохранить цель';

  @override
  String get savingsGoalSavedMessage => 'Цель сохранена';

  @override
  String get savingsAddGoalButton => 'Создать цель';

  @override
  String get savingsEmptyTitle => 'Создайте первую цель';

  @override
  String get savingsEmptyMessage =>
      'Отслеживайте прогресс и сохраняйте мотивацию.';

  @override
  String get savingsErrorTitle => 'Не удалось загрузить цели';

  @override
  String get savingsRetryButton => 'Повторить попытку';

  @override
  String get savingsContributeAction => 'Пополнить';

  @override
  String get savingsEditAction => 'Редактировать';

  @override
  String get savingsArchiveAction => 'Архивировать';

  @override
  String savingsGoalArchivedMessage(String goal) {
    return 'Цель «$goal» архивирована';
  }

  @override
  String get savingsArchivedBadge => 'В архиве';

  @override
  String savingsRemainingLabel(String amount) {
    return 'Осталось $amount';
  }

  @override
  String get savingsShowArchivedToggle => 'Показывать архивные цели';

  @override
  String savingsContributeTitle(String goal) {
    return 'Пополнение цели «$goal»';
  }

  @override
  String get savingsAmountLabel => 'Сумма';

  @override
  String get savingsSourceAccountLabel => 'Счёт списания';

  @override
  String get savingsNoAccountOption => 'Без счёта';

  @override
  String get savingsContributionNoteLabel => 'Заметка (необязательно)';

  @override
  String get savingsSubmitContributionButton => 'Добавить пополнение';

  @override
  String get savingsContributionSuccess => 'Пополнение добавлено';

  @override
  String get transactionDefaultTitle => 'Транзакция';

  @override
  String get allTransactionsTitle => 'Все транзакции';

  @override
  String get allTransactionsFiltersTitle => 'Настройка фильтров';

  @override
  String get allTransactionsFiltersDate => 'Период';

  @override
  String get allTransactionsFiltersDateAny => 'Любая дата';

  @override
  String get allTransactionsFiltersAccount => 'Счёт';

  @override
  String get allTransactionsFiltersAccountAny => 'Все счета';

  @override
  String get allTransactionsFiltersCategory => 'Категория';

  @override
  String get allTransactionsFiltersCategoryAny => 'Все категории';

  @override
  String get allTransactionsFiltersLoading => 'Загрузка…';

  @override
  String get allTransactionsFiltersClear => 'Сбросить фильтры';

  @override
  String get allTransactionsEmpty =>
      'Транзакций по заданным условиям не найдено.';

  @override
  String allTransactionsError(String error) {
    return 'Не удалось загрузить транзакции: $error';
  }
}
