# Инструкции для ИИ-агентов и ExecPlan

Этот документ описывает, где лежат агентские инструкции и как оформлять ExecPlan для сложных задач.

## Где лежат инструкции

- `AGENTS.md` — быстрый вход, ключевые правила и команды.
- `.agent/PLANS.md` — руководство и шаблон ExecPlan.
- `.agent/workflows/` — пошаговые процедуры для конкретных операций.
- `docs/logic/feature_invariants.md` — инварианты и правила по фичам.

## Когда нужен ExecPlan

ExecPlan обязателен для:

- новых фич или заметных изменений UX/поведения;
- существенных рефакторингов;
- миграций БД/изменений схем Drift/логики синхронизации;
- изменений архитектуры и публичных API;
- производительности в горячих путях.

## Минимальные требования к ExecPlan

- Самодостаточный и проверяемый: понятно, что делаем и как валидируем.
- Живой документ: `Progress` обновляется по мере выполнения.
- Содержит обязательные секции из `.agent/PLANS.md`.

## Документация изменений

Любое изменение поведения должно быть отражено в `docs/`:

- **Что изменилось**, **зачем**, **как проверить**, **breaking changes**.
- **Миграции/схемы:** фиксировать в `docs/logic/` отдельным документом или обновлением существующего (с ссылками на миграции).
- **Изменения UX:** документировать в `docs/components/` (виджеты) или `docs/logic/` (поведение экранов).

Минимальный формат записи:

- Что изменилось:
- Зачем:
- Как проверить:
- Breaking changes:

## Обязательное правило для account deletion

Если агент добавляет новую пользовательскую коллекцию или подколлекцию в Firestore по пути вида `users/{uid}/...`, он обязан в той же задаче:

- добавить новую коллекцию в `SyncContract` manifest;
- убедиться, что через manifest она попала в `remoteCleanupCollections` и покрыта тестами cleanup/parity;
- проверить, что `UserAccountCleanupRepositoryImpl` использует manifest-driven cleanup без ручного расхождения списков;
- проверить, что сценарий удаления аккаунта не оставляет orphaned user data;
- при необходимости обновить документацию по удалению аккаунта и privacy policy.

Это правило считается обязательным архитектурным инвариантом, а не опциональной доработкой.

## Policy-level checklist для новых sync entity type

Если агент добавляет новую sync-сущность или переводит существующую local-only сущность в полноценный sync contract, в той же задаче нужно пройти весь checklist ниже.

### 1. Contract и классификация

- Добавить сущность в `SyncContract` manifest.
- Явно зафиксировать тип сущности: user-significant sync state, derived/rebuildable state или local-only state.
- Зафиксировать `delete semantics`: `tombstone`, доменный soft-delete (`isDone`, `isActive`) или допустимый hard delete только для явно ephemeral/non-user данных.
- Зафиксировать `conflict policy` и `dependency order`.

### 2. Local DB и модель данных

- Проверить, нужны ли новые поля в Drift (`isDeleted`, `deletedAt`, `updatedAt`, source markers, metadata`).
- Если схема меняется, добавить миграцию и обновить `schemaVersion`.
- Проверить, что UI/рабочие выборки скрывают tombstoned записи, а sync/diagnostics по-прежнему видят полный state.
- Не править вручную `*.g.dart`, `*.freezed.dart`, `*.drift.dart`.

### 3. Sync pipeline

- Добавить/обновить remote data source.
- Добавить outbox `entityType`, serialize/deserialize payload и dispatch в `SyncService`.
- Добавить login sync fetch/merge/persist в `AuthSyncService`.
- Проверить, что delete не делает `remoteDocumentDelete` для user-significant сущностей, если не доказана безопасность hard delete.
- Проверить сценарий resurrection: stale snapshot не должен возвращать уже удаленные пользователем данные.

### 4. Import / Export / Cleanup

- Добавить сущность в JSON/CSV export/import contract, если она user-significant.
- Проверить merge-only import: backup не должен по умолчанию удалять remote state для отсутствующих сущностей.
- Добавить сущность в manifest-driven cleanup coverage.
- Проверить удаление данных аккаунта для `users/{uid}/...` без orphaned remote/local state.

### 5. Diagnostics и тесты

- Добавить regression-тесты минимум на:
  - manifest parity;
  - create/update/delete sync path;
  - tombstone/restore conflict policy;
  - login sync merge;
  - import/export roundtrip или schema-aware import;
  - cleanup coverage, если появляется новая remote collection.
- Обновить DB integrity diagnostics, если сущность вводит новые ссылки, инварианты или orphan-сценарии.
- Убедиться, что debug/dev DB integrity report отражает новую сущность или связанные с ней нарушения.

### 6. Документация и сдача

- Обновить `docs/logic/firebase_sync.md`, если меняется sync contract.
- Обновить `docs/logic/feature_invariants.md`, если меняются доменные инварианты.
- Обновить ExecPlan `Progress` и `Outcomes & Retrospective`, чтобы checklist был явно закрыт.
- Перед сдачей прогнать форматирование, analyze, codegen и релевантные тесты; если полный прогон невозможен, зафиксировать причину.

## Проверка перед сдачей

Минимальный набор команд:

```bash
dart format --set-exit-if-changed .
flutter analyze
dart run build_runner build --delete-conflicting-outputs
flutter test --reporter expanded
```

Если команды не запускаются в окружении — зафиксируй причину и список требований для запуска.
