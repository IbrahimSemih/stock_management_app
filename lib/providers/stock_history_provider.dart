import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/stock_history.dart';
import '../services/db_helper.dart';

class StockHistoryProvider with ChangeNotifier {
  final DBHelper _db = DBHelper.instance;
  List<StockHistory> _history = [];
  bool _isLoading = false;

  List<StockHistory> get history => _history;
  bool get isLoading => _isLoading;

  /// Hafızadaki verileri temizler (kullanıcı değişiminde çağrılır)
  void clearData() {
    _history = [];
    notifyListeners();
  }

  String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;

  Future<void> loadHistory({int? productId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userId = _currentUserId;
      String? whereClause;
      List<dynamic>? whereArgs;

      if (productId != null && userId != null) {
        whereClause = 'product_id = ? AND user_id = ?';
        whereArgs = [productId, userId];
      } else if (productId != null) {
        whereClause = '1 = 0'; // Kullanıcı yoksa hiçbir şey gösterme
        whereArgs = null;
      } else if (userId != null) {
        whereClause = 'user_id = ?';
        whereArgs = [userId];
      } else {
        whereClause = '1 = 0'; // Kullanıcı yoksa hiçbir şey gösterme
        whereArgs = null;
      }

      final rows = await _db.query(
        'stock_history',
        where: whereClause,
        whereArgs: whereArgs,
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
    final userId = _currentUserId;
    final rows = await _db.query(
      'stock_history',
      where: userId != null
          ? 'product_id = ? AND user_id = ?'
          : '1 = 0', // Kullanıcı yoksa hiçbir şey gösterme
      whereArgs: userId != null ? [productId, userId] : null,
      orderBy: 'date DESC',
    );
    return rows.map((r) => StockHistory.fromMap(r)).toList();
  }

  Future<Map<String, dynamic>> getStatistics() async {
    final userId = _currentUserId;
    final allHistory = await _db.query(
      'stock_history',
      where: userId != null
          ? 'user_id = ?'
          : '1 = 0', // Kullanıcı yoksa hiçbir şey gösterme
      whereArgs: userId != null ? [userId] : null,
    );
    final historyList = allHistory.map((r) => StockHistory.fromMap(r)).toList();

    int totalIn = 0;
    int totalOut = 0;
    final Map<int, int> productInCount = {};
    final Map<int, int> productOutCount = {};

    for (var h in historyList) {
      if (h.type == 'IN') {
        totalIn += h.amount;
        productInCount[h.productId] =
            (productInCount[h.productId] ?? 0) + h.amount;
      } else {
        totalOut += h.amount;
        productOutCount[h.productId] =
            (productOutCount[h.productId] ?? 0) + h.amount;
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
