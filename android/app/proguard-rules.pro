## Flutter-specific rules
#-keep class io.flutter.** { *; }
#-keep class io.flutter.embedding.** { *; }
#
## Firebase-specific rules
#-keep class com.google.firebase.** { *; }
#-keep class com.google.android.gms.** { *; }
#
## Prevent obfuscation of generated classes
#-keepclassmembers class **.R$* {
#    <fields>;
#}
#-keep class **.R {
#    <fields>;
#}

# Flutter-specific rules

-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class com.google.firebase.** { *; }
-dontwarn io.flutter.embedding.**
-ignorewarnings




#-keepclassmembers enum * { *; }
