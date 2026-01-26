import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/db_helper.dart';
import '../models/category.dart';

class CategoryProvider with ChangeNotifier {
  final DBHelper _db = DBHelper.instance;
  List<Category> _categories = [];

  List<Category> get categories => _categories;

  /// Hafızadaki verileri temizler (kullanıcı değişiminde çağrılır)
  void clearData() {
    _categories = [];
    notifyListeners();
  }

  String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;

  Future<void> loadCategories() async {
    final userId = _currentUserId;
    // Sadece mevcut kullanıcının verilerini göster (user_id NULL olanları gösterme)
    final rows = await _db.query(
      'categories',
      where: userId != null
          ? 'user_id = ?'
          : '1 = 0', // Kullanıcı yoksa hiçbir şey gösterme
      whereArgs: userId != null ? [userId] : null,
      orderBy: 'name COLLATE NOCASE',
    );
    _categories = rows.map((r) => Category.fromMap(r)).toList();
    notifyListeners();
  }

  Future<int> addCategory(Category c) async {
    final categoryMap = c.toMap();
    final userId = _currentUserId;
    if (userId != null) {
      final db = await _db.database;
      final tableInfo = await db.rawQuery('PRAGMA table_info(categories)');
      final columnNames = tableInfo.map((row) => row['name'] as String).toSet();
      if (columnNames.contains('user_id')) {
        categoryMap['user_id'] = userId;
      }
    }
    final id = await _db.insert('categories', categoryMap);
    await loadCategories();
    return id;
  }

  Future<int> updateCategory(Category category) async {
    final categoryMap = category.toMap();
    final userId = _currentUserId;
    if (userId == null) return 0;

    final db = await _db.database;
    final tableInfo = await db.rawQuery('PRAGMA table_info(categories)');
    final columnNames = tableInfo.map((row) => row['name'] as String).toSet();
    if (columnNames.contains('user_id')) {
      categoryMap['user_id'] = userId;
    }
    final res = await _db.update(
      'categories',
      categoryMap,
      'id = ? AND user_id = ?',
      [category.id, userId],
    );
    await loadCategories();
    return res;
  }

  Future<int> deleteCategory(int id) async {
    final userId = _currentUserId;
    if (userId == null) return 0;

    final res = await _db.delete('categories', 'id = ? AND user_id = ?', [
      id,
      userId,
    ]);
    await loadCategories();
    return res;
  }
}
