import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/brand.dart';
import '../services/db_helper.dart';

class BrandProvider with ChangeNotifier {
  final DBHelper _db = DBHelper.instance;
  List<Brand> _brands = [];
  bool _isLoading = false;

  List<Brand> get brands => _brands;
  bool get isLoading => _isLoading;

  /// Hafızadaki verileri temizler (kullanıcı değişiminde çağrılır)
  void clearData() {
    _brands = [];
    notifyListeners();
  }

  String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;

  Future<void> loadBrands() async {
    _isLoading = true;
    notifyListeners();
    final userId = _currentUserId;
    // Sadece mevcut kullanıcının verilerini göster (user_id NULL olanları gösterme)
    final rows = await _db.query(
      'brands',
      where: userId != null
          ? 'user_id = ?'
          : '1 = 0', // Kullanıcı yoksa hiçbir şey gösterme
      whereArgs: userId != null ? [userId] : null,
      orderBy: 'name COLLATE NOCASE',
    );
    _brands = rows.map((r) => Brand.fromMap(r)).toList();
    _isLoading = false;
    notifyListeners();
  }

  Future<int> addBrand(Brand brand) async {
    final brandMap = brand.toMap();
    final userId = _currentUserId;
    if (userId != null) {
      final db = await _db.database;
      final tableInfo = await db.rawQuery('PRAGMA table_info(brands)');
      final columnNames = tableInfo.map((row) => row['name'] as String).toSet();
      if (columnNames.contains('user_id')) {
        brandMap['user_id'] = userId;
      }
    }
    final id = await _db.insert('brands', brandMap);
    await loadBrands();
    return id;
  }

  Future<int> updateBrand(Brand brand) async {
    final brandMap = brand.toMap();
    final userId = _currentUserId;
    if (userId == null) return 0;

    final db = await _db.database;
    final tableInfo = await db.rawQuery('PRAGMA table_info(brands)');
    final columnNames = tableInfo.map((row) => row['name'] as String).toSet();
    if (columnNames.contains('user_id')) {
      brandMap['user_id'] = userId;
    }
    final res = await _db.update('brands', brandMap, 'id = ? AND user_id = ?', [
      brand.id,
      userId,
    ]);
    await loadBrands();
    return res;
  }

  Future<int> deleteBrand(int id) async {
    final userId = _currentUserId;
    if (userId == null) return 0;

    // Check if brand is used in products
    final products = await _db.query(
      'products',
      where: 'brand_id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
    if (products.isNotEmpty) {
      throw Exception('Bu marka kullanılmakta olduğu için silinemez');
    }
    final res = await _db.delete('brands', 'id = ? AND user_id = ?', [
      id,
      userId,
    ]);
    await loadBrands();
    return res;
  }

  Brand? findById(int? id) {
    if (id == null) return null;
    try {
      return _brands.firstWhere((b) => b.id == id);
    } catch (e) {
      return null;
    }
  }
}
