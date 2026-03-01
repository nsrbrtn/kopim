# ExecPlan: Виджет логина и пароля в настройках профиля

## Context and Orientation
- Цель: добавить на экран настроек профиля отдельный виджет учетных данных с отображением логина/пароля и возможностью изменить логин и пароль.
- Область кода: `lib/features/profile/presentation/screens/profile_settings_screen.dart`, `lib/features/profile/presentation/widgets/`, `lib/features/profile/domain/repositories/auth_repository.dart`, `lib/features/profile/data/`.
- Контекст/ограничения: пароль нельзя получить из Firebase, поэтому отображается только маска; смена email/пароля требует re-auth.
- Риски: ошибки `requires-recent-login`, `wrong-password`, валидация полей и синхронизация UI после обновления email.

## Interfaces and Dependencies
- Внешние сервисы (Firebase/Analytics/Crashlytics): `FirebaseAuth`.
- Локальные зависимости (Drift, codegen): l10n (`app_*.arb` + генерация), Riverpod.
- Затрагиваемые API/модули: `AuthRepository`, `AuthRepositoryImpl`, `OfflineAuthRepository`, профильные виджеты.

## Plan of Work
- Расширить auth-репозиторий операциями смены email/пароля.
- Добавить UI-карту учетных данных в настройки профиля.
- Подключить диалоги изменения данных и обработку ошибок.
- Обновить локализацию и выполнить проверки.

## Concrete Steps
1) Добавить в `AuthRepository` методы `updateEmail` и `updatePassword`.
2) Реализовать методы в `AuthRepositoryImpl` через `reauthenticateWithCredential` + `updateEmail/updatePassword`.
3) Реализовать офлайн-заглушки в `OfflineAuthRepository`.
4) Создать новый виджет `ProfileCredentialsSettingsCard` и подключить его на `ProfileSettingsScreen`.
5) Добавить l10n-строки для заголовков/кнопок/подсказок и обновить генерируемые локализации.
6) Прогнать `dart format` и `flutter analyze` по измененным файлам.

## Validation and Acceptance
- Команды проверки:
```bash
dart format --set-exit-if-changed lib/features/profile lib/l10n
flutter analyze lib/features/profile lib/l10n
```
- Acceptance criteria:
  - На экране настроек профиля отображается логин (email) и маска пароля.
  - Доступны действия смены логина и смены пароля.
  - При ошибках Firebase показывается понятное сообщение.
  - Код проходит форматирование и анализ.

## Idempotence and Recovery
- Что можно безопасно перезапускать: `dart format`, `flutter analyze`, генерация l10n.
- Как откатиться/восстановиться: откатить изменения в виджете/репозитории/auth API.
- План rollback (для миграций): не требуется.

## Progress
- [x] Шаг 1: Сформирован план изменений.
- [x] Шаг 2: Расширить auth-слой методами смены email/пароля.
- [x] Шаг 3: Добавить виджет с логином/паролем и диалогами изменения.
- [x] Шаг 4: Обновить l10n и проверить проект.

## Surprises & Discoveries
- Пароль пользователя из Firebase недоступен для чтения, только изменение через re-auth.

## Decision Log
- Отображать пароль как маску `••••••••`, а не пытаться показывать реальное значение.

## Outcomes & Retrospective
- Что сделано:
  - Добавлены методы смены логина и пароля в `AuthRepository` и реализации.
  - Добавлен `ProfileCredentialsSettingsCard` и подключен на `ProfileSettingsScreen`.
  - Добавлены новые l10n-строки RU/EN для секции и диалогов.
  - Выполнены `flutter gen-l10n`, `dart format`, `flutter analyze`.
- Что бы улучшить в следующий раз:
