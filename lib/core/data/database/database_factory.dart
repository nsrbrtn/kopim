import 'package:kopim/core/data/database.dart';

import 'native_database.dart'
    if (dart.library.html) 'web_database.dart'
    as platform;

AppDatabase constructDb() {
  return AppDatabase.connect(platform.openAppDatabaseConnection());
}
