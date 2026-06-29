# Аудит Play/local-first cloud-capable transition

Дата: 2026-06-28

Проверка выполнена в режиме read-only:

- код приложения не менялся;
- тесты не запускались;
- вывод основан на текущем checkout и незакомиченных изменениях.

Связанные документы:

- [ExecPlan 2026-06-27](/home/artem/StudioProjects/kopim/.agent/exec_plans/2026-06-27-play-market-local-first-cloud-capable-transition.md:1)
- [Progress tracker](/home/artem/StudioProjects/kopim/docs/logic/local_cloud_entitlement_progress.md:1)

## Краткий вывод

План не выполнен. В репозитории есть заметный технический прогресс по capability matrix, claims contract, web gate и account-switch safety, но product contour для production mobile всё ещё не доведён до рабочего состояния.

Главные расхождения:

1. post-login cloud flow не доведён до понятного пользовательского сценария;
2. экран выбора действий после входа не закрывает ключевой сценарий "в облаке есть данные, локально пусто";
3. progress tracker сейчас завышает готовность;
4. часть UI и тестов всё ещё живёт в старой модели;
5. web logout gate обходит штатный cleanup workflow.

## Что проверено

- `lib/core/config/app_capabilities.dart`
- `lib/core/navigation/app_router.dart`
- `lib/features/profile/presentation/controllers/auth_controller.dart`
- `lib/features/profile/presentation/controllers/cloud_activation_decision_controller.dart`
- `lib/features/profile/presentation/screens/sign_in_screen.dart`
- `lib/features/profile/presentation/screens/cloud_sync_intro_screen.dart`
- `lib/features/profile/presentation/screens/cloud_access_status_screen.dart`
- `lib/features/profile/presentation/screens/cloud_activation_preflight_screen.dart`
- `lib/features/profile/presentation/screens/cloud_activation_choice_screen.dart`
- `lib/features/profile/presentation/screens/web_entitlement_gate_screen.dart`
- `lib/features/profile/presentation/widgets/profile_sync_settings_card.dart`
- `test/features/profile/presentation/auth_controller_test.dart`
- `test/features/profile/presentation/screens/sign_in_screen_test.dart`
- `test/core/navigation/app_router_test.dart`
- незакомиченные изменения через `git status --short`

## Незакомиченные изменения

На момент аудита изменены:

- `lib/core/navigation/app_router.dart`
- `lib/features/profile/presentation/controllers/auth_controller.dart`
- `lib/features/profile/presentation/widgets/profile_account_settings_card.dart`
- `lib/features/profile/presentation/widgets/profile_management_body.dart`
- `lib/features/profile/presentation/widgets/profile_sync_settings_card.dart`
- `test/core/navigation/app_router_test.dart`
- `test/features/profile/presentation/auth_controller_test.dart`
- `test/features/profile/presentation/widgets/profile_sync_settings_card_test.dart`

## Основные findings

### 1. Post-login flow после входа не доведён до целевого UX

Сейчас после успешного входа `SignInScreen` при `resumeCloudActivation=true` делает `refreshEntitlement()` и затем всегда уходит в `CloudActivationPreflightScreen`, а не сразу в product-ready экран выбора действий:

- [sign_in_screen.dart](/home/artem/StudioProjects/kopim/lib/features/profile/presentation/screens/sign_in_screen.dart:756)
- [cloud_activation_preflight_screen.dart](/home/artem/StudioProjects/kopim/lib/features/profile/presentation/screens/cloud_activation_preflight_screen.dart:171)

Это значит:

- авто-проверка статуса подписки частично появилась, но не доказана end-to-end;
- после входа пользователь не попадает сразу в экран настройки облачных функций;
- итоговый путь всё ещё зависит от промежуточного preflight-экрана и старой fail-closed copy.

Статус: `in_progress`, не `done`.

### 2. Сценарий "в облаке есть данные, локально пусто" фактически не закрыт

Пользовательский сценарий "скачать облачные данные в пустое локальное хранилище" в коде обозначен как `replaceLocalWithCloud`, но в decision controller он помечен как `unavailableUntilExecutionFlow`:

- [cloud_activation_decision_controller.dart](/home/artem/StudioProjects/kopim/lib/features/profile/presentation/controllers/cloud_activation_decision_controller.dart:268)

А на экране выбора это приводит только к placeholder/snackbar, без рабочего завершения сценария:

- [cloud_activation_choice_screen.dart](/home/artem/StudioProjects/kopim/lib/features/profile/presentation/screens/cloud_activation_choice_screen.dart:353)

Простыми словами: вариант "данные уже есть в облаке, загрузи их сюда" в коде назван, но для пользователя ещё не работает как завершённый путь.

### 3. Production mobile flow всё ещё содержит нежелательные варианты и техническую copy

В production cloud-entry ещё остались ветки, которые пользователь уже отклонил:

- `Продолжить локально` на intro screen:
  - [cloud_sync_intro_screen.dart](/home/artem/StudioProjects/kopim/lib/features/profile/presentation/screens/cloud_sync_intro_screen.dart:53)
- `Продолжить локально` на access-status screen:
  - [cloud_access_status_screen.dart](/home/artem/StudioProjects/kopim/lib/features/profile/presentation/screens/cloud_access_status_screen.dart:131)
- `Остаться локально` и `Объединить локальные и облачные данные` в choice screen:
  - [cloud_activation_decision_controller.dart](/home/artem/StudioProjects/kopim/lib/features/profile/presentation/controllers/cloud_activation_decision_controller.dart:225)
  - [cloud_activation_decision_controller.dart](/home/artem/StudioProjects/kopim/lib/features/profile/presentation/controllers/cloud_activation_decision_controller.dart:281)
- технические/system-style формулировки вроде `readiness`, `metadata`, `execution flow`, `design-gate` в пользовательских текстах:
  - [cloud_activation_decision_controller.dart](/home/artem/StudioProjects/kopim/lib/features/profile/presentation/controllers/cloud_activation_decision_controller.dart:201)
  - [cloud_activation_choice_screen.dart](/home/artem/StudioProjects/kopim/lib/features/profile/presentation/screens/cloud_activation_choice_screen.dart:130)

Это расходится с вашим текущим продуктовым решением:

- `merge` пока не делаем;
- `Продолжить локально` не нужен в cloud-entry после sign-in;
- приложение должно само подсказывать правильное действие по состоянию local/cloud;
- системные слова должны исчезнуть из интерфейса.

### 4. Auto-check статуса подписки реализован только частично и требует отдельной проверки

В незакомиченных изменениях `AuthController` уже начал автоматически вызывать `refreshEntitlement()` после cloud sign-in/sign-up/reauth перед `refreshForCurrentContext()`:

- [auth_controller.dart](/home/artem/StudioProjects/kopim/lib/features/profile/presentation/controllers/auth_controller.dart:266)

Это правильное направление, но аудиторских доказательств "полностью работает" пока нет, потому что:

- post-login маршрут всё ещё не ведёт сразу в финальный action/setup screen;
- не видно тестов на полный production path "вошёл -> entitlement refresh -> открылся правильный следующий экран";
- не видно тестов на сценарии:
  - `cloud has data / local empty`;
  - `local has data / cloud empty`;
  - `expired -> renewed`;
  - `refresh failed`.

Итог: в плане нужно считать это `partially landed`, а не "закрыто".

### 5. `ProfileSyncSettingsCard` в dirty changes стал тупиком для `requiresEntitlement`

Для production ветки `requiresEntitlement` карточка теперь только показывает текст и больше не даёт путь в `CloudAccessStatusScreen`:

- [profile_sync_settings_card.dart](/home/artem/StudioProjects/kopim/lib/features/profile/presentation/widgets/profile_sync_settings_card.dart:128)

То есть пользователь может видеть "доступ не активен", но из карточки уже не попадает в экран повторной проверки статуса.

Это регресс относительно ожидаемого продукта и относительно текущего ExecPlan.

### 6. Web entitlement gate всё ещё обходит штатный logout workflow

`WebEntitlementGateScreen` вызывает `cloudAuthRepository.signOut()` напрямую:

- [web_entitlement_gate_screen.dart](/home/artem/StudioProjects/kopim/lib/features/profile/presentation/screens/web_entitlement_gate_screen.dart:57)

При этом штатный logout идёт через:

- [auth_controller.dart](/home/artem/StudioProjects/kopim/lib/features/profile/presentation/controllers/auth_controller.dart:155)
- [cloud_sign_out_use_case.dart](/home/artem/StudioProjects/kopim/lib/features/profile/domain/usecases/cloud_sign_out_use_case.dart:16)

Простыми словами: этот экран может "выйти из Firebase", но не пройти весь обязательный cleanup вокруг sync state, entitlement cache и локального профиля. В результате часть хвостов может остаться в локальном состоянии, хотя пользователь думает, что вышел полностью.

### 7. План и runtime matrix расходятся в dev/tooling контракте

В плане и статусных формулировках фигурирует мысль, что dev entitlement/tooling path сохранён. Но реальная capability matrix для `firebaseDev` говорит другое:

- [app_capabilities.dart](/home/artem/StudioProjects/kopim/lib/core/config/app_capabilities.dart:73)

Сейчас для `firebaseDev`:

- `canRegisterInApp = kIsWeb`
- `canShowPaymentOrPurchaseUi = kIsWeb`
- `canActivatePromoOrLicenseInApp = false`

При этом отдельные тесты вручную подставляют capability, которой реальный runtime не даёт:

- [sign_in_screen_test.dart](/home/artem/StudioProjects/kopim/test/features/profile/presentation/screens/sign_in_screen_test.dart:79)

Простыми словами: тест говорит "в dev это можно", а настоящее приложение отвечает "нет, в таком runtime это нельзя". Значит тест подтверждает искусственную конфигурацию, а не реальное поведение сборки.

### 8. Progress tracker сейчас завышает готовность

В `docs/logic/local_cloud_entitlement_progress.md` сейчас отмечены как `done`:

- Play contour transition;
- server-backed entitlement lifecycle;
- web expired barrier;
- choice screen.

По текущему checkout это неверно. Эти части нужно держать как минимум в `in_progress`, потому что:

- product mobile cloud-entry не доведён;
- post-login routing не закрыт;
- `replaceLocalWithCloud` не доведён до рабочего пользовательского сценария;
- auto entitlement refresh не закрыт доказательствами и тестами;
- web logout cleanup не закрыт;
- tests/runtime matrix расходятся.

## Что уже реально продвинулось

Ниже не проблемы, а то, что действительно уже есть в коде:

- capability matrix для `offlineOnly` / `storeProdLocalFirst` / `webProdCloudOnly` существует;
- claims contract переведён на `cloudAccess`, `cloudPlan`, `cloudAccessUntilMillis`;
- web shell уже не открывается без `featureAccess.webApp == enabled`;
- ownership/account-switch hardening заметно продвинулся;
- auto entitlement refresh после sign-in начал внедряться.

Это важный прогресс, но он ещё не превращает весь план в выполненный.

## Что должно быть отражено в плане

1. Автоматическая проверка статуса подписки обязательна после входа и при explicit resume cloud flow.
2. Для этого нужен отдельный пункт проверки корректности реализации и отдельное тестовое покрытие.
3. После входа production mobile должен открывать экран настройки облачных функций без промежуточного "тупикового" UX.
4. Экран выбора действий должен сам предлагать правильный основной action:
   - если локально пусто, а в облаке есть данные -> предложить загрузить облачные данные;
   - если локально есть данные, а облако пусто -> предложить загрузить локальные данные в облако;
   - если и локально, и в облаке есть данные -> merge не предлагать, оставить fail-closed explanation и отдельный future scope.
5. Из production mobile cloud-entry нужно убрать:
   - `Продолжить локально`;
   - `Остаться локально`;
   - `Merge`;
   - технические/system слова в copy.
6. `ProfileSyncSettingsCard` не должен быть тупиком для `requiresEntitlement`.
7. `WebEntitlementGateScreen` должен выходить только через штатный logout workflow.
8. Тесты должны проверять реальный runtime matrix, а не искусственно подставленные capability-флаги.

## Простое объяснение двух ключевых проблем

### Почему прямой logout из `WebEntitlementGateScreen` плохой

Потому что "выйти из Firebase" и "полностью корректно выйти из облачного режима приложения" это не одно и то же.

Штатный logout у проекта делает не только sign out, но и cleanup вокруг:

- текущего sync UID;
- entitlement cache;
- локального profile/sync состояния.

Если экран обходит этот маршрут и вызывает только `signOut()` у auth-репозитория, пользователь формально выйдет, но часть локального облачного состояния может остаться висеть.

### Почему mismatch между планом, runtime и тестами опасен

Если тесты проверяют "воображаемую" capability matrix, они могут зелёным светом подтверждать поведение, которого в реальной сборке нет.

То есть команда будет думать:

- "dev/runtime путь сохранён и работает",

хотя фактически приложение в этой сборке этот путь не даёт. Это создаёт ложное чувство завершённости и мешает поймать реальные product gaps до релиза.

## Итоговый статус

- ExecPlan: `in_progress`
- Progress tracker: требует коррекции
- Post-login cloud action flow: `not done`
- Auto entitlement refresh: `partially implemented, not fully verified`
- Empty-local -> download-from-cloud scenario: `not done`
- Production copy cleanup for cloud-entry: `not done`
- Web logout workflow alignment: `not done`
- Runtime-aligned test coverage: `not done`
