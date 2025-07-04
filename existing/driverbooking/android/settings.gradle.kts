pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

// Apply plugins with compatible versions for Java 21 and your Flutter project
plugins {
    id("com.android.application") version "8.2.1"
    id("com.android.library") version "8.2.1"
    id("org.jetbrains.kotlin.android") version "1.9.0"
}

include(":app")
