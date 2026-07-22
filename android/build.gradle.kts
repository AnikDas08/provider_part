allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    val configureNamespace = {
        val android = extensions.findByName("android") as? com.android.build.api.dsl.CommonExtension<*, *, *, *, *, *>
        if (android != null && android.namespace == null) {
            val manifestFile = file("src/main/AndroidManifest.xml")
            if (manifestFile.exists()) {
                val manifestText = manifestFile.readText()
                val match = Regex("""package=["']([^"']+)["']""").find(manifestText)
                if (match != null) {
                    android.namespace = match.groupValues[1]
                } else {
                    android.namespace = "dev.flutter.plugins.${project.name.replace('-', '_')}"
                }
            } else {
                android.namespace = "dev.flutter.plugins.${project.name.replace('-', '_')}"
            }
        }
    }

    if (project.state.executed) {
        configureNamespace()
    } else {
        project.afterEvaluate {
            configureNamespace()
        }
    }

    tasks.withType(org.jetbrains.kotlin.gradle.tasks.KotlinCompile::class.java).configureEach {
        val targetVersion = (project.extensions.findByName("android") as? com.android.build.api.dsl.CommonExtension<*, *, *, *, *, *>)
            ?.compileOptions?.targetCompatibility?.toString() ?: "17"
        kotlinOptions {
            jvmTarget = targetVersion
        }
    }
}





tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

