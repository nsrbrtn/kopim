---
description: Деплой web-приложения в Firebase Hosting
---

Этот workflow описывает ручной деплой web-приложения в Firebase Hosting.

Важно:
- выполнять только по явному запросу пользователя;
- перед деплоем убедиться, что используется нужный Firebase-проект и нужная ветка/сборка.

1. Собрать web-приложение в release-режиме
```bash
flutter build web --release
```

2. Выполнить деплой в Firebase Hosting
```bash
firebase deploy --only hosting
```
