plugins {
    id("com.android.application")
    id("kotlin-android")
    // Flutter Gradle Plugin must be applied last
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.body_log"

    // ✅ SDK 및 NDK 설정
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.example.body_log"
        minSdk = 21           // 최소 지원 버전
        targetSdk = 33        // 구글 권장 안정 버전
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            // 배포용 릴리즈 빌드에 필요한 서명 설정
            signingConfig = signingConfigs.getByName("debug") // 디버그 키 사용 중
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }
}

flutter {
    source = "../.."
}
