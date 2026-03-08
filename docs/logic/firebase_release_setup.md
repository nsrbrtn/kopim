# Firebase для релиза: dev / prod схема и настройка `Kopim-prod`

Этот гайд описывает правильную схему Firebase для Kopim:

- `dev/test` остается на старом Firebase project;
- `prod` использует новый Firebase project `Kopim-prod`.

Документ написан как пошаговая инструкция: что создать в Firebase Console, какие файлы скачать, как развести конфиги по окружениям и как проверить, что production действительно смотрит в `Kopim-prod`.

## Когда использовать этот гайд

- Ты создал новый Firebase project `Kopim-prod`.
- Нужно выпустить приложение в сторы, но не потерять старый Firebase для разработки.
- Нужно развести `dev` и `prod` по разным Firebase-конфидам.

## Целевая схема проекта

В проекте должна быть такая архитектура:

- [main.dart](/home/artem/StudioProjects/kopim/lib/main.dart) -> `dev/test Firebase`
- [main_prod.dart](/home/artem/StudioProjects/kopim/lib/main_prod.dart) -> `prod Firebase`

Firebase-конфиги на уровне Dart:

- [firebase_options_dev.dart](/home/artem/StudioProjects/kopim/lib/firebase_options_dev.dart) -> старый Firebase project
- [firebase_options_prod.dart](/home/artem/StudioProjects/kopim/lib/firebase_options_prod.dart) -> `Kopim-prod`

Выбор окружения выполняется через:

- [firebase_environment.dart](/home/artem/StudioProjects/kopim/lib/core/config/firebase_environment.dart)

Важно:

- production release-сборки всегда должны идти через `--target lib/main_prod.dart`;
- `dev/test` должен запускаться через обычный [main.dart](/home/artem/StudioProjects/kopim/lib/main.dart).

## Что важно понять заранее

Firebase в проекте живет на двух уровнях:

1. Firebase Console
   Там ты создаешь проект, приложения Android/iOS/Web и включаешь сервисы.

2. Конфиги внутри приложения
   Это:
   - `firebase_options_*.dart`
   - `google-services.json`
   - `GoogleService-Info.plist`

Нельзя считать настройку законченной, если сделан только один из уровней.

## Текущий контекст Kopim

- Android package prod: `qmodo.ru.kopim`
- iOS bundle id prod: `qmodo.ru.kopim`
- Android flavor: `prod`
- Android prod config: `android/app/src/prod/google-services.json`
- iOS dev plist: `ios/Runner/GoogleService-Info-Dev.plist`
- iOS prod plist: `ios/Runner/GoogleService-Info-Prod.plist`

Важно:

- `firebase_options_dev.dart` и `firebase_options_prod.dart` не редактируем вручную;
- их генерирует `flutterfire configure`;
- platform-файлы тоже не правим вручную.

## Шаг 0. Подготовка

Убедись, что у тебя есть:

1. Доступ к Firebase Console.
2. `firebase-tools`.
3. `flutterfire_cli`.
4. Android keystore для production подписи.

Проверка:

```bash
firebase --version
flutter --version
dart --version
```

Если `firebase` не установлен:

```bash
npm install -g firebase-tools
```

Если `flutterfire` не установлен:

```bash
dart pub global activate flutterfire_cli
```

Потом:

```bash
firebase login
```

## Шаг 1. Создать проект `Kopim-prod`

В Firebase Console:

1. `Create project`
2. Имя: `Kopim-prod`
3. Включить Google Analytics

Важно:

- `Project name` и `Project ID` это не одно и то же;
- в командах CLI потом нужен именно `Project ID`.

## Шаг 2. Добавить Android app

Внутри `Kopim-prod`:

1. `Project settings`
2. `Your apps`
3. `Add app`
4. `Android`

Поля:

- `Android package name`: `qmodo.ru.kopim`
- `App nickname`: например `Kopim Android Prod`

После этого:

- скачать `google-services.json`
- положить его в:

```text
android/app/src/prod/google-services.json
```

## Шаг 3. Добавить Android SHA fingerprints

В Android app внутри Firebase Console добавь:

- `SHA1`
- `SHA256`

Это берется с production keystore.

Для текущего production keystore Kopim:

```text
SHA1: E7:86:DF:D0:CB:CD:6A:1F:63:5B:B7:80:3F:0F:42:6A:A9:56:BD:8A
SHA256: DA:3A:FC:78:A3:8C:99:88:A3:2D:28:5D:F2:03:F4:DA:D0:1E:43:00:53:87:B9:B3:F2:5E:35:26:7E:F7:B2:00
```

Если later будет `Play App Signing`, после первого билда в Play Console стоит добавить и fingerprint от `App signing key`.

## Шаг 4. Добавить iOS app

В `Kopim-prod`:

1. `Add app`
2. `iOS`

Поля:

- `Bundle ID`: `qmodo.ru.kopim`
- `App nickname`: например `Kopim iOS Prod`

После этого:

- скачать `GoogleService-Info.plist`
- сохранить его как production plist:

```text
ios/Runner/GoogleService-Info-Prod.plist
```

## Шаг 5. Добавить Web app

Если production web тоже должен идти в `Kopim-prod`:

1. `Add app`
2. `Web`
3. nickname, например `Kopim Web Prod`

Зачем это нужно:

- чтобы FlutterFire сгенерировал web options для production;
- чтобы production web не ходил в старый Firebase.

## Шаг 6. Включить нужные сервисы

Минимум для текущего проекта:

1. `Authentication`
2. `Cloud Firestore`
3. `Firebase Storage`
4. `Crashlytics`
5. `Analytics`
6. `Cloud Messaging`
7. `Remote Config`

Проверь хотя бы:

- `Email/Password`
- `Anonymous auth`

Если это не включить, production login/register не заработает.

## Шаг 7. Сгенерировать prod-конфиг через FlutterFire CLI

Важный принцип:

- старый [firebase_options.dart](/home/artem/StudioProjects/kopim/lib/firebase_options.dart) / [firebase_options_dev.dart](/home/artem/StudioProjects/kopim/lib/firebase_options_dev.dart) остается для dev/test;
- production генерируется в отдельный файл.

Команда:

```bash
flutterfire configure \
  --project=<firebase_project_id_prod> \
  --platforms=android,ios,web \
  --android-package-name=qmodo.ru.kopim \
  --ios-bundle-id=qmodo.ru.kopim \
  --out=lib/firebase_options_prod.dart
```

Пример:

```bash
flutterfire configure \
  --project=kopim-prod \
  --platforms=android,ios,web \
  --android-package-name=qmodo.ru.kopim \
  --ios-bundle-id=qmodo.ru.kopim \
  --out=lib/firebase_options_prod.dart
```

Что делает команда:

- берет данные нового проекта;
- не переписывает текущий dev-конфиг;
- создает отдельный prod Dart-config.

## Шаг 8. Проверить, что prod-файл правильный

Открой:

- [firebase_options_prod.dart](/home/artem/StudioProjects/kopim/lib/firebase_options_prod.dart)

Проверь:

1. `projectId` = `kopim-prod`
2. `appId` новые, от production app
3. в файле нет старого `device-streaming-74c1af8e`

Открой:

- [firebase_options_dev.dart](/home/artem/StudioProjects/kopim/lib/firebase_options_dev.dart)

Проверь:

1. там остался старый dev/test Firebase
2. он не смотрит в `kopim-prod`

## Шаг 9. Привязать entrypoint-ы к окружениям

Правильная схема уже должна быть такой:

- [main.dart](/home/artem/StudioProjects/kopim/lib/main.dart) вызывает Firebase environment `dev`
- [main_prod.dart](/home/artem/StudioProjects/kopim/lib/main_prod.dart) вызывает Firebase environment `prod`

Если это не так, то `firebase_options_prod.dart` сам по себе ничего не даст.

## Шаг 10. Проверить platform-файлы

Проверь, что сейчас production platform-конфиги лежат здесь:

### Android

```text
android/app/src/prod/google-services.json
```

### iOS

```text
ios/Runner/GoogleService-Info-Prod.plist
```

Важно:

- Android prod уже flavor-aware;
- iOS теперь использует split по конфигурациям:
  - `Debug` -> `GoogleService-Info-Dev.plist`
  - `Release/Profile` -> `GoogleService-Info-Prod.plist`

## Шаг 11. Проверить сборку

После генерации prod-конфига:

```bash
flutter pub get
flutter analyze
flutter test --reporter expanded
```

Потом production Android:

```bash
flutter build appbundle \
  --flavor prod \
  --release \
  --target lib/main_prod.dart \
  --dart-define-from-file=defines.json
```

Production iOS:

```bash
flutter build ipa \
  --release \
  --target lib/main_prod.dart \
  --dart-define-from-file=defines.json
```

## Шаг 12. Проверить живой production flow

После первой production сборки проверь руками:

1. Приложение запускается без ошибки инициализации Firebase.
2. Login / registration работают.
3. Пользователь появляется в `Authentication` проекта `Kopim-prod`.
4. Новые документы пишутся в Firestore именно `Kopim-prod`.
5. В Analytics приходят события.
6. Crashlytics начинает видеть production build.

Если данные уходят в старый проект, production setup не завершен.

## Что считается успешным результатом

Можно считать схему настроенной правильно, если:

- `main.dart` работает со старым dev/test Firebase;
- `main_prod.dart` работает с `Kopim-prod`;
- `firebase_options_dev.dart` и `firebase_options_prod.dart` физически разные;
- Android prod использует новый `google-services.json`;
- iOS release использует `GoogleService-Info-Prod.plist`;
- production build реально пишет данные в `Kopim-prod`.

## Частые ошибки

### 1. Перепутали `Project name` и `Project ID`

В CLI нужен именно `Project ID`.

### 2. Обновили только `google-services.json`, но не сгенерировали `firebase_options_prod.dart`

Тогда Android частично переключен, а Dart Firebase остается старым.

### 3. Сгенерировали `firebase_options_prod.dart`, но не привязали его к `main_prod.dart`

Файл существует, но production build им не пользуется.

### 4. Нажали `yes` и переписали общий `firebase_options.dart`

Так можно случайно перевести и dev/test в production.

### 5. Не добавили SHA fingerprints

Это часто проявляется не сразу, а позже на production Android сценариях.

### 6. Не включили Auth / Firestore / Storage в новом проекте

Сборка проходит, но приложение функционально не работает.

## Короткий чеклист

1. Создать `Kopim-prod`
2. Добавить Android app `qmodo.ru.kopim`
3. Добавить `SHA1` и `SHA256`
4. Положить новый `android/app/src/prod/google-services.json`
5. Добавить iOS app `qmodo.ru.kopim`
6. Положить новый `ios/Runner/GoogleService-Info.plist`
7. Добавить Web app
8. Включить Auth / Firestore / Storage / Crashlytics / Analytics / Messaging / Remote Config
9. Сгенерировать:

```bash
flutterfire configure \
  --project=kopim-prod \
  --platforms=android,ios,web \
  --android-package-name=qmodo.ru.kopim \
  --ios-bundle-id=qmodo.ru.kopim \
  --out=lib/firebase_options_prod.dart
```

10. Проверить `firebase_options_prod.dart`
11. Собрать prod через `lib/main_prod.dart`
12. Убедиться, что данные идут в `Kopim-prod`

## Официальные источники

- Firebase Flutter setup: https://firebase.google.com/docs/flutter/setup
- Firebase Android setup: https://firebase.google.com/docs/android/setup
- Firebase Apple setup: https://firebase.google.com/docs/ios/setup
- Firebase Cloud Messaging for Flutter: https://firebase.google.com/docs/cloud-messaging/flutter/client
