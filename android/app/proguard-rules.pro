# ProGuard/R8 obfuscation rules for "seguridad" app
# These rules prevent R8 from removing or incorrectly obfuscating classes
# that are referenced via reflection by Firebase, Flutter plugins, etc.

# Flutter engine - classes needed for embedding
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase Messaging / Firebase Core - uses reflection internally
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# flutter_secure_storage - uses Android Keystore and EncryptedSharedPreferences
-keep class androidx.security.crypto.** { *; }
-dontwarn androidx.security.crypto.**

# MainActivity and RASP security MethodChannel
# Explicitly kept to ensure R8 doesn't eliminate code it thinks is unused
-keep class com.ameth.seguridad.MainActivity { *; }

# Preserve annotations - required for Firebase and AndroidX to work correctly
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Suppress warnings from libraries that handle their own keep rules
-dontwarn kotlin.**
-dontwarn kotlinx.**

# Flutter Play Store Deferred Components
# This project does not use Play Store dynamic feature delivery, but the
# Flutter engine includes references to these classes in case an app needs
# them. Since the com.google.android.play:core library is not a dependency
# here, R8 reports them as "missing classes". They are safely ignored.
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**