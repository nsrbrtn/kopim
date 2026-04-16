# Таксономия типов счетов

Документ фиксирует каноничные типы счетов, правила совместимости с legacy-данными и поведение backup/import/sync после account model rework.

## Каноничные типы v1

Пользователь может создавать только следующие типы счетов:

- `cash`
- `bank`
- `credit_card`
- `investment`

`legacy_unknown` не является пользовательским типом и используется только как internal fallback при чтении старых записей.

## Что больше не считается каноничным типом счета

- `card`
- `custom:*`
- `savings`
- `deposit`
- `debt`
- `loan`

`saving_goal` остается отдельной сущностью и не считается типом счета.

## Stored type и canonical type

- `stored type` — строковое значение, которое хранится в БД, backup и remote snapshot.
- `canonical type` — значение, которое использует новая доменная логика после normalization.

На первом этапе rollout приложение работает в compatibility-first режиме:

- старые записи не переписываются немедленно;
- normalization выполняется на чтении;
- новые записи создаются только с каноничными типами.

## Whitelist normalization

Детерминированный mapping для legacy-значений:

- `card -> bank`

Дополнительно допускаются уже понятные системе legacy/raw значения вроде `cash`, `bank`, `credit`, `credit_card`, `debt`, `investment`, `savings`, но только по явному whitelist без эвристик.

Неизвестные или кастомные значения:

- не роняют приложение;
- не переписываются автоматически;
- интерпретируются как `legacy_unknown` на уровне доменной семантики.

## Marker версии типа

Для записей `accounts` используется `typeVersion`.

- `0` — legacy stored type без подтвержденного backfill.
- `1` — canonical stored type или детерминированно нормализуемая запись, уже подтвержденная новой моделью.

Правила:

- новый backup экспортирует `typeVersion`;
- legacy backup без `typeVersion` импортируется с `typeVersion = 0`;
- sync и merge локального/remote snapshot учитывают `typeVersion` раньше, чем `updatedAt`, когда речь идет о поле `accounts.type`.

## Deferred backfill

Backfill запускается отдельно от первого shipping compatibility layer.

Он:

- переписывает только whitelisted legacy types;
- не трогает `legacy_unknown` и `custom:*`;
- идемпотентен;
- не меняет `account.id`;
- обновляет только `accounts.type`, `typeVersion` и связанные outbox payload.

## Backup / Import

- JSON/CSV export схемы `1.6.0+` сохраняет `accounts.typeVersion`.
- Import новых backup сохраняет marker без потери canonical state.
- Import старых backup остается поддержанным: отсутствие `typeVersion` трактуется как legacy snapshot.

## Sync anti-churn policy

- stale local outbox с меньшим `typeVersion` не должен откатывать remote canonical type;
- при merge local/remote snapshot более высокий `typeVersion` выигрывает для `accounts.type`, даже если второй снимок новее по `updatedAt`;
- после backfill canonical stored type не должен ping-pong'иться обратно в legacy raw value.
