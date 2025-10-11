# 📱 kopim

**kopim** — современное, масштабируемое и безопасное финансовое приложение с поддержкой офлайн-режима и синхронизации.  
Мультиплатформенное решение: **Android, iOS, Web, Desktop**.

---

## ✨ Основные возможности

- 🏦 **Счета**: создание, редактирование, удаление, синхронизация
- 💸 **Транзакции**: расходы и доходы, офлайн-режим, обновление баланса счёта
- 🗂 **Категории**: управление категориями с иконками и цветами
- 📊 **Аналитика**: графики, фильтрация, топ-траты
- 👤 **Профиль и вход**: Firebase Auth (email, офлайн-гость)
- 🎯 **Бюджеты**: установка лимитов, уведомления о превышении
- 🔄 **Повторяющиеся операции**: автоматизация доходов и расходов
- 🤖 **ИИ-финансовый помощник**: анализ трат, советы по бюджету

---

## 🏗 Архитектура

Проект следует принципам **Clean Architecture** и **DDD**.

lib/
core/ # Общие компоненты: UI kit, utils, сервисы
features/
accounts/ # Счета
domain/
data/
presentation/
transactions/ # Транзакции
categories/ # Категории
analytics/ # Аналитика
budgets/ # Бюджеты
auth/ # Авторизация, профиль
ai/ # Финансовый помощник (ИИ)


- **presentation/** → UI, state management
- **domain/** → сущности, use cases
- **data/** → репозитории, источники данных

---

## 🛠 Технологии

- **Flutter**
- **Riverpod** — state management
- **Freezed + Equatable** — модели и иммутабельность
- **Drift (ex-Moor)** — локальная база данных
- **Firebase (Auth, Firestore, Analytics, Crashlytics)** — облачная инфраструктура
- **Sentry** — мониторинг
- **Logger** — локальные логи

---

## 🔄 Offline-first

1. Все операции сначала пишутся в Drift (локально).
2. При наличии сети данные синхронизируются с Firebase.
3. Конфликты решаются стратегией `last-write-wins` (или merge).

---

## ✅ Тестирование

- Unit-тесты (use cases, репозитории)
- Widget-тесты (UI-компоненты)
- Integration-тесты (база данных, синхронизация)

---

## 🚀 Запуск проекта

### 1. Установить зависимости
```bash
База

flutter doctor — проверка окружения. 
docs.flutter.dev

flutter create <app> — создать проект. 
docs.flutter.dev

flutter analyze — статический анализ. 
docs.flutter.dev

flutter test — запустить тесты. 
docs.flutter.dev

flutter run — запустить на устройстве/эмуляторе. 
docs.flutter.dev

flutter devices — список устройств. 
docs.flutter.dev

flutter clean — очистить сборочные артефакты. 
docs.flutter.dev

Работа с зависимостями (pub)

flutter pub get — установить зависимости. 
dart.dev

flutter pub upgrade — обновить зависимости. 
dart.dev

flutter pub add <pkg> / flutter pub remove <pkg> — добавить/удалить пакет. 
docs.flutter.dev

dart pub outdated — посмотреть устаревшие пакеты. 
dart.dev

Сборки

flutter build apk --release — Android APK. 
docs.flutter.dev

flutter build appbundle --release — AAB для Play. 
docs.flutter.dev

flutter build ios --release — iOS сборка (на macOS). 
docs.flutter.dev

flutter build web — Web сборка. 
docs.flutter.dev

Каналы и SDK

flutter --version — версия SDK. 
docs.flutter.dev

flutter channel / flutter channel <name> — каналы SDK. 
docs.flutter.dev

flutter upgrade / flutter downgrade — обновить/откатить SDK. 
docs.flutter.dev

flutter precache — предзагрузка бинарей платформ. 
docs.flutter.dev

flutter config --enable-<platform> — включить платформу. 
docs.flutter.dev

Устройства и эмуляторы

flutter emulators — список эмуляторов.

flutter emulators --launch <id> — запустить эмулятор. 
docs.flutter.dev

Отладка и профилирование

dart devtools — запустить DevTools. 
docs.flutter.dev

flutter run --profile — профильный запуск. 
docs.flutter.dev

Частые утилиты проекта

flutter gen-l10n — генерация локализаций (если настроено). 
docs.flutter.dev

dart format . — автоформат. 
dart.dev

dart fix --apply — автофиксы анализа. 
dart.dev

dart run build_runner build --delete-conflicting-outputs — кодоген (Freezed/Drift и т.п.)
📜 Лицензия

MIT License © 2025 — kopim project
