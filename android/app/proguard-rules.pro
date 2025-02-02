# Keep Razorpay-specific classes
-keep class com.razorpay.** { *; }
-keepclassmembers class com.razorpay.** { *; }

# Prevent obfuscation of annotations
-keep class proguard.annotation.Keep { *; }
-keep class proguard.annotation.KeepClassMembers { *; }

# Keep Flutter-related classes
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }

# Keep all resource identifiers
-keepclassmembers class **.R$* {
    public static <fields>;
}
