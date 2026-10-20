# KNIFE ARENA — حزمة Flutter Android

## ما تم إصلاحه
- إضافة ملفات منصة Android الحديثة باستخدام Flutter Android embedding v2.
- إضافة MainActivity باستخدام `io.flutter.embedding.android.FlutterActivity`.
- ضبط Target SDK على Android 15 / API 35، وJava/Kotlin على 17.
- إصلاح تحويلات `clamp()` إلى `double` في ملفات اللعبة.
- إبقاء المشروع مبنيًا على Flutter وFlame، مع ملفات اللعبة الأصلية.

## البناء
1. افتح مجلد المشروع الذي يحتوي `pubspec.yaml` في بيئة Flutter تدعم المشاريع الكاملة.
2. تأكد من أن Flutter SDK وAndroid SDK مثبتان ومهيآن.
3. نفّذ `flutter pub get`.
4. نفّذ `flutter analyze` ثم `flutter build apk --release`.

## ملاحظات قبل تسليم نسخة إنتاجية
- هذه الحزمة لم تُبنَ داخل بيئة Flutter هنا؛ لذلك لا أستطيع ضمان نجاح البناء النهائي قبل تشغيل أوامر التحقق أعلاه.
- نسخة Release تستخدم توقيع debug للتجربة فقط. يجب إعداد مفتاح توقيع رسمي للشركة قبل النشر.
- إذا كانت أداة البناء تنشئ ملفات Android تلقائيًا، افتح المجلد الجذري للمشروع ولا تفتح مجلد `lib` وحده.
