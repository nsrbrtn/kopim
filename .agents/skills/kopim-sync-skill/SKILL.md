---

name: kopim-sync-skill
description: Правила работы с синхронизацией данных, Outbox, Auth Sync, ownership, entitlement и Firebase/Firestore в проекте Kopim.

---


# Kopim Sync Skill

Этот навык используется для задач, которые затрагивают offline-first синхронизацию, Outbox queue, Firebase/Firestore, Auth Sync, Sync Contract, ownership, entitlement/capability gates и очистку пользовательских cloud-данных.

## 1. Когда использовать этот навык

Используй этот навык, если задача затрагивает:

* sync-сущности и их сериализацию/десериализацию;
* `SyncContract` / sync manifest;
* Outbox queue, dispatch ordering, retry, conflict handling;
* `SyncService`;
* `AuthSyncService`;
* login/logout sync workflow;
* cloud ownership / sync ownership guard;
* local/cloud data mode;
* cloud activation / fresh upload / local-to-cloud migration;
* entitlement / custom claims / cloud access checks;
* capabilities / flavor gates, если они влияют на cloud sync;
* Firestore remote data sources;
* структуру Firestore-документов или коллекций;
* `firestore.rules`;
* tombstone / soft delete / resurrection protection;
* очистку данных пользователя при удалении аккаунта;
* import/export sync-сущностей;
* offline/online режимы приложения.

Не используй этот навык только для локальных CRUD-задач, которые не затрагивают sync-сущности, `SyncContract`, Outbox, ownership projection, import/export, auth/cloud mode и таблицы, участвующие в синхронизации.

Не используй этот навык для чисто визуальных UI-изменений, если они не меняют поведение sync/auth/cloud/data mode.

## 2. Что читать в первую очередь

Не читай все файлы сразу. Начни с точечного поиска по названию сущности, сервиса, теста, ошибки или изменяемого сценария.

Обычно релевантны:

* `sync_contract.dart` — manifest/контракт синхронизируемых сущностей.
* `sync_service.dart` — оркестратор синхронизации.
* `auth_sync_service.dart` — сценарии синхронизации при логине.
* `firebase_sync_service.dart` / remote data sources — работа с Firestore.
* `outbox` DAO/model/service — очередь локальных изменений.
* ownership projection / `SyncOwnershipGuard` — проверка принадлежности строк.
* data mode / cloud activation controllers/services — переключение local/cloud режима.
* entitlement/custom claims/capability services — доступ к cloud-функциям.
* `firestore.rules` — если меняются права доступа, ownership, entitlement или структура cloud-документов.
* scripts для custom claims / entitlement — если задача затрагивает доступ к cloud-функциям.
* `user_account_cleanup_repository_impl.dart` — очистка cloud-данных при удалении аккаунта.
* `docs/logic/firebase_sync.md` — документация по архитектуре синхронизации, если меняется контракт или поведение sync.
* релевантные тесты по имени сущности/сервиса.

Если путь к файлу изменился, найди актуальный путь через поиск по имени класса/файла.

## 3. Архитектурные правила

* UI/presentation слой не должен обращаться к Firebase/Firestore напрямую.
* Domain слой не должен зависеть от Firebase SDK.
* Доступ к Firestore должен идти через data layer / remote data source / sync service.
* Local database остаётся source of truth для offline-first сценариев.
* Outbox должен сохранять локальные изменения до успешной отправки в cloud.
* Cloud sync нельзя включать только на основании факта входа в аккаунт.
* Cloud sync можно выполнять только если это разрешено build capabilities, runtime data mode, auth state, entitlement и ownership guard.
* Firestore Rules не являются доказательством успешной remote verification. Rules только ограничивают допустимые операции.
* Любые операции local → cloud должны быть идемпотентными и безопасными при restart/crash.
* Любой сценарий, который может затронуть пользовательские данные, должен иметь safe rollback/resume или явное описание, почему он не нужен.

При добавлении новой sync-сущности нужно проверить весь путь:

* локальная модель;
* Drift/DAO;
* ownership projection;
* Outbox triggers/payload;
* sync serialization;
* Firestore document format;
* `SyncContract`;
* pull/push путь;
* import/export, если сущность участвует в переносе данных;
* account cleanup;
* Firebase security rules;
* тесты.

## 4. Outbox ownership safety

Outbox dispatch запрещён, если:

* `currentUid` отсутствует или пустой;
* `entry.ownerUid` отсутствует;
* `entry.ownerUid != currentUid`;
* `entry.ownerUid` начинается с `local-`;
* runtime mode не разрешает cloud sync;
* entitlement не разрешает cloud sync;
* build capability не разрешает cloud sync;
* ownership guard не подтвердил принадлежность строки текущему cloud-пользователю.

Если пользователь вышел из аккаунта, Outbox не должен выполнять unfiltered dispatch.

`OutboxDao._filterEntriesForCurrentOwner` или эквивалентная логика не должна возвращать все записи при пустом `currentUid`.

Перед push в Firebase должен быть финальный safety check, который отклоняет отправку, если:

* userId отсутствует;
* userId начинается с `local-`;
* entry owner не совпадает с userId;
* запись не принадлежит текущему cloud workspace;
* sync запрещён текущим mode/capability/entitlement.

## 5. Cloud activation / Fresh Upload lifecycle

Fresh Upload и обычная замена локальной базы cloud-состоянием — это разные сценарии. Не смешивай их.

Для local → cloud activation используй явную последовательность состояний:

```text
deleted
-> freshUploadInProgress
-> controlled upload
-> remote verification
-> active
-> local finalization
-> runtime cloudEnabled
```

Контракт состояний:

* `deleted` — remote workspace очищен или считается непригодным для использования.
* `freshUploadInProgress` — начат controlled upload локального графа в пустое/подготовленное облако.
* `controlled upload` — клиент отправляет локальные данные в cloud под контролем ownership/migration guard.
* `remote verification` — клиент проверяет, что remote graph полон, консистентен и соответствует ожидаемому canonical payload.
* `active` — remote graph verified and accepted as canonical.
* `local finalization` — локальная база и ownership/outbox/sync metadata доводятся до cloud-owned состояния.
* `runtime cloudEnabled` — cloud sync разрешён в runtime только после успешной local finalization.

Важно:

* remote metadata state `active` не означает, что local finalization уже завершена.
* runtime `cloudEnabled` нельзя включать до успешной local finalization.
* local finalization должна быть идемпотентной.
* если приложение упало после remote `active`, но до local finalization, следующий запуск должен безопасно продолжить local finalization.
* если local finalization не завершена, обычный sync dispatch должен оставаться заблокированным.
* fresh upload должен работать только для явно разрешённого сценария и только после preflight/readiness checks.

## 6. Entitlement / Capability gates

Перед включением cloud sync обязательно проверить:

* build capability;
* runtime data mode;
* auth state;
* entitlement/custom claims;
* cloud activation state;
* ownership projection;
* local/remote workspace readiness;
* отсутствие запрещённых local-only строк для выбранного сценария;
* отсутствие pending migration/finalization state, который блокирует обычный sync.

Cloud sync нельзя включать только потому, что:

* Firebase Auth пользователь существует;
* custom claim есть в старом токене;
* remote metadata выглядит непустой;
* Firestore Rules разрешили запись;
* UI-кнопка была нажата.

После изменения entitlement/custom claims нужно учитывать token refresh. Если логика зависит от claims, она должна явно обновлять/перечитывать актуальное состояние доступа.

При истечении доступа:

* web/cloud-режим должен становиться read-only или sync-paused согласно продуктовой логике;
* локальные данные пользователя нельзя удалять автоматически;
* новые локальные операции должны оставаться безопасными для offline-first режима;
* cloud-owned данные нельзя silently отправлять в cloud без восстановленного entitlement.

## 7. Запрещённые действия

Запрещено без отдельного ExecPlan, регрессионных тестов и явного подтверждения пользователя:

* менять структуру Firestore-документов;
* менять `SyncContract`;
* менять outbox ordering;
* менять tombstone-логику;
* менять conflict resolution / LWW правила;
* менять auth/login sync workflow;
* менять ownership guard;
* менять cloud activation / fresh upload lifecycle;
* менять entitlement/capability gates для cloud sync;
* менять формат import/export для sync-сущностей;
* менять Drift schema/migrations, если изменение связано с синхронизацией;
* обновлять Firebase/Firestore зависимости;
* подключаться к production Firebase/Firestore;
* выполнять миграцию, очистку или seed production cloud-данных.

Категорически запрещено читать, писать, очищать, seed-ить или мигрировать production Firebase/Firestore без явного подтверждения пользователя и проверки target project.

Перед любым действием с Firebase/Firestore агент обязан явно проверить target project/environment, если действие может затронуть реальные данные.

## 8. Tombstone и hard delete

Для пользовательских sync-сущностей, представляющих ценность, по умолчанию используй soft delete / tombstone:

* accounts;
* transactions;
* categories;
* budgets;
* recurring entities;
* goals;
* credit/payment entities;
* другие финансовые данные пользователя.

Цель tombstone — не допустить resurrection удалённых данных при последующей синхронизации.

Hard delete допустим только в специальных сценариях:

* полная очистка cloud-данных при удалении аккаунта;
* подготовка пустого remote workspace перед controlled fresh upload;
* локальные временные/служебные записи без пользовательской ценности;
* тестовые данные в test/emulator окружении;
* явно описанный и подтверждённый сценарий.

При hard delete нужно проверить:

* не приведёт ли это к resurrection из другого источника;
* очищается ли Outbox;
* очищается ли sync metadata;
* не остаются ли orphaned references;
* не ломается ли import/export;
* не возникает ли расхождение local/cloud ownership.

## 9. Что обязательно проверить при изменениях sync

При изменении существующей sync-сущности:

* payload Outbox;
* сериализацию в Firestore;
* десериализацию из Firestore;
* `updatedAt` / ordering / conflict behavior;
* tombstone behavior;
* поведение при offline → online;
* поведение при login sync;
* отсутствие resurrection;
* отсутствие orphaned references;
* ownerUid/currentUid checks;
* поведение при sign out;
* поведение при expired entitlement;
* поведение при restart/crash во время незавершённого sync/finalization.

При добавлении новой sync-сущности дополнительно проверить:

* добавлена ли сущность в `SyncContract`;
* добавлен ли pull/push путь;
* добавлена ли ownership projection;
* добавлена ли очистка в `UserAccountCleanupRepositoryImpl`;
* нужны ли индексы Firestore;
* нужны ли Firebase security rules;
* нужна ли документация в `docs/logic/firebase_sync.md`;
* нужны ли import/export изменения;
* нужны ли migration/backfill шаги;
* нужны ли тесты на отсутствие orphaned data.

## 10. Типичные ошибки, которые надо предотвращать

* Resurrection: удалённая запись восстанавливается из старого cloud snapshot.
* Orphaned data: новая коллекция не очищается при удалении аккаунта.
* Потеря связей: `categoryId`, `groupId`, goal/credit/payment links теряются при sync/import.
* Нарушение FK в Drift при pull данных с отсутствующими зависимостями.
* Неправильный порядок Outbox операций.
* Гонка create → update → delete.
* Push локальных данных в чужой/неподходящий cloud account.
* Push `local-*` owned данных в cloud.
* Unfiltered Outbox dispatch при signed-out состоянии.
* Синхронизация в offline/local-only режиме.
* Обращение к Firebase до разрешённого cloud/auth режима.
* Включение `cloudEnabled` до local finalization.
* Смешивание fresh upload и replaceLocalWithCloud.
* Использование Firestore Rules как замены remote verification.
* Изменение server/cloud schema без миграционного плана.
* Очистка sync metadata в неправильный момент.
* Потеря локальных пользовательских данных при logout/expired entitlement.

## 11. Проверки

Минимально после sync-изменений:

```bash
./tool/ai_check.sh
```

Для затронутой области сначала запускай targeted tests:

```bash
./tool/ai_check.sh <path_to_relevant_test>
```

Релевантные тесты найди поиском по имени сущности/сервиса. Не полагайся на один фиксированный путь.

Полный sync/db/auth набор запускай, если изменение затрагивает:

* `SyncContract`;
* Outbox ordering;
* Drift schema/migrations;
* Auth Sync;
* ownership guard;
* tombstone logic;
* import/export;
* account cleanup;
* Firestore document format;
* Firestore rules;
* entitlement/custom claims;
* cloud activation / fresh upload lifecycle.

`build_runner` запускай только если менялись generated-модели, Drift schema, freezed/json_serializable или файлы, требующие генерации:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Firebase rules deploy не выполнять автоматически. Если менялись rules, сначала использовать emulator/tests или доступный auditor. Deploy только по явному запросу пользователя.

Firebase production project не использовать для тестов, seed, cleanup, migration или ручных проверок без явного подтверждения пользователя.

## 12. Минимальные тестовые сценарии

Для sync/security изменений нужны targeted tests на релевантные сценарии.

Минимальный набор для Outbox/ownership:

* `currentUid == null` → dispatch ничего не отправляет;
* `currentUid == ''` → dispatch ничего не отправляет;
* `entry.ownerUid == null` → push запрещён;
* `entry.ownerUid != currentUid` → push запрещён;
* `entry.ownerUid startsWith('local-')` → push запрещён;
* signed out не приводит к unfiltered outbox access;
* cloud sync disabled → outbox не отправляется.

Минимальный набор для cloud activation / fresh upload:

* remote `active`, но local finalization incomplete → runtime `cloudEnabled` ещё выключен;
* restart/crash после remote `active` → local finalization безопасно продолжается;
* repeated finalization → идемпотентно и без дубликатов;
* failed upload не включает `cloudEnabled`;
* failed verification не включает `cloudEnabled`;
* обычный sync dispatch заблокирован во время fresh upload/finalization.

Минимальный набор для tombstone/conflict:

* удалённая локально запись не resurrect после pull;
* delete после update не восстанавливается старым snapshot;
* create → update → delete сохраняет корректный финальный state;
* missing references не ломают Drift FK;
* import/export не теряет связи между финансовыми сущностями.

Минимальный набор для entitlement:

* нет entitlement → cloud sync не включается;
* expired entitlement → cloud write/sync запрещён или paused согласно продуктовой логике;
* token refresh после изменения claims корректно обновляет доступ;
* локальные данные не удаляются при истечении доступа.

## 13. Ожидаемый результат

После выполнения sync-задачи агент должен вывести:

* какие sync-файлы изменены;
* затронут ли `SyncContract`;
* затронуты ли Drift schema/migrations;
* затронуты ли Firestore document format или collection paths;
* затронуты ли `firestore.rules`;
* затронут ли account cleanup;
* затронуты ли entitlement/capability gates;
* затронут ли cloud activation / fresh upload lifecycle;
* как защищён Outbox dispatch;
* как проверены `currentUid`, `ownerUid`, `local-*` и runtime mode;
* как предотвращены resurrection/orphaned data/FK ошибки;
* как обеспечена безопасность при offline → online;
* как обеспечена безопасность при sign out / expired entitlement;
* какие тесты добавлены или обновлены;
* какие проверки запущены;
* результат проверок;
* какие риски или ручные follow-up остались.

Если новая sync-сущность не добавлялась, не нужно писать, что обновлён `SyncContract` или cleaner.

Если Firestore format/rules не менялись, нужно явно написать, что они не затронуты.

Если Drift schema/migrations не менялись, нужно явно написать, что миграции не затронуты.

Если остались риски для пользовательских данных, их нужно выделить отдельно и не скрывать за успешными тестами.
