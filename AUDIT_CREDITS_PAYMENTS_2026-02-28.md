# Аудит кредитных платежей (2026-02-28)

## Краткий итог
Обнаружены системные проблемы, которые напрямую объясняют ваши симптомы:
1. После перезапуска/синка теряются атрибуты кредитного платежа и связки кредита.
2. Экран кредита и шторка оплаты используют разные источники суммы «к оплате».
3. В списках транзакций кредитный платеж рендерится как общий `transfer`, а не как операция конкретного кредита.

Ниже — конкретные причины по коду и план исправлений.

## Область аудита
- `lib/features/credits/*`
- `lib/features/transactions/*`
- `lib/core/services/auth_sync_service.dart`
- `lib/features/*/data/sources/remote/*`

## Findings (по критичности)

### F1 (Критично): потеря `groupId` у транзакций при синке => «платёж по кредиту» превращается в «перевод»
- Где:
  - `lib/features/transactions/data/sources/remote/transaction_remote_data_source.dart:67-85`
  - `lib/features/transactions/data/sources/remote/transaction_remote_data_source.dart:88-113`
  - `lib/core/services/auth_sync_service.dart:752-758`
  - `lib/core/services/auth_sync_service.dart:1113-1134`
- Что происходит:
  - В remote payload транзакции не сериализуется `groupId`.
  - При чтении из Firestore `groupId` тоже не десериализуется.
  - В `AuthSyncService` merge выбирает remote-версию, если `updatedAt` не старее (`!existingUpdatedAt.isAfter(remoteUpdatedAt)`), то есть при равенстве/новизне remote перетирает локальную запись.
- Эффект:
  - Транзакции теряют группировку кредитного платежа.
  - Лента показывает обычный `transfer` вместо grouped credit payment.

### F2 (Критично): потеря полей кредита в remote (`interestCategoryId`, `feesCategoryId`, `firstPaymentDate`)
- Где:
  - `lib/features/credits/data/sources/remote/credit_remote_data_source.dart:64-80`
  - `lib/features/credits/data/sources/remote/credit_remote_data_source.dart:83-104`
- Что происходит:
  - В Firestore для кредита не пишутся и не читаются важные поля: `interestCategoryId`, `feesCategoryId`, `firstPaymentDate`.
- Эффект:
  - После синка кредит теряет категориальные связи процентов/комиссий.
  - Проценты и комиссии начинают хуже находиться в фильтрах/истории кредита.
  - Расчёт/отображение ближайшего платежа может опираться на деградированные данные.

### F3 (Высокий): сумма «следующего платежа» на экране кредита берётся не из schedule
- Где:
  - `lib/features/credits/presentation/screens/credit_details_screen.dart:139-143`
  - `lib/features/credits/presentation/screens/credit_details_screen.dart:237`
- Что происходит:
  - В UI показывается `calculateAnnuityMonthlyPayment(...)` от исходных параметров кредита.
  - Но фактическая оплата создаётся через `PayCreditSheet` с данными `scheduleItem`.
- Эффект:
  - На экране может быть одна сумма, а в операции другая (особенно после частичных оплат, округлений, последнего периода).

### F4 (Высокий): в шторке оплаты не учитывается уже оплаченная часть периода
- Где:
  - `lib/features/credits/presentation/widgets/pay_credit_sheet.dart:53-62`
- Что происходит:
  - Поля инициализируются `principalAmount` и `interestAmount`, а не остатком:
    - должно быть `principalAmount - principalPaid`
    - и `interestAmount - interestPaid`
- Эффект:
  - При частично оплаченных периодах пользователь видит/проводит завышенные суммы.

### F5 (Средний): нет явного типа `credit_payment`, используется `transfer`
- Где:
  - `lib/features/credits/domain/use_cases/make_credit_payment_use_case.dart:116-133`
  - `lib/features/transactions/domain/entities/transaction_type.dart:1`
- Что происходит:
  - «Платёж по кредиту» хранится как `transfer` (+ дополнительные expense-транзакции по процентам/комиссиям).
- Эффект:
  - Без `groupId` UI не может стабильно отличить кредитный платеж от обычного перевода.

### F6 (Средний): список транзакций не умеет показывать кредит как сущность (название + иконка)
- Где:
  - `lib/features/transactions/presentation/screens/all_transactions_screen.dart:619-621`
  - `lib/features/transactions/presentation/screens/all_transactions_screen.dart:679-681`
  - `lib/features/credits/presentation/widgets/grouped_credit_payment_tile.dart:61`
  - `lib/features/home/domain/use_cases/group_transactions_by_day_use_case.dart:66-73`
- Что происходит:
  - Обычный `transfer` рендерится generic-лейблом и generic-иконкой.
  - Для grouped payment заголовок фиксирован (`homeTransactionsGroupedPayment`), без названия кредита.
  - В feed закладывается `creditId: ''`, что мешает обогащать карточку данными кредита.
- Эффект:
  - Не выполняется требование «вместо “платёж по кредиту” показывать название кредита и иконку кредита».

### F7 (Низкий, но важный для качества): пробелы в тестах на round-trip sync и согласованность суммы
- Наблюдение:
  - Нет тестов, которые проверяют round-trip для `groupId` транзакций и полей кредита в remote data sources.
  - Нет теста, который гарантирует, что сумма в карточке кредита равна сумме, с которой открывается/создаётся платеж.

## Почему симптомы выглядят именно так
- Сразу после оплаты до полного sync/merge grouped-логика ещё может работать.
- После перезапуска и подтягивания удалённых данных часть полей теряется:
  - теряется `groupId` => UI показывает обычный `transfer`.
  - теряются поля кредита => хуже определяется структура платежа (проценты/комиссии), история и суммы расходятся.
- На домашнем экране сумма может выглядеть «верно» за счёт локальной группировки текущих транзакций, а на экране кредита — расходиться из-за другого источника суммы (формула vs schedule).

## План исправления (приоритетный)

### Этап 1. Починить целостность sync данных (критический блокер)
1. `TransactionRemoteDataSource`
- Добавить `groupId` в `mapTransaction(...)` и `_fromDocument(...)`.
2. `CreditRemoteDataSource`
- Добавить в map/parse: `interestCategoryId`, `feesCategoryId`, `firstPaymentDate`.
3. Добавить unit-тесты round-trip remote mapping:
- transaction: `groupId` не теряется.
- credit: все 3 поля не теряются.

Ожидаемый результат: после перезапуска/синка данные платежей и кредита не деградируют.

### Этап 2. Выравнять источник суммы «к оплате»
1. На `CreditDetailsScreen` выводить сумму из ближайшего `scheduleItem`:
- `nextTotal = (principalAmount - principalPaid) + (interestAmount - interestPaid)`
- fallback на расчетную формулу только если schedule реально отсутствует.
2. В `PayCreditSheet` предзаполнять остатки по schedule, а не полные плановые суммы.
3. Добавить unit/widget тест на согласованность суммы между карточкой и оплатой.

Ожидаемый результат: на экране кредита, в кнопке оплаты и в созданной транзакции одинаковая логика суммы.

### Этап 3. Улучшить отображение кредитного платежа в списках
1. Для кредитных платежей (grouped и/или identifiable transfer):
- title = имя кредита,
- leading icon = иконка кредитного аккаунта,
- не использовать generic `Перевод`.
2. В `GroupTransactionsByDayUseCase` передавать реальный `creditId` вместо пустой строки.
3. В `GroupedCreditPaymentTile`/transaction tiles подмешивать данные кредита/счета по `creditId`.

Ожидаемый результат: пользователь всегда видит, по какому именно кредиту прошёл платеж.

### Этап 4. Регрессии и приемка
- Проверки:
  - `dart format --set-exit-if-changed .`
  - `flutter analyze`
  - `flutter test --reporter expanded`
- Сценарии приемки:
  1. Создать кредит, провести платеж (тело + проценты), перезапустить приложение.
  2. Убедиться, что запись не деградировала до generic transfer в контексте кредита.
  3. Проверить, что сумма «следующего платежа» и сумма в созданной операции совпадают.
  4. Убедиться, что в списке транзакций отображаются название и иконка конкретного кредита.

## Дополнительные инженерные рекомендации
- Для устойчивой семантики стоит рассмотреть явный признак кредитного платежа в транзакции:
  - либо новый `type` (например, `credit_payment`),
  - либо стабильный `operationKind`/`metadata` без изменения базового `type`.
- Минимально инвазивный вариант: не менять enum сейчас, но сделать детерминированное определение кредитного платежа по `groupId + link to CreditPaymentGroup`.

## Риски внедрения
- Изменение remote mapping может затронуть совместимость старых документов в Firestore.
- Правка расчета суммы «к оплате» требует аккуратного fallback для старых кредитов без schedule.
- Переоформление списка транзакций потребует дополнительных загрузок/маппинга (важно не ухудшить производительность).

## Что уже подтверждено в коде
- `groupId` есть в локальной модели и БД, но отсутствует в remote mapping транзакций.
- Ключевые поля кредита присутствуют в локальной модели/DAO, но отсутствуют в remote mapping кредита.
- Экран кредита использует формулу аннуитета, а не ближайший schedule item как источник суммы «к оплате».

