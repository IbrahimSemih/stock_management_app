# Firebase SHA-1 Sertifika Hash'i Ekleme

## GoogleApiManager Hatası Çözümü

Bu hata, Android uygulamanızın SHA-1 sertifika hash'inin Firebase Console'a eklenmemesinden kaynaklanır.

## Adımlar

### 1. SHA-1 Hash'ini Alın

**Windows (PowerShell):**
```powershell
cd android
.\gradlew signingReport
```

Veya direkt keytool ile:
```powershell
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

**macOS/Linux:**
```bash
cd android
./gradlew signingReport
```

Veya:
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

### 2. SHA-1 Hash'ini Bulun

Çıktıda şu satırı arayın:
```
SHA1: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
```

### 3. Firebase Console'a Ekleyin

1. [Firebase Console](https://console.firebase.google.com/)'a gidin
2. Projenizi seçin
3. **Project Settings** (⚙️) > **Your apps** bölümüne gidin
4. Android uygulamanızı bulun (`com.devisb.stock_management`)
5. **Add fingerprint** butonuna tıklayın
6. SHA-1 hash'ini yapıştırın
7. **Save** butonuna tıklayın

### 4. google-services.json'u Yeniden İndirin

1. Firebase Console'da **Project Settings** > **Your apps**
2. Android uygulamanızın yanındaki **Download google-services.json** butonuna tıklayın
3. Dosyayı `android/app/` klasörüne kopyalayın (mevcut dosyanın üzerine yazın)

### 5. Uygulamayı Yeniden Derleyin

```bash
flutter clean
flutter pub get
flutter run
```

## Release Build için

Release build için de SHA-1 hash'ini eklemeniz gerekir:

```powershell
keytool -list -v -keystore "path/to/your/keystore.jks" -alias your-key-alias
```

Bu hash'i de Firebase Console'a ekleyin.

## Not

- Debug ve Release için farklı SHA-1 hash'leri olabilir
- Her ikisini de eklemeniz önerilir
- Hash ekledikten sonra birkaç dakika beklemeniz gerekebilir

