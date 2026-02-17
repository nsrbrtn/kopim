# ExecPlan: Подготовка релиза iOS в Apple App Store (TestFlight -> Production)

## Context and Orientation
- Цель: выпустить стабильную iOS-версию приложения через App Store Connect с прогоном через TestFlight.
- Область кода: `ios/`, `lib/main_prod.dart`, `pubspec.yaml`, App Store Connect артефакты.
- Контекст/ограничения:
  - Bundle ID проекта: `qmodo.ru.kopim`.
  - Версия в iOS берется из Flutter (`CFBundleShortVersionString=$(FLUTTER_BUILD_NAME)`, `CFBundleVersion=$(FLUTTER_BUILD_NUMBER)`).
  - В репозитории запрещено редактировать секреты и выполнять деплой без явного запроса.
- Риски:
  - В `ios/` отсутствует `Podfile` (возможный блокер `pod install` и архивации IPA).
  - Текущий тестовый прогон проекта красный (`flutter test` падает), что нарушает релизный DoD.
  - Возможные требования App Store по privacy/permissions и метаданным (Data Safety/Privacy Nutrition Labels/возрастной рейтинг).

## Interfaces and Dependencies
- Внешние сервисы (Firebase/Analytics/Crashlytics):
  - Firebase для iOS подключен через `ios/Runner/GoogleService-Info.plist`.
  - Используются Analytics/Crashlytics/Messaging/Remote Config.
- Локальные зависимости:
  - Xcode + Command Line Tools.
  - CocoaPods (должен быть доступен и корректно инициализирован в `ios/`).
  - Flutter toolchain и codegen.
- Затрагиваемые API/модули:
  - iOS project settings: `ios/Runner.xcodeproj/project.pbxproj`.
  - Plist permissions: `ios/Runner/Info.plist`.
  - Версионирование: `pubspec.yaml`.

## Plan of Work
- Закрыть preflight по iOS toolchain и сборочному контуру.
- Подготовить подпись/профили и собрать валидный IPA для TestFlight.
- Пройти внешний/внутренний тест через TestFlight, затем staged релиз в App Store.

## Concrete Steps
1) Preflight окружения и проекта
- Проверить toolchain:
```bash
flutter --version
xcodebuild -version
xcode-select -p
```
- Проверить iOS-зависимости:
  - Если `ios/Podfile` отсутствует, восстановить iOS scaffolding командой `flutter create .` (без перетирания бизнес-кода) и затем `flutter pub get`.
  - Выполнить `cd ios && pod repo update && pod install`.
- Убедиться, что проект открывается через `ios/Runner.xcworkspace`.

2) Подпись и идентификаторы
- Подтвердить `PRODUCT_BUNDLE_IDENTIFIER=qmodo.ru.kopim` для Runner target.
- Включить `Signing & Capabilities` с корректной Apple Team и `Automatic signing` (или manual, если это требование команды).
- Проверить наличие и валидность:
  - Apple Distribution certificate.
  - Provisioning profile для App Store.
- Проверить capability по факту используемых функций (Push Notifications/Background Modes и т.д.).

3) Версионирование и релизная конфигурация
- Обновить версию в `pubspec.yaml` (`version: x.y.z+build`), чтобы iOS получил новые `build name/number`.
- Подтвердить release entrypoint:
```bash
flutter build ipa --release --target lib/main_prod.dart
```
- Убедиться, что debug-флаги и dev-настройки не попадают в релиз.

4) Качество и регресс
- Выполнить обязательные проверки:
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart format --set-exit-if-changed .
flutter analyze
flutter test --reporter expanded
```
- Устранить P0/P1 дефекты до загрузки в TestFlight.
- Дополнительно прогнать smoke на реальном iPhone:
  - запуск/логин;
  - критичный offline-first сценарий;
  - уведомления и восстановление после рестарта.

5) Сборка и загрузка в TestFlight
- Собрать IPA:
```bash
flutter build ipa --release --target lib/main_prod.dart
```
- Загрузить билд в App Store Connect (Transporter/Xcode Organizer).
- Заполнить метаданные TestFlight (What to Test, тест-группы).
- Пройти внутреннее тестирование и зафиксировать known issues.

6) Подготовка App Store карточки и compliance
- Заполнить/актуализировать:
  - Privacy Policy URL.
  - App Privacy (данные, собираемые SDK Firebase и app-логикой).
  - Возрастной рейтинг.
  - Скриншоты/описание/ключевые слова.
  - Export compliance (шифрование), если требуется.
- Проверить тексты permission-диалогов в `ios/Runner/Info.plist` (камера/фото и др.).

7) Публикация в App Store
- Отправить сборку на App Review из стабильного TestFlight-билда.
- Использовать phased release (по возможности в App Store Connect).
- Мониторить первые 24-72 часа:
  - crashes, hangs, критичные ошибки авторизации/синхронизации.
- При проблемах: выпустить hotfix с повышением build number.

## Validation and Acceptance
- Команды проверки:
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart format --set-exit-if-changed .
flutter analyze
flutter test --reporter expanded
flutter build ipa --release --target lib/main_prod.dart
```
- Acceptance criteria:
  - IPA успешно собирается и загружается в TestFlight.
  - Internal TestFlight не содержит блокирующих P0/P1 дефектов.
  - App Store Connect metadata/compliance заполнены без блокеров.
  - Приложение одобрено App Review и опубликовано.

## Idempotence and Recovery
- Что можно безопасно перезапускать:
  - `pub get`, `build_runner`, `format`, `analyze`, `test`, `build ipa`, `pod install`.
- Как откатиться/восстановиться:
  - Отклонить релиз в App Store Connect до момента публикации.
  - Выпустить hotfix с новым `build number`.
- План rollback:
  - После публикации бинарник не откатывается мгновенно, используем ускоренный hotfix-релиз.
  - Для удаленных конфигов использовать feature-flag rollback (если применимо).

## Progress
- [x] Шаг 1: Выполнен аудит iOS-конфигурации в репозитории.
- [x] Шаг 2: Сформирован ExecPlan релиза iOS в App Store.
- [ ] Шаг 3: Закрыть preflight по iOS tooling и `Podfile/CocoaPods`.
- [ ] Шаг 4: Пройти release-quality проверки и устранить блокеры.
- [ ] Шаг 5: Загрузить IPA в TestFlight.
- [ ] Шаг 6: Отправить в App Review и выпустить в Production.

## Surprises & Discoveries
- В `ios/` отсутствует `Podfile`; для Flutter+iOS это нетипично и требует отдельной проверки/восстановления.
- Bundle ID настроен как `qmodo.ru.kopim`, deployment target — iOS 13.0.
- В `Info.plist` уже есть пользовательские тексты для `NSCameraUsageDescription` и `NSPhotoLibraryUsageDescription`.
- На уровне всего проекта preflight выявил красный тестовый набор (`flutter test`), что блокирует релизный DoD.

## Decision Log
- Канал релиза: сначала TestFlight (internal), затем App Store production.
- Базовый релизный target: `lib/main_prod.dart`.
- Отдельный gate: восстановление и валидация iOS dependency pipeline (`Podfile`/CocoaPods).

## Outcomes & Retrospective
- Что сделано:
  - Подготовлен пошаговый план релиза iOS, привязанный к текущей структуре проекта.
  - Выделены первичные технические блокеры до публикации.
- Что бы улучшить в следующий раз:
  - Добавить CI pipeline для iOS (автосборка IPA + автопроверки + загрузка в TestFlight).
  - Вынести постоянный чеклист в `docs/logic/release_ios_app_store.md`.
