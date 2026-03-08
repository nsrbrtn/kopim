// Production entrypoint для release-сборок.
// Держим отдельный target, чтобы release-команды и документация
// явно указывали боевую точку входа, но реальный bootstrap оставался общим.
import 'package:kopim/core/config/firebase_environment.dart';

import 'main.dart' as app_main;

Future<void> main() =>
    app_main.runKopimApp(environment: FirebaseEnvironment.prod);
