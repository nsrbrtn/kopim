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
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val requestedTaskNames = gradle.startParameter.taskNames.map { it.lowercase() }
val hasOfflineTask = requestedTaskNames.any { it.contains("offline") }
val hasCloudFlavorTask = requestedTaskNames.any {
    it.contains("dev") || it.contains("stage") || it.contains("prod")
}

// Для offline-only сборок не подключаем Firebase Gradle plugins, чтобы variant
// не требовал google-services.json и не прогонял Crashlytics processing.
val shouldApplyFirebasePlugins =
    requestedTaskNames.isEmpty() || !hasOfflineTask || hasCloudFlavorTask

if (shouldApplyFirebasePlugins) {
    apply(plugin = "com.google.gms.google-services")
    apply(plugin = "com.google.firebase.crashlytics")
}

android {
    namespace = "qmodo.ru.kopim"
    // Явно фиксируем SDK-версии для публикации в Google Play.
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
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
        minSdk = 24
        targetSdk = 35
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
        create("offline") {
            dimension = "env"
            applicationId = "kopim.app"
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

    sourceSets {
        getByName("offline") {
            manifest.srcFile("src/offline/AndroidManifest.xml")
            res.srcDirs("src/offline/res")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Desugaring для Java 8+ API
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")

    // Совместимое edge-to-edge поведение для Android 15+ и более старых версий.
    implementation("androidx.core:core:1.17.0")
}

// Включаем подробные предупреждения компилятора Java об устаревших API
tasks.withType<JavaCompile>().configureEach {
    options.compilerArgs.addAll(listOf("-Xlint:deprecation", "-Xlint:unchecked"))
}
