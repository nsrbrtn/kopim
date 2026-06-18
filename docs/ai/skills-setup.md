# Настройка и установка внешних навыков (Skills Setup)

В проекте Kopim рекомендуется использовать внешние специализированные навыки ИИ-агентов от сообщества разработки Flutter и Dart для получения актуальных практик написания кода и оптимизации.

---

## 1. Автоматическая установка через `npx skills`

Если окружение агента имеет доступ к сети и Node.js/npx, установите официальные наборы навыков следующей командой:

```bash
# Установка навыков Flutter и Dart в локальную директорию .agents/skills/
npx @modelcontextprotocol/skills install flutter/skills dart-lang/skills --dest .agents/skills/
```

Эта команда загрузит актуальные наборы правил верстки, управления стейтом, оптимизации рендеринга и работы с Dart SDK.

---

## 2. Ручная установка (Offline Fallback)

Если запуск автоматической установки невозможен (например, из-за сетевых ограничений или отсутствия `npx`), выполните установку вручную:

1. Создайте в `.agents/skills/` папки `flutter-skills` и `dart-skills`.
2. Скачайте/скопируйте манифесты `SKILL.md` из официальных репозиториев:
   * [Flutter Skills Repository](https://github.com/flutter/skills)
   * [Dart Skills Repository](https://github.com/dart-lang/skills)
3. Поместите их в соответствующие папки. Структура должна выглядеть так:
   ```text
   .agents/
   └── skills/
       ├── flutter-skills/
       │   └── SKILL.md
       └── dart-skills/
           └── SKILL.md
   ```
4. Если навыки лежат в нестандартной папке, зарегистрируйте их пути в файле `.agents/skills.json` в корне проекта:
   ```json
   {
     "entries": [
       { "path": ".agents/skills/flutter-skills" },
       { "path": ".agents/skills/dart-skills" }
     ]
   }
   ```
   После этого ИИ-агент автоматически обнаружит и подключит их при запуске.
