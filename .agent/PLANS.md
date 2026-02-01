# ExecPlan (PLANS.md)

ExecPlan — самодостаточный, проверяемый и «живой» план работы для сложных задач. Он позволяет верифицировать подход до начала реализации и фиксировать прогресс по мере выполнения.

## Когда ExecPlan обязателен

- Новая фича или заметное изменение UX/поведения.
- Существенный рефакторинг.
- Миграции БД, изменение схем Drift, правила синхронизации.
- Изменение архитектуры, публичных API, offline-first потоков.
- Оптимизации производительности в горячих путях.

## Правила форматирования

- Один ExecPlan = одна задача.
- Не вкладывать тройные бэктики внутрь одного fenced-блока.
- Команды — отдельным fenced-блоком с языком `bash`.
- Файлы указывать точными путями (`lib/...`, `docs/...`).
- План «живой»: после каждого шага обновлять `Progress`.
- План нужно создавать в папке .agent/exec_plans

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
- ...

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

# ExecPlan: Экран кредита по образцу

## Context and Orientation
- Цель: собрать экран деталей кредита по предоставленному образцу, используя шрифты и цвета темы.
- Область кода: `lib/features/credits/presentation/screens/`, `lib/features/credits/presentation/widgets/`, `lib/core/navigation/app_router.dart`.
- Контекст/ограничения: отступ между основными контейнерами 8px; данные из текущих сущностей/потоков; никаких захардкоженных цветов/шрифтов.
- Риски: расхождение текста/структуры с образцом; отсутствие данных для некоторых блоков.

## Interfaces and Dependencies
- Внешние сервисы (Firebase/Analytics/Crashlytics): нет.
- Локальные зависимости (Drift, codegen): возможна генерация l10n при добавлении строк.
- Затрагиваемые API/модули: роутинг `GoRouter`, UI компонентов кредитов.

## Plan of Work
- Сформировать новый экран деталей кредита и подключить его в роутинг.
- Перенастроить навигацию с карточки кредита на новый экран.
- Подключить данные аккаунта/транзакций и сверстать блоки по образцу с темой.
- При необходимости обновить локализацию.

## Concrete Steps
1) Создать экран `CreditDetailsScreen` и сверстать секции (остаток, следующий платеж, история).
2) Добавить маршрут и переход с карточки кредита; предусмотреть переход к редактированию.
3) Подключить данные аккаунта/транзакций и фильтр истории; добавить l10n-строки при необходимости.

## Validation and Acceptance
- Команды проверки:
```bash
dart format --set-exit-if-changed .
flutter analyze
```
- Acceptance criteria:
  - Экран кредита визуально соответствует образцу по структуре.
  - Используются цвета/шрифты темы, отступы между контейнерами 8px.
  - Экран открывается из списка кредитов и не ломает существующие сценарии.

## Idempotence and Recovery
- Что можно безопасно перезапускать: `dart format`, `flutter analyze`, генерация l10n.
- Как откатиться/восстановиться: вернуть изменения в добавленных экранах/роуте.
- План rollback (для миграций): не требуется.

## Progress
- [x] Шаг 1: Создать экран и каркас секций.
- [x] Шаг 2: Подключить маршрут и навигацию.
- [x] Шаг 3: Подключить данные/фильтры и локализацию.

## Surprises & Discoveries
- ...

## Decision Log
- ...

## Outcomes & Retrospective
- Что сделано:
- Что бы улучшить в следующий раз:

# ExecPlan: Идемпотентные автоплатежи (Upcoming)

## Context and Orientation
- Цель: устранить дубли автоплатежей при повторных запусках/смещении часового пояса, добавив идемпотентность на уровне правил и транзакций.
- Область кода: `lib/features/upcoming_payments/`, `lib/features/transactions/`, `lib/core/data/database.dart`, sync/outbox.
- Контекст/ограничения: offline-first, Drift миграции обязательны, автоген не править вручную.
- Риски: некорректная миграция, расхождение схемы локально/в Firebase, ложные блокировки новых транзакций.

## Interfaces and Dependencies
- Внешние сервисы (Firebase/Analytics/Crashlytics): Firestore (payload транзакций/Upcoming).
- Локальные зависимости (Drift, codegen): миграции Drift, build_runner, outbox.
- Затрагиваемые API/модули: `AddTransactionUseCase`, `UpcomingPaymentsWorkScheduler`, репозитории транзакций, мапперы DTO.

## Plan of Work
- Спроектировать idempotency key и маркеры выполнения для Upcoming.
- Внести изменения в схему БД и маппинг (Drift/Firebase).
- Встроить проверку идемпотентности в автопостинг.
- Добавить тесты и документацию.

## Concrete Steps
1) Определить формат ключей:
   - `idempotencyKey = "upcoming:${payment.id}:${yyyy-MM-dd}"` (по локальной due-дате),
   - `lastGeneratedPeriod = "yyyy-MM"` в `UpcomingPayment`.
2) Drift:
   - добавить `idempotencyKey` (text, nullable, unique index) в таблицу транзакций;
   - добавить `lastGeneratedPeriod` (text, nullable) в `UpcomingPayments`;
   - создать миграцию с безопасным дефолтом.
3) Модели/репозитории/мапперы:
   - расширить `TransactionEntity`, `AddTransactionRequest`, `TransactionDao`/репозиторий;
   - обновить payload для Firestore/outbox;
   - добавить метод `findByIdempotencyKey`.
4) Логика автоплатежей:
   - вычислять `dueLocal`, `periodKey`;
   - если `lastGeneratedPeriod == periodKey` → пропуск;
   - иначе проверять `idempotencyKey` в транзакциях и только потом создавать;
   - при успешном создании писать `lastGeneratedPeriod` и `idempotencyKey`.
5) Тесты:
   - unit на `UpcomingPaymentsWorkScheduler`/usecase: повторный запуск не создает дубль;
   - кейсы: смена часового пояса, catch-up после простоя, повтор WorkManager.
6) Документация:
   - описать инварианты идемпотентности и формат ключей в `docs/logic/`.

## Validation and Acceptance
- Команды проверки:
```bash
dart format --set-exit-if-changed .
flutter analyze
dart run build_runner build --delete-conflicting-outputs
flutter test --reporter expanded
```
- Acceptance criteria:
  - Автоплатеж за один период создается ровно один раз.
  - Повторный запуск воркера не создает дубликаты.
  - Смена часового пояса не приводит к дублям.

## Idempotence and Recovery
- Что можно безопасно перезапускать: миграции (в test/CI), build_runner, форматирование, тесты.
- Как откатиться/восстановиться: откат миграции и удаление новых полей из payload.
- План rollback (для миграций): хранить обе колонки nullable; если откат — игнорировать поля в коде, не полагаясь на индекс.

## Progress
- [ ] Шаг 1: Формат ключей и модельная спецификация.
- [ ] Шаг 2: Drift миграции и обновление схемы.
- [ ] Шаг 3: Репозитории/мапперы/DTO.
- [ ] Шаг 4: Идемпотентность в автопостинге.
- [ ] Шаг 5: Тесты.
- [ ] Шаг 6: Документация.

## Surprises & Discoveries
- ...

## Decision Log
- Выбран вариант 3: idempotency key в транзакциях + lastGeneratedPeriod в Upcoming.

## Outcomes & Retrospective
- Что сделано:
- Что бы улучшить в следующий раз:
