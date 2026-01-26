import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../config/firebase_config.dart';
import '../services/db_helper.dart';

class AuthProvider with ChangeNotifier {
  FirebaseAuth? _auth;
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isFirebaseInitialized = false;
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  bool get isFirebaseInitialized => _isFirebaseInitialized;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    // Firebase'in başlatılıp başlatılmadığını kontrol et
    try {
      if (FirebaseConfig.isConfigured) {
        _auth = FirebaseAuth.instance;
        _isFirebaseInitialized = true;

        // Auth state değişikliklerini dinle
        _auth!.authStateChanges().listen((User? user) async {
          final oldUserId = _user?.uid;
          final newUserId = user?.uid;
          _user = user;
          
          // Kullanıcı değiştiğinde (logout veya farklı hesap girişi) tüm eski verileri temizle
          if (oldUserId != null && newUserId != oldUserId) {
            // Eski kullanıcının verilerini temizle
            await _clearOldUserData(oldUserId);
            // user_id NULL olan tüm verileri de temizle
            await _clearOldUserData(null);
            debugPrint('User changed: cleared data for oldUserId: $oldUserId and NULL user_id');
          } else if (oldUserId != null && newUserId == null) {
            // Logout yapıldı - eski kullanıcının verilerini ve NULL verileri temizle
            await _clearOldUserData(oldUserId);
            await _clearOldUserData(null);
            debugPrint('User logged out: cleared data for userId: $oldUserId and NULL user_id');
          } else if (oldUserId == null && newUserId != null) {
            // Yeni kullanıcı giriş yaptı - NULL verileri temizle
            await _clearOldUserData(null);
            debugPrint('New user logged in: cleared NULL user_id data');
          }
          
          notifyListeners();
        });

        // Mevcut oturumu kontrol et
        _user = _auth!.currentUser;
      }
    } catch (e) {
      // Firebase başlatılmamış, offline mod kullanılacak
      _isFirebaseInitialized = false;
      debugPrint('Firebase not initialized: $e');
    }

  }

  /// Eski kullanıcının verilerini temizler
  Future<void> _clearOldUserData(String? userId) async {
    try {
      final dbHelper = DBHelper.instance;
      await dbHelper.clearUserData(userId);
      debugPrint('Old user data cleared for userId: $userId');
    } catch (e) {
      debugPrint('Error clearing old user data: $e');
    }
  }

  Future<bool> signInWithEmailPassword(String email, String password) async {
    if (!_isFirebaseInitialized || _auth == null) {
      _errorMessage = 'firebase_not_initialized';
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Önce eski kullanıcının verilerini temizle
      final oldUserId = _user?.uid;
      if (oldUserId != null) {
        final dbHelper = DBHelper.instance;
        await dbHelper.clearUserData(oldUserId);
        debugPrint('Old user data cleared before sign in for userId: $oldUserId');
      }
      
      // user_id NULL olan tüm verileri de temizle
      final dbHelper = DBHelper.instance;
      await dbHelper.clearUserData(null);
      debugPrint('All NULL user_id data cleared before sign in');

      final userCredential = await _auth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _user = userCredential.user;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.keyIsLoggedIn, true);
      await prefs.setString(AppConstants.keyUserEmail, email);

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getErrorKey(e.code, e.message ?? '');
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'error_generic';
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
      _errorMessage = 'firebase_not_initialized';
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Önce eski kullanıcının verilerini temizle
      final oldUserId = _user?.uid;
      if (oldUserId != null) {
        final dbHelper = DBHelper.instance;
        await dbHelper.clearUserData(oldUserId);
        debugPrint('Old user data cleared before register for userId: $oldUserId');
      }
      
      // user_id NULL olan tüm verileri de temizle
      final dbHelper = DBHelper.instance;
      await dbHelper.clearUserData(null);
      debugPrint('All NULL user_id data cleared before register');

      final userCredential = await _auth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Display name'i güncelle
      if (userCredential.user != null && displayName.isNotEmpty) {
        await userCredential.user!.updateDisplayName(displayName);
        await userCredential.user!.reload();
        _user = _auth!.currentUser;
      } else {
        _user = userCredential.user;
      }
      
      // Email verification gönder (isteğe bağlı)
      if (_user != null && !_user!.emailVerified) {
        await _user!.sendEmailVerification();
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.keyIsLoggedIn, true);
      await prefs.setString(AppConstants.keyUserEmail, email);

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getErrorKey(e.code, e.message ?? '');
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'error_generic';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      final userId = _user?.uid;
      
      if (_isFirebaseInitialized && _auth != null) {
        await _auth!.signOut();
      }
      
      // Kullanıcı çıkış yaptığında tüm yerel verileri temizle
      final dbHelper = DBHelper.instance;
      if (userId != null) {
        await dbHelper.clearUserData(userId);
        debugPrint('User data cleared on sign out for userId: $userId');
      }
      // user_id NULL olan tüm verileri de temizle
      await dbHelper.clearUserData(null);
      debugPrint('All NULL user_id data cleared on sign out');
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.keyIsLoggedIn, false);
      await prefs.remove(AppConstants.keyUserEmail);
      _user = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'error_logout';
      notifyListeners();
    }
  }

  Future<bool> resetPassword(String email) async {
    if (!_isFirebaseInitialized || _auth == null) {
      _errorMessage = 'firebase_not_initialized_password';
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Şifre sıfırlama e-postası gönder
      await _auth!.sendPasswordResetEmail(email: email);

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('Password reset error: ${e.code} - ${e.message}');
      _errorMessage = _getErrorKey(e.code, e.message ?? '');
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('Password reset generic error: $e');
      _errorMessage = 'error_generic';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  String _getErrorKey(String code, String message) {
    final lowerCode = code.toLowerCase();
    final lowerMessage = message.toLowerCase();

    // Firebase Auth error codes
    if (lowerCode == 'weak-password' || 
        (lowerMessage.contains('password') && lowerMessage.contains('weak'))) {
      return 'error_weak_password';
    }
    if (lowerCode == 'email-already-in-use' || 
        (lowerMessage.contains('email') && lowerMessage.contains('already'))) {
      return 'error_email_in_use';
    }
    if (lowerCode == 'user-not-found' || 
        (lowerMessage.contains('user') && lowerMessage.contains('not found'))) {
      return 'error_user_not_found';
    }
    if (lowerCode == 'wrong-password' || 
        lowerCode == 'invalid-credential' ||
        (lowerMessage.contains('invalid') && lowerMessage.contains('credentials'))) {
      return 'error_wrong_password';
    }
    if (lowerCode == 'invalid-email' || 
        (lowerMessage.contains('invalid') && lowerMessage.contains('email'))) {
      return 'error_invalid_email';
    }
    if (lowerCode == 'user-disabled') {
      return 'error_user_disabled';
    }
    if (lowerCode == 'too-many-requests' || 
        (lowerMessage.contains('too many') || lowerMessage.contains('rate limit'))) {
      return 'error_too_many_requests';
    }
    if (lowerCode == 'operation-not-allowed') {
      return 'error_operation_not_allowed';
    }
    // Şifre sıfırlama için özel hatalar
    if (lowerCode == 'invalid-email' || lowerCode == 'missing-email') {
      return 'error_invalid_email';
    }

    return 'error_generic';
  }

  Future<bool> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.keyIsLoggedIn) ?? false;
  }

  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    if (!_isFirebaseInitialized || _auth == null || _user == null) {
      _errorMessage = 'firebase_not_initialized';
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Firebase'de şifre değiştirme için önce mevcut şifre ile yeniden kimlik doğrulama yapılmalı
      final credential = EmailAuthProvider.credential(
        email: _user!.email!,
        password: currentPassword,
      );
      
      await _user!.reauthenticateWithCredential(credential);
      await _user!.updatePassword(newPassword);

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getErrorKey(e.code, e.message ?? '');
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'error_generic';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAccount(String password) async {
    if (!_isFirebaseInitialized || _auth == null || _user == null) {
      _errorMessage = 'firebase_not_initialized';
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Firebase'de hesap silme için önce şifre ile yeniden kimlik doğrulama yapılmalı
      final credential = EmailAuthProvider.credential(
        email: _user!.email!,
        password: password,
      );
      
      await _user!.reauthenticateWithCredential(credential);
      await _user!.delete();

      // Clear local data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.keyIsLoggedIn, false);
      await prefs.remove(AppConstants.keyUserEmail);
      _user = null;

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getErrorKey(e.code, e.message ?? '');
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'error_generic';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendEmailVerification() async {
    if (!_isFirebaseInitialized || _auth == null || _user == null) {
      _errorMessage = 'firebase_not_initialized';
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Firebase'de email doğrulama linki gönder
      await _user!.sendEmailVerification();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'error_generic';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
