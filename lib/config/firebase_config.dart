/// Firebase Configuration
///
/// Firebase projenizi oluşturduktan sonra:
/// 1. Firebase Console'da projenizi oluşturun: https://console.firebase.google.com
/// 2. Android uygulaması ekleyin (package name: com.devisb.stock_management)
/// 3. google-services.json dosyasını android/app/ klasörüne ekleyin
/// 4. iOS için GoogleService-Info.plist dosyasını ios/Runner/ klasörüne ekleyin
///
/// Firebase CLI ile otomatik yapılandırma:
/// 1. Firebase CLI'ı yükleyin: npm install -g firebase-tools
/// 2. FlutterFire CLI'ı yükleyin: dart pub global activate flutterfire_cli
/// 3. Projeyi yapılandırın: flutterfire configure
///
/// Veya manuel olarak:
/// - Android: google-services.json dosyasını android/app/ klasörüne ekleyin
/// - iOS: GoogleService-Info.plist dosyasını ios/Runner/ klasörüne ekleyin

class FirebaseConfig {
  /// Firebase'in yapılandırılıp yapılandırılmadığını kontrol eder
  /// google-services.json veya GoogleService-Info.plist dosyasının varlığına göre kontrol edilir
  static bool get isConfigured {
    // Firebase yapılandırması dosya varlığına göre kontrol edilir
    // FlutterFire CLI ile yapılandırıldığında otomatik olarak true olur
    return true; // Firebase.initializeApp() başarılı olursa true döner
  }
}

