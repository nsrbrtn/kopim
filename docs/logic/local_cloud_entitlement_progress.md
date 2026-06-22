# Progress: local/cloud entitlement model

Этот файл нужен как отдельный живой трекер прогресса по реализации модели из [local_cloud_entitlement_model.md](/home/artem/StudioProjects/kopim/docs/logic/local_cloud_entitlement_model.md:1).

Статусы:

- `done` — этап реализован и зафиксирован в репозитории или в завершённом ExecPlan.
- `in_progress` — этап в работе на текущем checkout.
- `planned` — этап запланирован, но ещё не реализован.

## Общий статус

| Направление | Статус | Основание |
| --- | --- | --- |
| Разделение `AppCapabilities` / `FeatureAccess` / `DataMode` | `done` | зафиксировано в модели и предыдущем этапе |
| Gate-based доступ к cloud/web/AI вместо raw flavor checks | `done` | зафиксировано в текущей runtime matrix |
| Safe preflight-only flow перед включением cloud | `done` | отдельный preflight controller/screen подключены в profile flow и покрыты targeted tests |
| Choice screen для сценариев `local -> cloud` | `done` | read-only этап сохранён fail-closed, а выбранный сценарий теперь фиксируется как pending intent вне `DataModeController` |
| Readiness / local snapshot classifier | `done` | local+remote read-only snapshot classifier, matrix-driven readiness/choice flow и legacy handoff guard-tests зафиксированы в текущем checkout |
| Первый execution path: `enableCloudSync` для пустого workspace | `done` | explicit activation flag per UID, final revalidation, guarded runtime transition и auth/startup sync gate зафиксированы в текущем checkout |
| Второй execution path: `startWithEmptyCloud` | `done` | explicit backup/export перед destructive step, guarded local reset, отдельный activation scenario per UID и targeted regressions зафиксированы в текущем checkout |
| Реальная миграция `local -> cloud` | `planned` | сознательно отложено |
| Server-backed entitlement / trial lifecycle | `planned` | сознательно отложено |
| Web read-only barrier для expired entitlement | `planned` | сознательно отложено |

## Этапы

### 1. Архитектурное разделение local / cloud / entitlement

Статус: `done`

Что считаем уже сделанным:

- выделены независимые оси `Build Flavor`, `Runtime Data Mode`, `Entitlement`;
- доступ к функциям строится через feature gates;
- `offline` не должен открывать cloud/Firebase сценарии;
- в документации уже есть актуальная runtime matrix текущего этапа.

Основные источники:

- [local_cloud_entitlement_model.md](/home/artem/StudioProjects/kopim/docs/logic/local_cloud_entitlement_model.md:584)
- [2026-06-19-local-cloud-entitlement-next-phase.md](/home/artem/StudioProjects/kopim/.agent/exec_plans/2026-06-19-local-cloud-entitlement-next-phase.md:1)

### 2. Safe preflight-only flow

Статус: `done`

Что входит в этап:

- отдельный preflight controller;
- отдельный preflight screen;
- безопасный вход из profile sync/settings UI;
- stop-state перед любым рискованным `local -> cloud` переходом;
- targeted tests на состояния и навигацию.

Что видно на текущем checkout:

- preflight screen открывается из profile sync/settings UI;
- `blockedByLocalOnlyData` и `readyForNextStep` больше не ведут к auth side effects и открывают следующий безопасный этап;
- router и targeted tests для preflight flow уже подключены и проходят.

Основной план:

- [2026-06-19-local-cloud-preflight-flow.md](/home/artem/StudioProjects/kopim/.agent/exec_plans/2026-06-19-local-cloud-preflight-flow.md:1)

### 3. Choice screen для перехода в облако

Статус: `done`

Что считаем зафиксированным на текущем checkout:

- отдельный экран выбора сценария;
- read-only decision controller;
- отдельный pending intent controller вне `DataModeController`;
- варианты:
  - `enableCloudSync`
  - `stayLocalOnly`
  - `migrateLocalToCloud`
  - `startWithEmptyCloud`
  - `replaceLocalWithCloud`
  - `mergeLocalAndCloud`

Ограничение этапа:

- никаких real sync/migration side effects;
- только product-state и UX-слой.

Основной план:

- [2026-06-20-local-cloud-activation-decision-model-and-choice-screen.md](/home/artem/StudioProjects/kopim/.agent/exec_plans/2026-06-20-local-cloud-activation-decision-model-and-choice-screen.md:1)

### 4. Первый execution path: enableCloudSync для пустого workspace

Статус: `done`

Что зафиксировано:
- Условие: локально нет пользовательских данных, в облаке нет данных и метаданных.
- Активация: сохранение явного флага активации в `CloudActivationStateRepository` для UID со сценарием `enableCloudSync`.
- Runtime: переход в `DataMode.cloudEnabled` с проверкой флага активации на запуске/логине.

Основной план:
- [2026-06-20-local-cloud-enable-sync-empty-workspace-execution.md](/home/artem/StudioProjects/kopim/.agent/exec_plans/2026-06-20-local-cloud-enable-sync-empty-workspace-execution.md:1)

### 5. Второй execution path: startWithEmptyCloud

Статус: `done`

Что зафиксировано:
- Hardening review: атомарность деструктивных действий (SQLite reset до сброса метаданных синка, post-reset валидация).
- Сохранение данных: экспорт резервной копии перед любыми деструктивными операциями.
- Reset: сброс локальной БД без генерации outbox rows и tombstones.
- Регрессии: автотесты на сбои сброса, очистки метаданных, блокировки outbox по `ownerUid` и интеграционный roundtrip-тест.

Основной план:
- [2026-06-20-local-cloud-start-with-empty-cloud-execution.md](/home/artem/StudioProjects/kopim/.agent/exec_plans/2026-06-20-local-cloud-start-with-empty-cloud-execution.md:1)

### 6. Реальная миграция local -> cloud

Статус: `planned`

Пока не реализуется в текущем безопасном этапе:

- merge local data в cloud;
- upload локальной базы после preflight;
- автоматическое включение sync;
- изменение auth/sync workflow;
- изменение `SyncContract`, Drift schema, outbox ordering, ownership guard.

## Ближайший фокус

1. Следующий незакрытый scenario-specific execution path: `migrateLocalToCloud`, но только отдельным plan’ом без переиспользования `startWithEmptyCloud` semantics.
2. Сохранить текущий fail-closed stage: `startWithEmptyCloud` остаётся отдельным backup/export + local reset flow и не должен расширяться до upload/merge semantics без нового ExecPlan.
3. `remote=hasOnlyMetadata` для `startWithEmptyCloud` остаётся заблокированным в v1 до отдельного metadata-whitelist этапа с собственными регрессиями.

## Как обновлять этот файл

Обновляйте только три места:

1. `Общий статус`
2. `Статус` у этапа
3. `Ближайший фокус`

Это специально короткий файл, чтобы прогресс читался быстро и не терялся внутри большого продуктового документа.
