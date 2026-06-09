# Android build toolchain

## Что изменилось

- Проект обновлён до `Gradle wrapper 8.14`.
- `Android Gradle Plugin` обновлён до `8.11.1`.
- Версия `org.jetbrains.kotlin.android` обновлена до `2.2.20`.
- Корневой `android/build.gradle.kts` переведён на актуальную схему Flutter без legacy `buildscript`.
- Android app-модуль мигрирован с `kotlin-android` + `kotlinOptions` на `kotlin { compilerOptions { ... } }`.
- Java и Kotlin toolchain для Android модуля зафиксированы на `17`.

## Зачем

- Flutter 3.44 предупреждает о скором прекращении поддержки старых версий Gradle, AGP и Kotlin.
- AGP `8.11.1` официально поддерживает API 36, что соответствует текущему Android target проекта.
- Связка `Gradle 8.14` + `AGP 8.11.1` + `Kotlin 2.2.20` находится в официально совместимом диапазоне Kotlin/AGP.
- Переход app-level конфигурации на built-in Kotlin style снижает риск перед будущим переходом на AGP 9.

## Как проверить

```bash
flutter analyze
flutter build apk --debug --flavor dev
./android/gradlew --version
```

Ожидаемый результат:
- `flutter analyze` проходит без ошибок.
- Android debug APK для flavor `dev` успешно собирается.
- `./android/gradlew --version` показывает `Gradle 8.14`.

## Ограничения и known issues

- После обновления toolchain могут оставаться warnings Flutter о `Kotlin Gradle Plugin` в сторонних пакетах.
- На момент обновления предупреждения приходят от: `firebase_analytics`, `firebase_remote_config`, `firebase_storage`, `flutter_timezone`, `package_info_plus`, `sentry_flutter`, `workmanager_android`.
- Это не проблема app-level Gradle-конфигурации Kopim: Android-модули этих пакетов сами ещё применяют legacy KGP.
- Пока upstream-пакеты не мигрируют на built-in Kotlin, проект может собираться с warnings, но без ошибки на текущем Flutter 3.44.1.
- Флаги `android.builtInKotlin=false` и `android.newDsl=false` в `android/gradle.properties` оставлены намеренно как transitional-совместимость Flutter/plugin ecosystem.

## Breaking changes

- Для Android-сборки теперь требуется совместимый JDK уровня `17+`.
- Любые будущие ручные правки Android Gradle-файлов нужно сверять с актуальным шаблоном Flutter 3.44+ и не возвращать legacy `buildscript` или `kotlin-android` в app-модуль.
