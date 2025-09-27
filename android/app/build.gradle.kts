// android/app/build.gradle.kts
plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "qmodo.ru.kopim"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8  // Для совместимости с desugaring
        targetCompatibility = JavaVersion.VERSION_1_8  // Для совместимости с desugaring
        isCoreLibraryDesugaringEnabled = true  // Исправлено: добавлен префикс "is" для KTS
    }

    kotlinOptions {
        jvmTarget = "1.8"  // Для Kotlin compatibility с Java 8
    }

    defaultConfig {
        // Specify your own unique Application ID[](https://developer.android.com/studio/build/application-id.html).
        applicationId = "qmodo.ru.kopim"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Desugaring библиотека (версия для AGP 8.x+)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")  // Необходима для desugaring

    // ... (остальные зависимости, если есть)
}