import 'package:flutter/material.dart';
import '../models/brand.dart';
import '../services/db_helper.dart';

class BrandProvider with ChangeNotifier {
  final DBHelper _db = DBHelper.instance;
  List<Brand> _brands = [];
  bool _isLoading = false;

  List<Brand> get brands => _brands;
  bool get isLoading => _isLoading;

  Future<void> loadBrands() async {
    _isLoading = true;
    notifyListeners();
    final rows = await _db.query('brands', orderBy: 'name COLLATE NOCASE');
    _brands = rows.map((r) => Brand.fromMap(r)).toList();
    _isLoading = false;
    notifyListeners();
  }

  Future<int> addBrand(Brand brand) async {
    final id = await _db.insert('brands', brand.toMap());
    await loadBrands();
    return id;
  }

  Future<int> updateBrand(Brand brand) async {
    final res = await _db.update(
      'brands',
      brand.toMap(),
      'id = ?',
      [brand.id],
    );
    await loadBrands();
    return res;
  }

  Future<int> deleteBrand(int id) async {
    // Check if brand is used in products
    final products = await _db.query(
      'products',
      where: 'brand_id = ?',
      whereArgs: [id],
    );
    if (products.isNotEmpty) {
      throw Exception('Bu marka kullanılmakta olduğu için silinemez');
    }
    final res = await _db.delete('brands', 'id = ?', [id]);
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

