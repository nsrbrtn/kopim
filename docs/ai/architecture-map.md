# Карта архитектуры (Architecture Map) проекта Kopim

Этот документ описывает физическое расположение слоев, фич, базы данных, сервисов синхронизации, зависимостей и конфигурационных файлов проекта Kopim. Используется агентами для быстрой локализации нужного кода без полного чтения репозитория.

---

## 1. Архитектурные слои (Clean Architecture + DDD)

Проект организован по подходу **feature-first** (модули по фичам в директории `lib/features/`). Внутри каждой фичи код делится на слои:
1. `presentation/` — UI-компоненты (виджеты), экраны, контроллеры состояния и провайдеры Riverpod.
2. `domain/` — Доменные сущности (иммутабельные модели Freezed), Use Cases (инварианты и бизнес-логика), интерфейсы репозиториев. Слой **не зависит** от Flutter, Firebase и Drift.
3. `data/` — Реализации репозиториев, Drift DAO, Firebase-адаптеры/Data Sources, мапперы данных.

---

## 2. Карта фич и ключевых модулей

Все модули расположены в [lib/features/](file:///home/artem/StudioProjects/kopim/lib/features):

* **Счета и баланс (Accounts):** [lib/features/accounts/](file:///home/artem/StudioProjects/kopim/lib/features/accounts)
* **Категории транзакций:** [lib/features/categories/](file:///home/artem/StudioProjects/kopim/lib/features/categories)
* **Транзакции и переводы:** [lib/features/transactions/](file:///home/artem/StudioProjects/kopim/lib/features/transactions)
* **Бюджеты и лимиты:** [lib/features/budgets/](file:///home/artem/StudioProjects/kopim/lib/features/budgets)
* **Регулярные платежи (Recurring):** [lib/features/upcoming_payments/](file:///home/artem/StudioProjects/kopim/lib/features/upcoming_payments)
* **Кредитные карты и лимиты (Credits):** [lib/features/credits/](file:///home/artem/StudioProjects/kopim/lib/features/credits)
* **Цели сбережений (Savings):** [lib/features/savings/](file:///home/artem/StudioProjects/kopim/lib/features/savings)
* **Аналитика и графики:** [lib/features/analytics/](file:///home/artem/StudioProjects/kopim/lib/features/analytics)
* **Профиль пользователя и очистка аккаунта:** [lib/features/profile/](file:///home/artem/StudioProjects/kopim/lib/features/profile)
* **Настройки, импорт/экспорт бэкапов:** [lib/features/settings/](file:///home/artem/StudioProjects/kopim/lib/features/settings)

---

## 3. База данных (Drift SQLite)

* **Точка входа БД и схема:** [database.dart](file:///home/artem/StudioProjects/kopim/lib/core/data/database.dart)
* **Таблицы и DAO по фичам:** Искать файлы вида `*_dao.dart` и описания таблиц в соответствующих папках `data/` внутри фич (например, `lib/features/transactions/data/`).
* **Миграции и схемы Drift:** папка [drift_schemas/](file:///home/artem/StudioProjects/kopim/drift_schemas)

---

## 4. Синхронизация (Firebase / Cloud Firestore)

* **Контракт и типы данных:** [sync_contract.dart](file:///home/artem/StudioProjects/kopim/lib/core/services/sync/sync_contract.dart)
* **Сервисы:**
  * [sync_service.dart](file:///home/artem/StudioProjects/kopim/lib/core/services/sync_service.dart) — фоновая синхронизация, outbox очередь.
  * [auth_sync_service.dart](file:///home/artem/StudioProjects/kopim/lib/core/services/auth_sync_service.dart) — синхронизация при авторизации, слияние данных.
  * [user_account_cleanup_repository_impl.dart](file:///home/artem/StudioProjects/kopim/lib/features/profile/data/user_account_cleanup_repository_impl.dart) — очистка remote/local данных пользователя при удалении аккаунта.

---

## 5. Внедрение зависимостей (DI) и Настройки

* **Генерируемые инжекторы DI:** [injectors.g.dart](file:///home/artem/StudioProjects/kopim/lib/core/di/injectors.g.dart)
* **Глобальная тема и дизайн-токены:** [lib/core/theme/](file:///home/artem/StudioProjects/kopim/lib/core/theme)

---

## 6. Тестирование

Все тесты расположены в корневой папке [test/](file:///home/artem/StudioProjects/kopim/test):
* **Unit-тесты домена и мапперов:** [test/unit/](file:///home/artem/StudioProjects/kopim/test/unit) (или аналогичные подпапки).
* **Widget-тесты интерфейса:** [test/widget/](file:///home/artem/StudioProjects/kopim/test/widget).
* **Integration-тесты синхронизации и БД:** [test/integration/](file:///home/artem/StudioProjects/kopim/test/integration).

---

## 7. Сборочные и релизные конфигурации

* **Android:** каталог [android/](file:///home/artem/StudioProjects/kopim/android)
  * Target SDK и версии Gradle: [android/app/build.gradle](file:///home/artem/StudioProjects/kopim/android/app/build.gradle)
* **iOS:** каталог [ios/](file:///home/artem/StudioProjects/kopim/ios)
* **Web:** каталог [web/](file:///home/artem/StudioProjects/kopim/web)
* **Firebase config:**
  * [firebase.json](file:///home/artem/StudioProjects/kopim/firebase.json) — правила хостинга и функций.
  * [firestore.rules](file:///home/artem/StudioProjects/kopim/firestore.rules) — правила безопасности Firestore.
