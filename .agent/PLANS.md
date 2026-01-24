# ExecPlan (PLANS.md)

ExecPlan — это самодостаточный, проверяемый и «живой» план работы для сложных задач. Он должен позволять верифицировать подход до начала реализации и фиксировать прогресс по мере выполнения.

## Когда ExecPlan обязателен

- Новая фича или заметное изменение UX/поведения.
- Существенный рефакторинг.
- Миграции БД, изменение схем Drift, правила синхронизации.
- Изменение архитектуры, публичных API, offline-first потоков.
- Оптимизации производительности в горячих путях.

## Правила форматирования

- Один ExecPlan = один файл/раздел задачи.
- Не вкладывать тройные бэктики внутрь одного fenced-блока.
- Команды — отдельным fenced-блоком с языком `bash`.
- Файлы указывать точными путями (`lib/...`, `docs/...`).
- План «живой»: после каждого шага обновлять `Progress`.

## Шаблон ExecPlan

Скопируй шаблон ниже и заполни.

# ExecPlan: <краткое название задачи>

## Context and Orientation
- Цель:
- Область кода:
- Контекст/ограничения:
- Риски:

## Interfaces and Dependencies
- Внешние сервисы (Firebase/Analytics/Crashlytics):
- Локальные зависимости (Drift, codegen):
- Затрагиваемые API/модули:

## Plan of Work
- Крупные этапы работы (1–5 пунктов):

## Concrete Steps
1) ...
2) ...
3) ...

## Validation and Acceptance
- Команды проверки:
```bash
dart format --set-exit-if-changed .
flutter analyze
dart run build_runner build --delete-conflicting-outputs
flutter test --reporter expanded
```
- Acceptance criteria:
  - ...

## Idempotence and Recovery
- Что можно безопасно перезапускать:
- Как откатиться/восстановиться:
- План rollback (для миграций):

## Progress
- [ ] Шаг 1: ...
- [ ] Шаг 2: ...
- [ ] Шаг 3: ...

## Surprises & Discoveries
- Список точек записи транзакций:
  - Use cases: `lib/features/transactions/domain/use_cases/add_transaction_use_case.dart`, `lib/features/transactions/domain/use_cases/update_transaction_use_case.dart`, `lib/features/transactions/domain/use_cases/delete_transaction_use_case.dart`.
  - Репозиторий: `lib/features/transactions/data/repositories/transaction_repository_impl.dart` (upsert/softDelete).
  - DAO: `lib/features/transactions/data/sources/local/transaction_dao.dart` (upsert/upsertAll/markDeleted).
  - Sync: `lib/core/services/auth_sync_service.dart` (`_transactionDao.upsertAll` + перерасчёт балансов).
  - Import: `lib/features/settings/data/repositories/import_data_repository_impl.dart` (`_transactionDao.upsertAll` + перерасчёт балансов).
  - Savings: `lib/features/savings/data/repositories/saving_goal_repository_impl.dart` (взнос через `_transactionDao.upsert` и ручной апдейт аккаунта).
  - Upcoming payments: `lib/features/upcoming_payments/data/services/upcoming_payments_work_scheduler.dart` (через `AddTransactionUseCase`).

## Decision Log
- ...

## Outcomes & Retrospective
- Что сделано:
  - Централизован пересчёт балансов в data‑слое и унифицированы обходы use cases (sync/import/взносы).
  - Добавлены unit‑тесты инвариантов баланса; `transaction_repository_impl_test` проходит.
- Что бы улучшить в следующий раз:

# ExecPlan: Единая модель денег (minor-units + scale)

## Context and Orientation
- Цель: заменить `double` на `minor + scale` (BigInt) с единым правилом округления, чтобы исключить накопление ошибок в балансах/аналитике/бюджетах и поддержать крипту.
- Область кода: доменные сущности денег и транзакций, Drift схемы, мапперы, аналитика, бюджеты, синк, импорт/экспорт, UI форматтеры.
- Контекст/ограничения: нужна миграция БД; автоген не править; все вычисления денег должны быть детерминированы.
- Риски: несоответствие форматов в синке/импорте, несовместимость истории, регресс UI‑форматтеров, рост объёма данных.

## Interfaces and Dependencies
- Внешние сервисы: Firestore (синк), CSV import/export.
- Локальные зависимости: Drift миграции, Freezed модели, build_runner.
- Затрагиваемые API/модули: Transactions/Accounts/Budgets/Analytics/Sync/Import/Export.

## Plan of Work
- Спроектировать модель денег `minor + scale` и правила округления/преобразования.
- Провести миграции и обновить хранилища/синк.
- Обновить бизнес‑логику и UI‑форматтеры.
- Добавить тесты инвариантов денег.

## Concrete Steps
1) Выбрать подход: `minor` (BigInt) + `scale` на уровне валюты/актива; зафиксировать правила округления.
2) Обновить доменные сущности и API (Transaction/Account/Budget и т.д.) под новую модель.
3) Добавить Drift‑миграции (новые колонки, backfill, rollback‑стратегия).
4) Обновить синк/импорт/экспорт (преобразование, версия схемы payload).
5) Обновить аналитические агрегации и форматтеры UI.
6) Добавить unit/integration тесты: суммы, округление, transfer, import/export, sync merge.
7) Обновить docs (`docs/logic/feature_invariants.md` и отдельный документ по модели денег).

## Validation and Acceptance
- Команды проверки:
```bash
dart format --set-exit-if-changed .
flutter analyze
dart run build_runner build --delete-conflicting-outputs
flutter test --reporter expanded
```
- Acceptance criteria:
  - Нет `double` для денежных сумм в доменной модели.
  - Баланс и аналитика совпадают на больших наборах данных.
  - Импорт/экспорт и sync сохраняют значения без дрейфа.
  - Крипто‑валюты корректно обрабатываются через `scale`.

## Idempotence and Recovery
- Что можно безопасно перезапускать: миграции в тестовой БД, build_runner, тесты.
- Как откатиться/восстановиться: rollback‑миграция и возврат к `double` в DTO (временно).
- План rollback (для миграций): миграция‑обратка + сохранение исходных колонок до финального cutover.

## Progress
- [x] Шаг 1: Выбрать модель денег и правила округления.
- [x] Шаг 2: Обновить доменные сущности и API.
- [x] Шаг 3: Drift‑миграции и backfill (accounts/transactions/budgets/upcoming/debts/credits/credit_cards — в работе).
- [x] Шаг 4: Синк/импорт/экспорт (обновление payload/remote/export).
- [x] Шаг 5: Аналитика и UI‑форматтеры.
- [x] Шаг 6: Тесты инвариантов денег.
- [x] Шаг 7: Документация.

## Surprises & Discoveries
- ...

## Decision Log
- ...

## Outcomes & Retrospective
- Что сделано:
- Что бы улучшить в следующий раз:

# ExecPlan: Производительность аналитики (актуальная реализация)

## Context and Orientation
- Цель: вынести тяжёлые агрегации аналитики из UI‑isolate и стабилизировать расчёты на больших наборах данных.
- Примечание: ниже есть дублирующий ExecPlan про агрегации; этот раздел оставлен как основной.
- Область кода: `lib/features/analytics/domain/use_cases/watch_monthly_analytics_use_case.dart`, `lib/features/analytics/presentation/controllers/analytics_providers.dart`, `lib/core/db/*` (DAO/SQL при необходимости).
- Контекст/ограничения: не править автоген (`*.g.dart`, `*.freezed.dart`); логика отчётов и фильтров должна совпасть с текущей; offline‑first.
- Риски: расхождение сумм из‑за фильтров/переводов, регресс скорости при неверных индексах, дергание UI от лишних rebuild.

## Interfaces and Dependencies
- Внешние сервисы (Firebase/Analytics/Crashlytics): не затрагиваются.
- Локальные зависимости (Drift, codegen): Drift/SQL, возможны новые DAO‑запросы и индексы.
- Затрагиваемые API/модули: аналитические use cases, провайдеры, форматтеры результата.

## Plan of Work
- Зафиксировать текущую логику и метрики времени на наборе данных 10k+.
- Перенести агрегации в Drift/SQL (или isolate), сохранив инварианты.
- Стабилизировать rebuild через `.select()` и кэш.
- Добавить тесты на совпадение результатов и обновить документацию.

## Concrete Steps
1) Инвентаризация: где именно считаются суммы, какие фильтры и группировки используются.
2) Спроектировать SQL‑агрегации (Drift) под текущие отчёты: month/year, account/category filters, transfers.
3) Реализовать DAO‑запросы и use case, заменить вычисления в `analytics_providers.dart`.
4) Добавить кэш/мемоизацию и минимизировать rebuild через `.select()`.
5) Добавить unit‑тесты на совпадение результатов (до/после) на фиксированных наборах данных.
6) Обновить `docs/logic/feature_invariants.md` (раздел аналитики).

## Validation and Acceptance
- Команды проверки:
```bash
dart format --set-exit-if-changed .
flutter analyze
flutter test --reporter expanded
```
- Acceptance criteria:
  - Аналитика по месяцам и счетам совпадает с текущими значениями на эталонных данных.
  - Время построения отчёта на 10k+ транзакций не блокирует UI.
  - Провайдеры не пересчитывают полную аналитику при незначимых изменениях.

## Idempotence and Recovery
- Что можно безопасно перезапускать: тесты, форматирование, analyze, build_runner (если потребуется).
- Как откатиться/восстановиться: вернуть вычисления в памяти и удалить новые DAO‑запросы.
- План rollback (для миграций): без миграций; изменения только в коде.

## Progress
- [x] Шаг 1: Инвентаризация логики и метрик.
- [x] Шаг 2: Проектирование SQL‑агрегаций.
- [x] Шаг 3: Реализация DAO/use case и замена провайдеров.
- [x] Шаг 4: Оптимизация rebuild/caching.
- [x] Шаг 5: Тесты совпадения результатов.
- [x] Шаг 6: Документация.

## Surprises & Discoveries
- ...

## Decision Log
- ...

## Outcomes & Retrospective
- Что сделано:
- Тесты на совпадение результатов аналитики добавлены, документация обновлена.
- Предупреждения analyze по private types в провайдерах аналитики устранены (публичные окна дат/месяцев).
- Что бы улучшить в следующий раз:

# ExecPlan: Полный отказ от double в модели денег

## Context and Orientation
- Цель: убрать legacy `double` из доменных денег, перейти на `minor/scale` во всех сущностях, моделях, use cases и форматтерах UI.
- Область кода: `lib/features/*/domain`, `lib/features/*/data`, `lib/core/money/*`, аналитика, бюджеты, upcoming payments, credits, savings, home.
- Контекст/ограничения: не править автоген (`*.g.dart`, `*.freezed.dart`); не менять секреты; миграции Drift уже есть.
- Риски: массовые изменения API сущностей, регресс сериализации, ломаются тесты/формы/форматтеры.

## Interfaces and Dependencies
- Внешние сервисы: Firestore payload (sync), CSV/JSON import/export.
- Локальные зависимости: Freezed, Drift, build_runner, Riverpod.
- Затрагиваемые API/модули: Account/Transaction/Budget/Upcoming/Credits/Savings/Analytics.

## Plan of Work
- Зафиксировать источники `double` и определить правила замены на `minor/scale`.
- Перевести доменные сущности и DTO на `minor/scale`.
- Обновить use cases/репозитории/форматтеры/аналитику.
- Перегенерировать код и стабилизировать тесты.

## Concrete Steps
1) Инвентаризация: список сущностей и моделей, где `double` ещё используется.
2) Обновить доменные сущности и вспомогательные модели (remove `double`, добавить `minor/scale`).
3) Обновить мапперы/DAO/remote payloads под `minor/scale` как единственный источник.
4) Обновить UI‑форматтеры и расчёты аналитики на `MoneyAmount`/`MoneyAccumulator`.
5) Прогнать build_runner, форматирование, анализ и тесты; исправить регрессии.
6) Обновить `docs/logic/money_model.md` и `docs/logic/feature_invariants.md`.

## Validation and Acceptance
- Команды проверки:
```bash
dart format --set-exit-if-changed .
flutter analyze
dart run build_runner build --delete-conflicting-outputs
flutter test --reporter expanded
```
- Acceptance criteria:
  - В доменных сущностях нет денежных `double`.
  - Все расчёты денег выполняются через `minor/scale`.
  - Тесты зелёные, сериализация стабильна.

## Idempotence and Recovery
- Что можно безопасно перезапускать: build_runner, тесты, форматирование.
- Как откатиться/восстановиться: вернуть legacy `double` поля и конвертеры.
- План rollback: без миграций (схема уже расширена).

## Progress
- [x] Шаг 1: Инвентаризация источников `double`.
- [x] Шаг 2: Обновить доменные сущности и модели.
- [x] Шаг 3: Обновить мапперы/DAO/remote payloads.
- [x] Шаг 4: Обновить UI и аналитику.
- [x] Шаг 5: Проверки и фиксы тестов.
- [x] Шаг 6: Обновить документацию.

## Surprises & Discoveries
- Основные денежные `double` остаются в domain/entities и моделей (Account/Transaction/Budget/BudgetInstance/Upcoming/Credits/Savings/Analytics/Home/AI), а также в use cases/DAO/formatters.

## Decision Log
- ...

## Outcomes & Retrospective
- Что сделано:
- Что бы улучшить в следующий раз:

## Definition of Done (чек-лист)

- `dart format --set-exit-if-changed .` без изменений.
- `flutter analyze` без ошибок.
- `dart run build_runner build --delete-conflicting-outputs` проходит.
- `flutter test --reporter expanded` проходит.
- Новая логика покрыта unit-тестами и хотя бы одним widget или integration тестом.
- Нет тяжелого CPU/I/O на UI isolate.
- Для изменений производительности — есть измерение до/после.

## Regression checklist

- Riverpod: минимизированы лишние rebuild, использованы `.select()`/листовые `ConsumerWidget`.
- Freezed: модели и состояния immutable, корректная генерация.
- Drift: миграции добавлены и протестированы, схема не правится вручную.
- Offline-first: запись сначала в локальную БД.
- Sync: конфликт-стратегия ясна, upsert идемпотентен.
- UI: списки оптимизированы (`itemExtent`/`prototypeItem`), форматтеры кэшированы.
- Ошибки/сеть: корректные offline/syncing/up-to-date состояния.

## Документация

- Любое изменение поведения → обновить `docs/`.
- Миграции/схемы → описать в `docs/logic/` (отдельный документ или обновление существующего).
- Изменения UX → `docs/components/` или `docs/logic/` с описанием поведения.
- Минимальный формат записи:
  - Что изменилось
  - Зачем
  - Как проверить
  - Breaking changes (если есть)

# ExecPlan: Настройки и учет счетов для виджета обзора

## Context and Orientation
- Цель: исправить расчеты виджета обзора (учитывать все счета по умолчанию) и добавить экран настроек обзора для выбора счетов и категорий.
- Область кода: `lib/features/home/*`, `lib/features/overview/*`, `lib/core/navigation/app_router.dart`, `lib/l10n/*`, `docs/components/HomeOverviewSummaryCard.md`.
- Контекст/ограничения: настройки обзора не должны влиять на аналитику и другие экраны; авто‑генерируемые файлы не редактировать вручную.
- Риски: регресс фильтрации счетов/категорий; отсутствие синхронизации между устройствами.

## Interfaces and Dependencies
- Внешние сервисы (Firebase/Analytics/Crashlytics): не затрагиваются.
- Локальные зависимости (Drift, codegen): Freezed + SharedPreferences, возможен `flutter gen-l10n`.
- Затрагиваемые API/модули: `WatchHomeOverviewSummaryUseCase`, Riverpod провайдеры, Overview UI.

## Plan of Work
- Спроектировать модель настроек обзора и репозиторий хранения.
- Подключить настройки к расчету summary.
- Реализовать экран настроек (шестеренка на Overview screen).
- Обновить тесты и документацию.

# ExecPlan: Учет переводов в аналитике

## Context and Orientation
- Цель: корректно учитывать переводы между счетами в балансах/кэшфлоу и аналитике по выбранным счетам.
- Область кода: `lib/features/analytics/presentation/controllers/analytics_providers.dart`, `lib/features/analytics/domain/use_cases/*`, возможно `lib/features/transactions/domain/entities/transaction.dart`.
- Контекст/ограничения: не трогать автоген; не менять модель денег без необходимости; логика должна учитывать transferAccountId и направление перевода.
- Риски: регресс в существующих отчётах, неверные фильтры по счетам, расхождения с UI ожиданиями.

## Interfaces and Dependencies
- Внешние сервисы: не затрагиваются.
- Локальные зависимости: Riverpod providers, Money model, аналитические use cases.
- Затрагиваемые API/модули: аналитика баланса/кэшфлоу, фильтры по счетам, возможно форматтеры.

## Plan of Work
- Зафиксировать бизнес‑логику перевода в аналитике (как влияет на исходный/целевой счет).
- Обновить расчёты баланса и кэшфлоу с учетом transferAccountId.
- Добавить/обновить тесты аналитики по переводам.
- Обновить документацию об инвариантах аналитики.

## Concrete Steps
1) Просмотреть текущую реализацию аналитики и точки расчётов баланса/кэшфлоу.
2) Определить правила:
   - перевод между счетами: уменьшает исходный, увеличивает целевой;
   - фильтр по выбранным счетам учитывает обе стороны перевода.
3) Обновить расчёты в `analytics_providers.dart` и/или use case.
4) Добавить unit‑тесты на перевод между двумя счетами и на фильтр по одному счету.
5) Обновить `docs/logic/feature_invariants.md` (раздел аналитики/переводов).

## Validation and Acceptance
- Команды проверки:
```bash
dart format --set-exit-if-changed .
flutter analyze
flutter test --reporter expanded
```
- Acceptance criteria:
  - Баланс/кэшфлоу по счетам учитывает переводы.
  - Перевод между счетами корректно отражается при фильтре по одному счету.
  - Тесты аналитики зелёные.

## Idempotence and Recovery
- Что можно безопасно перезапускать: тесты, форматирование, analyze.
- Как откатиться/восстановиться: вернуть расчёты к текущей логике, удалить новые тесты.
- План rollback: без миграций, откат по git.

## Progress
- [x] Шаг 1: Анализ текущей логики аналитики
- [x] Шаг 2: Определение правил учета переводов
- [x] Шаг 3: Реализация изменений
- [x] Шаг 4: Тесты
- [x] Шаг 5: Документация

## Surprises & Discoveries
- ...

## Decision Log
- ...

## Outcomes & Retrospective
- Что сделано:
- Что бы улучшить в следующий раз:

# ExecPlan: Пересчет балансов после LWW merge в sync

## Context and Orientation
- Цель: после LWW merge аккаунтов пересчитывать баланс по транзакциям, чтобы избежать рассинхронизации `account.balance`.
- Область кода: `lib/core/services/auth_sync_service.dart`, возможные helpers в data‑слое.
- Контекст/ограничения: offline‑first, источник истины — Drift; автоген не трогать; без изменения схемы Drift.
- Риски: регресс в синке/слиянии, ошибки производительности, неконсистентность при частичном обновлении.

## Interfaces and Dependencies
- Внешние сервисы: Firestore (sync).
- Локальные зависимости: Drift, transaction balance helper, account DAO.
- Затрагиваемые API/модули: `AuthSyncService`, sync merge accounts, пересчет балансов.

## Plan of Work
- Найти точку LWW merge аккаунтов и текущие места пересчёта балансов.
- Определить единый путь пересчёта по транзакциям после merge.
- Внедрить пересчет в sync и закрыть edge‑cases.
- Добавить unit‑тест на конфликтный merge.
- Обновить документацию по sync‑инвариантам.

## Concrete Steps
1) Проанализировать `auth_sync_service.dart` (LWW merge аккаунтов, текущий пересчет).
2) Зафиксировать правила пересчёта: баланс = `openingBalance + сумма транзакций` с учетом переводов/кредитов.
3) Реализовать пересчет через общий helper после merge (внутри транзакции sync).
4) Добавить unit‑тест: конфликт локальные/удаленные транзакции + проверка баланса.
5) Обновить `docs/logic/feature_invariants.md` (sync).

## Validation and Acceptance
- Команды проверки:
```bash
dart format --set-exit-if-changed .
flutter analyze
flutter test --reporter expanded
```
- Acceptance criteria:
  - После merge баланс соответствует транзакциям.
  - Переводы/кредиты учитываются в пересчете.
  - Тест синка стабилен.

## Idempotence and Recovery
- Что можно безопасно перезапускать: sync тесты, форматирование, analyze.
- Как откатиться/восстановиться: убрать пересчет из sync, оставить прежний LWW.
- План rollback: без миграций, откат по git.

## Progress
- [x] Шаг 1: Анализ LWW merge и точек пересчёта
- [x] Шаг 2: Правила пересчёта в sync
- [x] Шаг 3: Реализация
- [x] Шаг 4: Тесты
- [x] Шаг 5: Документация

## Surprises & Discoveries
- ...

## Decision Log
- ...

## Outcomes & Retrospective
- Что сделано:
- Что бы улучшить в следующий раз:

# ExecPlan: Стабилизация тестов sync/transactions

## Context and Orientation
- Цель: устранить падения тестов, отмеченные в аудите (auth_sync, transactions, upcoming_payments, ai repo).
- Область кода: `test/core/services/auth_sync_service_test.dart`, `test/features/transactions/*`, `test/features/upcoming_payments/*`, `test/features/ai/*`.
- Контекст/ограничения: не менять поведение без фикса в доменной логике; автоген не править.
- Риски: маскирование ошибок вместо фикса; регресс поведения.

## Interfaces and Dependencies
- Внешние сервисы: Fake Firestore, моки.
- Локальные зависимости: Riverpod, Drift, mocktail.
- Затрагиваемые API/модули: AuthSyncService, TransactionForm, Upcoming notifications, AI repo.

## Plan of Work
- Собрать список актуальных падений и их причин.
- Починить тесты/логику по одному, начиная с auth_sync и transactions.
- Добавить/скорректировать моки/фейки и ожидания.
- Прогнать наборы тестов и обновить документацию при изменении поведения.

## Concrete Steps
1) Пройтись по падениям из аудита и сверить с текущими логами.
2) Исправить `AuthSyncService` тесты (outbox normalizer, контракт ошибок).
3) Исправить `transactions` тесты (таймеры/DB mocks/DI).
4) Исправить `upcoming_payments` и `ai` тесты (mocktail fallback, verifyNever).
5) Прогнать точечные тесты и обновить DoD.

## Validation and Acceptance
- Команды проверки:
```bash
flutter test --reporter expanded
```
- Acceptance criteria:
  - Все указанные тесты проходят.
  - Поведение сервиса не изменено без фикса логики.

## Idempotence and Recovery
- Что можно безопасно перезапускать: тесты, analyze.
- Как откатиться/восстановиться: вернуть изменения в тестах/моках по git.
- План rollback: не требуется.

## Progress
- [x] Шаг 1: Анализ текущих падений
- [x] Шаг 2: AuthSyncService тесты
- [x] Шаг 3: Transactions тесты
- [x] Шаг 4: Upcoming/Ai тесты
- [x] Шаг 5: Проверка полного набора

## Surprises & Discoveries
- ...

## Decision Log
- ...

## Outcomes & Retrospective
- Что сделано:
- Что бы улучшить в следующий раз:

## Concrete Steps
1) Создать сущность/репозиторий/контроллер настроек обзора (SharedPreferences).
2) Изменить `WatchHomeOverviewSummaryUseCase` и провайдеры, чтобы учитывать выбранные счета/категории (по умолчанию — все).
3) Добавить экран настроек обзора и кнопку‑шестеренку, подключить к роутеру.
4) Обновить l10n строки, тесты и docs.

## Validation and Acceptance
- Команды проверки:
```bash
dart format --set-exit-if-changed .
flutter analyze
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
flutter test --reporter expanded
```
- Acceptance criteria:
  - Скрытые счета учитываются в обзоре по умолчанию.
  - Настройки обзора применяются только к виджету обзора.
  - По умолчанию выбраны все счета/категории (включая кредиты/долги).
  - Шестеренка открывает экран настройки обзора.

## Idempotence and Recovery
- Что можно безопасно перезапускать: `flutter gen-l10n`, `build_runner`.
- Как откатиться/восстановиться: удалить новые настройки из SharedPreferences и вернуть прежнюю логику фильтрации.
- План rollback (для миграций): не требуется.

## Progress
- [x] Шаг 1: Создать сущность/репозиторий/контроллер настроек обзора.
- [x] Шаг 2: Подключить настройки к расчету summary.
- [x] Шаг 3: Экран настроек обзора и шестеренка.
- [x] Шаг 4: L10n, тесты, docs.

## Surprises & Discoveries
- Синхронизация настроек между устройствами требует отдельной инфраструктуры; в рамках задачи используем локальное хранение.

## Decision Log
- Настройки обзора храним локально (SharedPreferences), синхронизацию откладываем.
- В фильтре категорий используем root‑категорию; `null` означает «все».

## Outcomes & Retrospective
- Что сделано:
- Что бы улучшить в следующий раз:

## Definition of Done (чек-лист)

- `dart format --set-exit-if-changed .` без изменений.
- `flutter analyze` без ошибок.
- `dart run build_runner build --delete-conflicting-outputs` проходит.
- `flutter test --reporter expanded` проходит.
- Новая логика покрыта unit-тестами и хотя бы одним widget или integration тестом.
- Нет тяжелого CPU/I/O на UI isolate.

## Regression checklist

- Riverpod: минимизированы лишние rebuild, использованы `.select()`/листовые `ConsumerWidget`.
- Freezed: модели и состояния immutable, корректная генерация.
- Drift: миграции добавлены и протестированы, схема не правится вручную.
- Offline-first: запись сначала в локальную БД.
- Sync: конфликт-стратегия ясна, upsert идемпотентен.
- UI: списки оптимизированы (`itemExtent`/`prototypeItem`), форматтеры кэшированы.
- Ошибки/сеть: корректные offline/syncing/up-to-date состояния.

## Документация

- Обновить `docs/components/HomeOverviewSummaryCard.md` с описанием новых настроек.

# ExecPlan: Единый источник баланса транзакций

## Context and Orientation
- Цель: убрать двойной пересчёт балансов и оставить единый источник (use cases).
- Область кода: `lib/features/transactions/domain/use_cases/*`, `lib/features/transactions/data/repositories/transaction_repository_impl.dart`, тесты в `test/features/transactions/domain/use_cases/*`.
- Контекст/ограничения: изменения без миграций БД; автоген не трогать.
- Риски: скрытые вызовы репозитория напрямую без use case; регресс в балансах.

# ExecPlan: Корректный пересчет балансов транзакций (single source of truth)

## Context and Orientation
- Цель: исключить двойной пересчет, привести create/update/delete к единой логике, гарантировать корректные балансы при sync/import.
- Область кода: `lib/features/transactions/domain/use_cases/add_transaction_use_case.dart`, `lib/features/transactions/domain/use_cases/update_transaction_use_case.dart`, `lib/features/transactions/data/repositories/transaction_repository_impl.dart`, `lib/core/services/auth_sync_service.dart`, `lib/features/settings/data/repositories/import_data_repository_impl.dart`, `lib/features/savings/data/repositories/saving_goal_repository_impl.dart`.
- Контекст/ограничения: без правки автоген‑файлов; без правки секретов; синк должен оставаться идемпотентным.
- Риски: скрытые прямые вызовы репозитория; регресс в балансах и аналитике.

## Interfaces and Dependencies
- Внешние сервисы: Firestore (синк).
- Локальные зависимости: Drift, Riverpod, Freezed.
- Затрагиваемые API/модули: use cases транзакций, репозиторий, sync/import.

## Plan of Work
- Зафиксировать единственный источник пересчета и симметрию операций create/update/delete.
- Привести обходы use cases (sync/import/взносы) к единому механизму.
- Закрыть тестами инварианты баланса.

## Concrete Steps
1) Зафиксировать решение об единственном источнике баланса и описать контракт.
2) Удалить дублирование пересчета и сделать удаление симметричным.
3) Унифицировать обходы use cases (sync/import/взносы).
4) Добавить unit‑тесты инвариантов баланса.
5) Обновить документацию (контракт балансов).

## Validation and Acceptance
- Команды проверки:
```bash
dart format --set-exit-if-changed .
flutter analyze
dart run build_runner build --delete-conflicting-outputs
flutter test --reporter expanded
```
- Acceptance criteria:
  - Баланс меняется ровно на 1 дельту на create/update/delete.
  - Удаление через репозиторий и через use case дает одинаковый результат.
  - После sync/import баланс совпадает с `openingBalance + сумма транзакций`.

## Idempotence and Recovery
- Что можно безопасно перезапускать: `build_runner`, тесты.
- Как откатиться/восстановиться: вернуть прежнюю логику пересчета в одном месте (use case или репозиторий) и удалить общий helper.
- План rollback (для миграций): не требуется.

## Progress
- [x] Шаг 1: Зафиксировать решение об источнике баланса.
- [x] Шаг 2: Удалить дублирование пересчета и сделать удаление симметричным.
- [x] Шаг 3: Унифицировать обходы use cases (sync/import/взносы).
- [x] Шаг 4: Добавить unit‑тесты инвариантов баланса.
- [x] Шаг 5: Обновить документацию (контракт балансов).

## Surprises & Discoveries
- Список точек записи транзакций:
  - Use cases: `lib/features/transactions/domain/use_cases/add_transaction_use_case.dart`, `lib/features/transactions/domain/use_cases/update_transaction_use_case.dart`, `lib/features/transactions/domain/use_cases/delete_transaction_use_case.dart`.
  - Репозиторий: `lib/features/transactions/data/repositories/transaction_repository_impl.dart` (upsert/softDelete).
  - DAO: `lib/features/transactions/data/sources/local/transaction_dao.dart` (upsert/upsertAll/markDeleted).
  - Sync: `lib/core/services/auth_sync_service.dart` (`_transactionDao.upsertAll` + перерасчёт балансов).
  - Import: `lib/features/settings/data/repositories/import_data_repository_impl.dart` (`_transactionDao.upsertAll` + перерасчёт балансов).
  - Savings: `lib/features/savings/data/repositories/saving_goal_repository_impl.dart` (взнос через `_transactionDao.upsert` и ручной апдейт аккаунта).
  - Upcoming payments: `lib/features/upcoming_payments/data/services/upcoming_payments_work_scheduler.dart` (через `AddTransactionUseCase`).

## Decision Log
- Баланс считается derived‑значением и пересчитывается централизованно в data‑слое для всех путей записи транзакций.

## Outcomes & Retrospective
- Что сделано:
- Что бы улучшить в следующий раз:

## Definition of Done (чек-лист)

- `dart format --set-exit-if-changed .` без изменений.
- `flutter analyze` без ошибок.
- `dart run build_runner build --delete-conflicting-outputs` проходит.
- `flutter test --reporter expanded` проходит.
- Новая логика покрыта unit-тестами и хотя бы одним widget или integration тестом.
- Нет тяжелого CPU/I/O на UI isolate.

## Regression checklist

- Riverpod: минимизированы лишние rebuild, использованы `.select()`/листовые `ConsumerWidget`.
- Freezed: модели и состояния immutable, корректная генерация.
- Drift: миграции добавлены и протестированы, схема не правится вручную.
- Offline-first: запись сначала в локальную БД.
- Sync: конфликт-стратегия ясна, upsert идемпотентен.
- UI: списки оптимизированы (`itemExtent`/`prototypeItem`), форматтеры кэшированы.
- Ошибки/сеть: корректные offline/syncing/up-to-date состояния.

## Документация

- Обновить `docs/logic/` с описанием контракта балансов.

## Interfaces and Dependencies
- Внешние сервисы (Firebase/Analytics/Crashlytics): не затрагиваются.
- Локальные зависимости (Drift, codegen): Drift используется; изменений схемы нет.
- Затрагиваемые API/модули: `TransactionRepositoryImpl`, use cases add/update/delete.

## Plan of Work
- Удалить пересчёт баланса из репозитория, оставить в use cases.
- Усилить покрытие unit‑тестами для балансовых сценариев.
- Зафиксировать факт выполнения в аудит‑отчёте.

## Concrete Steps
1) Удалить `_applyAccountBalanceDelta` и связанные элементы из `TransactionRepositoryImpl`.
2) Добавить unit‑тест на смену типа транзакции и корректную дельту баланса.
3) Прогнать локальные тесты на use cases транзакций.
4) Обновить `AUDIT_2026-01-18.md` отметкой о выполнении.

## Validation and Acceptance
- Команды проверки:
```bash
flutter test test/features/transactions/domain/use_cases/add_transaction_use_case_test.dart
flutter test test/features/transactions/domain/use_cases/update_transaction_use_case_test.dart
flutter test test/features/transactions/domain/use_cases/delete_transaction_use_case_test.dart
```
- Acceptance criteria:
  - Баланс пересчитывается только в use cases.
  - Unit‑тесты на баланс (income/expense/transfer, update, delete) проходят.

## Idempotence and Recovery
- Что можно безопасно перезапускать: unit‑тесты, локальные правки в use cases.
- Как откатиться/восстановиться: вернуть `_applyAccountBalanceDelta` в репозиторий.
- План rollback (для миграций): не требуется.

## Progress
- [x] Шаг 1: Удалить пересчёт баланса из репозитория.
- [x] Шаг 2: Добавить unit‑тест на смену типа транзакции.
- [x] Шаг 3: Прогнать тесты use cases.
- [x] Шаг 4: Обновить AUDIT‑отчёт.

## Surprises & Discoveries
- ...

## Decision Log
- Единый источник баланса: use cases add/update/delete.

## Outcomes & Retrospective
- Что сделано:
- Что бы улучшить в следующий раз:

# ExecPlan: Стартовый баланс (opening balance)

## Context and Orientation
- Цель: ввести стартовый баланс счета и привести перерасчет балансов к формуле openingBalance + сумма транзакций.
- Область кода: `lib/core/data/database.dart`, `lib/features/accounts/*`, `lib/core/services/auth_sync_service.dart`, `lib/features/settings/data/repositories/import_data_repository_impl.dart`.
- Контекст/ограничения: требуется миграция Drift; автоген не редактировать.
- Риски: некорректная миграция, изменение семантики редактирования баланса.

## Interfaces and Dependencies
- Внешние сервисы: Firestore (accounts).
- Локальные зависимости: Drift, Freezed, build_runner.
- Затрагиваемые API: AccountEntity, AccountDao, AccountRemoteDataSource, формы добавления/редактирования счета.

## Plan of Work
- Добавить openingBalance в модель и БД.
- Обновить импорт/синк/формы для пересчета.
- Добавить/обновить тесты.

## Concrete Steps
1) Добавить openingBalance в Accounts таблицу и миграцию, обновить AccountEntity/DAO/remote.
2) Привести пересчёт баланса к openingBalance + сумма транзакций, корректно деривировать openingBalance при отсутствии.
3) Обновить add/edit account flows и тесты.
4) Прогнать релевантные тесты и обновить AUDIT.

## Validation and Acceptance
- Команды проверки:
```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/features/settings/data/import_data_repository_impl_test.dart
flutter test test/features/transactions/domain/use_cases/add_transaction_use_case_test.dart
```
- Acceptance criteria:
  - Баланс = openingBalance + сумма транзакций.
  - Импорт/синк корректно пересчитывают openingBalance и баланс.
  - Формы add/edit сохраняют ожидаемый баланс.

## Idempotence and Recovery
- Что можно безопасно перезапускать: build_runner, тесты.
- Как откатиться/восстановиться: вернуть schemaVersion и удалить openingBalance.
- План rollback: не использовать новый столбец (оставить прежнюю логику).

## Progress
- [x] Шаг 1: Добавить openingBalance в модели/БД/remote.
- [x] Шаг 2: Обновить пересчёты баланса.
- [x] Шаг 3: Обновить формы add/edit и тесты.
- [x] Шаг 4: Прогнать тесты и обновить AUDIT.

## Surprises & Discoveries
- ...

## Decision Log
- openingBalance хранится в accounts и синкается в Firestore.

## Outcomes & Retrospective
- Что сделано:
- Что бы улучшить в следующий раз:

# ExecPlan: Производительность аналитики (агрегации вне UI isolate)

## Context and Orientation
- Цель: убрать тяжёлые аналитические агрегации из UI‑изолята и стабилизировать время построения отчётов на больших наборах транзакций.
- Примечание: дублирует план выше, оставлен как итоговая/историческая версия.
- Область кода: `lib/features/analytics/domain/use_cases/watch_monthly_analytics_use_case.dart`, `lib/features/analytics/presentation/controllers/analytics_providers.dart`, возможно `lib/core/db/*` и SQL‑запросы Drift.
- Контекст/ограничения: не править автоген (`*.g.dart`, `*.freezed.dart`); формулы и инварианты аналитики сохраняются; офлайн‑first без регресса.
- Риски: расхождение сумм из‑за логики фильтров, рост времени запросов при неправильных индексах, регресс UI (задержки/мерцание).

## Interfaces and Dependencies
- Внешние сервисы (Firebase/Analytics/Crashlytics): не затрагиваются.
- Локальные зависимости (Drift, codegen): Drift/SQL, возможны новые DAO‑запросы и индексы.
- Затрагиваемые API/модули: аналитические use cases, провайдеры, форматтеры результата.

## Plan of Work
- Зафиксировать текущую логику и точки агрегации, собрать метрики времени.
- Перенести агрегации в Drift/SQL (или isolate при необходимости) и вернуть те же результаты.
- Добавить тесты сравнения результатов и документацию по контракту аналитики.

## Concrete Steps
1) Инвентаризация: где именно в аналитике считаются суммы по всем транзакциям, какие фильтры и группировки используются.
2) Спроектировать SQL‑агрегации (Drift) под текущие отчёты: month/year, account/category filters, transfers.
3) Реализовать DAO‑запросы и use case, заменить вычисления в `analytics_providers.dart`.
4) Добавить кэш/мемоизацию и минимизировать rebuild через `.select()`.
5) Добавить unit‑тесты на совпадение результатов (до/после) на наборе фикстур.
6) Обновить документацию инвариантов аналитики в `docs/logic/feature_invariants.md`.

## Validation and Acceptance
- Команды проверки:
```bash
dart format --set-exit-if-changed .
flutter analyze
flutter test --reporter expanded
```
- Acceptance criteria:
  - Аналитика по месяцам и счетам совпадает с текущими значениями на эталонных данных.
  - Время построения отчёта на 10k+ транзакций не блокирует UI.
  - Провайдеры не пересчитывают полную аналитику при незначимых изменениях.

## Idempotence and Recovery
- Что можно безопасно перезапускать: тесты, форматирование, build_runner (если потребуется).
- Как откатиться/восстановиться: вернуть вычисления в памяти и удалить новые DAO‑запросы.
- План rollback (для миграций): без миграций; изменения только в коде.

## Progress
- [x] Шаг 1: Инвентаризация текущей логики и метрик.
- [x] Шаг 2: Проектирование SQL‑агрегаций.
- [x] Шаг 3: Реализация DAO/use case и замена провайдеров.
- [x] Шаг 4: Оптимизация rebuild/caching.
- [x] Шаг 5: Тесты совпадения результатов.
- [x] Шаг 6: Документация.

## Surprises & Discoveries
- ...

## Decision Log
- ...

## Outcomes & Retrospective
- Что сделано:
- Что бы улучшить в следующий раз:

# ExecPlan: Оптимизация бюджетов (агрегации вне UI isolate)

## Context and Orientation
- Цель: убрать пересчёт бюджетов по всем транзакциям в UI‑isolate и стабилизировать время расчёта прогресса/категорий.
- Область кода: `lib/features/budgets/presentation/controllers/budgets_providers.dart`, `lib/features/budgets/domain/use_cases/compute_budget_progress_use_case.dart`, `lib/features/transactions/data/sources/local/transaction_dao.dart`, `lib/features/transactions/domain/repositories/transaction_repository.dart`.
- Контекст/ограничения: не править автоген (`*.g.dart`, `*.freezed.dart`); формулы бюджета остаются прежними (income/transfer не участвуют).
- Риски: расхождение сумм из‑за фильтров периодов/категорий/счетов, регресс в UI‑обновлениях, неправильная обработка scale.

## Interfaces and Dependencies
- Внешние сервисы: не затрагиваются.
- Локальные зависимости: Drift/SQL, Riverpod.
- Затрагиваемые API/модули: TransactionDao, TransactionRepository, провайдеры бюджетов.

## Plan of Work
- Спроектировать SQL‑агрегации для расходов бюджета по периоду.
- Перевести расчёт бюджета на агрегаты с кэшем и минимальными rebuild.
- Добавить тесты корректности и нагрузочные сценарии.

## Concrete Steps
1) Описать SQL‑агрегации расходов по периоду с группировкой по account/category и scale.
2) Добавить метод DAO + репозитория для получения агрегатов, внедрить в провайдеры бюджетов.
3) Обновить вычисления `budgetsWithProgress`/`budgetCategorySpend` с использованием агрегатов.
4) Добавить тесты агрегатов и сценарии больших наборов данных (performance‑safety).
5) Обновить `docs/logic/feature_invariants.md` и при необходимости `docs/logic/analytics.md`.

## Validation and Acceptance
- Команды проверки:
```bash
dart format --set-exit-if-changed .
flutter analyze
flutter test --reporter expanded
```
- Acceptance criteria:
  - Пересчёт бюджетов не проходит по всем транзакциям в памяти.
  - Суммы бюджета совпадают с прежней логикой на эталонных данных.
  - Тесты на агрегаты и большие наборы данных проходят.

## Idempotence and Recovery
- Что можно безопасно перезапускать: тесты, форматирование, build_runner (если потребуется).
- Как откатиться/восстановиться: вернуть расчёт на списке транзакций в провайдерах.
- План rollback (для миграций): не требуется.

## Progress
- [x] Шаг 1: Спроектировать SQL‑агрегации расходов по периодам.
- [x] Шаг 2: Реализовать DAO/репозиторий и внедрить в провайдеры.
- [x] Шаг 3: Добавить тесты и обновить документацию.

## Surprises & Discoveries
- ...

## Decision Log
- ...

## Outcomes & Retrospective
- Что сделано:
- Расходы для бюджетов агрегируются в Drift и используются в провайдерах без перебора всех транзакций.
- Добавлены тесты агрегатов, включая нагрузочный сценарий.
- Что бы улучшить в следующий раз:
