// android/app/build.gradle.kts

import org.gradle.api.tasks.compile.JavaCompile

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
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "qmodo.ru.kopim"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Для простоты подписываем debug-ключом, чтобы `flutter run --release` работал.
            signingConfig = signingConfigs.getByName("debug")
            // При необходимости включите минификацию:
            // isMinifyEnabled = true
            // proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
        debug {
            // Настройки для отладки при необходимости
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Desugaring для Java 8+ API
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")

    // Прочие зависимости модуля app при необходимости:
    // implementation("...")
}

// Включаем подробные предупреждения компилятора Java об устаревших API
tasks.withType<JavaCompile>().configureEach {
    options.compilerArgs.addAll(listOf("-Xlint:deprecation", "-Xlint:unchecked"))
}

