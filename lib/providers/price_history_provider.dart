import 'package:flutter/material.dart';
import '../models/price_history.dart';
import '../services/db_helper.dart';

class PriceHistoryProvider with ChangeNotifier {
  final DBHelper _db = DBHelper.instance;
  List<PriceHistory> _history = [];
  bool _isLoading = false;

  List<PriceHistory> get history => _history;
  bool get isLoading => _isLoading;

  Future<void> loadHistory({int? productId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final rows = await _db.query(
        'price_history',
        where: productId != null ? 'product_id = ?' : null,
        whereArgs: productId != null ? [productId] : null,
        orderBy: 'date DESC',
      );
      _history = rows.map((r) => PriceHistory.fromMap(r)).toList();
    } catch (e) {
      debugPrint('Error loading price history: $e');
      _history = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addPriceHistory(PriceHistory priceHistory) async {
    await _db.insert('price_history', priceHistory.toMap());
    await loadHistory();
  }

  Future<List<PriceHistory>> getHistoryByProduct(int productId) async {
    final rows = await _db.query(
      'price_history',
      where: 'product_id = ?',
      whereArgs: [productId],
      orderBy: 'date DESC',
    );
    return rows.map((r) => PriceHistory.fromMap(r)).toList();
  }
}

