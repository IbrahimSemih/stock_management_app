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

  // Initialize Firebase (optional - wrapped in try-catch if Firebase won't be used)
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // Continue if Firebase is not configured
    debugPrint('Firebase initialization failed: $e');
  }

  runApp(const SmartStockApp());
}
