# Firebase для релиза: настройка и ротация ключей

Этот гайд описывает безопасную настройку Firebase для production-релиза Kopim и выпуск новых ключей без простоя.

## Когда нужен этот гайд

- Подготовка первого релиза в Google Play / App Store.
- Переезд на новый Firebase project.
- Ротация ключей (компрометация, плановая безопасность, смена окружения).

## Текущий контекст проекта

- Android package (prod): `qmodo.ru.kopim`
- iOS bundle id (prod): `qmodo.ru.kopim`
- Flavor на Android: `dev`, `stage`, `prod`
- Firebase options генерируются через FlutterFire CLI: `lib/firebase_options.dart`

Важно: `lib/firebase_options.dart` и platform-конфиги не редактируем вручную, только через `flutterfire configure`.

## 1) Рекомендуемая схема окружений

Для релиза лучше использовать отдельный Firebase project для production:

- `kopim-prod` — боевые пользователи и данные.
- `kopim-dev` (или текущий проект) — разработка/тесты.

Это уменьшает риск случайной отправки тестовых данных в прод.

## 2) Создание приложений в Firebase (prod)

В Firebase Console для `kopim-prod` создайте приложения:

- Android app:
  - Package name: `qmodo.ru.kopim`
- iOS app:
  - Bundle ID: `qmodo.ru.kopim`
- Web app (если web нужен в проде)

После создания скачайте конфиги:

- Android: `google-services.json`
- iOS: `GoogleService-Info.plist`

## 3) Android: release fingerprints (SHA-1 / SHA-256)

Для корректной работы Google Sign-In, Dynamic Links и части SDK добавьте SHA отпечатки release-ключа:

```bash
keytool -list -v \
  -keystore /absolute/path/to/upload-keystore.jks \
  -alias <keyAlias>
```

Скопируйте SHA-1 и SHA-256 в настройки Android app в Firebase Console.

Примечание: если используете Play App Signing, добавьте также fingerprint от Google Play (из Play Console).

## 4) Генерация новых Firebase конфигов через FlutterFire CLI

Убедитесь, что вы залогинены в нужный Firebase аккаунт:

```bash
firebase login
dart pub global activate flutterfire_cli
```

Перегенерируйте `firebase_options.dart` под production project:

```bash
flutterfire configure \
  --project=<firebase_project_id_prod> \
  --platforms=android,ios,web \
  --android-package-name=qmodo.ru.kopim \
  --ios-bundle-id=qmodo.ru.kopim
```

Проверьте, что в `lib/firebase_options.dart` новый `projectId`.

## 5) Размещение platform-конфигов в репозитории проекта

Android (с flavor):

- prod-конфиг кладём в `android/app/src/prod/google-services.json`
- при необходимости оставляем/обновляем `android/app/google-services.json` только как fallback

iOS:

- основной файл: `ios/Runner/GoogleService-Info.plist`

Если для iOS появятся отдельные build-конфигурации/схемы окружений, используйте отдельные plist на каждую конфигурацию и скрипт копирования при сборке.

## 6) Выпуск новых ключей (ротация)

### 6.1 API keys Firebase apps (Android/iOS/Web)

Что делать:

1. Создать новые app-конфиги в Firebase Console (или пересоздать app при необходимости).
2. Перегенерировать `lib/firebase_options.dart` через `flutterfire configure`.
3. Обновить `google-services.json` и `GoogleService-Info.plist`.
4. Выпустить тестовую сборку (internal/TestFlight).
5. После проверки отключить/ограничить старые ключи в GCP API restrictions.

Рекомендации:

- Ограничивайте Web API key по allowed APIs + HTTP referrers.
- Для Android API key добавьте ограничение по package name + SHA-1.
- Для iOS API key добавьте ограничение по bundle id.

### 6.2 Service Account keys (если используете в CI/скриптах)

Порядок безопасной ротации:

1. Создать новый service account key в Google Cloud IAM.
2. Обновить секреты в CI/CD и локальном окружении.
3. Проверить рабочие операции (deploy, admin scripts, интеграции).
4. Только после успешной проверки отозвать старый key.

Никогда не храните service account JSON в открытом репозитории.

## 7) Что проверить перед релизом

Технический чеклист:

1. `flutter analyze` — без ошибок.
2. `flutter test --reporter expanded` — зелёный прогон.
3. Android prod сборка:
```bash
flutter build appbundle --release --flavor prod --target lib/main_prod.dart
```
4. iOS prod сборка:
```bash
flutter build ipa --release --target lib/main_prod.dart
```
5. Firebase Analytics/Crashlytics события приходят в prod-проект.
6. Firestore пишет данные в прод-коллекции, а не dev.

## 8) Проверка после выката

В первые 24-72 часа:

- Crash-free users/sessions.
- ANR (Android) / crash rate (iOS).
- Ошибки авторизации и синхронизации.
- Наличие событий в Analytics и ошибок в Crashlytics.

## 9) Частые ошибки

- Перепутали Firebase project между dev и prod.
- Не добавили release SHA-1/SHA-256 для Android.
- Обновили `firebase_options.dart`, но не обновили platform-конфиги.
- Ротировали ключи до обновления CI/секретов (простой сборок).

## 10) Минимальный план ротации без простоя

1. Создать новые ключи/конфиги.
2. Обновить приложение и CI.
3. Выпустить внутренний билд.
4. Проверить Firebase каналы (Auth/Firestore/Crashlytics/Analytics).
5. Переключить production.
6. Отозвать старые ключи.
