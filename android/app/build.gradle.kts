// android/app/build.gradle.kts

import org.gradle.api.tasks.compile.JavaCompile
import java.util.Properties
import java.io.File
import java.io.FileInputStream

// Load keystore properties
val keystoreProps = Properties()
val propsFile = rootProject.file("key.properties")
if (propsFile.exists()) {
    keystoreProps.load(FileInputStream(propsFile))
}

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

    signingConfigs {
        create("release") {
            if (propsFile.exists()) {
                val storeFilePath = keystoreProps.getProperty("storeFile")
                if (!storeFilePath.isNullOrBlank()) {
                    val candidate = File(storeFilePath)
                    storeFile = if (candidate.isAbsolute) candidate else rootProject.file(storeFilePath)
                }
                storePassword = keystoreProps.getProperty("storePassword")
                keyAlias = keystoreProps.getProperty("keyAlias")
                keyPassword = keystoreProps.getProperty("keyPassword")
            }
        }
    }

    defaultConfig {
        applicationId = "qmodo.ru.kopim"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions("env")
    productFlavors {
        create("dev") {
            dimension = "env"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
        }
        create("stage") {
            dimension = "env"
            applicationIdSuffix = ".stage"
            versionNameSuffix = "-stage"
        }
        create("prod") {
            dimension = "env"
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
        }
        getByName("debug") {
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
