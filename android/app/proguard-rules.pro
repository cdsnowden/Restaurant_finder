## Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.embedding.** { *; }

# Keep all Flutter plugin classes
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.plugin.common.** { *; }
-keep class io.flutter.embedding.engine.plugins.** { *; }

# Keep JSON serialization classes
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# Keep all native methods and their classes
-keepclasseswithmembernames,includedescriptorclasses class * {
    native <methods>;
}

# Keep Flutter GeneratedPluginRegistrant
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }

# Provider package
-keep class * extends java.lang.Object {
    void notifyListeners();
}

# HTTP package and network
-keep class okhttp3.** { *; }
-keep class okio.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**

# Shared Preferences plugin
-keep class androidx.preference.** { *; }
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# URL Launcher plugin
-keep class io.flutter.plugins.urllauncher.** { *; }

# PathProvider plugin
-keep class io.flutter.plugins.pathprovider.** { *; }

# Keep MainActivity and package
-keep class com.chris.restaurantfinder.** { *; }
-keep class com.example.restaurant_finder.** { *; }

# Keep Kotlin metadata
-keep class kotlin.Metadata { *; }
-keep class kotlin.** { *; }
-dontwarn kotlin.**

# AndroidX
-keep class androidx.lifecycle.** { *; }
-dontwarn androidx.**

# Keep crash reporting
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

# Don't obfuscate
-dontobfuscate

# Don't warn about missing classes
-dontwarn io.flutter.embedding.**
-dontwarn io.flutter.plugins.**
