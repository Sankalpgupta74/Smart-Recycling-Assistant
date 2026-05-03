
allprojects {
    repositories {
        google()
        mavenCentral()
        maven {
            url = uri("https://storage.googleapis.com/download.flutter.io")
        }
    }
}

// Fixed Kotlin Syntax for Subprojects
subprojects {
    configurations.all {
        resolutionStrategy {
            force("androidx.activity:activity:1.9.3")
            force("androidx.core:core-ktx:1.15.0")
            force("androidx.core:core:1.15.0")
            force("androidx.navigationevent:navigationevent-android:1.0.0")
        }
    }

    afterEvaluate {
        val project = this
        if (project.plugins.hasPlugin("com.android.application") || project.plugins.hasPlugin("com.android.library")) {
            val android = project.extensions.findByName("android") as? com.android.build.gradle.BaseExtension
            android?.apply {
                compileSdkVersion(35)
                buildToolsVersion("35.0.0")

                defaultConfig {
                    targetSdkVersion(35)
                }
            }
        }
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newBuildDir: Directory = rootProject.layout.buildDirectory.dir(project.name).get()
    project.layout.buildDirectory.value(newBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}