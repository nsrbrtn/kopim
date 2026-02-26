# ExecPlan: Перенос toggla автопроведения и сворачиваемый контейнер заметки

## Context and Orientation
- Цель: перенести `Проводить автоматически` в контейнер напоминаний под поле дней и сделать заметку в виде сворачиваемого контейнера с готовым компонентом.
- Область кода: `lib/features/upcoming_payments/presentation/screens/edit_upcoming_payment_screen.dart`, `docs/logic/upcoming_payment_form.md`.
- Контекст/ограничения: дизайн базовых контейнеров не меняется; использовать существующий `KopimExpandableSectionPlayful`.
- Риски: регресс в отображении toggla при выключенном `Напомнить`.

## Interfaces and Dependencies
- Внешние сервисы (Firebase/Analytics/Crashlytics): нет.
- Локальные зависимости (Drift, codegen): не требуются.
- Затрагиваемые API/модули: только presentation-слой формы.

## Plan of Work
- Переразместить `autoPost` в секции напоминаний.
- Перевести заметку на сворачиваемый компонент.
- Обновить документацию и проверить экран.

## Concrete Steps
1) Вынести `SwitchListTile` автопроведения из третьего контейнера во второй, под поле «За сколько дней напомнить».
2) Заменить секцию заметки на `KopimExpandableSectionPlayful` с заголовком и стрелкой.
3) Обновить `docs/logic/upcoming_payment_form.md` под новую структуру формы.
4) Запустить `dart format` и `flutter analyze` для экрана.

## Validation and Acceptance
- Команды проверки:
```bash
dart format lib/features/upcoming_payments/presentation/screens/edit_upcoming_payment_screen.dart
flutter analyze lib/features/upcoming_payments/presentation/screens/edit_upcoming_payment_screen.dart
```
- Acceptance criteria:
  - Toggle `Проводить автоматически` находится под полем дней напоминания во 2 контейнере.
  - Заметка отображается в свернутом контейнере: заголовок+стрелка, поле появляется при раскрытии.

## Idempotence and Recovery
- Что можно безопасно перезапускать: форматирование, analyze.
- Как откатиться/восстановиться: откатить изменения в экране и docs.
- План rollback (для миграций): не требуется.

## Progress
- [x] Шаг 1: Создать ExecPlan.
- [x] Шаг 2: Обновить layout экрана.
- [x] Шаг 3: Обновить docs.
- [x] Шаг 4: Проверки.

## Surprises & Discoveries
- Для использования `KopimExpandableSectionPlayful` в блоке заметки достаточно локально подменить `surfaceContainer` через `Theme.copyWith`, чтобы визуально не выбиваться из текущего контейнера.

## Decision Log
- Используем `KopimExpandableSectionPlayful` как единый компонент свернутых секций.

## Outcomes & Retrospective
- Что сделано:
  - Переключатель `Проводить автоматически` перенесен во второй контейнер и отображается под полем «За сколько дней напомнить».
  - Третий контейнер заметки переведен на `KopimExpandableSectionPlayful` (заголовок+стрелка, поле внутри при раскрытии).
  - Документация формы обновлена.
- Что бы улучшить в следующий раз:
