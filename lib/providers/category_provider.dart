import 'package:flutter/material.dart';
import '../services/db_helper.dart';
import '../models/category.dart';

class CategoryProvider with ChangeNotifier {
  final DBHelper _db = DBHelper.instance;
  List<Category> _categories = [];

  List<Category> get categories => _categories;

  Future<void> loadCategories() async {
    final rows = await _db.query('categories', orderBy: 'name COLLATE NOCASE');
    _categories = rows.map((r) => Category.fromMap(r)).toList();
    notifyListeners();
  }

  Future<int> addCategory(Category c) async {
    final id = await _db.insert('categories', c.toMap());
    await loadCategories();
    return id;
  }

  Future<int> updateCategory(Category category) async {
    final res = await _db.update('categories', category.toMap(), 'id = ?', [
      category.id,
    ]);
    await loadCategories();
    return res;
  }

  Future<int> deleteCategory(int id) async {
    final res = await _db.delete('categories', 'id = ?', [id]);
    await loadCategories();
    return res;
  }
}
