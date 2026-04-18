enum AppRuntimeFlavor { offline, firebaseDev, firebaseProd }

final class AppRuntimeConfig {
  AppRuntimeConfig._();

  static AppRuntimeFlavor _flavor = AppRuntimeFlavor.firebaseDev;

  static AppRuntimeFlavor get flavor => _flavor;

  static bool get isOffline => _flavor == AppRuntimeFlavor.offline;

  static bool get usesFirebase => !isOffline;

  static void configure(AppRuntimeFlavor flavor) {
    _flavor = flavor;
  }
}
