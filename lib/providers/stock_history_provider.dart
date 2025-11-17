import 'package:flutter/material.dart';
import '../models/stock_history.dart';
import '../services/db_helper.dart';

class StockHistoryProvider with ChangeNotifier {
  final DBHelper _db = DBHelper.instance;
  List<StockHistory> _history = [];
  bool _isLoading = false;

  List<StockHistory> get history => _history;
  bool get isLoading => _isLoading;

  Future<void> loadHistory({int? productId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final rows = await _db.query(
        'stock_history',
        where: productId != null ? 'product_id = ?' : null,
        whereArgs: productId != null ? [productId] : null,
        orderBy: 'date DESC',
      );
      _history = rows.map((r) => StockHistory.fromMap(r)).toList();
    } catch (e) {
      debugPrint('Error loading stock history: $e');
      _history = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<List<StockHistory>> getHistoryByProduct(int productId) async {
    final rows = await _db.query(
      'stock_history',
      where: 'product_id = ?',
      whereArgs: [productId],
      orderBy: 'date DESC',
    );
    return rows.map((r) => StockHistory.fromMap(r)).toList();
  }

  Future<Map<String, dynamic>> getStatistics() async {
    final allHistory = await _db.query('stock_history');
    final historyList = allHistory.map((r) => StockHistory.fromMap(r)).toList();

    int totalIn = 0;
    int totalOut = 0;
    final Map<int, int> productInCount = {};
    final Map<int, int> productOutCount = {};

    for (var h in historyList) {
      if (h.type == 'IN') {
        totalIn += h.amount;
        productInCount[h.productId] = (productInCount[h.productId] ?? 0) + h.amount;
      } else {
        totalOut += h.amount;
        productOutCount[h.productId] = (productOutCount[h.productId] ?? 0) + h.amount;
      }
    }

    return {
      'totalIn': totalIn,
      'totalOut': totalOut,
      'netChange': totalIn - totalOut,
      'productInCount': productInCount,
      'productOutCount': productOutCount,
      'totalTransactions': historyList.length,
    };
  }
}

