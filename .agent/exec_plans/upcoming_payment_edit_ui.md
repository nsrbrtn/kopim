# ExecPlan: Редизайн формы предстоящего платежа

## Context and Orientation
- Цель: переработать UI экрана добавления/редактирования предстоящего платежа с группировкой полей в контейнеры, кастомными dropdown, выбором даты/времени через пикеры и кнопкой удаления при редактировании.
- Область кода: `lib/features/upcoming_payments/presentation/screens/edit_upcoming_payment_screen.dart`, `lib/core/widgets/kopim_dropdown_field.dart` (использование), l10n при необходимости.
- Контекст/ограничения: цвета/шрифты только из темы; использовать существующий кастомный dropdown; day-of-month выбирается через календарь; кнопка удаления только в режиме редактирования.
- Риски: неверная обработка дня месяца при выборе даты; доступность действий при `isSubmitting`.

## Interfaces and Dependencies
- Внешние сервисы (Firebase/Analytics/Crashlytics): нет.
- Локальные зависимости (Drift, codegen): не требуются.
- Затрагиваемые API/модули: `DeleteUpcomingPaymentUC`, `KopimDropdownField`, диалоги/пикеры Flutter.

## Plan of Work
- Обновить разметку формы: контейнеры и кастомные dropdown.
- Добавить пикеры даты/времени и иконки действий.
- Добавить кнопку удаления на экране редактирования и подтянуть логику подтверждения.

## Concrete Steps
1) Найти текущую форму и заменить account/category на `KopimDropdownField`, сгруппировать поля в 3 контейнера.
2) Сделать выбор дня через `showDatePicker` и времени через `showTimePicker`, добавить иконки календаря/часов.
3) Добавить внизу строку с иконкой удаления (только для редактирования) и кнопкой сохранения, подключить delete use case.

## Validation and Acceptance
- Команды проверки:
```bash
dart format --set-exit-if-changed .
flutter analyze
```
- Acceptance criteria:
  - Поля сгруппированы в 3 контейнера с фоном `surfaceContainer`.
  - День месяца выбирается через календарь, время — через тайм-пикер; в полях есть иконки.
  - Account/Category используют кастомный dropdown.
  - На экране редактирования есть удаление + сохранение в одной строке.

## Idempotence and Recovery
- Что можно безопасно перезапускать: `dart format`, `flutter analyze`.
- Как откатиться/восстановиться: вернуть изменения в `lib/features/upcoming_payments/presentation/screens/edit_upcoming_payment_screen.dart`.
- План rollback (для миграций): не требуется.

## Progress
- [x] Шаг 1: Контейнеры и кастомные dropdown.
- [x] Шаг 2: Дата/время с пикерами и иконками.
- [x] Шаг 3: Удаление + сохранение в одной строке.

## Surprises & Discoveries
- ...

## Decision Log
- ...

## Outcomes & Retrospective
- Что сделано:
- Что бы улучшить в следующий раз:
