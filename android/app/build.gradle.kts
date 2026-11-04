import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Tanda tangan rilis dari android/key.properties (di-gitignore; dibuat oleh CI dari GitHub Secrets
// atau secara lokal, lihat docs/rilis-dan-pembaruan.md). Tanpa berkas itu build rilis memakai kunci
// debug agar `flutter run --release` tetap jalan, tetapi APK-nya TIDAK bisa menimpa APK rilis
// bertanda tangan resmi (dan sebaliknya).
val keystoreProperties = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) FileInputStream(file).use { load(it) }
}
val hasReleaseKey = keystoreProperties.getProperty("storeFile") != null
if (!hasReleaseKey && System.getenv("REQUIRE_RELEASE_SIGNING") == "true") {
    throw GradleException("REQUIRE_RELEASE_SIGNING=true tetapi android/key.properties tidak ada.")
}

android {
    namespace = "id.eabsensi.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // APP_ID_SUFFIX / APP_LABEL (variabel lingkungan) membuat build kedua yang bisa
        // dipasang berdampingan dengan build biasa, mis. APP_ID_SUFFIX=.baru APP_LABEL="eAbsensi Baru".
        applicationId = "id.eabsensi.app" + (System.getenv("APP_ID_SUFFIX") ?: "")
        manifestPlaceholders["appLabel"] = System.getenv("APP_LABEL") ?: "eAbsensi"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseKey) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseKey) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
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
