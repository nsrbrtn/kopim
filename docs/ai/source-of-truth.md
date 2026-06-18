# Источники истины (Source of Truth) для проекта Kopim

Этот документ фиксирует ключевые системные пути, версии SDK, конфигурации и авторитетные источники документации проекта Kopim. Перед изменением системных контрактов, баз данных, синхронизации или логики сборки ИИ-агент обязан свериться с этим документом.

---

## 1. Окружение и SDK

* **Язык программирования:** Dart
* **Фреймворк:** Flutter
* **SDK Constraints (из `pubspec.yaml`):** Dart `sdk: '>=3.9.0 <4.0.0'` (соответствует Flutter 3.29/3.30+).
* **Фактическая локальная версия окружения:**
  * Flutter: `3.44.1` (channel stable)
  * Dart: `3.12.1`
  * *Примечание: Фактическую версию окружения всегда можно проверить командой `flutter --version`.*
* **Конфигурация зависимостей:**
  * Файл декларации зависимостей: [pubspec.yaml](file:///home/artem/StudioProjects/kopim/pubspec.yaml)
  * Зафиксированные версии: [pubspec.lock](file:///home/artem/StudioProjects/kopim/pubspec.lock)

---

## 2. Ключевые компоненты архитектуры

### База данных (Drift SQLite)
* **Класс БД и конфигурация:** [database.dart](file:///home/artem/StudioProjects/kopim/lib/core/data/database.dart)
* **Схемы Drift для миграций:** папка [drift_schemas/](file:///home/artem/StudioProjects/kopim/drift_schemas)

### Контракт Синхронизации (Sync Contract)
* **Манифест синхронизации:** [sync_contract.dart](file:///home/artem/StudioProjects/kopim/lib/core/services/sync/sync_contract.dart) (определяет зарегистрированные сущности, их типы, удаление tombstone, логику слияния и cleanup).

### Сервисы Синхронизации
* **Основной сервис синхронизации:** [sync_service.dart](file:///home/artem/StudioProjects/kopim/lib/core/services/sync_service.dart)
* **Сервис синхронизации авторизации:** [auth_sync_service.dart](file:///home/artem/StudioProjects/kopim/lib/core/services/auth_sync_service.dart)

---

## 3. Стандартные команды проверок

Все проверки качества и генерации должны осуществляться следующими стандартными инструментами:

```bash
# Проверка форматирования и статического анализа + тесты с помощью общего скрипта
./tool/ai_check.sh

# Генерация кода (Freezed, Drift, Riverpod)
dart run build_runner build --delete-conflicting-outputs

# Ручные базовые проверки (если скрипт не используется)
dart format --set-exit-if-changed .
flutter analyze
```

---

## 4. Авторитетные внешние источники документации

Если внутренняя база знаний агента конфликтует с внешними источниками, приоритет отдается официальной документации и текущему коду проекта:

1. **Flutter & Dart:**
   * [Flutter Documentation](https://docs.flutter.dev/) (включая breaking changes и release notes).
   * [Dart Language Guide](https://dart.dev/guides).
   * [pub.dev](https://pub.dev/) — для проверки API и версий конкретных пакетов.
2. **Firebase:**
   * [Firebase Flutter Documentation](https://firebase.google.com/docs/flutter/setup) — Firestore, Auth, Crashlytics, Messaging.
3. **Android & iOS:**
   * [Android Developer Docs](https://developer.android.com/) — требования к target SDK (35), разрешениям (permissions), edge-to-edge, фоновым задачам (Workmanager).
   * [Apple Developer Documentation](https://developer.apple.com/documentation/) — требования к iOS-сборкам.
