import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val uploadPropertiesFile = rootProject.file("key.properties")
val uploadProperties = Properties().apply {
    if (uploadPropertiesFile.exists()) uploadPropertiesFile.inputStream().use { load(it) }
}
val unsignedSmokeBuild = providers.gradleProperty("unsignedSmokeBuild").orNull == "true"

android {
    namespace = "com.ahmedhassan.passthephone"
    compileSdk = maxOf(36, flutter.compileSdkVersion)
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // Permanent identity approved by the owner; retain for all future upgrades.
        applicationId = "com.ahmedhassan.passthephone"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = maxOf(36, flutter.targetSdkVersion)
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (uploadPropertiesFile.exists() && !unsignedSmokeBuild) {
            create("upload") {
                fun required(name: String): String = requireNotNull(uploadProperties.getProperty(name)) {
                    "Missing upload signing property: $name"
                }
                storeFile = rootProject.file(required("storeFile"))
                storePassword = required("storePassword")
                keyAlias = required("keyAlias")
                keyPassword = required("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (unsignedSmokeBuild) null else signingConfigs.findByName("upload")
        }
    }
}

gradle.taskGraph.whenReady {
    if (allTasks.any { it.project == project && it.name in listOf("assembleRelease", "bundleRelease") }) {
        require(android.defaultConfig.applicationId == "com.ahmedhassan.passthephone") {
            "Release applicationId must match the approved permanent identity com.ahmedhassan.passthephone."
        }
        if (!unsignedSmokeBuild) {
            require(uploadPropertiesFile.exists()) {
                "Release requires local android/key.properties and an upload key. No debug signing fallback."
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
