# ExecPlan: Аудит и план исправления кредитных платежей

## Context and Orientation
- Цель: устранить расхождения в типах/суммах кредитных платежей после перезапуска и синка, а также привести отображение кредитных операций к понятному виду.
- Область кода: `lib/features/credits/*`, `lib/features/transactions/*`, `lib/core/services/auth_sync_service.dart`, `lib/features/*/data/sources/remote/*`.
- Контекст/ограничения: offline-first, Drift как source-of-truth, синк через outbox + Firestore, автоген (`*.g.dart`) не редактируется вручную.
- Риски: потеря ссылок между сущностями при merge/sync, регресс балансов при корректировке логики платежей.

## Interfaces and Dependencies
- Внешние сервисы: Firestore (`transactions`, `credits`).
- Локальные зависимости: Drift (`transactions.group_id`, `credits.*CategoryId`, `credits.firstPaymentDate`), Riverpod-провайдеры кредитов/транзакций.
- Затрагиваемые модули:
  - `TransactionRemoteDataSource`
  - `CreditRemoteDataSource`
  - `MakeCreditPaymentUseCase`
  - `PayCreditSheet`
  - `CreditDetailsScreen`
  - `GroupTransactionsByDayUseCase`

## Plan of Work
- Зафиксировать и документировать фактические дефекты по типам и суммам.
- Спроектировать безопасные правки сериализации/десериализации для восстановления целостности кредитных данных.
- Уточнить расчет/источник суммы «следующего платежа» и сумму фактического списания.
- Спроектировать UX-правки списка транзакций (название кредита + иконка кредита).
- Добавить тест-контур для защиты от повторной деградации.

## Concrete Steps
1) Синк и целостность данных
- Добавить `groupId` в remote-map транзакций и remote-parse транзакций.
- Добавить `interestCategoryId`, `feesCategoryId`, `firstPaymentDate` в remote-map/parse кредитов.
- Проверить merge-поведение `AuthSyncService` на кейсе «локально есть groupId/категории, в remote не было». 

2) Корректность сумм платежа
- На экране кредита показывать сумму из ближайшего `scheduleItem.totalAmount` (или остатка `total - alreadyPaid`), а не по общей формуле от первоначального долга.
- В `PayCreditSheet` предзаполнять остаток по ближайшему платежу:
  - `principal = max(0, principalAmount - principalPaid)`
  - `interest = max(0, interestAmount - interestPaid)`
- Согласовать single-source расчета «к оплате» между карточкой кредита и шторкой оплаты.

3) Отображение в списках
- Для кредитного платежа в обычном списке транзакций показывать:
  - title = имя кредита,
  - icon = иконка кредитного счета,
  - вместо общего `Перевод`/`Платёж по кредиту`.
- Для этого обогатить feed/group данными кредита (не оставлять `creditId: ''`).

4) Тестирование
- Unit: remote mapping для `TransactionRemoteDataSource` и `CreditRemoteDataSource` (round-trip полей).
- Unit: вычисление суммы к оплате (частично оплаченный период).
- Integration/Service: auth sync не теряет `groupId` и credit-category links.
- Widget: экран кредита и список транзакций показывают согласованные суммы и корректные заголовки.

## Validation and Acceptance
- Команды проверки:
```bash
dart format --set-exit-if-changed .
flutter analyze
flutter test --reporter expanded
```
- Acceptance criteria:
  - После перезапуска/синка кредитный платеж не деградирует до «обычного перевода».
  - Сумма «следующего платежа» на экране кредита равна сумме, с которой открывается/проводится оплата.
  - В списке транзакций для кредитного платежа отображаются название и иконка кредита.

## Idempotence and Recovery
- Что можно безопасно перезапускать: форматирование, analyze, тесты, sync-скрипты/тесты.
- Как откатиться: revert изменений в remote data sources и UI логике суммы/тайлов; повторная синхронизация восстановит текущую схему данных.
- План rollback: поля в remote payload добавляются backward-compatible (nullable), rollback возможен без миграций БД.

## Progress
- [x] Шаг 1: Проведен аудит кода и выявлены корневые причины.
- [x] Шаг 2: Сформирован ExecPlan.
- [x] Шаг 3: Подготовлен детальный аудит-отчет с планом исправления.

## Surprises & Discoveries
- В remote-моделях кредитов и транзакций отсутствуют критические поля, что вызывает скрытую деградацию после merge/sync.

## Decision Log
- Для согласованности сумм выбран приоритет графика платежей (`CreditPaymentSchedule`) как источника правды для «следующего платежа».

## Outcomes & Retrospective
- Что сделано: выявлены дефекты и сформирован приоритетный план исправления.
- Что бы улучшить в следующий раз: добавить обязательные round-trip тесты для каждого remote data source при расширении доменных моделей.
