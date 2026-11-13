[Português](README.md) | [English](README.en.md) | [Français](README.fr.md) | [Español](README.es.md) | [简体中文](README.zh.md) | [日本語](README.ja.md) | [Deutsch](README.de.md) | [العربية](README.ar.md) | [हिन्दी](README.hi.md) | [한국어](README.ko.md)

# Cloudflare DNS Manager

تطبيق Flutter لإدارة سجلات DNS عبر واجهة Cloudflare API.

يحتوي هذا الملف على معلومات مشتركة بين جميع المنصات. للاطلاع على أوامر البناء والاختبار والتفاصيل الخاصة بكل منصة، راجع أدلة [Android](README-Android.md) و[Linux](README-Linux.md) و[Windows](README-Windows.md) و[iOS](README-iOS.md) و[macOS](README-macOS.md).

## الميزات

- تسجيل دخول محلي بكلمة مرور، وتسجيل دخول بالقياسات الحيوية على المنصات المدعومة.
- تسجيل خروج تلقائي عند إغلاق التطبيق وإعادة فتحه.
- قائمة النطاقات مع حالات نشط وقيد الانتظار وغير نشط.
- محرر سجلات DNS قابل للضبط، والتحكم بوكيل Cloudflare، ومسح ذاكرة CDN المؤقتة.
- إعداد رمز Cloudflare API والتحقق منه.
- مظهر فاتح أو داكن أو تابع للنظام؛ واجهة بالبرتغالية والإنجليزية والفرنسية والإسبانية والصينية المبسطة واليابانية والألمانية والعربية والهندية والكورية.
- سجل إصدارات مترجم داخل التطبيق.

## الوصول والأمان

عند الاستخدام الأول، أنشئ كلمة مرور للتطبيق. تتطلب كل جلسة جديدة تسجيل الدخول. تبقى الجلسة في الذاكرة فقط. تُحفظ كلمة المرور كتجزئة PBKDF2-HMAC-SHA256 مع قيمة عشوائية في التخزين الآمن للمنصة. يُحفظ رمز Cloudflare بالطريقة نفسها. تُخزن إعدادات المظهر وDNS في التفضيلات المحلية المعتادة.

## رمز Cloudflare API

1. سجّل الدخول إلى التطبيق.
2. افتح **الإعدادات**.
3. ألصق [رمز Cloudflare API](https://dash.cloudflare.com/profile/api-tokens).
4. اختر **اختبار** ثم **حفظ**.

### رمز API لإدارة النطاقات المسجلة فقط

لعرض النطاقات الحالية والتحقق من تفعيلها ومسح ذاكرة CDN المؤقتة، استخدم:

- **Zone / Zone / Edit** لعرض المناطق وإعادة فحص تفعيل المناطق المعلقة.
- **Zone / Cache Purge / Purge** لمسح ذاكرة CDN المؤقتة.

لا يسمح هذا الملف بإنشاء سجلات DNS أو تعديلها أو حذفها.

### رمز API لإضافة نطاقات جديدة وإدارة النطاقات الحالية

استخدم الأذونات السابقة وأضف:

- **Zone / DNS / Edit** لعرض سجلات DNS وإنشائها وتعديلها وحذفها.
- **Zone resources / Include / All zones**.
- **User / Memberships / Read**، ويُنصح به لعرض كل الحسابات المتاحة، حتى التي لا تضم نطاقات.

## البنية

- Flutter / Dart؛ تُستخدم `shared_preferences` للبيانات المحلية غير الحساسة.
- تُستخدم `flutter_secure_storage` للأسرار و`local_auth` للمصادقة الحيوية.
- تُستخدم `http` للاتصال بالشبكة و`url_launcher` للروابط الخارجية.

## مشكلة معروفة

يتطلب Windows حزمة Microsoft Visual C++ Redistributable 2015–2022. إذا كان الملف `MSVCP140.dll` أو `VCRUNTIME140.dll` أو `VCRUNTIME140_1.dll` مفقودًا، فثبّت الحزمة من [صفحة Microsoft الرسمية](https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist).

## الترخيص

MIT
