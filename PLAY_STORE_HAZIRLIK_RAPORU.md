# 📊 Play Store Hazırlık Raporu

## ✅ Yapılan Düzeltmeler

### 1. AndroidManifest.xml İzinleri Eklendi ✅
Aşağıdaki izinler `AndroidManifest.xml` dosyasına eklendi:
- ✅ Kamera izni (barkod tarama için)
- ✅ Depolama izinleri (dosya işlemleri için)
- ✅ İnternet izni (Supabase sync için)
- ✅ Ağ durumu izni
- ✅ Kamera özellik bildirimleri

**Dosya:** `android/app/src/main/AndroidManifest.xml`

### 2. ProGuard Kuralları Dosyası Oluşturuldu ✅
Release build için ProGuard kuralları hazırlandı.

**Dosya:** `android/app/proguard-rules.pro`

### 3. Template Dosyalar Oluşturuldu ✅
- ✅ `android/key.properties.example` - Keystore yapılandırma şablonu
- ✅ `android/app/build.gradle.kts.example` - Production signing örneği
- ✅ `PLAY_STORE_CHECKLIST.md` - Detaylı kontrol listesi

---

## ⚠️ Yapılması Gerekenler

### 🔴 KRİTİK (Yayınlamadan Önce Zorunlu)

#### 1. Package Name Değiştirme
**Mevcut:** `com.devisb.stock_management` (güncellendi ✅)  
**Yapılacak:** Benzersiz bir package name seçin

**Örnekler:**
- `com.yourname.smartstock`
- `com.yourcompany.stockmanagement`
- `io.yourdomain.smartstock`

**Dosyalar:**
- `android/app/build.gradle.kts` (namespace ve applicationId)
- `android/app/src/main/kotlin/com/example/stock_management/MainActivity.kt` (dosya yolu ve package)

**⚠️ UYARI:** Package name değiştirdikten sonra uygulama verileri silinebilir!

---

#### 2. Production App Signing
Play Store'da yayınlamak için keystore oluşturmanız gerekiyor.

**Adımlar:**

1. **Keystore oluştur:**
   ```bash
   keytool -genkey -v -keystore android/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. **key.properties dosyası oluştur:**
   - `android/key.properties.example` dosyasını `android/key.properties` olarak kopyalayın
   - Şifreleri doldurun

3. **build.gradle.kts güncelle:**
   - `android/app/build.gradle.kts.example` dosyasındaki örnekleri kullanın
   - Keystore yapılandırmasını ekleyin

4. **.gitignore'a ekle:**
   ```
   android/key.properties
   android/upload-keystore.jks
   ```

**📖 Detaylı talimatlar:** `PLAY_STORE_CHECKLIST.md` dosyasına bakın.

---

#### 3. Privacy Policy URL
Play Store, özellikle kullanıcı verisi toplayan uygulamalar için Privacy Policy URL'i zorunlu kılar.

**Seçenekler:**
- GitHub Pages (ücretsiz)
- Google Sites (ücretsiz)
- Kendi web siteniz
- Hazır template'ler kullanın

**Privacy Policy'de olması gerekenler:**
- Hangi veriler toplanıyor
- Veriler nasıl saklanıyor (SQLite, Supabase)
- Veriler üçüncü taraflarla paylaşılıyor mu
- Kullanıcı hakları

**Uygulamaya ekleme:**
Settings ekranında Privacy Policy linkini ekleyin.

---

### 🟡 ÖNEMLİ (Önerilir)

#### 4. Terms of Service
Privacy Policy gibi Terms of Service URL'i de ekleyin.

#### 5. ProGuard Yapılandırması
`proguard-rules.pro` dosyası hazır, sadece `build.gradle.kts`'e eklemeniz gerekiyor.

#### 6. Store Listing Hazırlığı
- App açıklaması (TR ve EN)
- Ekran görüntüleri (en az 2 adet)
- Feature graphic (1024x500)
- App icon (512x512)
- Kategori seçimi
- İçerik derecelendirmesi

---

## 📋 Hızlı Kontrol Listesi

Yayınlamadan önce kontrol edin:

- [ ] Package name değiştirildi
- [ ] Keystore oluşturuldu
- [ ] key.properties dosyası hazır
- [ ] build.gradle.kts production signing ile yapılandırıldı
- [ ] Privacy Policy URL hazır
- [ ] ProGuard kuralları build.gradle.kts'e eklendi
- [ ] Release build test edildi
- [ ] AAB dosyası oluşturuldu (`flutter build appbundle --release`)
- [ ] Store listing hazır
- [ ] Google Play Console hesabı oluşturuldu

---

## 🚀 Sonraki Adımlar

1. **Package name değiştir** (en önemli!)
2. **Keystore oluştur ve yapılandır**
3. **Privacy Policy hazırla**
4. **Release build test et**
5. **AAB oluştur**
6. **Play Store Console'a yükle**

---

## 📚 Yardımcı Dosyalar

- **`PLAY_STORE_CHECKLIST.md`** - Detaylı adım adım rehber
- **`android/key.properties.example`** - Keystore yapılandırma şablonu
- **`android/app/build.gradle.kts.example`** - Production signing örneği
- **`android/app/proguard-rules.pro`** - ProGuard kuralları (hazır)

---

## ⚠️ Önemli Hatırlatmalar

1. **Keystore'u kaybetmeyin!** Kaybederseniz uygulamayı güncelleyemezsiniz.
2. **Package name değiştirilemez!** İlk yayınlamadan önce doğru seçin.
3. **İlk yayınlama ücreti:** $25 (tek seferlik)
4. **İnceleme süresi:** 1-3 gün (bazen 7 güne kadar)

---

**Sorularınız için:** `PLAY_STORE_CHECKLIST.md` dosyasına bakın veya Google Play Console dokümantasyonunu inceleyin.

**Başarılar! 🎉**

