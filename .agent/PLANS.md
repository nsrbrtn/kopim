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
