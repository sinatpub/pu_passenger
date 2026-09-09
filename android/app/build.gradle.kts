import java.util.Base64

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // F-09: firebase_crashlytics was a declared-but-unused dependency; the
    // Dart side is wired in main.dart and this applies the Gradle plugin so
    // native symbols actually upload.
    id("com.google.firebase.crashlytics")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Flutter forwards `--dart-define`/`--dart-define-from-file` values here as
// base64-encoded "key=value" pairs, comma-separated.
fun dartDefine(key: String): String {
    val raw = project.findProperty("dart-defines") as String? ?: return ""
    return raw.split(",")
        .map { String(Base64.getDecoder().decode(it)) }
        .map { it.split("=", limit = 2) }
        .firstOrNull { it.getOrNull(0) == key }
        ?.getOrNull(1) ?: ""
}

android {
    namespace = "com.tara.passenger.tara_passenger_mobile_application"
    compileSdk = 36
    ndkVersion =  "27.0.12077973"

    compileOptions {
        // Enable desugaring
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.tara.passenger.tara_passenger_mobile_application"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
        manifestPlaceholders["GOOGLE_MAPS_API_KEY"] = dartDefine("GOOGLE_MAPS_API_KEY")
    }


    signingConfigs {
        create("release") {
            storeFile = file("/Users/sinatnon/open_source/keystores/upload-keystore.jks")
            storePassword = project.property("storePassword") as String
            keyAlias = project.property("keyAlias") as String
            keyPassword = project.property("keyPassword") as String
        }
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = true // Or false, depending on your needs
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

flutter {
    source = "../.."
}
