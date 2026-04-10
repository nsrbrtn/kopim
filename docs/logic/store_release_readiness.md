# План выпуска Kopim в App Store и Google Play

Дата подготовки: 2026-03-07
Последнее обновление: 2026-04-10

## Цель документа

Этот документ фиксирует, что нужно сделать перед выпуском Kopim в `App Store` и `Google Play`:

- что доработать в коде;
- какие артефакты подготовить для сторов;
- какие legal/privacy документы нужны;
- как провести тестовый релиз и выкладку;
- что мониторить после публикации.

Документ привязан к текущему состоянию репозитория на `2026-03-07`.

## Текущая оценка на 2026-04-09

По состоянию на `2026-04-09` кодовая база выглядит достаточно зрелой для перехода от активной разработки к выпускному проходу:

- `flutter analyze` проходит без ошибок;
- `flutter test --reporter expanded` проходит полностью;
- в проекте уже есть production entrypoint, legal URL, account deletion flow и покрытие ключевых доменных сценариев;
- основной риск сместился с реализации фич на release readiness, store policy compliance и проверку production-контура на реальных сборках.

Вывод:

- в первую очередь нужно не расширять функциональность, а закрыть выпускные риски;
- ближайший приоритет проекта: довести `Android` и `iOS` release pipeline до состояния release candidate;
- новые фичи и UX-polish имеет смысл брать только после прохождения release smoke-checklist.

## Статус выполнения на 2026-04-10

### Подтверждено на практике

1. Android production pipeline уже собирает release-артефакт.

Проверенная команда:

```bash
flutter build appbundle --release --flavor prod --target lib/main_prod.dart
```

Результат:

- успешно собран `build/app/outputs/bundle/prodRelease/app-prod-release.aab`;
- `prod` flavor работает;
- `main_prod.dart` используется как валидный production entrypoint;
- Android release pipeline не упирается в немедленный blocker по flavor/setup/signing.

2. iOS release pipeline нельзя валидировать в текущем рабочем окружении.

Фактическое состояние:

- текущая машина работает под `Linux`;
- в этом окружении локальные subcommands `flutter build ios` и `flutter build ipa` недоступны;
- в репозитории уже есть `ios/Runner/GoogleService-Info-Dev.plist` и `ios/Runner/GoogleService-Info-Prod.plist`;
- в `ios/Runner.xcodeproj/project.pbxproj` уже заведён `FIREBASE_PLIST_PATH` для `Debug` и `Release/Profile`;
- iOS release-проверка должна выполняться на `macOS` runner или вручную через `Xcode`.

Практический вывод:

- Android можно считать подтвержденным направлением release pipeline;
- iOS split по Firebase уже подготовлен на уровне репозитория;
- iOS остается открытым release-блоком окружения и требует отдельного прохода на `macOS` для signing, archive и TestFlight-ready сборки.

## Технический аудит pre-smoke на 2026-04-10

Ниже перечислены именно те сигналы, которые выглядят релевантными для первого release smoke-pass.

### Findings

#### 1. AI privacy copy противоречит фактическому data flow

Серьезность: `высокая`

Что найдено:

- на экране условий использования AI явно сказано, что запросы уходят во внешний сервис `OpenRouter`:
  - [assistant_screen.dart](/home/artem/StudioProjects/kopim/lib/features/ai/presentation/screens/assistant_screen.dart#L500)
- при этом в onboarding/localization есть утверждение, что данные "не передаются третьим лицам":
  - [app_ru.arb](/home/artem/StudioProjects/kopim/lib/l10n/app_ru.arb#L3835)
  - [app_en.arb](/home/artem/StudioProjects/kopim/lib/l10n/app_en.arb#L3835)
- в коде также подтверждены внешние каналы:
  - `OpenRouter`
  - `Firebase Analytics`
  - `Firebase Crashlytics`
  - `Sentry`

Почему это риск:

- это уже не косметика, а потенциально неверное product/legal обещание;
- перед release такой текст нельзя оставлять в текущем виде.

Что делать:

- синхронизировать AI onboarding copy с фактическим data flow;
- убрать формулировку про отсутствие передачи данных третьим лицам, если она не соответствует реальному поведению.

#### 2. Брендинг расходится между Android, iOS и in-app UI

Серьезность: `средняя`

Что найдено:

- Android app name сейчас `Копим`:
  - [strings.xml](/home/artem/StudioProjects/kopim/android/app/src/main/res/values/strings.xml#L3)
- iOS name локализован как `Kopim` / `Копим`:
  - [InfoPlist.strings](/home/artem/StudioProjects/kopim/ios/Runner/en.lproj/InfoPlist.strings#L1)
  - [InfoPlist.strings](/home/artem/StudioProjects/kopim/ios/Runner/ru.lproj/InfoPlist.strings#L1)
- внутри UI и текстов активно используется именно `Kopim`.

Почему это риск:

- стора и само приложение будут выглядеть как разные бренды;
- это ухудшает восприятие продукта и делает store materials менее консистентными.

Что делать:

- выбрать единый release-branding для app name;
- затем синхронизировать Android label, iOS display name и store metadata.

#### 3. Пользовательские ошибки открытия сайта ссылаются на устаревший домен `qmodo.ru`

Серьезность: `средняя`

Что найдено:

- user-facing error text все еще указывает на `qmodo.ru`:
  - [app_ru.arb](/home/artem/StudioProjects/kopim/lib/l10n/app_ru.arb#L351)
  - [app_en.arb](/home/artem/StudioProjects/kopim/lib/l10n/app_en.arb#L351)
- этот текст используется и в меню, и на экране "О приложении":
  - [menu_screen.dart](/home/artem/StudioProjects/kopim/lib/features/profile/presentation/screens/menu_screen.dart#L77)
  - [about_app_screen.dart](/home/artem/StudioProjects/kopim/lib/features/profile/presentation/screens/about_app_screen.dart#L43)
- при этом release/legal/support URLs уже переведены на `kopim.site`.

Почему это риск:

- пользователь получает неправильное сообщение об ошибке в release-сценарии;
- это выглядит как незавершенный rebrand/migration хвост.

Что делать:

- обновить error copy под текущий домен или сделать ее нейтральной без упоминания конкретного URL.

#### 4. Экран "О приложении" имеет stale hardcoded fallback по версии

Серьезность: `средняя`

Что найдено:

- если `PackageInfo` не загрузится, UI покажет жестко зашитое значение `1.0.1 (1)`:
  - [about_app_screen.dart](/home/artem/StudioProjects/kopim/lib/features/profile/presentation/screens/about_app_screen.dart#L63)

Почему это риск:

- в release build может отображаться устаревшая версия;
- это плохо для support, QA и store review.

Что делать:

- либо убрать hardcoded fallback;
- либо сделать fallback нейтральным (`—` / `не удалось определить версию`), а не привязанным к старому релизному номеру.

#### 5. Экран авторизации содержит hardcoded и частично нелокализованные тексты

Серьезность: `средняя`

Что найдено:

- в `SignInScreen` есть прямые русские строки и незавернутые в l10n placeholders:
  - [sign_in_screen.dart](/home/artem/StudioProjects/kopim/lib/features/profile/presentation/screens/sign_in_screen.dart#L315)
  - [sign_in_screen.dart](/home/artem/StudioProjects/kopim/lib/features/profile/presentation/screens/sign_in_screen.dart#L356)
  - [sign_in_screen.dart](/home/artem/StudioProjects/kopim/lib/features/profile/presentation/screens/sign_in_screen.dart#L360)
  - [sign_in_screen.dart](/home/artem/StudioProjects/kopim/lib/features/profile/presentation/screens/sign_in_screen.dart#L378)
  - [sign_in_screen.dart](/home/artem/StudioProjects/kopim/lib/features/profile/presentation/screens/sign_in_screen.dart#L394)
  - [sign_in_screen.dart](/home/artem/StudioProjects/kopim/lib/features/profile/presentation/screens/sign_in_screen.dart#L400)

Почему это риск:

- EN-локаль будет выглядеть незавершенной;
- это заметный user-facing дефект на одном из самых важных экранов первого запуска.

Что делать:

- вынести все hardcoded строки и placeholders экрана авторизации в `l10n`.

### Что не подтвердилось как активный blocker

1. По быстрому поиску не видно, что `coming soon` / placeholder строки из `l10n` массово торчат в текущем UI.
2. Аналитика и overview используют placeholder-данные в empty-chart сценариях, но это выглядит как корректный empty-state, а не как незавершенная заглушка release-уровня.

### Приоритетный pre-smoke backlog по итогам аудита

1. Исправить AI privacy copy.
2. Убрать hardcoded и нелокализованные строки с auth-экранов.
3. Синхронизировать брендинг `Kopim` / `Копим` между Android, iOS и store metadata.
4. Убрать stale `qmodo.ru` из user-facing ошибок.
5. Убрать stale fallback версии на экране "О приложении".

### Статус исправлений после первого пакета правок на 2026-04-10

Уже исправлено:

1. AI privacy copy приведен в соответствие с фактическим data flow.
   - onboarding теперь прямо сообщает, что текст запроса передается внешнему AI-сервису;
   - предупреждение про чувствительные данные синхронизировано с экраном условий использования AI.
2. Нелокализованные auth-строки убраны с экрана входа и регистрации.
   - email/password labels теперь берутся из `l10n`;
   - placeholders, CTA "Забыли пароль?" и success snackbar после reset password переведены в `l10n`.
3. User-facing ошибка открытия сайта сделана нейтральной.
   - сообщение больше не зашито на конкретный домен `qmodo.ru`.
4. Fallback версии на экране "О приложении" сделан безопасным.
   - вместо устаревшего hardcoded release number теперь показывается нейтральное `—`.
5. Брендинг приложения синхронизирован на уровне platform labels и базовых user-facing строк.
   - Android app label переведен на единый бренд `Kopim`;
   - iOS display name / bundle name приведены к `Kopim`;
   - русские строки с названием приложения в ключевых точках (`About`, semantic label логотипа) тоже приведены к `Kopim`.

После этого pre-smoke backlog из аудита можно считать закрытым на уровне кода. Следующий этап уже не кодовый, а выпускной:

1. Прогнать ручной Android RC smoke-pass по checklist.
2. Подготовить final store metadata и приложить фактические privacy/data-safety ответы.
3. Повторить iOS часть на `macOS` через `Xcode` / `TestFlight`.

## Фактическая матрица permissions и data flows на 2026-04-10

Ниже зафиксировано то, что подтверждается текущим кодом, а не предварительными предположениями.

### Android permissions

#### `POST_NOTIFICATIONS`

- Где используется:
  - локальные уведомления и напоминания через `flutter_local_notifications`;
  - запрос разрешения делается в `lib/core/services/notifications_gateway_mobile.dart`.
- Пользовательская ценность:
  - напоминания о предстоящих платежах;
  - тестовое уведомление из настроек;
  - действия из уведомлений для reminder-flow.
- Можно ли выпустить без него:
  - технически да;
  - продуктово нежелательно, потому что reminder-flow сильно теряет ценность.

#### `SCHEDULE_EXACT_ALARM`

- Где используется:
  - проверка статуса и открытие системного экрана через `lib/core/services/exact_alarm_permission_service.dart`;
  - Android bridge в `android/app/src/main/kotlin/qmodo/ru/kopim/MainActivity.kt`;
  - UI настройки в `lib/features/profile/presentation/widgets/profile_exact_alarm_preferences_card.dart`.
- Пользовательская ценность:
  - точные напоминания в указанное время;
  - более предсказуемый recurring/upcoming flow на Android.
- Можно ли выпустить без него:
  - да, потому что в `lib/core/services/notifications_gateway_mobile.dart` уже есть fallback на `inexact`;
  - для store-review важно явно описывать это как opt-in сценарий.

#### `RECEIVE_BOOT_COMPLETED`

- Где используется:
  - `ScheduledNotificationBootReceiver` из `flutter_local_notifications`;
  - кастомный `RepeatBootReceiver` в `android/app/src/main/kotlin/qmodo/ru/kopim/RepeatBootReceiver.kt`.
- Пользовательская ценность:
  - восстановление напоминаний и фоновых задач после reboot;
  - recurring generation и upcoming apply rules не теряются после перезагрузки устройства.
- Можно ли выпустить без него:
  - да, но надежность reminder-flow после reboot ухудшится.

#### `CAMERA`

- Где используется:
  - camera avatar flow через `ImagePicker` в `lib/features/profile/presentation/controllers/avatar_controller.dart`.
- Пользовательская ценность:
  - пользователь может сделать фото для аватара прямо из приложения.
- Можно ли выпустить без него:
  - да, если оставить только gallery/preset avatar flow;
  - это не ядро продукта, но нормальная вспомогательная возможность.

#### `INTERNET`

- Где используется:
  - Firebase Auth, Firestore sync, Remote Config, Analytics, Crashlytics, Sentry и сетевые сервисы.
- Пользовательская ценность:
  - авторизация;
  - облачная синхронизация;
  - конфигурация и диагностика.
- Можно ли выпустить без него:
  - нет, если релиз сохраняет sync/account модель.

#### `ACCESS_NETWORK_STATE`

- Где используется:
  - network-aware поведение и более аккуратные сетевые проверки.
- Пользовательская ценность:
  - корректная реакция на offline/online;
  - меньше ложных сетевых операций.
- Можно ли выпустить без него:
  - теоретически да, но практический выигрыш от удаления низкий.

### iOS permission keys

#### `NSCameraUsageDescription`

- Подтвержден в `ios/Runner/Info.plist`.
- Нужен для camera avatar flow.

#### `NSPhotoLibraryUsageDescription`

- Подтвержден в `ios/Runner/Info.plist`.
- Нужен для выбора аватара из галереи.

### Карта данных и внешних сервисов

#### `Firebase Auth`

- Используется для email/password auth и удаления пользователя.
- Основные точки:
  - `lib/core/di/injectors.dart`
  - `lib/features/profile/data/auth_repository_impl.dart`
- Тип данных:
  - email;
  - user id;
  - auth/session data.

#### `Cloud Firestore`

- Используется как облачный sync-layer для пользовательских сущностей.
- Подтверждено по remote data sources в `profile`, `accounts`, `transactions`, `budgets`, `credits`, `savings`, `tags`, `upcoming_payments`.
- Тип данных:
  - профиль;
  - счета;
  - транзакции;
  - бюджеты;
  - накопления;
  - кредиты и долги;
  - теги;
  - upcoming/reminder сущности.

#### `Firebase Analytics`

- Используется через `lib/core/services/analytics_service.dart`.
- В коде реально логируются product events:
  - profile events;
  - savings events;
  - auth sync events;
  - AI events;
  - reminder scheduling events.
- Для store forms это означает, что analytics/app activity реально собираются.

#### `Firebase Crashlytics`

- Используется через `lib/core/services/analytics_service.dart` и местами напрямую.
- Для store forms это означает, что crash logs реально собираются.

#### `Sentry`

- Используется как дополнительный error reporting канал в `lib/core/services/analytics_service.dart`.
- Ошибки analytics и runtime errors тоже отправляются в Sentry.
- Для privacy disclosures это нужно учитывать отдельно от Crashlytics.

#### `Firebase Remote Config`

- Используется в `lib/core/config/app_config.dart`.
- Сейчас задействован для AI-конфига:
  - model;
  - base URL;
  - timeout;
  - retry policy;
  - enabled flag.

#### `Firebase Messaging`

- В коде подтвержден web push flow в `lib/core/services/push_permission_service_web.dart`.
- При разрешении вызываются:
  - `requestPermission()`;
  - `setAutoInitEnabled(true)`;
  - `getToken()`.
- Это означает, что для web-сценария может создаваться push token / messaging identifier.

#### `Firebase Storage`

- Capability присутствует в коде:
  - `lib/features/profile/data/remote/avatar_remote_data_source.dart`.
- Но текущий avatar flow нужно описывать аккуратно:
  - фото из камеры/галереи сейчас сохраняются как `data URL` локально;
  - это подтверждается `storeOfflineOnly = true` в `lib/features/profile/presentation/controllers/avatar_controller.dart`;
  - `lib/features/profile/data/profile_repository_impl.dart` не ставит `data URL` в outbox на remote sync;
  - preset avatars синхронизируются как asset path, а не как пользовательская фотография.
- Практический вывод:
  - SDK `Firebase Storage` подключен;
  - но текущий camera/gallery flow не выглядит как обязательная облачная загрузка пользовательских фото.

### Практический вывод для store forms

- Для `Google Play Data Safety` уже можно уверенно декларировать:
  - account data: да;
  - financial/user content: да;
  - analytics/app activity: да;
  - crash logs: да.
- Для фото и файлов нужен аккуратный ответ:
  - камера и photo library используются для avatar selection;
  - текущий camera/gallery flow не выглядит как обязательная загрузка фото в `Firebase Storage`;
  - перед заполнением store forms это нужно финально перепроверить на реальном авторизованном сценарии.

## Черновик ответов для store forms на 2026-04-10

Этот раздел не заменяет финальное юридическое и консольное заполнение, но уже дает рабочий черновик ответов, основанный на текущем коде.

### Google Play Data Safety: рабочий черновик

#### Какие типы данных выглядят собираемыми или обрабатываемыми

##### Account info

- `email address`: да
- `user ID`: да

Основание:

- `Firebase Auth` используется для email/password auth;
- пользовательская запись и удаление аккаунта подтверждены в коде.

##### App activity

- `app interactions`: да
- `in-app search history`: нет явных подтверждений
- `other actions`: да, частично через продуктовые analytics events

Основание:

- `Firebase Analytics` логирует profile, savings, auth sync, AI и reminder-related события.

##### Financial info

- `financial info`: да

Основание:

- счета, транзакции, бюджеты, накопления, кредиты и related user entities синхронизируются через `Cloud Firestore`.

##### Photos and videos

- `photos`: использовать осторожный ответ

Предварительная позиция:

- приложение получает доступ к фото/камере для выбора аватара;
- но текущий camera/gallery flow не выглядит как обязательная облачная загрузка пользовательских фото;
- до финального ответа это нужно перепроверить на реальном signed-in сценарии.

##### Crash logs

- `crash logs`: да

Основание:

- используется `Firebase Crashlytics`;
- дополнительно используется `Sentry`.

##### Device or other IDs

- `device or other IDs`: вероятно да, но нужно заполнить консервативно

Основание:

- web push flow через `Firebase Messaging` может создавать messaging token;
- `Firebase Analytics` и `Crashlytics` обычно опираются на служебные идентификаторы SDK.

#### Передаются ли данные третьим лицам

Предварительный рабочий ответ:

- данные передаются внешним сервисам инфраструктуры приложения:
  - Google Firebase;
  - Sentry.

Для внутренних store-форм это обычно не означает "sale", но означает передачу внешним обработчикам/processor-сервисам.

#### Собираются ли данные

Предварительный рабочий ответ:

- да, для account/auth;
- да, для sync данных пользователя;
- да, для analytics;
- да, для crash reporting.

#### Являются ли данные обязательными для работы приложения

Предварительный рабочий ответ:

- auth и cloud sync: да, для авторизованного сценария;
- analytics/crash reporting: нет, это не core user-facing feature;
- notifications/exact alarm: нет, приложение работает и без них;
- camera/photo access: нет, это вспомогательный avatar flow.

#### Шифруются ли данные при передаче

Предварительный рабочий ответ:

- да, по сетевым каналам Firebase/Sentry.

Это нужно финально подтвердить в legal/privacy формулировках, но для store forms такой ответ выглядит ожидаемым.

#### Можно ли запросить удаление данных

- да

Основание:

- в приложении реализован in-app account deletion flow;
- public deletion URL опубликован;
- cleaner удаляет известные пользовательские коллекции и локальные данные.

### App Store Privacy: рабочий черновик

#### Data used to track you

Предварительный рабочий ответ:

- `No`, если в финальной ревизии не подтвердится отдельный advertising/tracking SDK.

Текущее основание:

- в коде не видно ad SDK;
- нет подтверждения классического cross-app tracking сценария.

#### Data linked to the user

С высокой вероятностью сюда попадают:

- `Contact Info`:
  - email
- `Identifiers`:
  - user ID
  - вероятные service identifiers/token flows
- `Financial Info`:
  - счета, транзакции, бюджеты, накопления, кредиты
- `User Content`:
  - профиль
  - avatar/preset avatar state
- `Usage Data`:
  - analytics events
- `Diagnostics`:
  - crash logs, error reports

#### Data not linked to the user

Возможная часть diagnostics/analytics может оказаться в этой категории в зависимости от финальной конфигурации SDK и настроек консоли, но пока безопаснее считать, что analytics и sync-oriented account data связаны с пользователем.

### Что еще обязательно перепроверить перед реальным заполнением форм

1. Реальный signed-in сценарий avatar flow:
   - сохраняется ли camera/gallery avatar только локально;
   - не уходит ли пользовательское фото в `Firebase Storage` косвенно через другой путь.
2. Web push / messaging token сценарий:
   - нужен ли он в первом релизе;
   - надо ли отражать его в production store forms, если основной релизный акцент на mobile.
3. Финальные ответы по `Identifiers`:
   - сверить с актуальными подсказками Play Console и App Store Connect в момент заполнения.
4. Юридическая сверка текстов:
   - `privacy.html`
   - `terms.html`
   - `delete-account.html`
   - `support.html`

## Что делать сейчас в первую очередь

Ниже зафиксирован рекомендуемый порядок работ на ближайший выпускной цикл.

### Приоритет 0. Завершить текущий release-проход в рабочем дереве

Почему это первое:

- в репозитории уже есть незавершенные изменения в `AndroidManifest`, `Info.plist`, splash assets, exact alarm UX, account deletion cleanup и release-документации;
- это выглядит как активный релизный проход, который нужно либо довести до конца, либо стабилизировать и разделить на отдельные задачи;
- пока это не сделано, сложно считать текущее состояние проекта фиксированной release-точкой.

Что сделать:

1. Разобрать все незавершенные release-related изменения и подтвердить их целевое состояние.
2. Убедиться, что изменения по `exact alarm`, account deletion и platform assets не конфликтуют друг с другом.
3. Зафиксировать результат как отдельный стабильный этап перед дальнейшей подготовкой к стору.

Критерий завершения:

- нет неясных release-изменений в рабочем дереве;
- все текущие правки либо завершены и проверены, либо вынесены в отдельные явные задачи.

### Приоритет 1. Закрыть production pipeline и release-конфигурацию

Это главный технический приоритет.

Что сделать:

1. Проверить и зафиксировать production-команды сборки для:
   - `flutter build appbundle --release --flavor prod --target lib/main_prod.dart`
   - iOS archive/build проверить отдельно на `macOS` через `Xcode` или `flutter build ios` / `flutter build ipa`
2. Подтвердить, что production-сборка действительно использует production Firebase и production legal/support URLs.
3. Проверить Android release signing, `versionCode`, Crashlytics mapping upload и `prod` flavor.
4. Проверить iOS signing, `CFBundleIdentifier`, `CFBundleShortVersionString`, `CFBundleVersion`, production `GoogleService-Info.plist`, capabilities и privacy declarations.
5. Явно решить, нужен ли отдельный iOS production pipeline или текущая схема достаточна.

Критерий завершения:

- Android release build собирается локально без ручных обходов;
- iOS release build/archive собирается по задокументированному сценарию;
- подтверждено, что `main_prod.dart` и production Firebase реально используются в release-сборке.

### Приоритет 2. Закрыть store policy и privacy surface

Это главный продуктово-регуляторный риск для первого релиза.

Что сделать:

1. Провести финальную ревизию Android permissions:
   - где permission запрашивается;
   - какая пользовательская ценность;
   - можно ли выпустить без него.
2. Подготовить обоснование для `SCHEDULE_EXACT_ALARM`, `POST_NOTIFICATIONS`, `CAMERA`, `RECEIVE_BOOT_COMPLETED`.
3. Сверить `Privacy Policy`, `Terms`, `Support`, `Delete Account` URL с фактическим UX в приложении и будущими store forms.
4. Собрать фактическую карту данных для `Google Play Data Safety` и `App Store Privacy` по реальному использованию:
   - Firebase Analytics;
   - Crashlytics;
   - Auth;
   - Firestore;
   - Storage;
   - Messaging;
   - Sentry.
5. Перепроверить account deletion flow как store-blocker сценарий.

Критерий завершения:

- по каждому permission и data flow есть конкретный ответ, а не предположение;
- все legal/privacy URL согласованы между приложением, сайтом и store metadata;
- account deletion можно уверенно показывать в review как рабочий сценарий.

### Приоритет 3. Прогнать release candidate на реальных устройствах

После конфигурации и policy-подготовки нужно подтвердить, что выпускной контур работает не только в тестах.

Что сделать:

1. Собрать Android release candidate и проверить его на реальном устройстве.
2. Собрать iOS/TestFlight build и проверить его на реальном iPhone.
3. Пройти минимум следующие сценарии:
   - first launch;
   - sign up / sign in;
   - sync;
   - создание и редактирование транзакций;
   - upcoming payments и reminders;
   - permissions flow;
   - backup/export/import;
   - account deletion.
4. Отдельно проверить web fallback для reminders и точные уведомления на Android.

Критерий завершения:

- есть короткий smoke-report по Android и iOS;
- нет blocker-багов в базовом пользовательском пути;
- release candidate можно отдавать в TestFlight и Internal Testing.

### Приоритет 4. Подготовить store materials и metadata

Это следующий слой после технической стабилизации.

Что сделать:

1. Подготовить store screenshots без debug-артефактов и заглушек.
2. Подготовить icon master и `feature graphic` для Google Play.
3. Подготовить:
   - app name;
   - short description;
   - full description;
   - subtitle/promotional text;
   - keywords;
   - release notes;
   - support/legal/privacy links.
4. При необходимости подготовить отдельные `RU` и `EN` наборы материалов.

Критерий завершения:

- все поля для App Store Connect и Google Play Console можно заполнить без дополнительных блокеров;
- медиа и тексты соответствуют реальному текущему продукту.

## Краткий план на ближайшую неделю

### День 1

- завершить и стабилизировать текущий release-проход в рабочем дереве;
- зафиксировать итог по exact alarm, account deletion и platform configs.

### День 2

- собрать и задокументировать production pipeline для Android;
- проверить production Firebase, signing и release build.

### День 3

- собрать и задокументировать production pipeline для iOS;
- закрыть вопросы по signing, plist и privacy declarations.

### День 4

- заполнить permission/privacy/data safety matrix;
- сверить legal/support/delete-account UX и URL.

### День 5

- прогнать manual smoke-test release candidate на Android и iPhone;
- собрать список blocker/minor issues.

### После этого

- готовить store assets и metadata;
- только затем возвращаться к новым фичам или крупному UX-polish.

## Что уже есть в проекте

- Android package для prod: `qmodo.ru.kopim`.
- iOS bundle id для prod: `qmodo.ru.kopim`.
- На Android уже есть flavor `prod`.
- В проекте уже подключены `Firebase Analytics`, `Crashlytics`, `Auth`, `Firestore`, `Storage`, `Messaging`, `Remote Config`.
- Есть app icons и splash assets для Android/iOS.
- В `AppConfig` уже вынесены public legal/support URL для prod.
- На `kopim.site` уже опубликованы:
  - `https://kopim.site/privacy.html`
  - `https://kopim.site/terms.html`
  - `https://kopim.site/delete-account.html`
  - `https://kopim.site/support.html`
- На экране `О приложении` legal-ссылки уже открывают реальные `https`-страницы.
- В профиле внутри секции `Учетная запись` уже реализовано удаление аккаунта с подтверждением через кодовое слово и текущий пароль.
- Для production уже есть отдельный entrypoint `lib/main_prod.dart`, который делегирует в общий bootstrap из `lib/main.dart`.
- Firebase-конфиги разделены по окружениям: `main.dart` использует dev/test Firebase, `main_prod.dart` использует `Kopim-prod`.
- На web reminder-flow остается доступным, но UI должен явно предупреждать, что напоминания не будут надежно приходить в фоне и при закрытом приложении.

Связанный документ:

- `docs/logic/firebase_release_setup.md`
- `docs/logic/profile_management_screen.md`

## Текущие пробелы, которые видны прямо сейчас

### 1. Android permissions требуют policy-review

Файл:

- `android/app/src/main/AndroidManifest.xml`

Статус после ревизии `2026-03-07`:

- `POST_NOTIFICATIONS`
- `RECEIVE_BOOT_COMPLETED`
- `SCHEDULE_EXACT_ALARM`
- `INTERNET`
- `ACCESS_NETWORK_STATE`
- `CAMERA`
- Удалены из manifest как лишние или слишком рискованные для review:
  - `READ_MEDIA_IMAGES`
  - `READ_EXTERNAL_STORAGE`

Результат ревизии:

1. `POST_NOTIFICATIONS`:
   - реально используется для локальных напоминаний через `flutter_local_notifications`;
   - оставляем;
   - user value: уведомления о предстоящих платежах и напоминаниях.
2. `RECEIVE_BOOT_COMPLETED`:
   - реально используется через `ScheduledNotificationBootReceiver` и `RepeatBootReceiver`;
   - оставляем;
   - user value: восстановление notification/reschedule логики после перезагрузки устройства.
3. `INTERNET`:
   - реально используется Firebase, sync и web/network сервисами;
   - оставляем.
4. `ACCESS_NETWORK_STATE`:
   - оставляем как стандартное сетевое permission для connectivity/network-aware поведения;
   - review-risk низкий.
5. `CAMERA`:
   - реально используется в profile avatar flow (`Сделать фото`);
   - оставляем;
   - user value: съемка аватара прямо из приложения.
6. `SCHEDULE_EXACT_ALARM`:
   - возвращен в manifest;
   - пользователь может открыть системный экран exact alarm из настроек приложения;
   - без него приложение умеет fallback на `inexact`, но для точных напоминаний теперь поддерживается opt-in сценарий.
7. `READ_MEDIA_IMAGES` и `READ_EXTERNAL_STORAGE`:
   - удалены;
   - текущий avatar/gallery flow идет через `image_picker`, а для текущего сценария постоянный доступ к медиатеке не нужен;
   - это уменьшает permission surface для стора.

### 2. iOS release-конфигурация выглядит минимальной

Файлы:

- `ios/Runner/Info.plist`
- `ios/Runner.xcodeproj/project.pbxproj`

Сейчас:

- bundle version и short version string завязаны на Flutter build variables;
- есть usage descriptions для камеры и фото;
- отдельная prod-схема или набор конфигураций явно не виден.

Для релиза нужно:

- решить, нужен ли отдельный iOS release/prod pipeline с отдельным Firebase plist и scheme;
- проверить signing, capabilities и privacy declarations.

## Что сделать в коде

### Блок A. Release-конфигурация и окружения

Статус на `2026-03-07`:

- production entrypoint стандартизирован как `lib/main_prod.dart`;
- `main.dart` и `main_prod.dart` используют разные Firebase-конфиги;
- release-документация обновлена на этот стандарт.

1. Зафиксировать release-команды для Android и iOS.
2. Убедиться, что prod-сборка использует production Firebase.
3. Развести dev/stage/prod значения для:
   - API/config flags;
   - legal URLs;
   - support email;
   - feature flags;
   - analytics/crash reporting switches при необходимости.

Минимум по коду:

- использовать `lib/main_prod.dart` как обязательный `--target` для production release-команд;
- добавить/уточнить `AppConfig` для prod URL и legal links;
- проверить и документировать `firebaseInitializationProvider`;
- синхронизировать `docs/logic/firebase_release_setup.md` с реальной схемой запуска.

### Блок B. Legal и account lifecycle

Статус на `2026-03-07`:

- `Privacy Policy` уже опубликована на `https://kopim.site/privacy.html`.
- `Terms of Use` уже опубликованы на `https://kopim.site/terms.html`.
- `Account Deletion` страница уже опубликована на `https://kopim.site/delete-account.html`.
- В приложении уже есть переходы на legal-страницы и support page из экрана `О приложении`.
- На экране `О приложении` уже показывается реальная пара `version + build number` из build metadata.
- В приложении уже есть in-app flow удаления аккаунта из `Профиль -> Учетная запись`.

Нужно реализовать в приложении:

1. Проверку пользовательского текста в confirmation flow удаления аккаунта.
2. Понятное описание, что происходит с локальными и облачными данными при удалении аккаунта.
3. Сверку store-form URL с фактическими URL на `kopim.site`.

Почему это важно:

- `Google Play` требует возможность удаления аккаунта из приложения, если приложение поддерживает создание аккаунта.
- Для `App Store` это тоже критичная часть review, если у пользователя есть учетная запись и облачные данные.

Что уже сделано в коде:

1. `LegalConfig` в `AppConfig`:
   - `privacyPolicyUrl`
   - `termsOfUseUrl`
   - `accountDeletionUrl`
   - `supportUrl`
2. Экран `О приложении`:
   - версия берется из `PackageInfo.fromPlatform()`;
   - UI показывает фактические `version + build number`.
   - support page открывается по `supportUrl`.
3. Domain use case удаления аккаунта:
   - re-auth через текущий пароль;
   - удаление Firebase Auth user;
   - удаление известных Firestore-данных пользователя;
   - очистка локальных данных Drift.
4. UI на профиле:
   - пункт `Удалить аккаунт` в секции `Учетная запись`;
   - destructive confirmation dialog;
   - обязательный ввод текста-подтверждения и текущего пароля;
   - состояние загрузки и ошибок.
5. Public legal pages:
   - `privacy.html`
   - `terms.html`
   - `delete-account.html`
6. Архитектурное правило:
   - любая новая Firestore-подколлекция `users/{uid}/...` должна добавляться в cleaner удаления аккаунта.

Что еще нужно довести до релиза:

1. Сверить юридические тексты с фактическими реквизитами правообладателя.
2. Убедиться, что support/contact блоки на сайте и в store metadata совпадают.
3. При появлении новых пользовательских коллекций не забывать обновлять cleaner.

### Блок C. App metadata в самом приложении

1. Заменить hardcoded версию на фактическую версию сборки.
2. Проверить app name:
   - Android сейчас использует label `kopim`;
   - для стора и иконки лучше использовать единый бренд `Kopim`, если это целевое написание.
3. Проверить onboarding/empty states на предмет:
   - недописанных заглушек;
   - debug-текстов;
   - технических формулировок.
4. Проверить email/support links:
   - `mailto:qmodo@qmodo.ru` должен открываться корректно;
   - `supportUrl` должен вести на `https://kopim.site/support.html`.

### Блок D. Permissions и privacy surface

Статус на `2026-03-07` после ревизии Android permissions:

- оставлены `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`, `SCHEDULE_EXACT_ALARM`, `INTERNET`, `ACCESS_NETWORK_STATE`, `CAMERA`;
- `SCHEDULE_EXACT_ALARM` возвращен в manifest и вынесен в явный opt-in flow на экране настроек;
- `READ_MEDIA_IMAGES` и `READ_EXTERNAL_STORAGE` убраны из manifest;
- в настройках снова есть отдельный UI для включения точных напоминаний через системный экран Android.

Нужно пройтись по каждому permission и ответить на 3 вопроса:

1. Где в UI он реально запрашивается?
2. Какая пользовательская ценность у него есть?
3. Можно ли выпустить без него?

Рекомендуемая ревизия:

- `CAMERA`: оставлен, потому что аватар действительно можно снять с камеры.
- `POST_NOTIFICATIONS`: оставлен, потому что локальные уведомления и напоминания реально используются.
- `RECEIVE_BOOT_COMPLETED`: оставлен, потому что после reboot нужно восстанавливать уведомления и фоновые задачи.
- `SCHEDULE_EXACT_ALARM`: возвращен, потому что пользователю нужен opt-in сценарий для точных напоминаний без дрейфа по времени.
- `READ_MEDIA_IMAGES`: удален.
- `READ_EXTERNAL_STORAGE`: удален.

Отдельно для iOS:

- проверить, что `NSCameraUsageDescription` и `NSPhotoLibraryUsageDescription` соответствуют фактическому UX;
- не добавлять лишние permission keys;
- если будет push, проверить APNs capability, notification entitlements и тексты pre-permission UX.

### Блок E. Release quality gates

Перед release candidate должны проходить:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart format --set-exit-if-changed .
flutter analyze
flutter test --reporter expanded
flutter build appbundle --release --flavor prod --target lib/main_prod.dart
```

Дополнительно стоит добавить:

- iOS release/archive проверять на `macOS` через `Xcode` или `flutter build ios` / `flutter build ipa`;
- smoke-test release-сборки на реальном Android-устройстве;
- smoke-test TestFlight build на реальном iPhone;
- проверку cold start;
- проверку first-run permissions;
- проверку sign in / sign up / sync / backup / export / account deletion.

## Какие картинки и графику подготовить

### 1. Иконка приложения

Нужно подготовить исходник:

- квадратный master не меньше `1024x1024`;
- без мелких деталей по краям;
- без текста;
- векторный исходник или PNG высокого качества.

Платформенные требования:

- `App Store`: `1024x1024` без прозрачности;
- `Google Play`: `512x512`, PNG, обычно до `1024 KB`.

Практически:

- держать один master asset;
- от него генерировать Android/iOS наборы;
- проверить читаемость на маленьких размерах.

### 2. Feature graphic для Google Play

Нужно:

- `1024x500` PNG/JPG.

Это не то же самое, что иконка. Графика должна:

- показывать бренд;
- работать без мелкого текста;
- не обещать фичи, которых нет в релизе.

### 3. Скриншоты стора

Минимальный набор, который стоит подготовить:

- iPhone 6.7" screenshots;
- iPhone 6.5" screenshots, если понадобятся;
- Android phone screenshots;
- при желании tablet screenshots, если реально поддерживается качественный tablet UX.

Рекомендуемый сюжет скриншотов:

1. Главный экран со сводкой счетов и баланса.
2. Транзакции и быстрый ввод операций.
3. Бюджеты или накопления.
4. Кредиты/долги.
5. Аналитика.

Требования к самим скриншотам:

- только реальный UI приложения;
- без заглушек и dev-данных;
- локализованные тексты;
- консистентная тема;
- читаемые суммы, даты и заголовки;
- без статусных артефактов вроде debug banner.

Рекомендуется дополнительно подготовить:

- light theme набор;
- отдельный RU и EN набор, если стора планируются на нескольких языках.

### 4. Splash / launch assets

Проверить:

- что Android splash и iOS launch assets соответствуют текущему бренду;
- что иконка и splash не расходятся по стилю;
- что нет устаревшего логотипа или временных png.

### 5. Promo-видео

Не обязательно для первого релиза, но полезно подготовить позже:

- короткое видео 15-30 секунд для сайта/соцсетей;
- для Play можно добавить promo video через YouTube.

## Что подготовить для App Store Connect и Google Play Console

### Общие метаданные

Нужны заранее:

- app name;
- short description / subtitle;
- full description;
- keywords;
- support email;
- support URL: `https://kopim.site/support.html`;
- marketing URL;
- privacy policy URL;
- terms of use URL;
- data deletion URL или help-страница удаления аккаунта;
- категория приложения;
- возрастной рейтинг;
- copyright.

### App Store Connect

Подготовить:

- `App Name`
- `Subtitle`
- `Promotional Text`
- `Description`
- `Keywords`
- `Support URL`
- `Marketing URL`
- `Privacy Policy URL`
- screenshots
- app icon
- App Privacy answers
- age rating questionnaire

Дополнительно проверить:

- нужна ли `Export Compliance`;
- нужен ли `Sign in with Apple`.

Важно по `Sign in with Apple`:

- если в приложении появится сторонний вход типа Google/Facebook только на iOS, Apple часто требует предложить и `Sign in with Apple`;
- если используется только email/password и анонимная сессия, требование надо оценить отдельно при финальном review.

### Google Play Console

Подготовить:

- app name;
- short description;
- full description;
- app icon;
- feature graphic;
- phone screenshots;
- tablet screenshots, если заявляете поддержку планшетов;
- privacy policy URL;
- Data safety form;
- content rating questionnaire;
- contact details;
- release notes.

Отдельно проверить policy-блоки:

- `Permissions declaration`, если затронуты чувствительные разрешения;
- `Exact alarm` policy impact;
- раздел про удаление аккаунта;
- `Data deletion` и `Data safety`.

## Какие политики и юридические документы нужны

Минимум для релиза:

### 1. Privacy Policy

Обязательно должна содержать:

- какие данные собираются;
- какие данные хранятся локально;
- какие данные уходят в Firebase;
- зачем нужны Analytics/Crashlytics;
- используются ли push-уведомления;
- используются ли фото/камера;
- как пользователь может удалить данные и аккаунт;
- контакт для privacy-вопросов.

### 2. Terms of Use / Пользовательское соглашение

Нужно описать:

- условия использования;
- отказ от финансовых гарантий и инвестиционных обещаний;
- ограничения ответственности;
- правила использования аккаунта;
- возрастные ограничения, если они нужны;
- порядок удаления аккаунта и прекращения доступа.

### 3. Account Deletion / Data Deletion Policy

Нужна отдельная публичная страница или раздел:

- как удалить аккаунт;
- какие данные удаляются сразу;
- какие данные могут храниться ограниченное время;
- что происходит с локальными данными на устройстве;
- срок завершения удаления, если он не мгновенный.

Текущий статус:

- страница уже создана и доступна по `https://kopim.site/delete-account.html`;
- in-app удаление аккаунта уже реализовано в профиле;
- в проекте зафиксирован инвариант: новые пользовательские коллекции обязаны добавляться в cleaner удаления аккаунта.

### 4. Support Page

Желательно иметь отдельную support-страницу:

- FAQ;
- контакты;
- как написать о проблеме с релизом;
- как запросить удаление данных.

## Что нужно задекларировать по данным и приватности

### Для Google Play Data Safety

Нужно пройти по каждому типу данных:

- email / user id;
- фото профиля, если она загружается;
- device identifiers;
- crash logs;
- analytics events;
- app activity;
- files/photos, если есть доступ к галерее.

Для каждого определить:

- собираются ли данные;
- передаются ли третьим сторонам;
- обязательны ли они для работы;
- можно ли удалить данные;
- шифруются ли данные при передаче.

### Для App Store Privacy

Нужно отдельно ответить:

- какие данные используются для аналитики;
- какие данные связаны с личностью пользователя;
- используется ли tracking;
- есть ли third-party SDK, добавляющие telemetry.

Практический шаг:

- собрать фактическую карту SDK и data flows по коду;
- проверить ответы не "по ощущениям", а по реальному использованию Firebase/Sentry и профиля.

## Что проверить по сборке и инфраструктуре

### Android

1. Проверить `upload-keystore.jks`, `key.properties`, alias и release signing.
2. Включить `Play App Signing`.
3. Проверить `versionCode` и стратегию инкремента.
4. Убедиться, что `prod` flavor реально собирает production-конфигурацию.
5. Проверить `google-services.json` для `prod`.
6. Проверить shrink/minify release-сборки на отсутствие runtime regressions.
7. Проверить Crashlytics mapping upload.

### iOS

1. Проверить Apple Developer account, certificates, identifiers, profiles.
2. Проверить signing в Xcode.
3. Проверить `GoogleService-Info.plist` для production.
4. Проверить `CFBundleIdentifier`, `CFBundleShortVersionString`, `CFBundleVersion`.
5. Проверить release archive в Xcode / `flutter build ipa`.
6. Проверить dSYM upload для Crashlytics.
7. Проверить capability для push, если push реально используется.

### iOS/macOS prerequisites для отдельного прохода

Так как текущая рабочая среда не позволяет локально собрать iOS release, перед macOS-проходом нужно заранее подтвердить:

1. Есть доступ к `Apple Developer` и `App Store Connect` для нужной команды.
2. В Xcode доступен корректный `Signing Team` для `qmodo.ru.kopim`.
3. Для production target используется `ios/Runner/GoogleService-Info-Prod.plist`.
4. Archive собирается с:
   - `CFBundleIdentifier = qmodo.ru.kopim`
   - актуальными `FLUTTER_BUILD_NAME` и `FLUTTER_BUILD_NUMBER`
5. После archive можно:
   - экспортировать build;
   - отправить build в `TestFlight`;
   - увидеть dSYM/Crashlytics upload без явных ошибок.
6. Если push не входит в первый релиз, не добавлять лишние iOS capabilities только “на будущее”.

## Release-кандидат: сценарии ручной проверки

Перед загрузкой в `TestFlight` / `Internal testing` пройти минимум следующий smoke-checklist.

### Android RC checklist

1. Установить `app-prod-release.aab` / соответствующий internal build на реальное Android-устройство.
2. Проверить cold start:
   - splash отображается корректно;
   - нет debug-banner;
   - приложение открывается без startup error screen.
3. Пройти first-run permissions:
   - notifications permission;
   - exact alarm status screen в настройках;
   - camera/gallery avatar flow.
4. Проверить auth:
   - sign up;
   - sign in;
   - sign out;
   - восстановление сессии после перезапуска.
5. Проверить базовый финансовый путь:
   - создать счет;
   - добавить доход;
   - добавить расход;
   - создать перевод между счетами одной валюты.
6. Проверить расширенные сущности:
   - создать накопление и пополнение;
   - создать кредит или долг;
   - провести платеж по обязательству.
7. Проверить upcoming/reminder flow:
   - создать upcoming payment;
   - создать reminder;
   - убедиться, что планирование отрабатывает без ошибок;
   - отправить тестовое уведомление из настроек.
8. Проверить offline-first сценарий:
   - отключить сеть;
   - внести изменения локально;
   - включить сеть;
   - дождаться resync без потери данных.
9. Проверить backup/import/export:
   - export выполняется успешно;
   - backup включает `saving goals`, `credits`, `credit cards`, `debts`, `tags`, `transaction tags`, `budgets`, `budget instances`, `upcoming payments`, `payment reminders`;
   - import работает как restore и не оставляет старые локальные данные;
   - legacy backup не падает на `savingGoalId`.
10. Проверить account deletion:
   - destructive dialog требует кодовое слово и текущий пароль;
   - после удаления пользователь действительно выходит из аккаунта;
   - локальные данные очищаются;
   - повторный запуск не возвращает удаленную сессию.
11. Проверить legal/support путь:
   - открываются `privacy`;
   - открываются `terms`;
   - открывается `support`;
   - версия и build number показываются корректно.

### Дополнительно для Android

1. Проверить поведение reminders после reboot устройства.
2. Проверить exact alarm opt-in на Android 12+.
3. Проверить release build на отсутствие regressions от shrink/minify.

### iOS / TestFlight checklist

1. Установить TestFlight build на реальный iPhone.
2. Проверить cold start и launch screen.
3. Проверить auth:
   - sign up;
   - sign in;
   - sign out;
   - восстановление сессии.
4. Проверить базовый финансовый путь:
   - счет;
   - доход;
   - расход;
   - перевод.
5. Проверить savings / credit / debt flow.
6. Проверить upcoming/reminder UI:
   - создание правил;
   - отсутствие platform-specific ошибок;
   - корректное поведение при недоступности Android-specific exact alarm flow.
7. Проверить avatar flow:
   - gallery selection;
   - camera capture;
   - отсутствие permission-crash.
8. Проверить export/import.
9. Проверить account deletion.
10. Проверить legal/support links.

### Общие критерии успешного smoke-test

1. Нет blocker-багов в core user path.
2. Нет падений на first launch, auth, sync, export/import, account deletion.
3. Нет platform-specific dead-end экранов.
4. Локаль `ru` отображается корректно.
5. Денежные суммы и scale отображаются корректно.

## Порядок выпуска

### Этап 1. Техническая готовность

1. Закрыть пробелы по коду.
2. Прогнать analyze/tests/build.
3. Собрать production Firebase через `lib/main_prod.dart`.
4. Подготовить release notes.

### Этап 2. Store assets и legal

1. Подготовить иконку, feature graphic, screenshots.
2. Проверить, что `privacy`, `terms`, `support`, `account deletion` доступны на `kopim.site`.
3. Подготовить описания приложения на нужных языках.

### Этап 3. Внутреннее тестирование

1. Android Internal testing.
2. iOS TestFlight.
3. Проверка analytics/crashlytics в production.
4. Сбор замечаний и финальные правки.

### Этап 4. Подача в review

1. Заполнить App Store Connect.
2. Заполнить Google Play Console.
3. Проверить все URLs и disclosure-формы.
4. Отправить релиз на review.

### Этап 5. После публикации

В первые `24-72` часа мониторить:

- crash-free sessions;
- ANR и startup crashes;
- ошибки входа;
- ошибки sync;
- delivery notifications/reminders;
- воронку регистрации;
- первые отзывы пользователей.

## Рекомендуемый минимальный backlog перед релизом

### P0. Блокеры релиза

1. Проверить production Firebase и release signing.

### P1. Сильно желательно

1. Подготовить RU/EN store metadata.
2. Support page уже подготовлена: `https://kopim.site/support.html`.
3. Проверить весь onboarding/empty states на отсутствие заглушек.
4. Пройти release smoke-test на реальных устройствах.
5. Финально вычитать `Privacy Policy`, `Terms` и `Delete Account` под store review и реальные реквизиты.

### P2. После первого релиза

1. Улучшить App Store / Play visuals.
2. Добавить маркетинговую страницу продукта.
3. Автоматизировать release checklist в CI.
4. Вести шаблон release notes и regression checklist для каждого релиза.

## Definition of Done для первого релиза

- prod-сборки Android и iOS собираются без ручных обходов.
- В приложении нет placeholder-заглушек в legal-разделе.
- Пользователь может открыть privacy policy и terms.
- Пользователь может удалить аккаунт и понять, что будет с данными.
- Public страницы `privacy`, `terms`, `delete-account` доступны на `kopim.site`.
- Store assets готовы и согласованы с брендом.
- Data safety / App privacy формы заполнены по фактическим данным.
- Internal testing / TestFlight пройдены.
- Crashlytics и Analytics подтверждены на production-сборке.
- Есть план мониторинга первых 72 часов после релиза.
