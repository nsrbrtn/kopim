# ExecPlan: Подготовка релиза Android в Google Play (flavor `prod`)

## Context and Orientation
- Цель: выпустить стабильную Android-версию приложения в Google Play через `app bundle` для `prod` flavor.
- Область кода: `android/`, `lib/main_prod.dart`, `pubspec.yaml`, документация и релизные артефакты.
- Контекст/ограничения:
  - В проекте уже настроены flavor `dev/stage/prod` и release signing через `android/key.properties`.
  - Запрещено редактировать секреты и выполнять деплой-команды без явного запроса.
  - Release должен быть reproducible: одинаковая команда сборки и фиксированный чеклист перед публикацией.
- Риски:
  - Политика Google Play по `SCHEDULE_EXACT_ALARM` (возможен отказ модерации без обоснования).
  - Ошибочная конфигурация Firebase между flavor'ами.
  - Отсутствие автоматизации релиза (нет `fastlane`/`.github` pipeline).
  - Релиз без полного регресса (analyze/test/build).

## Interfaces and Dependencies
- Внешние сервисы (Firebase/Analytics/Crashlytics):
  - Firebase подключен (Core/Auth/Firestore/Crashlytics/Remote Config/Messaging).
  - Crashlytics Gradle plugin включен в `android/app/build.gradle.kts`.
  - `google-services.json` присутствует в `android/app/` и `android/app/src/prod/`.
- Локальные зависимости:
  - Flutter/Dart toolchain, Gradle, Android SDK.
  - Codegen: `build_runner`, Drift/Freezed/Riverpod.
- Затрагиваемые API/модули:
  - Android build config: `android/app/build.gradle.kts`.
  - Манифест: `android/app/src/main/AndroidManifest.xml`.
  - Версия приложения: `pubspec.yaml`.
  - Entry point: `lib/main_prod.dart`.

## Plan of Work
- Провести pre-release аудит конфигурации и политики Google Play.
- Зафиксировать релизный процесс сборки и валидации `prod` flavor.
- Подготовить артефакт `AAB`, пройти внутреннее тестирование (Internal testing track).
- Выполнить staged rollout в Production с мониторингом Crashlytics/ANR.

## Concrete Steps
1) Preflight и стабилизация окружения
- Зафиксировать версии toolchain (`flutter doctor -v`, `flutter --version`).
- Проверить, что `android/key.properties` заполнен и указывает на валидный upload keystore.
- Сверить package id для прода: `qmodo.ru.kopim` (`android/app/build.gradle.kts`).
- Синхронизировать release-версию в `pubspec.yaml` (новые `versionName/versionCode`).

2) Политики Google Play и безопасность
- Проверить необходимость `android.permission.SCHEDULE_EXACT_ALARM` в `android/app/src/main/AndroidManifest.xml`.
- Если разрешение не критично для core value приложения, удалить/ограничить использование перед релизом.
- Если разрешение критично, подготовить обоснование для Play Console Permissions Declaration.
- Убедиться, что в репозитории нет лишних сервисных ключей и тестовых admin JSON в release-контуре.

3) Проверка Firebase и flavor-конфигурации
- Подтвердить, что `prod` использует корректный `google-services.json` (`android/app/src/prod/google-services.json`).
- Проверить соответствие package name в Firebase проекте (`qmodo.ru.kopim`).
- Убедиться, что Crashlytics/Analytics включаются в prod и отключены отладочные флаги.

4) Release-quality проверки кода
- Выполнить:
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart format --set-exit-if-changed .
flutter analyze
flutter test --reporter expanded
```
- Зафиксировать и исправить ошибки/варнинги релизного уровня (особенно nullable/runtime/async ошибки).

5) Сборка и верификация релизного артефакта
- Собрать `AAB`:
```bash
flutter build appbundle --release --flavor prod --target lib/main_prod.dart
```
- Проверить артефакт `build/app/outputs/bundle/prodRelease/app-prod-release.aab`.
- Локально установить release APK (при необходимости через bundletool) и проверить ключевые сценарии:
  - Первый запуск.
  - Авторизация.
  - Базовый offline-first сценарий (создание/редактирование сущностей офлайн и последующий sync).
  - Push/локальные уведомления.

6) Публикация через треки Google Play
- Загрузить `AAB` в `Internal testing`.
- Пройти smoke с реальными аккаунтами/устройствами (Android 12/13/14+).
- Подготовить release notes и заполнить обязательные формы Data safety/Privacy policy/Permissions.
- Перевести сборку в `Production` через staged rollout (например, 5% -> 20% -> 50% -> 100%).

7) Пост-релизный мониторинг
- В первые 24-72 часа мониторить:
  - Crash-free users/sessions.
  - ANR rate.
  - Ошибки синхронизации и деградации авторизации.
- Иметь rollback-сценарий: остановка rollout и hotfix с новым `versionCode`.

## Validation and Acceptance
- Команды проверки:
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart format --set-exit-if-changed .
flutter analyze
flutter test --reporter expanded
flutter build appbundle --release --flavor prod --target lib/main_prod.dart
```
- Acceptance criteria:
  - Сборка `prodRelease` проходит без ошибок.
  - `AAB` загружается в Google Play без блокеров.
  - Internal testing не выявляет критических дефектов (P0/P1).
  - Нет блокирующих нарушений политик Google Play.
  - Crash/ANR показатели в пределах допустимого SLA после rollout.

## Idempotence and Recovery
- Что можно безопасно перезапускать:
  - `pub get`, `build_runner`, `format`, `analyze`, `test`, `build appbundle`.
- Как откатиться/восстановиться:
  - Остановить staged rollout в Play Console.
  - Выпустить hotfix с увеличенным `versionCode`.
  - Для критических инцидентов отключить проблемный remote config флаг (если применимо).
- План rollback:
  - На уровне стора откат бинарника недоступен, используем новый hotfix релиз.
  - Для серверной конфигурации использовать feature-flag rollback.

## Progress
- [x] Шаг 1: Выполнен аудит текущей release-конфигурации в репозитории.
- [x] Шаг 2: Сформирован подробный ExecPlan для релиза в Google Play.
- [ ] Шаг 3: Пройти preflight-команды и устранить найденные блокеры.
  - Факт на 2026-02-15: `flutter analyze` — без ошибок.
  - Факт на 2026-02-15: `flutter test --reporter expanded` — падает (15 failed, есть timeout/Binding initialization проблемы).
- [ ] Шаг 4: Собрать и загрузить `AAB` в Internal testing.
- [ ] Шаг 5: Выполнить staged rollout в Production.

## Surprises & Discoveries
- В проекте отсутствует готовая CI/CD автоматизация релиза (`fastlane`/`.github` workflow).
- В манифесте присутствует `SCHEDULE_EXACT_ALARM`, что требует отдельной проверки на соответствие политике Play.
- Для Firebase присутствуют как общий `android/app/google-services.json`, так и flavor-специфичный `android/app/src/prod/google-services.json`.
- Preflight показал технический блокер релиза: тестовый набор нестабилен/красный, в том числе в `test/core/services/auth_sync_service_test.dart`, `test/features/accounts/presentation/controllers/account_details_providers_test.dart`, `test/features/ai/data/local/ai_analytics_dao_test.dart`, `test/features/transactions/presentation/controllers/transaction_form_controller_test.dart`, `test/features/home/presentation/screens/home_screen_test.dart`.

## Decision Log
- Релиз ориентирован на flavor `prod` и entrypoint `lib/main_prod.dart`.
- Базовый канал выпуска: `Internal testing` -> staged rollout в `Production`.
- Отдельным gate перед публикацией является проверка соответствия политики exact alarms.

## Outcomes & Retrospective
- Что сделано:
  - Подготовлен рабочий план релиза, привязанный к текущей структуре репозитория.
  - Выделены критические риски и контрольные точки.
- Что бы улучшить в следующий раз:
  - Добавить автоматизированный release workflow (CI + подпись + upload в Play internal track).
  - Вынести релизный чеклист в отдельный документ `docs/logic/release_android_google_play.md`.
