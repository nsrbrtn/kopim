---
description: Deploy the web application to Firebase Hosting
---

This workflow builds the Flutter web application in release mode and deploys it to Firebase Hosting.

1. Build the web application
// turbo
```bash
flutter build web --release
```

2. Deploy to Firebase Hosting
// turbo
```bash
firebase deploy --only hosting
```
