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
  String get profileSignInPrompt => 'Войдите, чтобы управлять профилем.';

  @override
  String get profileSectionAccount => 'Учетная запись';

  @override
  String get profileNameLabel => 'Имя';

  @override
  String get profileCurrencyLabel => 'Валюта по умолчанию';

  @override
  String get profileLocaleLabel => 'Предпочитаемый язык';

  @override
  String profileLoadError(String error) {
    return 'Не удалось загрузить профиль: $error';
  }

  @override
  String get profileSaveCta => 'Сохранить изменения';

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
  String get signInError => 'Не удалось выполнить вход. Попробуйте еще раз.';

  @override
  String get signInLoading => 'Выполняется вход...';

  @override
  String get signInOfflineNotice =>
      'Похоже, что вы офлайн. Мы синхронизируем данные, как только подключитесь.';

  @override
  String get homeTitle => 'Домашний экран';

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
  String get homeTransactionsSection => 'Последние транзакции';

  @override
  String get homeTransactionsEmpty => 'Транзакций пока нет.';

  @override
  String homeTransactionsError(String error) {
    return 'Не удалось загрузить транзакции: $error';
  }

  @override
  String get homeTransactionsUncategorized => 'Без категории';

  @override
  String homeTransactionsCategory(String category) {
    return 'Категория: $category';
  }

  @override
  String get homeTransactionSymbolPositive => '+';

  @override
  String get homeTransactionSymbolNegative => '-';

  @override
  String get homeNavHome => 'Главная';

  @override
  String get homeNavAnalytics => 'Аналитика';

  @override
  String get homeNavSettings => 'Настройки';

  @override
  String get analyticsTitle => 'Аналитика';

  @override
  String get analyticsComingSoon => 'Скоро здесь появится подробная аналитика.';

  @override
  String get addTransactionTitle => 'Новая транзакция';

  @override
  String get addTransactionComingSoon =>
      'Создание транзакции скоро будет доступно.';

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
}
