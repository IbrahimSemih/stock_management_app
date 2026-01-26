import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart';
import '../models/stock_history.dart';
import '../services/db_helper.dart';

class ProductProvider with ChangeNotifier {
  final DBHelper _db = DBHelper.instance;
  List<Product> _products = [];
  bool _isLoading = false;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;

  /// Hafızadaki verileri temizler (kullanıcı değişiminde çağrılır)
  void clearData() {
    _products = [];
    notifyListeners();
  }

  String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;

  Future<void> loadAllProducts() async {
    _isLoading = true;
    notifyListeners();

    final userId = _currentUserId;
    // Sadece mevcut kullanıcının verilerini göster (user_id NULL olanları gösterme)
    final rows = await _db.query(
      'products',
      where: userId != null
          ? 'user_id = ?'
          : '1 = 0', // Kullanıcı yoksa hiçbir şey gösterme
      whereArgs: userId != null ? [userId] : null,
      orderBy: 'name COLLATE NOCASE',
    );
    _products = rows.map((r) => Product.fromMap(r)).toList();
    _isLoading = false;
    notifyListeners();
  }

  Future<int> addProduct(Product product) async {
    try {
      final productMap = product.toMap();

      // Veritabanındaki kolonları kontrol et ve sadece mevcut kolonları kullan
      final db = await _db.database;
      final tableInfo = await db.rawQuery('PRAGMA table_info(products)');
      final columnNames = tableInfo.map((row) => row['name'] as String).toSet();

      // Sadece mevcut kolonları içeren bir map oluştur
      final safeMap = <String, dynamic>{};
      for (var entry in productMap.entries) {
        if (columnNames.contains(entry.key)) {
          safeMap[entry.key] = entry.value;
        }
      }

      // user_id ekle
      final userId = _currentUserId;
      if (userId != null && columnNames.contains('user_id')) {
        safeMap['user_id'] = userId;
      }

      final id = await _db.insert('products', safeMap);
      // create initial stock history if stock > 0
      if (product.stock > 0) {
        final hist = StockHistory(
          productId: id,
          type: 'IN',
          amount: product.stock,
          date: product.createdAt,
          note: 'Initial stock',
        );
        final histMap = hist.toMap();
        if (userId != null) {
          final histTableInfo = await db.rawQuery(
            'PRAGMA table_info(stock_history)',
          );
          final histColumnNames = histTableInfo
              .map((row) => row['name'] as String)
              .toSet();
          if (histColumnNames.contains('user_id')) {
            histMap['user_id'] = userId;
          }
        }
        await _db.insert('stock_history', histMap);
      }
      await loadAllProducts();
      return id;
    } catch (e) {
      debugPrint('addProduct error: $e');
      rethrow;
    }
  }

  Future<int> updateProduct(Product product) async {
    try {
      final updatedAt = DateTime.now().toIso8601String();
      product.updatedAt = updatedAt;

      final productMap = product.toMap();

      // Veritabanındaki kolonları kontrol et ve sadece mevcut kolonları kullan
      final db = await _db.database;
      final tableInfo = await db.rawQuery('PRAGMA table_info(products)');
      final columnNames = tableInfo.map((row) => row['name'] as String).toSet();

      // Sadece mevcut kolonları içeren bir map oluştur
      final safeMap = <String, dynamic>{};
      for (var entry in productMap.entries) {
        if (entry.key == 'id') continue; // id'yi dahil etme
        if (columnNames.contains(entry.key)) {
          safeMap[entry.key] = entry.value;
        }
      }

      final res = await _db.update('products', safeMap, 'id = ?', [product.id]);
      await loadAllProducts();
      return res;
    } catch (e) {
      debugPrint('updateProduct error: $e');
      rethrow;
    }
  }

  Future<int> deleteProduct(int id) async {
    final userId = _currentUserId;
    if (userId == null) return 0;

    // delete histories first to maintain referential cleanliness
    await _db.delete('stock_history', 'product_id = ? AND user_id = ?', [
      id,
      userId,
    ]);
    final res = await _db.delete('products', 'id = ? AND user_id = ?', [
      id,
      userId,
    ]);
    await loadAllProducts();
    return res;
  }

  Future<void> changeStock(
    int productId,
    int amount,
    String type, {
    String? note,
  }) async {
    // type: "IN" or "OUT"
    final now = DateTime.now().toIso8601String();
    final userId = _currentUserId;
    final productRows = await _db.query(
      'products',
      where: userId != null ? 'id = ? AND user_id = ?' : '1 = 0',
      whereArgs: userId != null ? [productId, userId] : null,
    );
    if (productRows.isEmpty) return;
    final product = Product.fromMap(productRows.first);
    final newStock = type == 'IN'
        ? product.stock + amount
        : product.stock - amount;
    await _db.update(
      'products',
      {'stock': newStock, 'updated_at': now},
      'id = ?',
      [productId],
    );

    final hist = StockHistory(
      productId: productId,
      type: type,
      amount: amount,
      date: now,
      note: note,
    );
    final histMap = hist.toMap();
    if (userId != null) {
      final db = await _db.database;
      final histTableInfo = await db.rawQuery(
        'PRAGMA table_info(stock_history)',
      );
      final histColumnNames = histTableInfo
          .map((row) => row['name'] as String)
          .toSet();
      if (histColumnNames.contains('user_id')) {
        histMap['user_id'] = userId;
      }
    }
    await _db.insert('stock_history', histMap);
    await loadAllProducts();
  }

  Product? findById(int? id) {
    if (id == null) return null;
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}
