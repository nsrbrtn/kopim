# Offline flavor как автономный distribution contour

## Что изменилось

- В проекте существует отдельный `offlineOnly` flavor с entrypoint `lib/main_offline.dart`.
- Публичный package name первого релиза в Google Play: `kopim.app`.
- Android offline flavor теперь дополнительно определяет runtime по `appFlavor`, поэтому сборка `--flavor offlineOnly` не должна случайно поднять Firebase-контур даже если кто-то забудет `--target lib/main_offline.dart`.
- Offline runtime работает без обязательной инициализации Firebase и без рабочего AI/cloud sync контура.
- Пользователь получает постоянный локальный `user id` формата `local-...`, который сохраняется между перезапусками.
- В offline runtime:
  - нет обязательного экрана входа/регистрации;
  - online sync по умолчанию выключен и недоступен для включения;
  - `ИИ-ассистент` убран из нижней навигации и показан в меню как teaser `доступно позже`;
  - logout скрыт из профиля.
- Android display name для offline flavor теперь тоже `Kopim`, без суффикса `Offline`.

## Зачем

- Выпустить первую публичную версию как полнофункциональное локальное приложение без облачных блокеров.
- Поддерживать отдельный автономный contour под `kopim.app`, не зависящий от готовности backend/sync/AI.
- Сохранить параллельный privacy/offline дистрибутив, пока основной Play-контур развивается как `storeProdLocalFirst`.

## Текущее позиционирование

- Основной публичный Android Play contour теперь рассматривается как `storeProdLocalFirst`: local-first, но cloud-capable сборка.
- `offlineOnly` больше не считается основным Play flow и поддерживается как отдельный автономный distribution для offline/privacy сценариев.
- До финального smoke нового Play-контура `offlineOnly` остаётся поддерживаемым параллельным артефактом и не считается deprecated.

## Как проверить

1. Собрать Android offline flavor:

```bash
flutter build apk --flavor offlineOnly --target lib/main_offline.dart
```

2. Убедиться, что offline flavor стартует без экрана входа.
3. Проверить, что в нижней навигации нет вкладки `ИИ-ассистент`.
4. Открыть `Меню` и нажать `ИИ-ассистент`:
   - показывается заглушка про доступность позже по подписке.
5. Открыть профиль:
   - online sync выключен;
   - переключатель недоступен;
   - есть пояснение про будущую подписку;
   - кнопка выхода отсутствует.
6. Перезапустить приложение и убедиться, что локальный пользователь сохраняется, а данные остаются доступными.

Для сборки автономного `offlineOnly` артефакта используй `AAB`:

```bash
flutter build appbundle --flavor offlineOnly --release --target lib/main_offline.dart
```

## Google Play / policy notes

- Для `Google Play` даже приложение без сбора данных обязано иметь:
  - заполненную `Data safety` форму;
  - `privacy policy` URL.
- Offline release может публиковаться как отдельное приложение `kopim.app`, поэтому его `Data safety` и `privacy policy` ведутся отдельно от legacy-контура `qmodo.ru.kopim`.
- Публичный cloud-capable Play contour документируется отдельно как `storeProdLocalFirst` и не должен смешиваться с автономными policy/copy assumptions этого документа.
- В текущем состоянии offline runtime не инициализирует Firebase, sync и AI, но Android release artifact все еще содержит часть Firebase/Sentry SDK через общий `Flutter` dependency graph.
- Из-за этого `Data Safety` для `kopim.app` сейчас следует заполнять консервативно: не как полностью `zero-data` binary, а как offline-приложение с ограниченным техническим telemetry/diagnostics contour.

## Ограничения текущей сборки

- `offlineRelease` не требует `google-services.json` и не зависит от runtime-инициализации Firebase для пользовательского сценария.
- При этом полное физическое исключение Firebase/Sentry библиотек из Android artifact graph пока не достигнуто, потому что проект использует единый `pubspec.yaml`.
- Это не мешает публикации офлайн-релиза, но важно для `Data Safety`, policy-review и будущей задачи по дальнейшей build-time изоляции.

## Breaking changes

- Offline flavor больше не разделяет package name с legacy-контуром `qmodo.ru.kopim`.
- Локальная БД offline flavor хранится отдельно: `kopim_offline.db`.
