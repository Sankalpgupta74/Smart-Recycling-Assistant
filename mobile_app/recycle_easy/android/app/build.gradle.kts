plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}


android {
    namespace = "com.example.recycle_easy"
    compileSdk = 35 
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.example.recycle_easy"
        minSdk = flutter.minSdkVersion
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    constraints {
        implementation("androidx.activity:activity:1.9.3") {
            because("AGP 8.7.0 does not support compileSdk 36 which is required by activity 1.12+")
        }
        implementation("androidx.core:core-ktx:1.15.0") {
            because("AGP 8.7.0 does not support compileSdk 36")
        }
        implementation("androidx.core:core:1.15.0") {
            because("AGP 8.7.0 does not support compileSdk 36")
        }
        implementation("androidx.navigationevent:navigationevent-android:1.0.0") {
            because("AGP 8.7.0 does not support compileSdk 36")
        }
    }
}
