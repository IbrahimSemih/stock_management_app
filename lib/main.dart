import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase'i başlat (opsiyonel - Firebase kullanılmayacaksa try-catch ile sarmalayın)
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // Firebase yapılandırılmamışsa devam et
    debugPrint('Firebase başlatılamadı: $e');
  }

  runApp(const SmartStockApp());
}
