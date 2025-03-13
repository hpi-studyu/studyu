plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

import java.util.Properties
import java.io.FileInputStream

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use { localProperties.load(it) }
}

val flutterVersionCode = localProperties.getProperty("flutter.versionCode") ?: "1"
val flutterVersionName = localProperties.getProperty("flutter.versionName") ?: "1.0"

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

android {
    namespace = "health.studyu.app"
    // compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    // Start flutter_local_notifications
    compileSdk = maxOf(flutter.compileSdkVersion, 34)
    // End flutter_local_notifications
    // temp fix for record_audio package instead of "flutter.ndkVersion"
    // ndkVersion = "26.1.10909125"

    defaultConfig {
        // Start flutter_local_notifications
        multiDexEnabled = true
        // End flutter_local_notifications
        applicationId = "health.studyu.app"
        // minSdk = flutter.minSdkVersion
        minSdk = maxOf(flutter.minSdkVersion, 23)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutterVersionCode.toInt()
        versionName = flutterVersionName
    }

    compileOptions {
        // Start flutter_local_notifications
        // Flag to enable support for the new language APIs
        isCoreLibraryDesugaringEnabled = true
        // End flutter_local_notifications
        // sourceCompatibility = JavaVersion.VERSION_17
        // targetCompatibility = JavaVersion.VERSION_17
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        // jvmTarget = '17'
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "health.studyu.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // minSdk = flutter.minSdkVersion
        minSdk = Math.max(flutter.minSdkVersion, 23)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it as String) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }
    buildTypes {
        release {
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = if (keystorePropertiesFile.exists()) signingConfigs.getByName("release") else signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Start flutter_local_notifications
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:1.2.2")
    // Fix crash on Android 12L / 13 using workaround
    // See https://github.com/flutter/flutter/issues/110658#issuecomment-1320834920
    implementation("androidx.window:window:1.0.0")
    implementation("androidx.window:window-java:1.0.0")
    // End flutter_local_notifications
}
