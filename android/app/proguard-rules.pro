# ML Kit text recognition: only the Latin model is bundled. The plugin also
# references the Chinese, Devanagari, Japanese and Korean models, which are
# separate optional libraries; tell R8 they are absent on purpose.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
