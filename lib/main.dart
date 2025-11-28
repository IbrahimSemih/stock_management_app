import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Status bar stilini ayarla
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // Edge-to-edge modu etkinleştir
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
  );

  // Firebase'i başlat (opsiyonel - Firebase kullanılmayacaksa try-catch ile sarmalayın)
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // Firebase yapılandırılmamışsa devam et
    debugPrint('Firebase başlatılamadı: $e');
  }

  runApp(const SmartStockApp());
}
