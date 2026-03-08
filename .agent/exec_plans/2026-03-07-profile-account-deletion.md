# ExecPlan: Удаление аккаунта из настроек профиля

## Context and Orientation
- Цель: добавить удаление аккаунта на экран настроек профиля в секцию `Учетная запись` с подтверждением через ввод текста.
- Область кода: `lib/features/profile/**`, `lib/core/di/injectors.dart`, `test/features/profile/**`, `docs/logic/**`.
- Контекст/ограничения: удаление должно быть встроено в существующий профильный поток и не должно обходить архитектурные слои.
- Риски: ошибки reauthentication, частичная очистка данных, регрессии в auth/profile UI.

## Interfaces and Dependencies
- Внешние сервисы (Firebase/Analytics/Crashlytics): Firebase Auth, Firestore, Firebase Storage.
- Локальные зависимости (Drift, l10n): Drift, `flutter gen-l10n`.
- Затрагиваемые API/модули: `AuthRepository`, профильные репозитории/use case, `ProfileAccountSettingsCard`.

## Plan of Work
- Добавить доменный/data-слой удаления аккаунта.
- Добавить destructive UI и подтверждение через ввод текста.
- Обновить локализацию, документацию и тесты.

## Concrete Steps
1) Расширить auth/profile слой операциями удаления аккаунта и cleanup данных.
2) Добавить use case и метод в `AuthController`.
3) Добавить кнопку и диалог подтверждения в секцию `Учетная запись`.
4) Обновить `arb`, документацию и тесты.

## Validation and Acceptance
- Команды проверки:
```bash
flutter gen-l10n
flutter analyze
flutter test --reporter expanded test/features/profile
```
- Acceptance criteria:
  - В секции `Учетная запись` есть действие `Удалить аккаунт`.
  - Подтверждение требует кодовое слово и текущий пароль.
  - После успешного удаления auth-сессия закрывается.

## Idempotence and Recovery
- Что можно безопасно перезапускать: `flutter gen-l10n`, `flutter analyze`, профильные тесты.
- Как откатиться/восстановиться: вернуть изменения в профильном модуле, DI и документации.
- План rollback (для миграций): не требуется.

## Progress
- [ ] Шаг 1: Добавить доменный/data-слой удаления аккаунта.
- [ ] Шаг 2: Добавить UI удаления с подтверждением.
- [ ] Шаг 3: Обновить локализацию и документацию.
- [ ] Шаг 4: Прогнать анализ и тесты.
