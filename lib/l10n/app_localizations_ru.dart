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
  String get profileRegisterCta => 'Зарегистрироваться';

  @override
  String get profileRegisterHint =>
      'Создайте учётную запись, чтобы сохранить локальные данные и синхронизировать их между устройствами.';

  @override
  String get profileSectionAccount => 'Учетная запись';

  @override
  String get profileAppearanceSection => 'Внешний вид';

  @override
  String get profileGeneralSettingsTitle => 'Генеральные настройки';

  @override
  String get profileGeneralSettingsTooltip => 'Генеральные настройки';

  @override
  String get profileMenuTitle => 'Меню';

  @override
  String get creditsTitle => 'Кредиты и долги';

  @override
  String get creditsAddTitle => 'Добавить кредит';

  @override
  String get creditsEditTitle => 'Редактировать кредит';

  @override
  String get creditsNameLabel => 'Название';

  @override
  String get creditsAmountLabel => 'Сумма кредита';

  @override
  String get creditsInterestRateLabel => 'Процентная ставка (%)';

  @override
  String get creditsTermMonthsLabel => 'Срок (месяцев)';

  @override
  String get creditsStartDateLabel => 'Дата начала';

  @override
  String get creditsHiddenOnDashboardLabel => 'Скрывать счет на главном экране';

  @override
  String get creditsRemainingAmount => 'Осталось выплатить';

  @override
  String creditsTotalAmount(String total) {
    return 'Из $total';
  }

  @override
  String get creditsEmptyList => 'У вас пока нет активных кредитов';

  @override
  String get creditsSaveAction => 'Сохранить кредит';

  @override
  String get creditsPaymentDayLabel => 'День платежа (1-31)';

  @override
  String get creditsNextPaymentLabel => 'Следующий платеж';

  @override
  String get creditsRemainingPaymentsLabel => 'Осталось';

  @override
  String get creditsSegmentCredits => 'Кредиты';

  @override
  String get creditsSegmentDebts => 'Долги';

  @override
  String get creditsDeleteTitle => 'Удалить кредит?';

  @override
  String get creditsDeleteMessage =>
      'Кредит будет удалён без возможности восстановления.';

  @override
  String get debtsAddTitle => 'Добавить долг';

  @override
  String get debtsEditTitle => 'Редактировать долг';

  @override
  String get debtsNameLabel => 'Название';

  @override
  String get debtsAccountLabel => 'Счет';

  @override
  String get debtsAccountHint => 'Выберите счет';

  @override
  String get debtsAccountError => 'Выберите счет для долга';

  @override
  String get debtsAmountLabel => 'Сумма долга';

  @override
  String get debtsDueDateLabel => 'Дата платежа';

  @override
  String get debtsNoteLabel => 'Описание';

  @override
  String get debtsSaveAction => 'Сохранить долг';

  @override
  String get debtsSaveAndScheduleAction => 'Сохранить и напомнить';

  @override
  String get debtsEmptyList => 'У вас пока нет долгов';

  @override
  String get debtsDefaultTitle => 'Долг';

  @override
  String get debtsDeleteTitle => 'Удалить долг?';

  @override
  String get debtsDeleteMessage =>
      'Долг будет удалён без возможности восстановления.';

  @override
  String get profileGeneralSettingsManagementSection => 'Управление данными';

  @override
  String get profileManageCategoriesCta => 'Управлять категориями и тэгами';

  @override
  String get profileUpcomingPaymentsCta => 'Повторяющиеся платежи';

  @override
  String get profileExportDataCta => 'Экспортировать данные';

  @override
  String get profileDataTransferFormatLabel => 'Формат файла';

  @override
  String get profileDataTransferFormatCsv => 'CSV';

  @override
  String get profileDataTransferFormatJson => 'JSON';

  @override
  String get profileExportDataSuccess => 'Экспорт завершён успешно.';

  @override
  String profileExportDataSuccessWithPath(String target) {
    return 'Данные экспортированы в $target';
  }

  @override
  String profileExportDataFailure(String error) {
    return 'Не удалось экспортировать данные: $error';
  }

  @override
  String get profileExportDataDestinationLabel => 'Место сохранения';

  @override
  String get profileExportDataDefaultDestination => 'По умолчанию (загрузки)';

  @override
  String profileExportDataSelectedFolder(String path) {
    return 'Папка: $path';
  }

  @override
  String get profileExportDataSelectFolderCta => 'Выбрать папку';

  @override
  String get profileExportDataDirectoryPickerTitle =>
      'Выберите папку для сохранения данных экспорта';

  @override
  String get profileImportDataCta => 'Импортировать данные';

  @override
  String get profileImportDataSuccess => 'Импорт завершён успешно.';

  @override
  String profileImportDataSuccessWithStats(
    int accounts,
    int categories,
    int transactions,
  ) {
    return 'Импортировано счетов: $accounts, категорий: $categories, транзакций: $transactions.';
  }

  @override
  String get profileImportDataCancelled => 'Импорт отменён пользователем.';

  @override
  String profileImportDataFailure(String error) {
    return 'Не удалось импортировать данные: $error';
  }

  @override
  String get settingsNotificationsExactTitle => 'Точные напоминания';

  @override
  String get settingsNotificationsExactSubtitle =>
      'Показывать уведомления ровно в указанное время.';

  @override
  String settingsNotificationsExactError(String error) {
    return 'Не удалось получить статус: $error';
  }

  @override
  String get settingsNotificationsRetryTooltip => 'Обновить статус';

  @override
  String get settingsNotificationsTestCta => 'Отправить тестовое уведомление';

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
  String get profileManageCategoriesTitle => 'Управление категориями и тэгами';

  @override
  String get manageCategoriesTabCategories => 'Категории';

  @override
  String get manageCategoriesTabTags => 'Тэги';

  @override
  String get manageCategoriesAddAction => 'Добавить категорию';

  @override
  String get manageCategoryGroupAddAction => 'Добавить группу';

  @override
  String get manageCategoriesCreateSubAction => 'Создать подкатегорию';

  @override
  String get manageCategoriesAddSubcategoryAction => 'Добавить подкатегорию';

  @override
  String get manageCategoriesAddSubcategorySaveFirst =>
      'Сохраните категорию, чтобы добавить подкатегорию.';

  @override
  String get dialogCancel => 'Отмена';

  @override
  String get dialogConfirm => 'Готово';

  @override
  String get commonUndo => 'Отменить';

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
  String get manageCategoryGroupFavoritesTitle => 'Избранное';

  @override
  String get manageCategoryGroupOtherTitle => 'Остальное';

  @override
  String get manageCategoryGroupEmpty => 'Категорий в группе нет.';

  @override
  String get manageCategoryGroupEditAction => 'Редактировать группу';

  @override
  String manageCategoriesListError(String error) {
    return 'Не удалось загрузить категории: $error';
  }

  @override
  String get manageCategoriesCreateTitle => 'Новая категория';

  @override
  String get manageCategoriesEditTitle => 'Редактирование категории';

  @override
  String get manageCategoryGroupCreateTitle => 'Новая группа';

  @override
  String get manageCategoryGroupEditTitle => 'Редактирование группы';

  @override
  String get manageCategoriesNameLabel => 'Название';

  @override
  String get manageCategoryGroupNameLabel => 'Название группы';

  @override
  String get manageCategoriesNameRequired => 'Введите название.';

  @override
  String get manageCategoryGroupNameRequired => 'Введите название группы.';

  @override
  String get manageCategoryGroupCategoriesHint =>
      'Выберите категории для группы. Подкатегории добавляются автоматически.';

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
  String get manageCategoriesIconGroupGroceries => 'Продукты и еда';

  @override
  String get manageCategoriesIconGroupDining => 'Кафе и рестораны';

  @override
  String get manageCategoriesIconGroupClothing => 'Одежда и уход';

  @override
  String get manageCategoriesIconGroupHome => 'Дом и мебель';

  @override
  String get manageCategoriesIconGroupUtilities => 'Коммунальные услуги';

  @override
  String get manageCategoriesIconGroupCommunication => 'Связь и гаджеты';

  @override
  String get manageCategoriesIconGroupSubscriptions => 'Подписки и медиа';

  @override
  String get manageCategoriesIconGroupPublicTransport =>
      'Общественный транспорт';

  @override
  String get manageCategoriesIconGroupCar => 'Автомобиль';

  @override
  String get manageCategoriesIconGroupTaxi => 'Такси и парковки';

  @override
  String get manageCategoriesIconGroupTravel => 'Путешествия';

  @override
  String get manageCategoriesIconGroupHealth => 'Здоровье и медицина';

  @override
  String get manageCategoriesIconGroupSecurity => 'Безопасность';

  @override
  String get manageCategoriesIconGroupEducation => 'Образование';

  @override
  String get manageCategoriesIconGroupFamily => 'Семья и дети';

  @override
  String get manageCategoriesIconGroupPets => 'Питомцы';

  @override
  String get manageCategoriesIconGroupMaintenance => 'Ремонт и инструменты';

  @override
  String get manageCategoriesIconGroupEntertainment => 'Развлечения и досуг';

  @override
  String get manageCategoriesIconGroupSports => 'Спорт и фитнес';

  @override
  String get manageCategoriesIconGroupFinance => 'Финансы и банки';

  @override
  String get manageCategoriesIconGroupLoans => 'Кредиты и долги';

  @override
  String get manageCategoriesIconGroupDocuments => 'Документы и налоги';

  @override
  String get manageCategoriesIconGroupSettings => 'Настройки и системные';

  @override
  String get manageCategoriesIconGroupTransactionTypes => 'Типы транзакций';

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
  String get manageCategoriesFavoriteLabel => 'Добавить в избранное';

  @override
  String get manageCategoriesFavoriteSubtitle =>
      'Избранные категории отображаются вверху списка при создании транзакций.';

  @override
  String get manageCategoriesSaveCta => 'Сохранить категорию';

  @override
  String get manageCategoryGroupSaveCta => 'Сохранить группу';

  @override
  String manageCategoriesSaveError(String error) {
    return 'Не удалось сохранить категорию: $error';
  }

  @override
  String manageCategoryGroupSaveError(String error) {
    return 'Не удалось сохранить группу: $error';
  }

  @override
  String get manageCategoriesDuplicateNameError =>
      'Категория с таким названием уже существует, выберите другое';

  @override
  String get manageCategoryGroupDuplicateNameError =>
      'Группа с таким названием уже существует, выберите другое';

  @override
  String get manageCategoriesSuccessCreate => 'Категория успешно создана.';

  @override
  String get manageCategoriesSuccessUpdate => 'Категория обновлена.';

  @override
  String get manageCategoriesDeleteAction => 'Удалить';

  @override
  String get manageCategoryGroupDeleteAction => 'Удалить группу';

  @override
  String get manageCategoriesDeleteConfirmTitle => 'Удалить категорию';

  @override
  String get manageCategoryGroupDeleteConfirmTitle => 'Удалить группу';

  @override
  String manageCategoriesDeleteConfirmMessage(String name) {
    return 'Вы действительно хотите удалить категорию «$name»? Все подкатегории также будут удалены.';
  }

  @override
  String get manageCategoryGroupDeleteConfirmMessage =>
      'Удалить группу и переместить категории в «Остальное»?';

  @override
  String get manageCategoryGroupDeleteConfirmAction => 'Удалить';

  @override
  String get manageCategoriesDeleteSuccess => 'Категория удалена.';

  @override
  String manageCategoriesDeleteError(String error) {
    return 'Не удалось удалить категорию: $error';
  }

  @override
  String manageCategoryGroupDeleteError(String error) {
    return 'Не удалось удалить группу: $error';
  }

  @override
  String get manageTagsAddAction => 'Добавить тэг';

  @override
  String get manageTagsEmpty => 'Тэгов пока нет. Добавьте первый.';

  @override
  String manageTagsListError(String error) {
    return 'Не удалось загрузить тэги: $error';
  }

  @override
  String get manageTagsCreateTitle => 'Новый тэг';

  @override
  String get manageTagsEditTitle => 'Редактирование тэга';

  @override
  String get manageTagsNameLabel => 'Название';

  @override
  String get manageTagsNameRequired => 'Введите название.';

  @override
  String get manageTagsColorLabel => 'Цвет';

  @override
  String get manageTagsColorNone => 'Цвет не выбран';

  @override
  String get manageTagsColorSelected => 'Цвет выбран';

  @override
  String get manageTagsColorRequired => 'Выберите цвет.';

  @override
  String get manageTagsColorPickerTitle => 'Выберите цвет тэга';

  @override
  String get manageTagsSaveCta => 'Сохранить тэг';

  @override
  String manageTagsSaveError(String error) {
    return 'Не удалось сохранить тэг: $error';
  }

  @override
  String get manageTagsSuccessCreate => 'Тэг успешно создан.';

  @override
  String get manageTagsSuccessUpdate => 'Тэг обновлён.';

  @override
  String get manageTagsDeleteAction => 'Удалить';

  @override
  String get manageTagsDeleteConfirmTitle => 'Удалить тэг';

  @override
  String manageTagsDeleteConfirmMessage(String name) {
    return 'Вы действительно хотите удалить тэг «$name»?';
  }

  @override
  String get manageTagsDeleteSuccess => 'Тэг удалён.';

  @override
  String manageTagsDeleteError(String error) {
    return 'Не удалось удалить тэг: $error';
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
  String get profilePresetAvatarButton => 'Выбрать встроенную';

  @override
  String get profilePresetAvatarTitle => 'Выберите аватарку';

  @override
  String get profilePresetAvatarSubtitle =>
      'Выберите один из встроенных вариантов.';

  @override
  String profilePresetAvatarLabel(int index) {
    return 'Аватар $index';
  }

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
  String get authErrorUserNotFound => 'Пользователь с таким email не найден.';

  @override
  String get authErrorWrongPassword => 'Неверный пароль. Попробуйте снова.';

  @override
  String get authErrorInvalidCredentials =>
      'Неверный логин или пароль. Попробуйте снова.';

  @override
  String get authErrorInvalidEmail => 'Некорректный формат email.';

  @override
  String get authErrorEmailAlreadyInUse =>
      'Аккаунт с таким email уже существует.';

  @override
  String get authErrorWeakPassword =>
      'Слишком простой пароль. Минимум 6 символов.';

  @override
  String get authErrorUserDisabled => 'Этот аккаунт был отключен.';

  @override
  String get authErrorTooManyRequests =>
      'Слишком много неудачных попыток. Попробуйте позже.';

  @override
  String get authErrorNetworkFailed => 'Ошибка сети. Проверьте подключение.';

  @override
  String get authErrorDefault => 'Произошла ошибка входа. Попробуйте позже.';

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
  String get signInOfflineCta => 'Войти без учетной записи';

  @override
  String get signInError => 'Не удалось выполнить вход. Попробуйте еще раз.';

  @override
  String get signInLoading => 'Выполняется вход...';

  @override
  String get signInOfflineNotice =>
      'Похоже, что вы офлайн. Мы синхронизируем данные, как только подключитесь.';

  @override
  String get signInNoAccountCta => 'Создать аккаунт';

  @override
  String get signInAlreadyHaveAccountCta => 'Вернуться ко входу';

  @override
  String get signUpTitle => 'Создайте аккаунт Kopim';

  @override
  String get signUpSubtitle =>
      'Зарегистрируйтесь, чтобы синхронизировать финансы на всех устройствах.';

  @override
  String get signUpSubmitCta => 'Зарегистрироваться';

  @override
  String get signUpLoading => 'Создание аккаунта...';

  @override
  String get signUpError => 'Не удалось создать аккаунт. Попробуйте еще раз.';

  @override
  String get signUpConfirmPasswordLabel => 'Подтвердите пароль';

  @override
  String get signUpDisplayNameLabel => 'Имя (необязательно)';

  @override
  String get homeTitle => 'Домашний экран';

  @override
  String get homeProfileTooltip => 'Профиль';

  @override
  String get homeSyncStatusSuccess => 'Синхронизация завершена.';

  @override
  String get homeSyncStatusOffline => 'Вы офлайн. Синхронизация недоступна.';

  @override
  String get homeSyncStatusInProgress => 'Синхронизация уже выполняется.';

  @override
  String get homeSyncStatusNoChanges => 'Нет изменений для синхронизации.';

  @override
  String get homeSyncStatusAuthRequired =>
      'Войдите, чтобы синхронизировать данные.';

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
  String get homeHiddenAccountsToggleShowLabel => 'Показать';

  @override
  String get homeHiddenAccountsToggleHideLabel => 'Скрыть';

  @override
  String homeAccountType(String type) {
    return 'Тип: $type';
  }

  @override
  String get homeAccountMonthlyIncomeLabel => 'Доход';

  @override
  String get homeAccountMonthlyExpenseLabel => 'Расход';

  @override
  String get homeTransactionsTodayLabel => 'Сегодня';

  @override
  String get homeOverviewTotalBalanceLabel => 'Общий баланс';

  @override
  String homeOverviewIncomeValue(String amount) {
    return 'Доход: $amount';
  }

  @override
  String homeOverviewExpenseValue(String amount) {
    return 'Расход: $amount';
  }

  @override
  String get homeOverviewTopExpensesLabel => 'Топ расходов';

  @override
  String get homeOverviewTopExpensesEmpty => 'Нет расходов';

  @override
  String homeOverviewSummaryError(String error) {
    return 'Не удалось загрузить сводку: $error';
  }

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
  String get homeUpcomingPaymentsTitle => 'Предстоящие платежи';

  @override
  String get homeUpcomingPaymentsEmpty => 'Пока нет повторяющихся платежей.';

  @override
  String get homeUpcomingPaymentsEmptyHeader => 'Нет повторяющихся платежей';

  @override
  String homeUpcomingPaymentsCollapsedSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Список скрыт · $count платежей',
      many: 'Список скрыт · $count платежей',
      few: 'Список скрыт · $count платежа',
      one: 'Список скрыт · $count платеж',
      zero: 'Список скрыт · нет платежей',
    );
    return '$_temp0';
  }

  @override
  String get homeUpcomingPaymentsExpand => 'Показать список';

  @override
  String get homeUpcomingPaymentsCollapse => 'Свернуть список';

  @override
  String homeUpcomingPaymentsNextDate(String date) {
    return 'Ближайшая дата: $date';
  }

  @override
  String homeUpcomingPaymentsError(String error) {
    return 'Не удалось загрузить повторяющиеся платежи: $error';
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
      other: '# повторяющихся платежей',
      many: '# повторяющихся платежей',
      few: '# повторяющихся платежа',
      one: '# повторяющийся платеж',
      zero: 'Нет повторяющихся платежей',
    );
    return '$_temp0';
  }

  @override
  String get homeUpcomingPaymentsMore => 'Больше';

  @override
  String get homeUpcomingPaymentsBadgePaymentsLabel => 'Платежи';

  @override
  String get homeUpcomingPaymentsBadgeRemindersLabel => 'Напоминания';

  @override
  String homeUpcomingPaymentsBadgePaymentsSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# повторяющихся платежей',
      many: '# повторяющихся платежей',
      few: '# повторяющихся платежа',
      one: '# повторяющийся платеж',
      zero: 'Нет повторяющихся платежей',
    );
    return '$_temp0';
  }

  @override
  String homeUpcomingPaymentsBadgeRemindersSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# напоминаний',
      many: '# напоминаний',
      few: '# напоминания',
      one: '# напоминание',
      zero: 'Нет напоминаний',
    );
    return '$_temp0';
  }

  @override
  String get upcomingPaymentsTitle => 'Предстоящие платежи';

  @override
  String get upcomingPaymentsTabPayments => 'Предстоящие';

  @override
  String get upcomingPaymentsTabReminders => 'Напоминания';

  @override
  String get upcomingPaymentsEmptyPaymentsTitle =>
      'Повторяющиеся платежи ещё не настроены';

  @override
  String get upcomingPaymentsEmptyPaymentsDescription =>
      'Настройте повторяющиеся платежи и держите счета под контролем.';

  @override
  String get upcomingPaymentsEmptyRemindersTitle => 'Напоминаний пока нет';

  @override
  String get upcomingPaymentsEmptyRemindersDescription =>
      'Создайте напоминания, чтобы не пропустить ручные платежи.';

  @override
  String get upcomingPaymentsAddPayment => 'Добавить предстоящий платёж';

  @override
  String get upcomingPaymentsAddReminder => 'Добавить напоминание';

  @override
  String get upcomingPaymentsNewPaymentTitle => 'Новый повторяющийся платёж';

  @override
  String get upcomingPaymentsEditPaymentTitle =>
      'Редактирование повторяющегося платежа';

  @override
  String get upcomingPaymentsNewReminderTitle => 'Новое напоминание';

  @override
  String get upcomingPaymentsEditReminderTitle => 'Редактирование напоминания';

  @override
  String get upcomingPaymentsFieldTitle => 'Название';

  @override
  String get upcomingPaymentsFieldAccount => 'Счёт';

  @override
  String get upcomingPaymentsFieldCategory => 'Категория';

  @override
  String get upcomingPaymentsFieldAmount => 'Сумма';

  @override
  String get upcomingPaymentsFieldDayOfMonth => 'День месяца';

  @override
  String get upcomingPaymentsFieldNotifyDaysBefore =>
      'За сколько дней напомнить';

  @override
  String get upcomingPaymentsFieldNotifyTime => 'Время уведомления';

  @override
  String get upcomingPaymentsFieldAutoPost => 'Проводить автоматически';

  @override
  String get upcomingPaymentsFieldNote => 'Заметка';

  @override
  String get upcomingPaymentsFieldReminderWhen => 'Дата и время';

  @override
  String get upcomingPaymentsSubmit => 'Сохранить';

  @override
  String get upcomingPaymentsCancel => 'Отмена';

  @override
  String get upcomingPaymentsSaveSuccess => 'Повторяющийся платёж сохранён';

  @override
  String get upcomingPaymentsReminderSaveSuccess => 'Напоминание сохранено';

  @override
  String upcomingPaymentsSaveError(String error) {
    return 'Не удалось сохранить повторяющийся платёж: $error';
  }

  @override
  String upcomingPaymentsReminderSaveError(String error) {
    return 'Не удалось сохранить напоминание: $error';
  }

  @override
  String get upcomingPaymentsReminderMarkPaidAction => 'Оплачено';

  @override
  String get upcomingPaymentsReminderMarkPaidTooltip =>
      'Отметить напоминание как оплаченное';

  @override
  String get upcomingPaymentsReminderMarkPaidSuccess =>
      'Напоминание отмечено как оплаченное.';

  @override
  String upcomingPaymentsReminderMarkPaidError(String error) {
    return 'Не удалось отметить напоминание: $error';
  }

  @override
  String get upcomingPaymentsReminderEditAction => 'Редактировать';

  @override
  String get upcomingPaymentsReminderDeleteAction => 'Удалить';

  @override
  String get upcomingPaymentsReminderDeleteTitle => 'Удалить напоминание?';

  @override
  String upcomingPaymentsReminderDeleteMessage(String title) {
    return 'Удалить напоминание «$title»? Действие нельзя отменить.';
  }

  @override
  String get upcomingPaymentsReminderDeleteSuccess => 'Напоминание удалено.';

  @override
  String upcomingPaymentsReminderDeleteError(String error) {
    return 'Не удалось удалить напоминание: $error';
  }

  @override
  String get upcomingPaymentsEditAction => 'Редактировать';

  @override
  String get upcomingPaymentsDeleteAction => 'Удалить';

  @override
  String get upcomingPaymentsDeleteTitle => 'Удалить повторяющийся платёж?';

  @override
  String upcomingPaymentsDeleteMessage(String title) {
    return 'Удалить «$title»? Действие нельзя отменить.';
  }

  @override
  String get upcomingPaymentsDeleteSuccess => 'Повторяющийся платёж удалён.';

  @override
  String upcomingPaymentsDeleteError(String error) {
    return 'Не удалось удалить повторяющийся платёж: $error';
  }

  @override
  String get upcomingPaymentsValidationTitle => 'Введите название';

  @override
  String get upcomingPaymentsValidationAmount => 'Введите положительную сумму';

  @override
  String get upcomingPaymentsValidationDay =>
      'День должен быть в диапазоне 1–31';

  @override
  String get upcomingPaymentsValidationNotifyDays =>
      'Количество дней должно быть неотрицательным';

  @override
  String get upcomingPaymentsNoAccounts =>
      'Добавьте счёт, чтобы создать повторяющийся платёж.';

  @override
  String get upcomingPaymentsNoCategories =>
      'Создайте категорию, чтобы выбрать её для повторяющегося платежа.';

  @override
  String upcomingPaymentsMonthlySummary(int day) {
    return 'Каждый месяц, $day-го числа';
  }

  @override
  String upcomingPaymentsNotifySummary(int days, String time) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'за $days дня до платежа в $time',
      many: 'за $days дней до платежа в $time',
      few: 'за $days дня до платежа в $time',
      one: 'за $days день до платежа в $time',
      zero: 'в день платежа в $time',
    );
    return 'Напоминание $_temp0';
  }

  @override
  String upcomingPaymentsReminderDue(String date) {
    return 'Срок $date';
  }

  @override
  String upcomingPaymentsListError(String error) {
    return 'Не удалось загрузить элементы: $error';
  }

  @override
  String get upcomingPaymentsNotificationPermissionDenied =>
      'Уведомления отключены. Включите их, чтобы получать напоминания.';

  @override
  String get upcomingPaymentsScheduleTriggered =>
      'Фоновая задача запланирована';

  @override
  String get homeSavingsWidgetTitle => 'Копилки';

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
  String get homeNavAssistant => 'Ассистент';

  @override
  String get homeNavSavings => 'Накопления';

  @override
  String get homeNavSettings => 'Меню';

  @override
  String get mainNavigationExitTitle => 'Выйти из Kopim?';

  @override
  String get mainNavigationExitMessage => 'Вы хотите закрыть приложение?';

  @override
  String get mainNavigationExitConfirm => 'Выйти';

  @override
  String get mainNavigationExitCancel => 'Остаться';

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
  String get analyticsChartTypeLabel => 'Тип диаграммы';

  @override
  String get analyticsChartTypeDonut => 'Кольцевая';

  @override
  String get analyticsChartTypeBar => 'Столбчатая';

  @override
  String get analyticsTopCategoriesEmpty =>
      'Недостаточно данных для анализа категорий.';

  @override
  String analyticsTopCategoriesTapHint(String amount) {
    return 'Нажмите на категорию, чтобы увидеть сумму · Всего $amount';
  }

  @override
  String get analyticsCategoryUncategorized => 'Без категории';

  @override
  String get analyticsCategoryDirectLabel => 'В этой категории';

  @override
  String analyticsCategoryTransactionsTitle(String category) {
    return 'Транзакции: $category';
  }

  @override
  String get analyticsCategoryTransactionsEmpty =>
      'Для этой категории нет транзакций за выбранный период.';

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
  String get addTransactionAccountHint => 'Выберите счёт для этой транзакции';

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
  String get addTransactionTypeTransfer => 'Перевод';

  @override
  String get addTransactionTransferTargetLabel => 'На счет';

  @override
  String get addTransactionTransferNoTargets =>
      'Добавьте еще один счет, чтобы сделать перевод.';

  @override
  String get addTransactionTransferCategoryHint =>
      'Переводы не относятся к категориям.';

  @override
  String transactionTransferAccountPair(String from, String to) {
    return 'Из $from -> $to';
  }

  @override
  String transactionTransferAccountSingle(String account) {
    return 'Счет: $account';
  }

  @override
  String get addTransactionCategoryLabel => 'Категория';

  @override
  String get addTransactionCategoryHint =>
      'Привяжите категорию, чтобы аналитика работала точнее';

  @override
  String get addTransactionCategorySearchHint => 'Поиск категории';

  @override
  String get addTransactionShowAllCategories => 'Показать все категории';

  @override
  String get addTransactionHideCategories => 'Свернуть категории';

  @override
  String get addTransactionCategoryNone => 'Без категории';

  @override
  String get addTransactionCategoriesLoading => 'Загружаем категории…';

  @override
  String addTransactionCategoriesError(String error) {
    return 'Не удалось загрузить категории: $error';
  }

  @override
  String get transactionTagsAddButton => 'Добавить тэг';

  @override
  String get transactionTagsSearchHint => 'Найти тэг';

  @override
  String get transactionTagsNone => 'Тэги не найдены';

  @override
  String get transactionTagsDialogTitle => 'Выбор тэгов';

  @override
  String get transactionTagsDialogApply => 'Готово';

  @override
  String get addTransactionDateLabel => 'Дата';

  @override
  String get addTransactionTimeLabel => 'Время';

  @override
  String get addTransactionChangeDateTimeHint => 'Изменить дату и время';

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
  String get addTransactionUndoSuccess => 'Транзакция отменена.';

  @override
  String get addTransactionUndoError => 'Не удалось отменить транзакцию.';

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
  String get addAccountTypeCreditCard => 'Кредитная карта';

  @override
  String get addAccountTypeCustom => 'Другой тип';

  @override
  String get addAccountCreditCardSettingsTitle => 'Настройки кредитной карты';

  @override
  String get addAccountCreditCardLimitLabel => 'Кредитный лимит';

  @override
  String get addAccountCreditCardLimitPlaceholder => 'Введите лимит';

  @override
  String get addAccountCreditCardLimitError => 'Введите корректный лимит.';

  @override
  String get addAccountCreditCardStatementDayLabel => 'День выписки';

  @override
  String get addAccountCreditCardStatementDayPlaceholder => 'Например, 5';

  @override
  String get addAccountCreditCardStatementDayError =>
      'Введите день от 1 до 31.';

  @override
  String get addAccountCreditCardStatementDayHelp =>
      'День месяца, когда формируется выписка по карте.';

  @override
  String get addAccountCreditCardPaymentDueDaysLabel => 'Дней до платежа';

  @override
  String get addAccountCreditCardPaymentDueDaysPlaceholder => 'Например, 10';

  @override
  String get addAccountCreditCardPaymentDueDaysError =>
      'Введите корректное количество дней.';

  @override
  String get addAccountCreditCardPaymentDueDaysHelp =>
      'Сколько дней есть на оплату после дня выписки.';

  @override
  String get addAccountCreditCardInterestRateLabel => 'Годовая ставка, %';

  @override
  String get addAccountCreditCardInterestRatePlaceholder => 'Например, 25';

  @override
  String get addAccountCreditCardInterestRateError =>
      'Введите корректную ставку.';

  @override
  String get creditCardAvailableLimitLabel => 'Доступный лимит';

  @override
  String get creditCardSpentLabel => 'Потрачено';

  @override
  String get addAccountCustomTypeLabel => 'Собственный тип счёта';

  @override
  String get addAccountTypeRequired => 'Укажите тип счёта.';

  @override
  String get accountColorLabel => 'Цвет карточки';

  @override
  String get accountColorDefault => 'По умолчанию';

  @override
  String get accountColorGradient => 'Градиент';

  @override
  String get accountColorPickerTitle => 'Выберите цвет карточки';

  @override
  String get accountColorSelect => 'Выбрать';

  @override
  String get accountColorClear => 'Сбросить цвет';

  @override
  String get accountIconLabel => 'Иконка счёта';

  @override
  String get accountIconNone => 'Иконка не выбрана';

  @override
  String get accountIconSelected => 'Иконка выбрана';

  @override
  String get accountIconSelect => 'Выбрать иконку';

  @override
  String get accountIconClear => 'Сбросить иконку';

  @override
  String get accountIconPickerTitle => 'Выбор иконки счёта';

  @override
  String get accountPrimaryToggleLabel => 'Сделать счёт основным';

  @override
  String get accountPrimaryToggleSubtitle =>
      'Этот счёт будет выбираться по умолчанию при создании транзакций.';

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
  String get budgetsCategoryChartTitle => 'Траты по категориям';

  @override
  String get budgetsCategoryBreakdownTitle => 'Категории бюджета';

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
  String get budgetsDetailsButton => 'Подробнее';

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
  String get budgetAmountAutoHelper =>
      'Сумма рассчитывается автоматически по лимитам категорий.';

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
  String get budgetCategoryAllocationsTitle => 'Лимиты по категориям';

  @override
  String budgetCategoryLimitLabel(String category) {
    return 'Лимит для $category';
  }

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
  String get budgetErrorInvalidCategoryAmount =>
      'Укажите положительный лимит для каждой выбранной категории.';

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
  String get savingsTitle => 'Копилки';

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
  String get savingsGoalDetailsTitle => 'Накопление';

  @override
  String get savingsGoalDetailsEditTooltip => 'Редактировать накопление';

  @override
  String get savingsGoalDetailsNotFound => 'Накопление недоступно.';

  @override
  String get savingsGoalDetailsSummaryTitle => 'Прогресс';

  @override
  String savingsGoalDetailsCurrentLabel(String amount) {
    return 'Накоплено: $amount';
  }

  @override
  String savingsGoalDetailsTargetLabel(String amount) {
    return 'Цель: $amount';
  }

  @override
  String get savingsGoalDetailsNoContributions => 'Внесений ещё не было';

  @override
  String savingsGoalDetailsLastContribution(String date) {
    return 'Последнее внесение $date';
  }

  @override
  String savingsGoalDetailsTransactionsCount(int count) {
    return 'Связанных операций: $count';
  }

  @override
  String get savingsGoalDetailsAnalyticsTitle => 'Аналитика по счёту';

  @override
  String get savingsGoalDetailsAnalyticsEmpty =>
      'Добавьте операции к накоплению, чтобы увидеть аналитику по категориям.';

  @override
  String savingsGoalDetailsAnalyticsTotal(String amount) {
    return 'Всего внесено: $amount';
  }

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

  @override
  String get assistantScreenTitle => 'ИИ-ассистент';

  @override
  String get assistantInputHint => 'Спросите о своих финансах…';

  @override
  String get assistantQuickActionsTitle => 'Быстрые запросы';

  @override
  String get assistantQuickActionSpendingLabel => 'Сводка расходов';

  @override
  String get assistantQuickActionSpendingPrompt =>
      'Дай сводку расходов за текущий месяц.';

  @override
  String get assistantQuickActionBudgetLabel => 'Состояние бюджета';

  @override
  String get assistantQuickActionBudgetPrompt =>
      'Укладываюсь ли я в бюджеты в этом месяце?';

  @override
  String get assistantQuickActionSavingsLabel => 'Тренды накоплений';

  @override
  String get assistantQuickActionSavingsPrompt =>
      'Как растут мои накопления в последнее время?';

  @override
  String get assistantFiltersTitle => 'Фильтры';

  @override
  String get assistantFilterCurrentMonth => 'Этот месяц';

  @override
  String get assistantFilterLast30Days => 'Последние 30 дней';

  @override
  String get assistantFilterBudgets => 'Бюджеты';

  @override
  String get assistantEmptyStateTitle => 'Начните диалог';

  @override
  String get assistantEmptyStateSubtitle =>
      'Используйте быстрые запросы или задайте свой вопрос.';

  @override
  String get assistantOfflineBanner =>
      'Вы офлайн. Вопросы отправятся, как только появится связь.';

  @override
  String get assistantRetryButton => 'Повторить сейчас';

  @override
  String get assistantPendingMessageHint =>
      'Отправится, когда появится интернет.';

  @override
  String get assistantSendingMessageHint => 'Отправляется…';

  @override
  String get assistantFailedMessageHint => 'Не удалось отправить.';

  @override
  String get assistantGenericError =>
      'Не удалось получить ответ ассистента. Попробуйте позже.';

  @override
  String get assistantNetworkError =>
      'Соединение потеряно. Мы попробуем отправить сообщение автоматически.';

  @override
  String get assistantTimeoutError =>
      'Ассистент отвечает слишком долго. Попробуйте снова.';

  @override
  String get assistantRateLimitError =>
      'Превышен лимит запросов OpenRouter. Подождите минуту и попробуйте снова.';

  @override
  String get assistantServerError =>
      'Сервис OpenRouter (DeepSeek) временно недоступен. Сообщение сохранено — повторите попытку позже.';

  @override
  String get assistantDisabledError =>
      'Ассистент временно отключён. Попробуйте позже.';

  @override
  String get assistantConfigurationError =>
      'Не удалось загрузить конфигурацию ассистента. Обновите приложение или обратитесь в поддержку.';

  @override
  String get assistantStreamingPlaceholder => 'Ассистент формирует ответ…';

  @override
  String get assistantMessageCopied => 'Сообщение скопировано';

  @override
  String get assistantOnboardingTitle => 'Возможности ассистента';

  @override
  String get assistantOnboardingDescription =>
      'Задавайте вопросы про бюджеты, траты и цели накоплений, чтобы получить персональные подсказки.';

  @override
  String get assistantOnboardingFeatureInsights =>
      'Мгновенно анализируйте расходы по категориям и периодам.';

  @override
  String get assistantOnboardingFeatureBudgets =>
      'Отслеживайте выполнение бюджетов и получайте предупреждения до перерасхода.';

  @override
  String get assistantOnboardingFeatureSavings =>
      'Получайте идеи, как ускорить накопления и достичь целей.';

  @override
  String get assistantOnboardingLimitationsTitle => 'Что важно помнить';

  @override
  String get assistantOnboardingLimitationDataFreshness =>
      'Ассистент использует последние синхронизированные данные — не забудьте выгрузить офлайн-операции.';

  @override
  String get assistantOnboardingLimitationSecurity =>
      'Все расчёты выполняются внутри Kopim, данные не передаются третьим лицам.';

  @override
  String get assistantOnboardingLimitationAccuracy =>
      'Ответы носят рекомендательный характер — перепроверяйте суммы в детальных отчётах.';

  @override
  String get assistantFaqTitle => 'Ответы на вопросы';

  @override
  String get assistantFaqQuestionDataSources =>
      'Откуда ассистент берёт данные?';

  @override
  String get assistantFaqAnswerDataSources =>
      'Он использует ту же базу Drift и синхронизацию Firebase, что и приложение, поэтому ответы основаны на ваших реальных счетах, бюджетах и транзакциях.';

  @override
  String get assistantFaqQuestionLimits =>
      'Почему появляются ошибки про лимиты или недоступность?';

  @override
  String get assistantFaqAnswerLimits =>
      'Иногда OpenRouter ограничивает трафик. Подождите немного или сформулируйте запрос короче, чтобы остаться в пределах квоты.';

  @override
  String get assistantFaqQuestionImproveResults =>
      'Как улучшить качество ответов?';

  @override
  String get assistantFaqAnswerImproveResults =>
      'Уточняйте период, счёт или категорию. Используйте фильтры над чатом, чтобы дать больше контекста.';

  @override
  String get overviewScreenTitle => 'Обзор';

  @override
  String get overviewSettingsTitle => 'Настройки обзора';

  @override
  String get overviewSettingsTooltip => 'Настройки обзора';

  @override
  String get overviewSettingsAccountsSection => 'Счета';

  @override
  String get overviewSettingsCategoriesSection => 'Категории';

  @override
  String get overviewScreenPlaceholder =>
      'Скоро здесь появится информация обзора.';
}
