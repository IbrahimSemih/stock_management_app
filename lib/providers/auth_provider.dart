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
      _errorMessage = 'firebase_not_initialized';
      notifyListeners();
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
      _errorMessage = _getErrorKey(e.code);
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
      _errorMessage = _getErrorKey(e.code);
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
      _errorMessage = 'error_generic';
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

      await _auth!.sendPasswordResetEmail(email: email);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getErrorKey(e.code);
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

  String _getErrorKey(String code) {
    switch (code) {
      case 'weak-password':
        return 'error_weak_password';
      case 'email-already-in-use':
        return 'error_email_in_use';
      case 'user-not-found':
        return 'error_user_not_found';
      case 'wrong-password':
        return 'error_wrong_password';
      case 'invalid-email':
        return 'error_invalid_email';
      case 'user-disabled':
        return 'error_user_disabled';
      case 'too-many-requests':
        return 'error_too_many_requests';
      case 'operation-not-allowed':
        return 'error_operation_not_allowed';
      default:
        return 'error_generic';
    }
  }

  Future<bool> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.keyIsLoggedIn) ?? false;
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    if (!_isFirebaseInitialized || _auth == null || _user == null) {
      _errorMessage = 'firebase_not_initialized';
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Re-authenticate user with current password
      final credential = EmailAuthProvider.credential(
        email: _user!.email!,
        password: currentPassword,
      );
      await _user!.reauthenticateWithCredential(credential);

      // Update password
      await _user!.updatePassword(newPassword);

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getErrorKey(e.code);
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

      // Re-authenticate user before deletion
      final credential = EmailAuthProvider.credential(
        email: _user!.email!,
        password: password,
      );
      await _user!.reauthenticateWithCredential(credential);

      // Delete user account
      await _user!.delete();

      // Clear local data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.keyIsLoggedIn, false);
      await prefs.remove(AppConstants.keyUserEmail);
      _user = null;
      _isOfflineMode = false;

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getErrorKey(e.code);
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

