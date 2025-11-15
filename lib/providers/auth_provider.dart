import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class AuthProvider with ChangeNotifier {
  FirebaseAuth? _auth;
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isFirebaseInitialized = false;
  bool _isOfflineMode = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null || _isOfflineMode;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    // Firebase'in başlatılıp başlatılmadığını kontrol et
    try {
      if (Firebase.apps.isNotEmpty) {
        _auth = FirebaseAuth.instance;
        _isFirebaseInitialized = true;
        _auth!.authStateChanges().listen((User? user) {
          _user = user;
          notifyListeners();
        });
      }
    } catch (e) {
      // Firebase başlatılmamış, offline mod kullanılacak
      _isFirebaseInitialized = false;
    }
    
    // SharedPreferences'tan offline kullanım durumunu kontrol et
    final prefs = await SharedPreferences.getInstance();
    _isOfflineMode = prefs.getBool(AppConstants.keyIsLoggedIn) ?? false;
    if (_isOfflineMode && _user == null) {
      // Offline mod aktif
      notifyListeners();
    }
  }

  Future<bool> signInWithEmailPassword(String email, String password) async {
    if (!_isFirebaseInitialized || _auth == null) {
      _errorMessage = 'Firebase başlatılmamış. Lütfen offline kullan seçeneğini kullanın.';
      return false;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final userCredential = await _auth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;
      _isOfflineMode = false; // Firebase ile giriş yapıldığında offline mod kapatılır
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.keyIsLoggedIn, true);
      await prefs.setString(AppConstants.keyUserEmail, email);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Bir hata oluştu: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerWithEmailPassword(
    String email,
    String password,
    String displayName,
  ) async {
    if (!_isFirebaseInitialized || _auth == null) {
      _errorMessage = 'Firebase başlatılmamış. Lütfen offline kullan seçeneğini kullanın.';
      return false;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final userCredential = await _auth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      await userCredential.user?.updateDisplayName(displayName);
      _user = userCredential.user;
      _isOfflineMode = false; // Firebase ile giriş yapıldığında offline mod kapatılır
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.keyIsLoggedIn, true);
      await prefs.setString(AppConstants.keyUserEmail, email);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Bir hata oluştu: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInOffline() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.keyIsLoggedIn, true);
      await prefs.setString(AppConstants.keyUserEmail, 'offline@user.com');
      
      _isOfflineMode = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Bir hata oluştu: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      if (_isFirebaseInitialized && _auth != null) {
        await _auth!.signOut();
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.keyIsLoggedIn, false);
      await prefs.remove(AppConstants.keyUserEmail);
      _user = null;
      _isOfflineMode = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Çıkış yapılırken hata oluştu: $e';
      notifyListeners();
    }
  }

  Future<bool> resetPassword(String email) async {
    if (!_isFirebaseInitialized || _auth == null) {
      _errorMessage = 'Firebase başlatılmamış. Şifre sıfırlama özelliği kullanılamaz.';
      return false;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _auth!.sendPasswordResetEmail(email: email);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Bir hata oluştu: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'Şifre çok zayıf';
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten kullanılıyor';
      case 'user-not-found':
        return 'Kullanıcı bulunamadı';
      case 'wrong-password':
        return 'Yanlış şifre';
      case 'invalid-email':
        return 'Geçersiz e-posta adresi';
      case 'user-disabled':
        return 'Kullanıcı devre dışı bırakılmış';
      case 'too-many-requests':
        return 'Çok fazla istek. Lütfen daha sonra tekrar deneyin';
      case 'operation-not-allowed':
        return 'Bu işlem izin verilmiyor';
      default:
        return 'Bir hata oluştu: $code';
    }
  }

  Future<bool> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.keyIsLoggedIn) ?? false;
  }
}

