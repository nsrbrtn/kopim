// android/build.gradle.kts
buildscript {
    val kotlin_version = "1.9.25"  // Актуальная для Flutter 3.35.3 и Dart 3.9.2
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Android Gradle Plugin (AGP) для сборки и desugaring
        classpath("com.android.tools.build:gradle:8.5.2")
        // Kotlin для плагина kotlin-android
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version")
        // Для FlutterFire (Firebase integration)
        classpath("com.google.gms:google-services:4.4.4")
        classpath("com.google.firebase:firebase-crashlytics-gradle:3.0.6")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
