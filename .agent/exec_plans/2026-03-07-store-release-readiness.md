# ExecPlan: Подготовка выпуска Kopim в App Store и Google Play

## Context and Orientation
- Цель: подготовить проект и процесс к первому полноценному выпуску мобильного приложения в App Store и Google Play с учетом кода, метаданных сторов, графики, политик, доступа к данным и post-release мониторинга.
- Область кода: `lib/`, `android/`, `ios/`, `docs/logic/`, `.agent/exec_plans/`.
- Контекст/ограничения: приложение уже использует Flutter + Firebase, Android flavor `prod` есть, iOS отдельной prod-схемы пока не видно, политики на экране "О приложении" пока заглушки, секреты и автоген нельзя править вручную.
- Риски: отклонение релиза из-за неполных privacy disclosures, неготовых policy URLs, лишних permissions, расхождения dev/prod Firebase, отсутствия сценария удаления аккаунта и несогласованности сборочных инструкций.

## Interfaces and Dependencies
- Внешние сервисы (Firebase/Analytics/Crashlytics): Firebase Core, Auth, Firestore, Analytics, Crashlytics, Storage, Remote Config, Messaging.
- Локальные зависимости (Drift, codegen): Drift, build_runner, l10n, flavor-конфиги Android, Xcode signing/capabilities.
- Затрагиваемые API/модули: `lib/features/profile/presentation/screens/about_app_screen.dart`, `android/app/src/main/AndroidManifest.xml`, `android/app/build.gradle.kts`, `ios/Runner/Info.plist`, release-документация в `docs/logic/`.

## Plan of Work
- Зафиксировать release readiness checklist и реальные пробелы текущего проекта.
- Подготовить кодовую часть: конфиги окружений, permissions, legal links, version/build metadata, account deletion, release monitoring.
- Подготовить store-операционную часть: иконки, скриншоты, тексты, privacy/data safety, support/legal URLs.
- Прописать выпускной и post-release процесс.

## Concrete Steps
1) Зафиксировать текущие технические gaps для релиза:
   - placeholder для privacy policy и terms;
   - hardcoded версия в `AboutAppScreen`;
   - Android permissions требуют ревизии под Play policies;
  - release-документация должна быть синхронизирована с фактическим `lib/main_prod.dart`;
   - iOS prod-схема/конфигурация не описана.
2) Подготовить документ `docs/logic/store_release_readiness.md`:
   - кодовые изменения;
   - графические материалы;
   - стор-метаданные;
   - юридические документы и policy URLs;
   - тестирование и release gates;
   - шаги публикации и post-release мониторинг.
3) Обновить индекс `docs/logic/README.md` ссылкой на новый документ.

## Validation and Acceptance
- Команды проверки:
```bash
dart format --set-exit-if-changed .
flutter analyze
```
- Acceptance criteria:
  - Есть отдельный документ с пошаговым планом выпуска iOS/Android.
  - План привязан к текущему состоянию репозитория и перечисляет конкретные кодовые задачи.
  - План включает список обязательных материалов для сторов, legal/policy и release-валидацию.

## Idempotence and Recovery
- Что можно безопасно перезапускать: подготовку документации, уточнение чеклистов, обновление ExecPlan и индекса docs.
- Как откатиться/восстановиться: удалить добавленные документы или вернуть изменения в `docs/logic/README.md`.
- План rollback (для миграций): не требуется, схема БД не меняется.

## Progress
- [x] Шаг 1: Зафиксировать текущие gaps релизной подготовки.
- [x] Шаг 2: Подготовить release checklist в `docs/logic/`.
- [x] Шаг 3: Обновить индекс документации.

## Surprises & Discoveries
- `AboutAppScreen` пока показывает snackbar-заглушку вместо открытия privacy policy и terms.
- Версия приложения в `AboutAppScreen` захардкожена как `1.0.1`, а не берется из build metadata.
- В `AndroidManifest.xml` уже запрошены `CAMERA`, `READ_MEDIA_IMAGES`, `POST_NOTIFICATIONS`, `SCHEDULE_EXACT_ALARM`, `RECEIVE_BOOT_COMPLETED`; для Play это нужно отдельно обосновать и часть разрешений может оказаться лишней.
- В репозитории уже есть `lib/main_prod.dart`, который выступает production-target и делегирует в общий bootstrap из `lib/main.dart`.
- Для Android уже есть `prod` flavor и `android/app/src/prod/google-services.json`, для iOS отдельная схема production явно не оформлена.

## Decision Log
- Основной план выпуска сохранен в `docs/logic/`, потому что это долгоживущая продуктовая и техническая документация, а не одноразовая заметка.

## Outcomes & Retrospective
- Что сделано: подготовлен план выпуска в сторы с привязкой к текущему состоянию проекта и явными задачами по коду, legal и стор-операциям.
- Что бы улучшить в следующий раз: вынести release readiness в регулярный checklist для каждого релиза, а не только для первого выхода в сторы.
