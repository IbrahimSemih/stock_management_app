# 📄 GitHub Pages Kurulum Rehberi

Bu rehber, Privacy Policy ve Terms of Service sayfalarını GitHub Pages'de yayınlamanız için adım adım talimatlar içerir.

## 🚀 Hızlı Kurulum (5 Dakika)

### Adım 1: GitHub Repository Oluşturun

1. GitHub'da yeni bir repository oluşturun:
   - Repository adı: `smartstock-privacy` (veya istediğiniz bir isim)
   - Public olarak oluşturun (GitHub Pages ücretsiz sadece public repo'larda çalışır)
   - README eklemeyin (boş repo oluşturun)

### Adım 2: Dosyaları Yükleyin

1. Bu klasördeki (`docs/`) HTML dosyalarını repository'ye yükleyin:
   - `privacy-policy.html`
   - `terms-of-service.html`

2. **Önemli:** Dosyaları repository'nin **root** dizinine koyun (klasör içine değil)

### Adım 3: GitHub Pages'i Aktifleştirin

1. Repository'nizde **Settings** sekmesine gidin
2. Sol menüden **Pages** seçeneğine tıklayın
3. **Source** bölümünden:
   - Branch: `main` (veya `master`)
   - Folder: `/ (root)`
   - **Save** butonuna tıklayın

### Adım 4: URL'inizi Alın

Birkaç dakika sonra sayfalarınız hazır olacak. URL formatı:
```
https://[kullanıcı-adınız].github.io/smartstock-privacy/privacy-policy.html
https://[kullanıcı-adınız].github.io/smartstock-privacy/terms-of-service.html
```

**Örnek:**
- Kullanıcı adı: `ibrahimsemih`
- Privacy Policy: `https://ibrahimsemih.github.io/smartstock-privacy/privacy-policy.html`
- Terms of Service: `https://ibrahimsemih.github.io/smartstock-privacy/terms-of-service.html`

---

## 📝 Uygulamadaki URL'leri Güncelleyin

`lib/utils/constants.dart` dosyasında URL'leri güncelleyin:

```dart
static const String privacyPolicyUrl = 'https://[kullanıcı-adınız].github.io/smartstock-privacy/privacy-policy.html';
static const String termsOfServiceUrl = 'https://[kullanıcı-adınız].github.io/smartstock-privacy/terms-of-service.html';
```

---

## 🔧 Alternatif: Custom Domain (Opsiyonel)

Eğer kendi domain'iniz varsa:

1. GitHub Pages'de custom domain ayarlayın
2. DNS kayıtlarınızı yapılandırın
3. URL'leri güncelleyin

---

## ✅ Kontrol Listesi

- [ ] GitHub repository oluşturuldu
- [ ] HTML dosyaları yüklendi
- [ ] GitHub Pages aktifleştirildi
- [ ] URL'ler test edildi (tarayıcıda açıldı)
- [ ] `constants.dart` dosyasındaki URL'ler güncellendi
- [ ] Uygulamada linkler test edildi

---

## 🆘 Sorun Giderme

### Sayfalar görünmüyor?
- Birkaç dakika bekleyin (GitHub Pages ilk kez yayınlarken 1-5 dakika sürebilir)
- Repository'nin public olduğundan emin olun
- Settings > Pages'de doğru branch seçildiğini kontrol edin

### 404 Hatası?
- Dosya isimlerinin doğru olduğundan emin olun
- Dosyaların root dizinde olduğunu kontrol edin
- URL'deki büyük/küçük harfleri kontrol edin

### HTTPS çalışmıyor?
- GitHub Pages otomatik olarak HTTPS sağlar
- Birkaç dakika bekleyin, otomatik olarak aktif olacaktır

---

## 📚 Daha Fazla Bilgi

- [GitHub Pages Documentation](https://docs.github.com/en/pages)
- [Custom Domain Setup](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site)

---

**Başarılar! 🎉**

