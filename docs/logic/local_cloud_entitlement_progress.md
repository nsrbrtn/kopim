# Progress: local/cloud entitlement model

Этот файл нужен как отдельный живой трекер прогресса по реализации модели из [local_cloud_entitlement_model.md](/home/artem/StudioProjects/kopim/docs/logic/local_cloud_entitlement_model.md:1).

`2026-06-28`: статус ниже скорректирован после repo-backed audit [play_market_local_first_transition_audit_2026-06-28.md](/home/artem/StudioProjects/kopim/docs/logic/play_market_local_first_transition_audit_2026-06-28.md:1). Технические заготовки choice/auth/web flow есть, но product contour для production mobile ещё не доведён до завершённого состояния.

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
| Choice screen для сценариев `local -> cloud` | `done` | экран и pending intent слой полностью доведены до рабочего flow, product copy очищена, финальная CTA matrix и targeted widget/decision tests полностью проходят |
| Readiness / local snapshot classifier | `done` | local+remote read-only snapshot classifier, matrix-driven readiness/choice flow и legacy handoff guard-tests зафиксированы в текущем checkout |
| Первый execution path: `enableCloudSync` для пустого workspace | `done` | explicit activation flag per UID, final revalidation, guarded runtime transition и auth/startup sync gate зафиксированы в текущем checkout |
| Второй execution path: `startWithEmptyCloud` | `done` | explicit backup/export перед destructive step, guarded local reset, отдельный activation scenario per UID и targeted regressions зафиксированы в текущем checkout |
| Реальная миграция `local -> cloud` | `done` | Подключение runtime transition и controlled execution flow поверх upload/verification/conversion слоев завершено, все интеграционные сценарии и граничные тесты полностью покрыты и проходят. |
| Переход Play-контура на `storeProdLocalFirst` | `done` | базовый contour и runtime hardening полностью реализованы, post-login action flow, choice UX, copy cleanup и targeted tests успешно проходят |
| Server-backed entitlement / trial lifecycle | `done` | canonical claims contract, force refresh, cache snapshots и expired UX с runtime-aligned tests полностью приземлены |
| Web read-only barrier для expired entitlement | `done` | web gate закрывает shell без доступа, logout идет через штатный cleanup workflow, expired read-only web gate и тесты полностью проходят |

## Этапы

### 1. Архитектурное разделение local / cloud / entitlement

Статус: `done`

Что считаем уже сделанным:

- выделены независимые оси `Build Flavor`, `Runtime Data Mode`, `Entitlement`;
- доступ к функциям строится через feature gates;
- `offlineOnly` не должен открывать cloud/Firebase сценарии;
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

Что зафиксировано:

- реализован отдельный экран выбора сценария;
- реализован read-only decision controller;
- реализован отдельный pending intent controller вне `DataModeController`;
- завершены технические ветки `enableCloudSync`, `migrateLocalToCloud`, `startWithEmptyCloud`, `replaceLocalWithCloud`, `mergeLocalAndCloud`;
- production `sign-in -> forced entitlement refresh` маршрутизирует пользователя в `CloudActivationChoiceScreen` или `CloudAccessStatusScreen`;
- `ProfileSyncSettingsCard` для production `requiresEntitlement` открывает `CloudAccessStatusScreen`;
- `CloudActivationDecisionState` вычисляет рекомендуемый сценарий, а production `storeProdLocalFirst` скрывает stay-local и merge варианты;
- product copy очищена, а `replaceLocalWithCloud` полностью поддержан и покрыт тестами.

Текущий активный план доведения:

- [2026-06-27-play-market-local-first-cloud-capable-transition.md](/home/artem/StudioProjects/kopim/.agent/exec_plans/2026-06-27-play-market-local-first-cloud-capable-transition.md:1)

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

Статус: `done`

Что зафиксировано:
- controlled execution flow и runtime transition для `migrateLocalToCloud`;
- исключение технического remote marker (`users/{userId}/migration_state/status`) из проверок пустоты и синхронизации;
- field-aware canonicalization для double/int сравнения remote payloads;
- scoped outbox consumption на основе строк плана;
- startup recovery правила в DataModeController;
- интеграционные сценарии (Success Path, Crash Recovery с partial resume, UID changed сбой и write-freeze блокировки).

Основной план:
- [2026-06-21-local-cloud-migrate-local-to-cloud-execution.md](/home/artem/StudioProjects/kopim/.agent/exec_plans/2026-06-21-local-cloud-migrate-local-to-cloud-execution.md:1)

## Ближайший фокус

Ближайший фокус после завершения перехода:
1. Выпуск релиза с новым контуром `storeProdLocalFirst`.
2. Мониторинг работоспособности синхронизации и сбора локально/облачных метрик.
3. Проектирование merge-capable local+cloud стратегии для будущих этапов.

## Как обновлять этот файл

Обновляйте только три места:

1. `Общий статус`
2. `Статус` у этапа
3. `Ближайший фокус`

Это специально короткий файл, чтобы прогресс читался быстро и не терялся внутри большого продуктового документа.
