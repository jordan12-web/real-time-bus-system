plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android") version "2.3.20" // ✅ bump Kotlin version
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.passenger_app"
    compileSdk = 37 // ✅ keep stable SDK version
    ndkVersion = "28.2.13676358" // Required by jni plugin

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    // ✅ New DSL for Kotlin compiler options
    kotlin {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }

    defaultConfig {
        applicationId = "com.example.passenger_app"
        minSdk = flutter.minSdkVersion
        targetSdk = 37 // ✅ match compileSdk
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
