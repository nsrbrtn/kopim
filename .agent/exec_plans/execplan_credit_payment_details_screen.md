# ExecPlan: Экран деталей платежа по кредиту

## Context and Orientation
- Цель: добавить отдельный экран деталей группового платежа по кредиту из ленты транзакций.
- Область кода: `lib/features/credits/presentation/widgets/`, `lib/features/credits/presentation/screens/`, `lib/core/navigation/app_router.dart`.
- Контекст/ограничения: использовать только цвета/шрифты/поля из темы приложения; сохранить текущие сценарии открытия транзакций.
- Риски: нарушить поведение существующих карточек транзакций и навигацию в Home/All Transactions/деталях кредита.

## Interfaces and Dependencies
- Внешние сервисы (Firebase/Analytics/Crashlytics): нет.
- Локальные зависимости (Drift, codegen): не требуется.
- Затрагиваемые API/модули: `GroupedCreditPaymentTile`, `GoRouter`, `FeedItem.groupedCreditPayment`.

## Plan of Work
- Добавить экран `CreditPaymentDetailsScreen` с аргументами маршрута.
- Переключить tap на карточке группового платежа на новый экран.
- Подключить маршрут в `app_router.dart`.
- Обновить документацию компонента/экрана.

## Concrete Steps
1) Создать экран деталей платежа по кредиту с секциями: сумма, дата, комментарий, разбивка по частям платежа, список транзакций.
2) Обновить `GroupedCreditPaymentTile`, чтобы он открывал новый экран по нажатию и был визуально как обычная транзакция.
3) Добавить маршрут в `app_router.dart` и проверить все места использования tile.
4) Обновить `docs/components/README.md` и добавить документ по новому экрану.

## Validation and Acceptance
- Команды проверки:
```bash
dart format --set-exit-if-changed .
flutter analyze
```
- Acceptance criteria:
  - По tap на групповом платеже открывается отдельный экран.
  - Визуальный стиль использует тему приложения и совпадает с общим стилем транзакций.
  - Экран доступен из Home, All Transactions и деталей кредита.

## Idempotence and Recovery
- Что можно безопасно перезапускать: `dart format`, `flutter analyze`.
- Как откатиться/восстановиться: удалить новый экран/роут и вернуть старый onTap.
- План rollback (для миграций): не требуется.

## Progress
- [x] Шаг 1: Подготовка плана и анализ текущей реализации.
- [x] Шаг 2: Реализация экрана и навигации.
- [x] Шаг 3: Проверка, форматирование, документация.

## Surprises & Discoveries
- Текущий `GroupedCreditPaymentTile` имел пустой `onTap` и отдельную зелёную стилизацию, из-за чего не соответствовал обычным транзакциям.

## Decision Log
- Решение: открыть отдельный экран через `GoRouter` с передачей модели `GroupedCreditPaymentFeedItem` в `extra`.

## Outcomes & Retrospective
- Что сделано:
  - Добавлен экран `CreditPaymentDetailsScreen`.
  - Tap по `GroupedCreditPaymentTile` переведен на новый экран деталей.
  - Добавлен маршрут в `app_router.dart`.
  - Обновлена документация в `docs/components/`.
- Что бы улучшить в следующий раз:
  - Вынести отдельные l10n-ключи для строк разбивки (основной долг/комиссии/прочее).
