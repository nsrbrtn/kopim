# Аудит подготовки local / cloud / entitlement

Дата: 2026-06-18

Основание: `docs/logic/local_cloud_entitlement_model.md`, раздел "Первое задание агенту".

## Краткий вывод

В проекте уже есть зачатки нужного разделения:

* build/runtime flavor: `AppRuntimeFlavor`, `AppDistributionMode` в `lib/core/config/app_runtime.dart`;
* runtime data mode: `DataMode`, `DataModeController`;
* entitlement: `CloudEntitlementState`, `CloudEntitlementRepository`;
* защита sync: `NoopSyncService`, `SyncOwnershipGuard`, блокировка `cloudBlockedByLocalData`;
* тесты на часть поведения: `data_mode_controller_test.dart`, `cloud_entitlement_repository_test.dart`, `incremental_sync_test.dart`.

Но модель пока не доведена до трех независимых осей. Flavor все еще управляет пользовательским UI и доступностью функций, `DataModeState` хранит entitlement внутри себя, а AI и часть profile/sync UI завязаны на `AppRuntimeConfig.isOffline`, а не на feature gates.

## Проверенные точки

* `lib/core/config/app_runtime.dart`
* `lib/main.dart`, `lib/main_offline.dart`, `lib/main_prod.dart`
* `lib/core/application/app_startup_controller.dart`
* `lib/core/application/sync_coordinator.dart`
* `lib/core/application/sync_preferences_provider.dart`
* `lib/core/di/injectors.dart`
* `lib/core/services/firebase_initializer.dart`
* `lib/core/services/noop_sync_service.dart`
* `lib/core/services/sync_service.dart`
* `lib/core/services/sync_status.dart`
* `lib/features/profile/presentation/controllers/data_mode_controller.dart`
* `lib/features/profile/data/cloud_entitlement_repository.dart`
* `lib/features/profile/presentation/controllers/auth_controller.dart`
* `lib/features/profile/presentation/screens/sign_in_screen.dart`
* `lib/features/profile/presentation/widgets/profile_sync_settings_card.dart`
* `lib/features/profile/presentation/widgets/profile_management_body.dart`
* `lib/features/home/presentation/screens/home_screen.dart`
* `lib/features/home/presentation/widgets/sync_status_indicator.dart`
* `lib/features/app_shell/presentation/providers/main_navigation_tabs_provider.dart`
* `lib/features/ai/presentation/controllers/assistant_session_controller.dart`
* `lib/core/config/app_config.dart`
* релевантные тесты в `test/features/profile/**`, `test/core/services/**`.

## Найденные проблемы

### 1. Flavor все еще напрямую управляет UI

Примеры:

* `SignInScreen` показывает dev entitlement gate только для `firebaseDev`, а offline action только для `storeProdLocalFirst`.
* `mainNavigationTabsProvider` скрывает AI-вкладку через `!AppRuntimeConfig.isOffline`.
* `ProfileManagementBody`, `ProfileSettingsScreen`, `MenuScreen`, `ProfileSyncSettingsCard`, router redirects используют `AppRuntimeConfig.isOffline`.
* `AppStartupController` автоматически активирует `DEMO-CLOUD-KEY` в `storeProdLocalFirst`.

Риск: будущая публичная cloud-capable сборка не сможет быть "локальная по умолчанию, облако по entitlement" без точечных правок по UI.

### 2. `DataModeState` смешивает data mode и entitlement

`DataModeState` содержит:

* `dataMode`;
* `entitlementState`;
* `migrationDecision`.

`DataModeController._calculateState()` сначала проверяет entitlement, затем auth, затем локальные данные. Это удобно как переходное состояние, но не является независимой моделью. Например, `localOnly` может означать:

* offline-only distribution;
* entitlement не активирован;
* entitlement активен, но нет cloud user;
* cloud user есть, но пользователь выбрал остаться локально.

Риск: UI и DI не могут надежно объяснить пользователю причину состояния и предложить правильный CTA.

### 3. Entitlement пока является локальным demo-key, а не продуктовой моделью

`CloudEntitlementRepositoryImpl` хранит состояние в `SharedPreferences` и принимает только `DEMO-CLOUD-KEY`. Состояний `freeLocal`, `cloudTrial`, `cloudActive`, `cloudExpired`, `aiActive` нет. `expired` есть в enum, но не используется как серверно подтвержденное состояние.

Риск: trial, cloud subscription, web read-only и AI gate придется встраивать поверх неготовой модели.

### 4. Firebase-провайдеры защищены только через initialization, но не через capability gate

`firestoreProvider`, `firebaseAuthProvider`, `firebaseStorageProvider`, `firebaseRemoteConfigProvider` требуют `firebaseInitializationProvider.requireValue`. В offline-only distribution Firebase init возвращает success-like `void`, а не запрещающий sentinel.

На практике большинство путей не доходит до этих провайдеров из-за `AppRuntimeConfig.isOfflineOnlyDistribution` и `DataMode`, но сам provider не выражает "Firestore запрещен при localOnly".

Риск: новый код может случайно запросить `firestoreProvider` в localOnly/cloudBlocked режиме и получить Firebase instance, если сборка cloud-capable.

### 5. Remote data sources создаются через DI без отдельного feature gate

Remote data source providers напрямую читают `firestoreProvider`. `syncServiceProvider` правильно возвращает `NoopSyncService` для `localOnly` и `cloudBlockedByLocalData`, но remote providers сами по себе не знают, что cloud запрещен.

Риск: безопасно сейчас, пока remote providers используются только из gated сервисов; хрупко для новых features.

### 6. Local data -> cloud account пока блокируется, но не имеет полноценного UX выбора

`DataModeController` переводит cloud user + local data в `cloudBlockedByLocalData`. `NoopSyncService` возвращает `blockedByLocalData`. `AuthController` передает `migrationDecision` в `AuthSyncService`, но UI фактически предлагает только "Остаться в локальном режиме"/sign out, без сценариев:

* перенести локальные данные в аккаунт;
* объединить данные;
* заменить локальные данные облачными;
* оставить локально без выхода из аккаунта.

Риск: безопасная блокировка уже есть, но продуктовый переход local -> cloud не завершен.

### 7. UI sync-состояний местами технический

Pull-to-refresh в `HomeScreen` показывает сообщения вроде "Облачная синхронизация отключена для текущего режима данных" и "циклическая зависимость". Для пользователя нужны более простые состояния: "Синхронизация выключена", "Нужно действие", "Не удалось синхронизировать".

`SyncStatusIndicator` показывает только активный `syncing`, а остальные состояния скрывает.

Риск: пользователь видит техническую причину вместо понятного действия.

### 8. AI gated по flavor/offline и connectivity, не по entitlement

AI-вкладка скрывается в `offlineOnly` flavor, но доступна в cloud-capable flavor без проверки `canUseAiAssistant`. `GenerativeAiConfig.isEnabled` зависит от `!AppRuntimeConfig.isOffline` и Remote Config, а не от cloud entitlement.

Риск: при будущей подписке AI может оказаться доступен без cloud entitlement или, наоборот, недоступен в cloud-capable local-first сборке не по той причине.

### 9. Online sync preference дублирует DataMode

`onlineSyncPreferencesControllerProvider` хранит toggle "online sync enabled", но `syncServiceProvider` уже решает доступность через `DataMode`. Сейчас это отдельная пользовательская настройка, но она не встроена в `DataModeState`.

Риск: возможны состояния "toggle включен, но DataMode localOnly" или "toggle выключен, но entitlement/auth активны", которые UI должен явно объяснять.

### 10. Есть точечная навигационная ошибка в sync settings

`ProfileSyncSettingsCard` вызывает `Navigator.of(context).pushNamed('/signin')`, а реальный route name: `/sign-in`.

Риск: CTA "Войти в аккаунт" из карточки синхронизации может не открыть нужный экран.

## Предлагаемая модель

### AppCapabilities

Отвечает только за технические возможности сборки/платформы.

```dart
class AppCapabilities {
  final bool canInitializeFirebase;
  final bool canUseFirebaseAuth;
  final bool canUseFirestore;
  final bool canUseFirebaseStorage;
  final bool canUseRemoteConfig;
  final bool canRunCloudSync;
  final bool canOpenWebApp;
  final bool canUseAiTransport;
  final bool canUseBackgroundSync;
  final FirebaseEnvironment? firebaseEnvironment;
}
```

Начальная матрица:

| Flavor | Firebase | Auth | Firestore sync | AI transport | Default data mode |
| --- | --- | --- | --- | --- | --- |
| `offlineOnly` | нет | нет | нет | нет | `localOnly` |
| `dev` | да, dev project | да | да | да | `localOnly` до entitlement/auth |
| `storeProdLocalFirst` | да, prod project | да | да | да | `localOnly` до entitlement/auth |

### DataMode

Отвечает только за то, как сейчас работают данные пользователя.

```dart
enum DataMode {
  localOnly,
  cloudReadySignedOut,
  cloudEnabled,
  cloudBlockedByLocalData,
  syncInProgress,
  syncError,
  syncConflict,
}
```

Текущее `cloudBlockedByLocalData` оставить как safety barrier, но вынести `syncError`/`syncConflict` из `IncrementalSyncResult`/DAO в user-facing state projection.

### Entitlement

Отвечает только за права пользователя.

```dart
enum EntitlementState {
  freeLocal,
  cloudTrial,
  cloudActive,
  cloudExpired,
  unknown,
}
```

`aiActive` лучше не делать отдельным базовым entitlement, а выразить как feature gate:

```dart
class FeatureAccess {
  final bool canUseCloudSync;
  final bool canUseWebSync;
  final bool canUseAiAssistant;
  final bool canUseAdvancedAnalytics;
  final bool isWebReadOnly;
}
```

## Таблица состояний

| Capabilities | Auth | Entitlement | Local data | DataMode | UI state | Sync |
| --- | --- | --- | --- | --- | --- | --- |
| offline-only | local user | `freeLocal` | any | `localOnly` | "Локально" | disabled |
| cloud-capable | signed out | `freeLocal`/`unknown` | any | `localOnly` | "Синхронизация выключена" + "Включить" | disabled |
| cloud-capable | signed out | `cloudTrial`/`cloudActive` | any | `cloudReadySignedOut` | "Войдите, чтобы включить синхронизацию" | disabled |
| cloud-capable | signed in | `cloudTrial`/`cloudActive` | no local-only data | `cloudEnabled` | "Синхронизация включена" | enabled |
| cloud-capable | signed in | `cloudTrial`/`cloudActive` | local-only data exists | `cloudBlockedByLocalData` | "Нужно действие" | blocked |
| cloud-capable | signed in | `cloudExpired` | any | `localOnly` or `cloudPaused` | "Подписка закончилась" | paused |
| web | signed in | `cloudExpired` | remote snapshot | `cloudEnabled` read-only projection | "Только просмотр" | pull/read only |
| cloud-capable | signed in | active | conflict | `syncConflict` | "Нужно действие" | blocked |
| cloud-capable | signed in | active | error | `syncError` | "Ошибка синхронизации" | retryable |

### Актуализация на текущем checkout

После safe stage с `AppCapabilities`, `FeatureAccess` и preflight-only flow текущую runtime matrix стоит читать так:

| Runtime | Capabilities | `FeatureAccess.cloudSync` | Preflight | Комментарий |
| --- | --- | --- | --- | --- |
| `offlineOnly` | cloud/Firebase capabilities отсутствуют | `disabledByBuild` | `cloudUnavailableInBuild` | локальная-only сборка, без cloud continuation |
| `dev` | все cloud capabilities доступны через dev Firebase | `requiresEntitlement` / `requiresSignIn` / `blockedByLocalData` / `enabled` / `unavailable` | `entitlementRequired` / `signedOut` / `blockedByLocalOnlyData` / `readyForNextStep` / `alreadyCloudEnabled` / `unknown` | основной контур для безопасной проверки local/cloud UX |
| `storeProdLocalFirst` | все cloud capabilities доступны через prod Firebase | те же gate-статусы, что и у `dev` | те же preflight-статусы, что и у `dev` | продуктовый cloud-capable runtime без backend subscription lifecycle |
| `web` cloud-capable build | capability-модель совпадает с cloud-capable runtime | `webApp` и `cloudSync` зависят от entitlement/gates | те же preflight-статусы, если пользователь открывает preflight screen | `isWebReadOnly` пока только projection, не реальный write barrier |

Что важно не перепутать:

* `alreadyCloudEnabled` означает, что cloud уже активен, а не что нужно продолжать активацию.
* `readyForNextStep` не означает, что уже выполнен merge или что локальных данных точно нет.
* preflight сейчас intentionally fail-closed: он не запускает migration, upload или sync enablement.

## План миграции без ломки текущей логики

1. Зафиксировать текущий контракт документом и тестами.
   * Не менять SyncContract, Drift schema, outbox ordering и merge rules.
   * Добавить тесты на существующие barriers: offline-only не создает Firebase sync, local data blocks cloud sync, AI скрыт/недоступен согласно текущим правилам.

2. Ввести `AppCapabilitiesProvider`.
   * Первым шагом он просто оборачивает `AppRuntimeConfig`.
   * Заменять прямые UI-проверки `AppRuntimeConfig.isOffline` постепенно.

3. Разделить `CloudEntitlementState` и `DataModeState`.
   * `DataModeState` оставить совместимым временно, но добавить отдельный `entitlementControllerProvider`.
   * Убрать из `DataModeController` обязанность активировать ключ.

4. Ввести `FeatureAccessProvider`.
   * `canUseCloudSync = capabilities.canRunCloudSync && entitlement in trial/active && auth signed in && dataMode == cloudEnabled`.
   * `canUseAiAssistant = capabilities.canUseAiTransport && entitlement in trial/active`.
   * `canUseAdvancedAnalytics = entitlement in trial/active`.
   * `canUseWebSync = capabilities.canOpenWebApp && entitlement in trial/active`.

5. Перевести DI на feature gates.
   * `syncServiceProvider` оставить первой точкой: `FirebaseSyncService` создается только при `canUseCloudSync`.
   * Remote data source providers либо сделать private/internal для sync DI, либо добавить guard с понятной ошибкой при запрещенном cloud mode.
   * `firebaseAuthProvider` можно оставить capability-level, потому что sign-in нужен до cloud sync, но Firestore/Storage лучше gate-ить жестче.

6. Вынести UX перехода local -> cloud в отдельный controller.
   * `CloudMigrationController` или `CloudOnboardingController`.
   * Состояния: `hasLocalData`, `remoteIsEmpty`, `remoteHasData`, `decisionRequired`, `migrationInProgress`, `migrationFailed`.
   * Сначала реализовать только безопасный read-only audit/decision screen, без изменения merge behavior.

7. Переподключить UI.
   * Главный CTA: "Синхронизация выключена" -> "Включить".
   * Settings/Profile показывают продуктовые состояния, а не flavor.
   * Pull-to-refresh мапит technical result в 4-5 пользовательских сообщений.

8. Trial/backend entitlement.
   * Текущий `DEMO-CLOUD-KEY` оставить dev-only.
   * Добавить интерфейс серверной проверки: `EntitlementRemoteDataSource`.
   * Кэшировать последнее подтвержденное entitlement с `expiresAt`, `source`, `checkedAt`.
   * Для web expired entitlement включать read-only projection.

## Регрессионные тесты

Минимальный набор перед изменением логики:

1. `AppCapabilities`
   * `offlineOnly` не разрешает Firebase/Auth/Firestore/AI transport.
   * `dev` использует dev Firebase environment.
   * `storeProdLocalFirst` использует prod Firebase environment.

2. `Entitlement`
   * `freeLocal` не дает `canUseCloudSync`, `canUseAiAssistant`, `canUseAdvancedAnalytics`.
   * `cloudTrial` и `cloudActive` дают cloud gates.
   * `cloudExpired` отключает push/write sync и AI.
   * `DEMO-CLOUD-KEY` доступен только dev/debug-внутреннему контуру.

3. `DataMode`
   * signed out + cloud-capable + no entitlement => `localOnly`.
   * active entitlement + signed out => cloud-ready signed-out state.
   * active entitlement + signed in + no local data => `cloudEnabled`.
   * active entitlement + signed in + local data => `cloudBlockedByLocalData`.
   * expired entitlement не запускает push sync.

4. DI / Firebase barriers
   * `syncServiceProvider` возвращает `NoopSyncService` для `localOnly`.
   * `syncServiceProvider` возвращает `NoopSyncService(blockedByLocalData)` для local-data barrier.
   * Firestore remote data sources не создаются при disabled cloud sync.
   * offline-only startup не читает Firestore/Auth providers.

5. Auth/local -> cloud
   * login with local data не вызывает опасный merge/push без explicit decision.
   * выбранное `stayLocalOnly` не отправляет outbox.
   * будущий `migrateLocalToCloud` покрыть отдельными integration tests с fake Firestore.

6. UI
   * sign-in screen не зависит напрямую от flavor для продуктовых сообщений.
   * settings показывает "Синхронизация выключена" + "Включить" в cloud-capable local state.
   * blocked local data показывает "Нужно действие".
   * pull-to-refresh не показывает технические enum-сообщения пользователю.
   * AI tab скрыт/disabled по `canUseAiAssistant`, а не по flavor.
   * CTA из `ProfileSyncSettingsCard` ведет на `SignInScreen.routeName`.

7. Web read-only
   * `cloudExpired` на web запрещает create/update/delete actions.
   * read-only режим все еще разрешает pull/read отображение данных.
   * UI показывает причину и CTA продления.

## Рекомендации по UI-состояниям

Пользователю показывать не enum, а projection:

| Internal | User label | Text | Primary action |
| --- | --- | --- | --- |
| `localOnly` in offline-only | Локально | Данные хранятся только на этом устройстве. | none |
| `localOnly` in cloud-capable | Синхронизация выключена | Включите синхронизацию, чтобы пользоваться Kopim на разных устройствах. | Включить |
| `cloudReadySignedOut` | Войдите в аккаунт | Войдите, чтобы включить синхронизацию и web-доступ. | Войти |
| `cloudBlockedByLocalData` | Нужно действие | Мы нашли данные на устройстве и в аккаунте. Выберите, что с ними сделать. | Выбрать |
| `cloudEnabled` | Синхронизация включена | Данные синхронизируются между устройствами. | none |
| `syncError` | Ошибка синхронизации | Не удалось синхронизировать данные. Изменения сохранены на устройстве. | Повторить |
| `syncConflict` | Нужно действие | Мы остановили синхронизацию, чтобы не потерять финансовые данные. | Разобраться |
| `cloudExpired` mobile | Синхронизация на паузе | Приложение продолжает работать локально. Продлите доступ, чтобы снова синхронизировать данные. | Продлить |
| `cloudExpired` web | Только просмотр | Подписка закончилась, редактирование временно недоступно. | Продлить |

## Что не менять без отдельного плана

* Drift schema/migrations.
* `SyncContract`.
* Outbox ordering.
* Tombstone/conflict resolution.
* `AuthSyncService` merge logic.
* Firestore document format.
* Production Firebase data.

## Ближайшие безопасные задачи

1. Исправить route typo в `ProfileSyncSettingsCard`: `/signin` -> `SignInScreen.routeName`.
2. Добавить `AppCapabilities` как read-only wrapper вокруг текущего `AppRuntimeConfig`.
3. Добавить `FeatureAccess` projection без замены существующей логики.
4. Перевести AI tab на `canUseAiAssistant`.
5. Перевести sync settings card на продуктовые состояния "Синхронизация выключена"/"Включить".
6. Добавить тесты на существующие barriers до дальнейших UX-изменений.
