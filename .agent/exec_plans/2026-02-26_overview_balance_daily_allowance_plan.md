# ExecPlan: Виджет «Остаток в день» на Overview + связь с Upcoming Incomes

## Context and Orientation
- Цель: реализовать на `OverviewScreen` рабочий виджет «Остаток в день», который показывает, сколько можно тратить в день до ближайшего поступления денег, с учетом текущего остатка и будущих запланированных движений.
- Область кода:
  - `lib/features/overview/` (новый use case, provider, UI карточки)
  - `lib/features/upcoming_payments/` (модель, форма, Drift, мапперы)
  - `lib/core/data/database.dart` (миграция схемы)
  - `docs/logic/` (описание алгоритма и инвариантов)
- Контекст/ограничения:
  - offline-first, локальная БД — source-of-truth;
  - нельзя править автоген-файлы вручную;
  - тяжелые вычисления не в `build`; расчет в domain/use case.
- Риски:
  - неоднозначность по горизонту расчета, если нет ближайшего дохода;
  - корректность рецидива (31 число, февраль, TZ);
  - риск регрессии в Upcoming (валидация, синк, payload).

## Interfaces and Dependencies
- Внешние сервисы (Firebase/Analytics/Crashlytics):
  - Outbox/Firebase payload для `upcoming_payment` должен принять новое поле типа движения.
- Локальные зависимости (Drift, codegen):
  - миграция `upcoming_payments` + `build_runner`.
- Затрагиваемые API/модули:
  - `UpcomingPayment` entity/DAO/mapper/repository;
  - `EditUpcomingPaymentScreen` (добавить выбор «Расход/Доход»);
  - `OverviewScreen` + provider для карточки баланса.

## Plan of Work
- Расширить Upcoming Payments до двунаправленных движений (`expense`/`income`).
- Добавить доменный расчет «остатка в день» как отдельный use case с детерминированной формулой.
- Подключить расчет к `OverviewScreen` и обновить UI/локализацию.
- Закрыть тестами (алгоритм + миграция + ключевые UI-сценарии).

## Concrete Steps
1) Доменная модель и миграция Upcoming
- Добавить в `UpcomingPayment` поле `flowType` (`expense` | `income`) с дефолтом `expense`.
- Drift: добавить колонку `flow_type` в `upcoming_payments` (NOT NULL, default `'expense'`), поднять `schemaVersion`.
- Обновить mapper/dao/repository/outbox payload и remote data source.
- Обновить create/update use case и валидатор (правила одинаковые по сумме, знак хранится через `flowType`, сумма всегда > 0).

2) UI Upcoming: ввод «планируемого дохода»
- В `EditUpcomingPaymentScreen` добавить переключатель типа движения (расход/доход).
- Для `income` ограничить список категорий доходными (type=`income`), для `expense` — расходными (type=`expense`).
- В списках/карточках предстоящих платежей визуально различать направления (знак/цвет/иконка/подпись).
- Актуализировать тексты уведомлений: «к списанию» vs «к поступлению».

3) Новый use case для Overview
- Добавить `WatchOverviewDailyAllowanceUseCase` (stream) в `lib/features/overview/domain/use_cases/`.
- Источники:
  - `AccountRepository.watchAccounts()` — текущий остаток;
  - `UpcomingPaymentsRepository.watchAll()` — активные плановые движения;
  - `OverviewPreferences` — фильтр по счетам (как в финансовом индексе).
- Алгоритм (v1):
  - `currentBalance = sum(balanceMinor)` по выбранным счетам;
  - построить ближайшие upcoming-ивенты в окне `[today..horizon]` на основе `SchedulePolicy`;
  - `nextIncomeDate = ближайшая дата flowType=income` (если есть);
  - `horizon = nextIncomeDate`, иначе `today + 30 дней` (детерминированный fallback);
  - `plannedIncome = sum(income events <= horizon)`;
  - `plannedExpense = sum(expense events < horizon)`;
  - `disposable = currentBalance + plannedIncome - plannedExpense`;
  - `daysLeft = max(1, календарные дни до horizon)`;
  - `dailyAllowance = disposable / daysLeft`.
- Выходная DTO-модель:
  - `dailyAllowance`, `daysLeft`, `horizonDate`, `disposableAtHorizon`,
  - `plannedIncome`, `plannedExpense`, `hasIncomeAnchor`, `isNegative`.

4) Интеграция в Overview UI
- Добавить provider в `overview` presentation controllers.
- Заменить статический `_BalanceCard` на данные из нового provider.
- Состояния: loading skeleton, error fallback, empty fallback.
- Обновить формулировки в l10n:
  - основная метрика «Можно тратить в день»;
  - подстрока «до ближайшего поступления / на ближайшие 30 дней».

5) Тесты и документация
- Unit тесты расчета:
  - базовый сценарий с ближайшим доходом;
  - только расходы, без доходов (fallback 30 дней);
  - доход раньше расхода/расход раньше дохода;
  - месяцы с 28/30/31 днем;
  - отрицательный disposable.
- Unit/интеграция миграции Drift для `flow_type`.
- Widget тест карточки Balance с мок-провайдером.
- Обновить `docs/logic/feature_invariants.md` и добавить `docs/logic/overview_daily_allowance.md`.

## Validation and Acceptance
- Команды проверки:
```bash
dart format --set-exit-if-changed .
flutter analyze
dart run build_runner build --delete-conflicting-outputs
flutter test --reporter expanded
```
- Acceptance criteria:
  - На `OverviewScreen` карточка показывает дневной лимит из реальных данных.
  - Значение меняется при изменении баланса/предстоящих платежей в реальном времени.
  - Upcoming supports `income` и корректно учитывается в расчете.
  - Миграция не ломает существующие записи (старые записи считаются `expense`).

## Idempotence and Recovery
- Что можно безопасно перезапускать:
  - `build_runner`, `format`, `analyze`, тесты, повторный апгрейд БД в тестовой среде.
- Как откатиться/восстановиться:
  - откатить использование `flowType` в UI/use cases,
  - временно игнорировать новое поле в расчетах.
- План rollback (для миграций):
  - `flow_type` добавляется с дефолтом и backward-compatible чтением;
  - при rollback код читает отсутствие поля как `expense`.

## Progress
- [x] Шаг 1: Модель `flowType` + миграция Drift + маппинг.
- [x] Шаг 2: UI Upcoming для выбора `Расход/Доход`.
- [x] Шаг 3: Use case `WatchOverviewDailyAllowanceUseCase`.
- [x] Шаг 4: Интеграция карточки остатка в `OverviewScreen`.
- [x] Шаг 5: Тесты + документация.

## Surprises & Discoveries
- Текущая карточка `_BalanceCard` на `OverviewScreen` полностью статическая и не использует доменные данные.
- В `UpcomingPayment` сейчас нет признака направления движения; модель де-факто «только расход».

## Decision Log
- Выбран явный `flowType` в `UpcomingPayment`, а не вывод направления только из `Category.type`:
  - проще миграция поведения формы;
  - меньше скрытых зависимостей;
  - понятнее для будущих сценариев (например, поступление без категории дохода на старте).
- Горизонт расчета выбран «до ближайшего дохода, иначе 30 дней» как стабильный и предсказуемый UX.

## Outcomes & Retrospective
- Что сделано:
  - Сформирован план реализации end-to-end с учетом БД, домена, UI и тестов.
- Что бы улучшить в следующий раз:
  - заранее зафиксировать продуктовые правила округления/отображения отрицательного дневного лимита.

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
- Что изменилось: добавлен расчет дневного лимита и поддержка плановых доходов в Upcoming.
- Зачем: показывать реалистичный «остаток в день» до поступления денег.
- Как проверить: изменить баланс/предстоящие доходы-расходы и убедиться, что карточка пересчитывается.
- Breaking changes: добавлено новое поле `flowType` в `UpcomingPayment` payload.
