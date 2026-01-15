# AGENTS.md

**Проект:** kopim  
**Стек:** Flutter, Riverpod, Freezed, Drift, Firebase  
**Цели:** Android, iOS, Web, Desktop

---

## 0) Language Policy

- Все ответы ИИ — **на русском языке**.
- Комментарии в коде, тексты в PR, описания коммитов, документация — **на русском языке**.
- В названиях классов/переменных/файлов — общепринятый **английский** (Flutter/Dart-идиомы).

---

## 1) Быстрый старт (ключевые команды)

```bash
flutter pub get

# Если обновлялись токены темы из Figma
flutter pub run tool/figma_theme/generate_tokens.dart

# Генерация кода (Freezed, Drift и др.)
dart run build_runner build --delete-conflicting-outputs

# Форматирование
dart format --set-exit-if-changed .

# Анализ
flutter analyze

# Тесты
flutter test --reporter expanded

# Проверка зависимостей
flutter pub outdated
```

---

## 2) Когда обязателен ExecPlan

ExecPlan обязателен для задач уровня «feature/рефакторинг/архитектура»:

- Новые фичи или крупные изменения UX/логики.
- Существенные рефакторинги модулей/слоев.
- Любые миграции БД, изменения схем Drift или логики синхронизации.
- Изменения архитектуры, публичных API модулей, offline-first потоков.
- Производительность в горячих путях (списки, аналитика, синк).

Шаблон и правила: `.agent/PLANS.md`.

---

## 3) Карта репозитория

- Точки входа:
  - `lib/main.dart`
  - `lib/app/app.dart`
- Фичи (feature-first):
  - `lib/features/*/presentation` — UI, Riverpod.
  - `lib/features/*/domain` — сущности (Freezed), use cases, интерфейсы.
  - `lib/features/*/data` — репозитории, Drift DAO, Firebase-адаптеры.
- Общие:
  - `lib/core/` — дизайн-система, тема, DI, сервисы.
  - `lib/core/db/` — Drift, миграции, адаптеры.
  - `docs/components/` — документация по UI-компонентам.
  - `docs/logic/` — архитектура, процессы, инварианты.

---

## 4) Архитектура и ключевые принципы

- Clean Architecture + DDD, модульность по фичам.
- Domain слой не зависит от Flutter/Firebase/Drift.
- Все модели и состояния — immutable (Freezed, value equality).
- Riverpod — DI и state management; в горячих путях использовать `.select()`.
- Drift — локальный source-of-truth; изменения через миграции.
- Любые тяжелые операции (Drift/JSON/агрегации) — вне UI isolate.
- Offline-first: сначала запись в Drift, синк с Firestore фоном.
- Производительность UI:
  - `itemExtent`/`prototypeItem` для списков.
  - Кэш форматтеров дат/денег.
  - Минимум логики в `build`, больше `const`.

Детальные инварианты по фичам: `docs/logic/feature_invariants.md`.

---

## 5) Тестирование и качество

- Unit: доменные сущности, value-объекты, use cases, мапперы.
- Widget: элементы списков, пустые/ошибочные состояния, формы.
- Integration: DB + sync, recurring (time travel).
- DoD: форматирование, analyze, build_runner, тесты зелёные.

---

## 6) Документация

- Любое изменение поведения → обновить `docs/`.
- Новый UI-компонент → `docs/components/`.
- Новое архитектурное решение/сервис → `docs/logic/`.
- Индексы: `docs/README.md` и `docs/logic/README.md`.
- Руководство по агентам и ExecPlan: `docs/logic/ai_agents.md`.

---

## 7) Безопасность, запреты, чувствительные файлы

- Не редактировать секреты и генерируемые конфиги: `.env`, `firebase_options.dart`, `google-services.json`, `GoogleService-Info.plist`, `upload-keystore.jks`.
- Не редактировать автоген: `*.g.dart`, `*.freezed.dart`, `*.drift.dart`.
- Не запускать деплой-команды без явного запроса:
  - `firebase deploy`, `flutter build ipa`, `flutter build appbundle` и т.п.
- Схема Drift меняется только через миграции с описанием и планом отката.

---

## 8) Где искать дополнительные правила

- ExecPlan: `.agent/PLANS.md`
- Workflows: `.agent/workflows/`
- Инварианты по фичам: `docs/logic/feature_invariants.md`
- Процессы для агентов: `docs/logic/ai_agents.md`

---

AGENTS.md — быстрый вход. Если меняются архитектура, сборка или тестирование, обновляй этот файл и соответствующие документы в `docs/logic/`.
