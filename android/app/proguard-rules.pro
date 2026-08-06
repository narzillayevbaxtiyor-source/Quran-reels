# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Dio
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn com.squareup.okhttp.**

# Hive
-keep class * extends com.google.protobuf.GeneratedMessageLite { *; }

# just_audio
-keep class com.ryanheise.just_audio.** { *; }

# Firebase
-keepattributes *Annotation*
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Google Sign In
-keep class com.google.android.gms.** { *; }

# General
-keepattributes SourceFile,LineNumberTable
-keepattributes EnclosingMethod

# Keep R8 from stripping necessary info
-keep,allowobfuscation,allowshrinking class * extends com.google.gson.TypeAdapterFactory
-keep,allowobfuscation,allowshrinking class * extends com.google.gson.JsonSerializer
-keep,allowobfuscation,allowshrinking class * extends com.google.gson.JsonDeserializer
