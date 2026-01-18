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
