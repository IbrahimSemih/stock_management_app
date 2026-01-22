import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/sync_service.dart';
import '../utils/constants.dart';
import '../models/product.dart';
import '../models/category.dart' as models;
import '../models/brand.dart';
import '../models/stock_history.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Senkronizasyon durumunu yöneten provider
class SyncProvider with ChangeNotifier {
  final SyncService _syncService = SyncService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isSyncEnabled = false;
  bool _isSyncing = false;
  String? _syncError;
  DateTime? _lastSyncTime;

  bool get isSyncEnabled => _isSyncEnabled;
  bool get isSyncing => _isSyncing;
  String? get syncError => _syncError;
  DateTime? get lastSyncTime => _lastSyncTime;
  bool get canSync => _auth.currentUser != null && _isSyncEnabled;

  SyncProvider() {
    _loadSyncSettings();
  }

  /// Senkronizasyon ayarlarını yükler
  Future<void> _loadSyncSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isSyncEnabled = prefs.getBool(AppConstants.keySyncEnabled) ?? false;
      
      // Son senkronizasyon zamanını yükle
      if (_isSyncEnabled) {
        _lastSyncTime = await _syncService.getLastSyncTime();
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading sync settings: $e');
    }
  }

  /// Senkronizasyonu aç/kapat
  Future<bool> toggleSync(bool enabled) async {
    try {
      if (enabled && _auth.currentUser == null) {
        _syncError = 'Lütfen önce giriş yapın';
        notifyListeners();
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.keySyncEnabled, enabled);
      _isSyncEnabled = enabled;

      if (enabled) {
        // Senkronizasyon açıldığında ilk senkronizasyonu yap
        _lastSyncTime = await _syncService.getLastSyncTime();
      } else {
        // Senkronizasyon kapatıldığında son senkronizasyon zamanını temizle
        _lastSyncTime = null;
      }

      _syncError = null;
      notifyListeners();
      return true;
    } catch (e) {
      _syncError = 'Ayarlar kaydedilirken hata oluştu: $e';
      notifyListeners();
      return false;
    }
  }

  /// Tüm verileri buluta yükler
  Future<bool> syncToCloud({
    required List<Product> products,
    required List<models.Category> categories,
    required List<Brand> brands,
    required List<StockHistory> stockHistory,
  }) async {
    if (!canSync) {
      _syncError = 'Senkronizasyon etkin değil veya kullanıcı giriş yapmamış';
      notifyListeners();
      return false;
    }

    try {
      _isSyncing = true;
      _syncError = null;
      notifyListeners();

      await _syncService.syncAllToCloud(
        products: products,
        categories: categories,
        brands: brands,
        stockHistory: stockHistory,
      );

      _lastSyncTime = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        AppConstants.keyLastSyncTime,
        _lastSyncTime!.toIso8601String(),
      );

      _isSyncing = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isSyncing = false;
      _syncError = 'Senkronizasyon hatası: $e';
      notifyListeners();
      return false;
    }
  }

  /// Tek bir ürünü buluta yükler
  Future<bool> syncProductToCloud(Product product) async {
    if (!canSync) return false;

    try {
      await _syncService.syncProductToCloud(product);
      _lastSyncTime = DateTime.now();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error syncing product: $e');
      return false;
    }
  }

  /// Buluttan bir ürünü siler
  Future<bool> deleteProductFromCloud(int productId) async {
    if (!canSync) return false;

    try {
      await _syncService.deleteProductFromCloud(productId);
      return true;
    } catch (e) {
      debugPrint('Error deleting product from cloud: $e');
      return false;
    }
  }

  /// Son senkronizasyon zamanını günceller
  Future<void> updateLastSyncTime() async {
    if (!canSync) return;

    try {
      _lastSyncTime = await _syncService.getLastSyncTime();
      if (_lastSyncTime != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          AppConstants.keyLastSyncTime,
          _lastSyncTime!.toIso8601String(),
        );
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating last sync time: $e');
    }
  }

  /// Kullanıcı değiştiğinde çağrılır
  void onUserChanged() {
    if (_auth.currentUser == null) {
      // Kullanıcı çıkış yaptıysa senkronizasyonu kapat
      _isSyncEnabled = false;
      _lastSyncTime = null;
    } else {
      // Kullanıcı giriş yaptıysa ayarları yükle
      _loadSyncSettings();
    }
    notifyListeners();
  }
}

