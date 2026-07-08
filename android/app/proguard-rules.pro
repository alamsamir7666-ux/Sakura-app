# Add project specific ProGuard rules here.
-keep class com.sakurabeauty.app.** { *; }
-keepattributes Signature
-keepattributes *Annotation*

# Flutter
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# Clerk
-keep class com.clerk.** { *; }

# Dio / OkHttp
-dontwarn okhttp3.**
-dontwarn okio.**
