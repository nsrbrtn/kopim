---

name: kopim-sync-skill
description: Правила работы с синхронизацией данных, Outbox, Auth Sync и Firebase/Firestore в проекте Kopim.
------------------------------------------------------------------------------------------------------------

# Kopim Sync Skill

Этот навык используется для задач, которые затрагивают offline-first синхронизацию, Outbox queue, Firebase/Firestore, Auth Sync, Sync Contract и очистку пользовательских cloud-данных.

## 1. Когда использовать этот навык

Используй этот навык, если задача затрагивает:

* sync-сущности и их сериализацию/десериализацию;
* `SyncContract` / sync manifest;
* Outbox queue, dispatch ordering, retry, conflict handling;
* `SyncService`;
* `AuthSyncService`;
* login/logout sync workflow;
* cloud ownership / sync ownership guard;
* Firestore remote data sources;
* структуру Firestore-документов или коллекций;
* tombstone / soft delete / resurrection protection;
* очистку данных пользователя при удалении аккаунта;
* offline/online режимы приложения.

Не используй этот навык для обычных UI-задач, локальных CRUD-задач без синхронизации и чисто визуальных изменений.

## 2. Что читать в первую очередь

Не читай все файлы сразу. Начни с точечного поиска по названию сущности, сервиса, теста или ошибки.

Обычно релевантны:

* `sync_contract.dart` — manifest/контракт синхронизируемых сущностей.
* `sync_service.dart` — оркестратор синхронизации.
* `auth_sync_service.dart` — сценарии синхронизации при логине.
* `firebase_sync_service.dart` / remote data sources — работа с Firestore.
* `outbox` DAO/model/service — очередь локальных изменений.
* `user_account_cleanup_repository_impl.dart` — очистка cloud-данных при удалении аккаунта.
* `docs/logic/firebase_sync.md` — документация по архитектуре синхронизации, если меняется контракт или поведение sync.
* Релевантные тесты по имени сущности/сервиса.

Если путь к файлу изменился, найди актуальный путь через поиск по имени класса/файла.

## 3. Архитектурные правила

* UI/presentation слой не должен обращаться к Firebase/Firestore напрямую.
* Domain слой не должен зависеть от Firebase SDK.
* Доступ к Firestore должен идти через data layer / remote data source / sync service.
* Local database остаётся source of truth для offline-first сценариев.
* Outbox должен сохранять локальные изменения до успешной отправки в cloud.
* При добавлении новой sync-сущности нужно проверить весь путь:

  * локальная модель;
  * Drift/DAO;
  * sync serialization;
  * Firestore document format;
  * `SyncContract`;
  * import/export, если сущность участвует в переносе данных;
  * account cleanup;
  * тесты.

## 4. Запрещённые действия

Запрещено без отдельного ExecPlan, регрессионных тестов и явного подтверждения пользователя:

* менять структуру Firestore-документов;
* менять `SyncContract`;
* менять outbox ordering;
* менять tombstone-логику;
* менять conflict resolution / LWW правила;
* менять auth/login sync workflow;
* менять ownership guard;
* менять формат import/export для sync-сущностей;
* менять Drift schema/migrations, если изменение связано с синхронизацией;
* обновлять Firebase/Firestore зависимости;
* подключаться к production Firebase/Firestore.

Категорически запрещено читать, писать, очищать, seed-ить или мигрировать production Firebase/Firestore без явного подтверждения пользователя и проверки target project.

## 5. Tombstone и hard delete

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
* локальные временные/служебные записи без пользовательской ценности;
* тестовые данные в test/emulator окружении;
* явно описанный и подтверждённый сценарий.

## 6. Что обязательно проверить при изменениях sync

При изменении существующей sync-сущности:

* payload Outbox;
* сериализацию в Firestore;
* десериализацию из Firestore;
* `updatedAt` / ordering / conflict behavior;
* tombstone behavior;
* поведение при offline → online;
* поведение при login sync;
* отсутствие resurrection;
* отсутствие orphaned references.

При добавлении новой sync-сущности дополнительно проверить:

* добавлена ли сущность в `SyncContract`;
* добавлен ли pull/push путь;
* добавлена ли очистка в `UserAccountCleanupRepositoryImpl`;
* нужны ли индексы Firestore;
* нужны ли Firebase security rules;
* нужна ли документация в `docs/logic/firebase_sync.md`;
* нужны ли import/export изменения.

## 7. Типичные ошибки, которые надо предотвращать

* Resurrection: удалённая запись восстанавливается из старого cloud snapshot.
* Orphaned data: новая коллекция не очищается при удалении аккаунта.
* Потеря связей: `categoryId`, `groupId`, goal/credit/payment links теряются при sync/import.
* Нарушение FK в Drift при pull данных с отсутствующими зависимостями.
* Неправильный порядок Outbox операций.
* Гонка create → update → delete.
* Push локальных данных в чужой/неподходящий cloud account.
* Синхронизация в offline flavor.
* Обращение к Firebase до разрешённого cloud/auth режима.
* Изменение server/cloud schema без миграционного плана.

## 8. Проверки

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
* account cleanup.

`build_runner` запускай только если менялись generated-модели, Drift schema, freezed/json_serializable или файлы, требующие генерации:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Firebase rules deploy не выполнять автоматически. Если менялись rules, сначала использовать emulator/tests или доступный auditor. Deploy только по явному запросу пользователя.

## 9. Expected Output

После выполнения sync-задачи агент должен вывести:

* какие sync-файлы изменены;
* затронут ли `SyncContract`;
* затронуты ли Drift schema/migrations;
* затронуты ли Firestore document format или collection paths;
* затронут ли account cleanup;
* как предотвращены resurrection/orphaned data/FK ошибки;
* какие тесты добавлены или обновлены;
* какие проверки запущены;
* результат проверок;
* какие риски или ручные follow-up остались.

Если новая sync-сущность не добавлялась, не нужно писать, что обновлён `SyncContract` или cleaner.
