# ExecPlan: Разделение Firebase конфигов на dev и prod

## Context and Orientation
- Цель: развести Firebase-конфиги для `dev/test` и `prod`, чтобы `main.dart` использовал старый Firebase project, а `main_prod.dart` — новый `Kopim-prod`.
- Область кода: `lib/main.dart`, `lib/main_prod.dart`, `lib/core/services/firebase_initializer.dart`, `lib/core/di/injectors.dart`, `lib/firebase_options*.dart`, `docs/logic/firebase_release_setup.md`, `docs/logic/store_release_readiness.md`.
- Контекст/ограничения: текущий `firebase_options.dart` указывает на старый проект; `firebase_options_prod.dart` сгенерирован через FlutterFire CLI; platform-конфиги уже частично заменены пользователем на production; `firebase_options.dart` как автоген лучше не переписывать вручную.
- Риски: если оставить один общий конфиг, dev/test случайно пойдут в production; если разнести только Dart-конфиги без entrypoint-ов, инициализация останется неоднозначной.

## Interfaces and Dependencies
- Внешние сервисы (Firebase/Analytics/Crashlytics): Firebase Core, Auth, Firestore, Storage, Remote Config, Messaging.
- Локальные зависимости (Drift, codegen): codegen не требуется, но нужен точечный `flutter analyze`.
- Затрагиваемые API/модули: bootstrap приложения, глобальная инициализация Firebase, release-документация.

## Plan of Work
- Вынести выбор Firebase-конфига в отдельный environment-aware слой.
- Привязать `main.dart` к dev Firebase, `main_prod.dart` к prod Firebase.
- Сохранить текущий старый конфиг как явный dev-конфиг и использовать новый prod-конфиг, сгенерированный FlutterFire.
- Обновить документацию под новую схему.

## Concrete Steps
1) Сохранить текущий `firebase_options.dart` как `firebase_options_dev.dart`.
2) Добавить модуль выбора окружения Firebase и переключить на него `main.dart`, `main_prod.dart`, `firebase_initializer.dart`, `injectors.dart`.
3) Обновить `docs/logic/firebase_release_setup.md` и `docs/logic/store_release_readiness.md`.

## Validation and Acceptance
- Команды проверки:
```bash
dart format --set-exit-if-changed lib/main.dart lib/main_prod.dart lib/core/config/firebase_environment.dart lib/core/services/firebase_initializer.dart lib/core/di/injectors.dart
flutter analyze lib/main.dart lib/main_prod.dart lib/core/config/firebase_environment.dart lib/core/services/firebase_initializer.dart lib/core/di/injectors.dart
```
- Acceptance criteria:
  - `main.dart` использует старый Firebase как dev/test.
  - `main_prod.dart` использует новый `Kopim-prod`.
  - В коде больше нет жесткой привязки инициализации к одному `firebase_options.dart`.
  - Документация описывает новую схему окружений.

## Idempotence and Recovery
- Что можно безопасно перезапускать: `flutterfire configure --out=...`, форматирование, analyze.
- Как откатиться/восстановиться: вернуть ссылки на старый `firebase_options.dart` и удалить environment-aware слой.
- План rollback (для миграций): не требуется.

## Progress
- [x] Шаг 1: Сгенерировать отдельный `firebase_options_prod.dart`.
- [x] Шаг 2: Внести environment-aware изменения в код.
- [x] Шаг 3: Обновить документацию и прогнать проверки.

## Surprises & Discoveries
- `flutterfire configure` с `no` не меняет существующий `firebase_options.dart`, но все равно регистрирует Firebase apps в проекте.
- Текущий проект уже имеет production Android/iOS platform-конфиги, но Dart-конфиг до этого момента оставался общим и dev-ориентированным.

## Decision Log
- Не переписывать автоген `firebase_options.dart` вручную; сохранить его как dev-конфиг и использовать через явный environment selector.

## Outcomes & Retrospective
- Что сделано: `dev/test` и `prod` разведены на уровне Dart-конфигов и entrypoint-ов; `main.dart` использует dev/test Firebase, `main_prod.dart` — `Kopim-prod`; документация обновлена под новую схему.
- Что бы улучшить в следующий раз: сразу заводить отдельные Firebase-конфиги и entrypoint-ы до начала store readiness.
