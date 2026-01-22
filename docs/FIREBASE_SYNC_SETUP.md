# Firebase Senkronizasyon Kurulumu

## Genel Bakış

SmartStock uygulaması, isteğe bağlı Firebase Firestore senkronizasyonu özelliği sunar. Bu özellik sayesinde:

- Verileriniz Firebase'de yedeklenir
- Çoklu cihaz senkronizasyonu yapabilirsiniz
- Cihaz kaybında verileriniz korunur

## Özellikler

### ✅ Tamamlanan Özellikler

1. **SyncService**: Firebase Firestore ile veri senkronizasyonu servisi
2. **SyncProvider**: Senkronizasyon durumu yönetimi
3. **Ayarlar Ekranı**: Senkronizasyon açma/kapama toggle'ı
4. **Manuel Senkronizasyon**: "Şimdi Senkronize Et" butonu
5. **Otomatik Senkronizasyon**: Ürün ekleme/güncelleme/silme işlemlerinde otomatik sync

### 📋 Senkronize Edilen Veriler

- ✅ Ürünler (Products)
- ✅ Kategoriler (Categories)
- ✅ Markalar (Brands)
- ✅ Stok Geçmişi (Stock History)

## Kullanım

### 1. Senkronizasyonu Aktif Etme

1. Uygulamaya Firebase Authentication ile giriş yapın
2. Ayarlar ekranına gidin
3. "Bulut Senkronizasyonu" toggle'ını açın
4. İlk senkronizasyon otomatik olarak başlar

### 2. Manuel Senkronizasyon

1. Ayarlar > Senkronizasyon bölümüne gidin
2. "Şimdi Senkronize Et" butonuna tıklayın
3. Senkronizasyon tamamlanana kadar bekleyin

### 3. Otomatik Senkronizasyon

Senkronizasyon açıkken:
- Yeni ürün eklendiğinde otomatik sync yapılır
- Ürün güncellendiğinde otomatik sync yapılır
- Ürün silindiğinde buluttan da silinir

## Teknik Detaylar

### Veri Yapısı

Firestore'da veriler şu yapıda saklanır:

```
users/
  └── {userId}/ (document)
      ├── products/ (subcollection)
      │   └── {productId}/ (document)
      ├── categories/ (subcollection)
      │   └── {categoryId}/ (document)
      ├── brands/ (subcollection)
      │   └── {brandId}/ (document)
      ├── stock_history/ (subcollection)
      │   └── {historyId}/ (document)
      └── data/ (subcollection)
          └── metadata/ (document)
              └── lastSyncTime
```

### Güvenlik Kuralları

Firebase Console'da şu güvenlik kurallarını ayarlayın:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Kullanıcılar sadece kendi verilerine erişebilir
    match /users/{userId} {
      // Kullanıcı dokümanı
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Subcollection'lar (products, categories, brands, stock_history, data)
      match /{collection}/{document=**} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

**Önemli:** Bu kurallar, kullanıcıların sadece kendi verilerine erişmesini sağlar. Başka kullanıcıların verilerine erişim engellenir.

### Maliyet

Firebase Firestore ücretsiz kotası:
- **Okuma**: 50,000/gün
- **Yazma**: 20,000/gün
- **Silme**: 20,000/gün

Küçük-orta ölçekli işletmeler için yeterlidir.

## Provider Entegrasyonu

### ProductProvider'a Otomatik Sync Ekleme

`lib/providers/product_provider.dart` dosyasında:

```dart
import '../providers/sync_provider.dart';

// addProduct metodunda:
final syncProvider = context.read<SyncProvider>();
if (syncProvider.canSync) {
  await syncProvider.syncProductToCloud(product);
}

// updateProduct metodunda:
if (syncProvider.canSync) {
  await syncProvider.syncProductToCloud(product);
}

// deleteProduct metodunda:
if (syncProvider.canSync) {
  await syncProvider.deleteProductFromCloud(productId);
}
```

## Sorun Giderme

### Senkronizasyon Çalışmıyor

1. Firebase Authentication ile giriş yaptığınızdan emin olun
2. İnternet bağlantınızı kontrol edin
3. Firebase Console'da Firestore'u aktif ettiğinizden emin olun
4. Güvenlik kurallarını kontrol edin

### Veri Çakışması

Şu anki implementasyonda:
- **Yerel veriler önceliklidir**
- Buluttan indirme özelliği henüz eklenmedi
- Çakışma çözümleme stratejisi: "Son yazma kazanır"

## Gelecek Geliştirmeler

- [ ] Buluttan veri indirme
- [ ] Çakışma çözümleme UI'ı
- [ ] Arka plan senkronizasyonu
- [ ] Çevrimdışı değişiklik kuyruğu
- [ ] Çoklu cihaz çakışma yönetimi

## Notlar

- Senkronizasyon tamamen isteğe bağlıdır
- Veriler yalnızca cihazda da saklanmaya devam eder
- Senkronizasyon kapalıyken uygulama normal çalışır
- Gizlilik politikası güncellenmelidir (Firebase'de veri saklama eklendi)

