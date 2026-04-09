# План выпуска Kopim в App Store и Google Play

Дата подготовки: 2026-03-07
Последнее обновление: 2026-04-09

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
   - `flutter build ipa --release --target lib/main_prod.dart`
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
flutter build ipa --release --target lib/main_prod.dart
```

Дополнительно стоит добавить:

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

## Release-кандидат: сценарии ручной проверки

Перед загрузкой в TestFlight/Internal testing пройти минимум:

1. Первый запуск приложения.
2. Регистрация и вход.
3. Анонимный режим, если он поддерживается.
4. Создание счета.
5. Добавление дохода, расхода и перевода.
6. Создание накопления и пополнение.
7. Создание кредита/долга и платеж.
8. Локальные уведомления и напоминания.
9. Синхронизация после перезапуска.
10. Работа без сети и последующий resync.
11. Экспорт данных.
    - проверить, что backup включает `saving goals`, `credits`, `credit cards`, `debts`, `tags`, `transaction tags`, `budgets`, `budget instances`, `upcoming payments`, `payment reminders`;
    - проверить, что import работает как restore и не оставляет старые локальные транзакции/обязательства;
    - проверить импорт legacy backup без падения на `savingGoalId`.
12. Удаление аккаунта.
13. Переходы на privacy policy, terms, support.

Отдельно проверить:

- обновление с предыдущей версии;
- поведение после reboot устройства для reminders;
- корректность локали `ru`;
- корректность сумм и валютных scale.

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
