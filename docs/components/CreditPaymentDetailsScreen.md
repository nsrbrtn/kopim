# CreditPaymentDetailsScreen

## Назначение
Экран показывает детали сгруппированного платежа по кредиту из ленты транзакций:
- общая сумма и дата платежа;
- разбивка на основной долг, проценты, комиссии;
- список транзакций внутри платежа с переходом в редактирование.

## Параметры
- `args: CreditPaymentDetailsScreenArgs`
  - `group: GroupedCreditPaymentFeedItem` — данные группового платежа;
  - `currencySymbol: String` — символ валюты для форматирования сумм.

## События и коллбэки
- Нажатие на строку транзакции открывает форму редактирования этой транзакции через `TransactionFormOpenContainer`.

## Визуальные принципы
- Используются цвета и типографика из `Theme.of(context)`.
- Карточки и секции построены на `surfaceContainerHigh`/`surfaceContainer`.
- Внешний вид элемента группового платежа унифицирован с обычными элементами списка транзакций.

## Как проверить
1. Открыть Home или All Transactions.
2. Нажать на карточку «Платёж по кредиту».
3. Убедиться, что открывается отдельный экран деталей.
4. Нажать на любую строку транзакции на этом экране и убедиться, что открывается форма редактирования.

## Связанные файлы
- `lib/features/credits/presentation/screens/credit_payment_details_screen.dart`
- `lib/features/credits/presentation/widgets/grouped_credit_payment_tile.dart`
- `lib/core/navigation/app_router.dart`
