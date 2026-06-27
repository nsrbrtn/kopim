---
name: kopim-release-skill
description: Правила сборки, релизов и настройки целевых платформ (Android SDK 35, iOS, Web) в проекте Kopim
---

# Kopim Release Skill

Этот навык регулирует подготовку сборок, обновление версий, конфигурацию платформ и деплой проекта.

## 1. Когда использовать этот навык
Активируйте этот навык при выполнении задач, которые затрагивают:
- Подготовку приложения к публикации в Google Play, App Store, Rustore или Web.
- Изменение конфигурационных файлов сборки (`build.gradle`, `Info.plist`, `firebase.json`).
- Обновление версий приложения (версионирование в `pubspec.yaml`).
- Настройку flavor-специфичного поведения (например, `dev` vs `storeProdLocalFirst`).

## 2. Какие файлы читать в первую очередь
- Конфигурации Android сборки: [android/app/build.gradle](file:///home/artem/StudioProjects/kopim/android/app/build.gradle)
- Конфигурация Firebase деплоя: [firebase.json](file:///home/artem/StudioProjects/kopim/firebase.json)
- Документация по релизам:
  - [android_build_toolchain.md](file:///home/artem/StudioProjects/kopim/docs/logic/android_build_toolchain.md)
  - [store_release_readiness.md](file:///home/artem/StudioProjects/kopim/docs/logic/store_release_readiness.md)
  - [firebase_release_setup.md](file:///home/artem/StudioProjects/kopim/docs/logic/firebase_release_setup.md)
  - [offline_flavor_release.md](file:///home/artem/StudioProjects/kopim/docs/logic/offline_flavor_release.md)

## 3. Запрещенные действия
- **Запрещено** запускать деплой-команды (`firebase deploy`, `flutter build ipa`, `flutter build appbundle`) без прямого запроса пользователя.
- **Запрещено** изменять конфиги Gradle wrapper, версию Kotlin, AGP (Android Gradle Plugin) или Java SDK без предварительного исследования совместимости и составления ExecPlan.
- **Запрещено** изменять и коммитить секреты, ключи подписи и файлы конфигурации окружения (`.env`, `google-services.json`, `upload-keystore.jks`).

## 4. Какие проверки запускать
- Для сборки dev-версии Android: `flutter build apk --debug --flavor dev`.
- Прогон статического анализа перед релизом: `./tool/ai_check.sh`.

## 5. Системные требования и лимиты
При работе с релизами помните о зафиксированном окружении:
- **Android Target SDK:** `35`, **Compile SDK:** `36`, **Min SDK:** `24`.
- **Android build toolchain:** Gradle wrapper `8.14`, AGP `8.11.1`, Kotlin `2.2.20`, Java/Kotlin target `17`.
- **Flavors:** Использовать `dev` для разработки/тестирования, `storeProdLocalFirst` для Android production cloud runtime и `offlineOnly` для локального Play-контура.

## 6. Ожидаемый результат (Expected Output)
- Версия приложения в `pubspec.yaml` увеличена в соответствии с семантическим версионированием.
- Сборка на целевой платформе проходит успешно и без предупреждений компилятора.
- Обновлены соответствующие конфигурации деплоя (при необходимости).
- Изменения задокументированы в релизных заметках.
