plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.ibi"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // 1. CORRECCIÓN: Sintaxis correcta para Kotlin DSL
        isCoreLibraryDesugaringEnabled = true 
    }

 defaultConfig {
        // Corrección de sintaxis para Kotlin DSL:
        applicationId = "com.example.jobhub"
        minSdk = flutter.minSdkVersion 
        targetSdk = 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // El truco para activar Multidex:
        multiDexEnabled = true 
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
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

// 3. CORRECCIÓN: Este es el bloque que le dice a Android de dónde descargar la librería
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
