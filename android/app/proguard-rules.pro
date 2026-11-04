# Dimuat otomatis oleh Flutter Gradle Plugin untuk build rilis (R8).

# ML Kit (deteksi wajah di langkah foto punch). Tanpa aturan ini R8 menyisipkan dan
# memangkas InputImage.fromByteArray sehingga setiap frame kamera gagal dengan
# NullPointerException (InputImageConverterError) dan wajah tidak pernah terdeteksi,
# padahal build debug normal.
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_** { *; }
-keep class com.google_mlkit_commons.** { *; }
-keep class com.google_mlkit_face_detection.** { *; }
