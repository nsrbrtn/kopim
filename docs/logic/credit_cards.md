# Кредитные карты (credit_card)

## Назначение
Отдельная сущность для кредитных карт, связанная с обычным счетом типа
`credit_card`. Используется для отображения доступного лимита и долга, а
также для синхронизации параметров карты.

## Модель
`CreditCardEntity`:
- `id`
- `accountId` — связь с `AccountEntity`
- `creditLimit` — лимит карты
- `statementDay` — день формирования выписки (1–31)
- `paymentDueDays` — количество дней до платежа после выписки
- `interestRateAnnual` — годовая ставка
- `createdAt`, `updatedAt`
- `isDeleted`

## Логика баланса
- В `AccountEntity.balance` хранится долг (отрицательное значение).
- Доступный лимит: `creditLimit + balance`.
- Долг: `max(0, -balance)`.

## Транзакции
- Покупки по карте: `expense` на счет `credit_card`.
- Возвраты/кэшбэк: `income` на счет `credit_card`.
- Погашение: только `transfer` на счет `credit_card`.

## UI
- На домашнем экране карта кредитной карты отображает доступный лимит.
- Вторая строка — долг (без отдельного лейбла).
- В форме создания/редактирования счета при выборе типа `credit_card`
  показываются дополнительные поля.

## Пример использования
Создание кредитной карты происходит при создании счета типа `credit_card`
и сохранении `CreditCardEntity` с параметрами карты.

## Код
- Сущность: `lib/features/credits/domain/entities/credit_card_entity.dart`
- DAO: `lib/features/credits/data/sources/local/credit_card_dao.dart`
- Репозиторий: `lib/features/credits/domain/repositories/credit_card_repository.dart`
- Экран добавления счета: `lib/features/accounts/presentation/accounts_add_screen.dart`
- Домашняя карточка: `lib/features/home/presentation/screens/home_screen.dart`
