// --- THÊM 2 DÒNG IMPORT NÀY VÀO ĐẦU FILE ---
import com.android.build.gradle.ProguardFiles.getDefaultProguardFile
import java.util.Properties
import java.io.FileInputStream
// ------------------------------------------

plugins {
    id("com.onesignal.androidsdk.onesignal-gradle-plugin")
    id("com.android.application")
    
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}



android {
    namespace = "com.example.warehouse"
    compileSdk = 34
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    signingConfigs {
        create("release") {
            val keyPropertiesFile = rootProject.file("key.properties")
            if (keyPropertiesFile.exists()) {
                val keyProperties = Properties() // Bây giờ đã hợp lệ
                keyProperties.load(FileInputStream(keyPropertiesFile)) // Bây giờ đã hợp lệ
                keyAlias = keyProperties.getProperty("keyAlias")
                keyPassword = keyProperties.getProperty("keyPassword")
                storeFile = file(keyProperties.getProperty("storeFile"))
                storePassword = keyProperties.getProperty("storePassword")
            }
        }
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.warehouse"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 23
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            isMinifyEnabled = true // Kích hoạt việc thu nhỏ mã nguồn và obfuscation
            isShrinkResources = true // Kích hoạt việc loại bỏ các tài nguyên không sử dụng

            // Chỉ định các tệp cấu hình ProGuard
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("release")
        }
    }
}


flutter {
    source = "../.."
}
