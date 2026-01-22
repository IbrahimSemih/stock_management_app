# 📱 Play Store Yayınlama Kontrol Listesi

Bu dosya, SmartStock uygulamanızı Play Store'da yayınlamadan önce tamamlamanız gereken tüm adımları içerir.

## ✅ Tamamlananlar

- ✅ App icon yapılandırması
- ✅ Versiyon numarası (1.0.0+1)
- ✅ App ismi (SmartStock)
- ✅ Çoklu dil desteği (TR/EN)
- ✅ AndroidManifest.xml izinleri eklendi

## ⚠️ Yapılması Gerekenler

### 1. 🔑 Package Name Değiştirme (KRİTİK)

**Mevcut:** `com.devisb.stock_management` (güncellendi ✅)  
**Yapılacak:** Benzersiz bir package name (örn: `com.yourcompany.smartstock`)

**Adımlar:**
1. `android/app/build.gradle.kts` dosyasında:
   ```kotlin
   namespace = "com.yourcompany.smartstock"
   applicationId = "com.yourcompany.smartstock"
   ```

2. `android/app/src/main/kotlin/com/example/stock_management/MainActivity.kt` dosyasını yeni package yapısına taşıyın:
   - Yeni klasör: `android/app/src/main/kotlin/com/yourcompany/smartstock/`
   - Package deklarasyonunu güncelleyin

3. Tüm dosyalarda `com.example.stock_management` referanslarını değiştirin

**⚠️ UYARI:** Package name değiştirdikten sonra eski veriler silinebilir. Test cihazında dikkatli olun!

---

### 2. 🔐 App Signing (KRİTİK)

Play Store'da yayınlamak için production keystore gereklidir.

**Adımlar:**

1. **Keystore oluştur:**
   ```bash
   keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
   - Şifreleri güvenli bir yerde saklayın!
   - Keystore dosyasını kaybetmeyin, geri alınamaz!

2. **key.properties dosyası oluştur** (`android/key.properties`):
   ```properties
   storePassword=your-store-password
   keyPassword=your-key-password
   keyAlias=upload
   storeFile=../upload-keystore.jks
   ```

3. **build.gradle.kts güncelle:**
   ```kotlin
   // Dosyanın başına ekle
   val keystoreProperties = Properties()
   val keystorePropertiesFile = rootProject.file("key.properties")
   if (keystorePropertiesFile.exists()) {
       keystoreProperties.load(FileInputStream(keystorePropertiesFile))
   }

   // buildTypes içinde değiştir
   buildTypes {
       release {
           signingConfig = signingConfigs.getByName("release")
       }
   }

   // signingConfigs ekle
   signingConfigs {
       create("release") {
           keyAlias = keystoreProperties["keyAlias"] as String
           keyPassword = keystoreProperties["keyPassword"] as String
           storeFile = file(keystoreProperties["storeFile"] as String)
           storePassword = keystoreProperties["storePassword"] as String
       }
   }
   ```

4. **key.properties dosyasını .gitignore'a ekle:**
   ```
   android/key.properties
   android/upload-keystore.jks
   ```

---

### 3. 📄 Privacy Policy & Terms of Service

Play Store, özellikle kullanıcı verisi toplayan uygulamalar için Privacy Policy URL'i zorunlu kılar.

**Seçenekler:**

**A) Web sayfası oluştur:**
- GitHub Pages, Netlify, veya kendi web sitenizde yayınlayın
- URL örnekleri:
  - `https://yourwebsite.com/privacy-policy`
  - `https://yourwebsite.com/terms-of-service`

**B) Google Sites kullan:**
- Ücretsiz ve hızlı
- `https://sites.google.com/view/smartstock-privacy`

**C) Hazır template kullan:**
- [Privacy Policy Generator](https://www.privacypolicygenerator.info/)
- [Terms of Service Generator](https://www.termsofservicegenerator.net/)

**Privacy Policy'de olması gerekenler:**
- Hangi veriler toplanıyor (ürün bilgileri, kullanıcı bilgileri)
- Veriler nasıl saklanıyor (SQLite, Supabase)
- Veriler üçüncü taraflarla paylaşılıyor mu
- Kullanıcı hakları (veri silme, düzeltme)

**Uygulamaya ekleme:**
- Settings ekranında Privacy Policy ve Terms of Service linklerini ekleyin
- URL'leri `lib/utils/constants.dart` veya ayrı bir config dosyasında saklayın

---

### 4. 🛡️ ProGuard/R8 Kuralları

Release build'de kod küçültme ve obfuscation için ProGuard kuralları ekleyin.

**Dosya oluştur:** `android/app/proguard-rules.pro`

```proguard
# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Supabase
-keep class io.supabase.** { *; }

# SQLite
-keep class com.tekartik.sqflite.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}
```

**build.gradle.kts'e ekle:**
```kotlin
buildTypes {
    release {
        signingConfig = signingConfigs.getByName("release")
        isMinifyEnabled = true
        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro"
        )
    }
}
```

---

### 5. 📦 App Bundle (AAB) Oluşturma

Play Store artık APK yerine AAB (Android App Bundle) formatını tercih ediyor.

**Build komutu:**
```bash
flutter build appbundle --release
```

Çıktı: `build/app/outputs/bundle/release/app-release.aab`

---

### 6. 🎯 Target SDK Kontrolü

Play Store, güncel Android versiyonlarını desteklemenizi ister.

**Kontrol:**
```bash
flutter doctor -v
```

**Güncelleme gerekirse:**
- `android/app/build.gradle.kts` içinde `targetSdk` değerini kontrol edin
- Flutter'ı güncelleyin: `flutter upgrade`

---

### 7. 📸 Store Listing Hazırlığı

Play Store Console'da doldurmanız gerekenler:

**Zorunlu:**
- ✅ App adı (SmartStock)
- ✅ Kısa açıklama (80 karakter)
- ✅ Uzun açıklama (4000 karakter)
- ✅ App icon (512x512 PNG)
- ✅ Feature graphic (1024x500 PNG)
- ✅ En az 2 ekran görüntüsü (telefon)
- ✅ Kategori seçimi
- ✅ İçerik derecelendirmesi
- ✅ Privacy Policy URL

**Önerilen:**
- 📱 Tablet ekran görüntüleri
- 🎥 Promo video (YouTube)
- 🌍 Çeviriler (zaten TR/EN var)

**Açıklama örneği:**
```
SmartStock - Modern Stok Yönetim Uygulaması

Küçük ve orta ölçekli işletmeler, perakende mağazalar ve depolar için tasarlanmış güçlü bir envanter yönetim uygulaması.

Özellikler:
• Ürün yönetimi (ekle, düzenle, sil)
• Barkod/QR kod tarama
• Stok takibi ve geçmişi
• Kategori ve marka organizasyonu
• PDF ve Excel raporları
• Çevrimdışı çalışma
• Supabase bulut yedekleme
• Türkçe ve İngilizce dil desteği
• Modern Material 3 tasarım
• Karanlık/Aydınlık tema
```

---

### 8. 🧪 Test Checklist

Yayınlamadan önce test edin:

- [ ] Release build ile test (debug değil!)
- [ ] Tüm özellikler çalışıyor mu?
- [ ] Kamera izni doğru çalışıyor mu?
- [ ] Dosya seçme/paylaşma çalışıyor mu?
- [ ] Çevrimdışı mod çalışıyor mu?
- [ ] Supabase sync çalışıyor mu?
- [ ] Farklı cihazlarda test (farklı ekran boyutları)
- [ ] Farklı Android versiyonlarında test
- [ ] Crash olmuyor mu? (Crashlytics ekleyebilirsiniz)

---

### 9. 📊 Analytics & Crash Reporting (Opsiyonel ama önerilir)

**Firebase Crashlytics:**
```bash
flutter pub add firebase_crashlytics
```

**Firebase Analytics:**
```bash
flutter pub add firebase_analytics
```

---

### 10. 🔄 Güncelleme Stratejisi

**Version Code:** Her yayın için artırın (1, 2, 3, ...)  
**Version Name:** Kullanıcıya gösterilen versiyon (1.0.0, 1.0.1, ...)

`pubspec.yaml`:
```yaml
version: 1.0.0+1  # versionName+versionCode
```

---

## 📋 Son Kontrol Listesi

Yayınlamadan önce:

- [ ] Package name değiştirildi
- [ ] Keystore oluşturuldu ve yapılandırıldı
- [ ] Privacy Policy URL hazır
- [ ] Terms of Service URL hazır (opsiyonel ama önerilir)
- [ ] ProGuard kuralları eklendi
- [ ] Release build başarılı
- [ ] AAB dosyası oluşturuldu
- [ ] Store listing hazır
- [ ] Test edildi
- [ ] Google Play Console hesabı oluşturuldu ($25 tek seferlik ücret)

---

## 🚀 Yayınlama Adımları

1. **Google Play Console'a giriş yap:**
   https://play.google.com/console

2. **Yeni uygulama oluştur**

3. **Store listing doldur**

4. **Production track'e AAB yükle**

5. **İçerik derecelendirmesi tamamla**

6. **Privacy Policy URL ekle**

7. **İnceleme için gönder**

8. **Onay bekleyin (genellikle 1-3 gün)**

---

## ⚠️ Önemli Notlar

- **Keystore'u kaybetmeyin!** Kaybederseniz uygulamayı güncelleyemezsiniz.
- **Package name değiştirilemez!** İlk yayınlamadan önce doğru seçin.
- **İlk yayınlama ücreti:** $25 (tek seferlik, ömür boyu)
- **İnceleme süresi:** Genellikle 1-3 gün, bazen 7 güne kadar çıkabilir

---

## 📞 Yardım

Sorun yaşarsanız:
- [Flutter Documentation](https://flutter.dev/docs)
- [Google Play Console Help](https://support.google.com/googleplay/android-developer)
- [Android Developer Guide](https://developer.android.com/distribute/best-practices/launch)

---

**Başarılar! 🎉**

