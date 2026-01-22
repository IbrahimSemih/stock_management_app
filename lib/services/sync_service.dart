import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/category.dart' as models;
import '../models/brand.dart';
import '../models/stock_history.dart';

/// Firebase Firestore senkronizasyon servisi
/// Kullanıcı verilerini buluta yedekler ve senkronize eder
class SyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Kullanıcının Firestore doküman referansını döndürür
  DocumentReference get _userDocRef {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return _firestore.collection('users').doc(user.uid);
  }

  /// Kullanıcının verilerinin Firestore'da olup olmadığını kontrol eder
  Future<bool> checkUserDataExists() async {
    try {
      final userDoc = await _userDocRef.collection('data').doc('metadata').get();
      return userDoc.exists;
    } catch (e) {
      debugPrint('Error checking user data: $e');
      return false;
    }
  }

  // ========== PRODUCTS SYNC ==========

  /// Tüm ürünleri Firestore'a yükler
  Future<void> syncProductsToCloud(List<Product> products) async {
    if (products.isEmpty) {
      debugPrint('No products to sync');
      return;
    }

    try {
      final batch = _firestore.batch();
      final productsRef = _userDocRef.collection('products');
      int addedCount = 0;

      for (final product in products) {
        if (product.id == null) {
          debugPrint('Warning: Product without ID skipped: ${product.name}');
          continue;
        }
        
        final docRef = productsRef.doc(product.id.toString());
        batch.set(docRef, {
          'id': product.id,
          'name': product.name,
          'barcode': product.barcode,
          'categoryId': product.categoryId,
          'brandId': product.brandId,
          'model': product.model,
          'stock': product.stock,
          'purchasePrice': product.purchasePrice,
          'salePrice': product.salePrice,
          'imagePath': product.imagePath,
          'description': product.description,
          'createdAt': product.createdAt,
          'updatedAt': product.updatedAt,
          'syncedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        addedCount++;
      }

      if (addedCount > 0) {
        await batch.commit();
        debugPrint('Products synced to cloud: $addedCount');
      } else {
        debugPrint('No products to sync (all skipped due to missing IDs)');
      }
    } catch (e, stackTrace) {
      debugPrint('Error syncing products to cloud: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Firestore'dan tüm ürünleri indirir
  Future<List<Product>> syncProductsFromCloud() async {
    try {
      final snapshot = await _userDocRef
          .collection('products')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Product(
          id: data['id'] as int?,
          name: data['name'] as String,
          barcode: data['barcode'] as String?,
          categoryId: data['categoryId'] as int,
          brandId: data['brandId'] as int?,
          model: data['model'] as String?,
          stock: data['stock'] as int,
          purchasePrice: (data['purchasePrice'] as num).toDouble(),
          salePrice: (data['salePrice'] as num).toDouble(),
          imagePath: data['imagePath'] as String?,
          description: data['description'] as String?,
          createdAt: data['createdAt'] as String,
          updatedAt: data['updatedAt'] as String,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error syncing products from cloud: $e');
      rethrow;
    }
  }

  /// Tek bir ürünü Firestore'a yükler
  Future<void> syncProductToCloud(Product product) async {
    try {
      final docRef = _userDocRef
          .collection('products')
          .doc(product.id?.toString() ?? 'temp_${DateTime.now().millisecondsSinceEpoch}');

      await docRef.set({
        'id': product.id,
        'name': product.name,
        'barcode': product.barcode,
        'categoryId': product.categoryId,
        'brandId': product.brandId,
        'model': product.model,
        'stock': product.stock,
        'purchasePrice': product.purchasePrice,
        'salePrice': product.salePrice,
        'imagePath': product.imagePath,
        'description': product.description,
        'createdAt': product.createdAt,
        'updatedAt': product.updatedAt,
        'syncedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error syncing product to cloud: $e');
      rethrow;
    }
  }

  /// Firestore'dan bir ürünü siler
  Future<void> deleteProductFromCloud(int productId) async {
    try {
      await _userDocRef
          .collection('products')
          .doc(productId.toString())
          .delete();
    } catch (e) {
      debugPrint('Error deleting product from cloud: $e');
      rethrow;
    }
  }

  // ========== CATEGORIES SYNC ==========

  /// Tüm kategorileri Firestore'a yükler
  Future<void> syncCategoriesToCloud(List<models.Category> categories) async {
    try {
      final batch = _firestore.batch();
      final categoriesRef = _userDocRef.collection('categories');

      for (final category in categories) {
        final docRef = categoriesRef.doc(category.id?.toString() ?? 'temp_${DateTime.now().millisecondsSinceEpoch}');
        batch.set(docRef, {
          'id': category.id,
          'name': category.name,
          'syncedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      debugPrint('Categories synced to cloud: ${categories.length}');
    } catch (e) {
      debugPrint('Error syncing categories to cloud: $e');
      rethrow;
    }
  }

  /// Firestore'dan tüm kategorileri indirir
  Future<List<models.Category>> syncCategoriesFromCloud() async {
    try {
      final snapshot = await _userDocRef
          .collection('categories')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return models.Category(
          id: data['id'] as int?,
          name: data['name'] as String,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error syncing categories from cloud: $e');
      rethrow;
    }
  }

  // ========== BRANDS SYNC ==========

  /// Tüm markaları Firestore'a yükler
  Future<void> syncBrandsToCloud(List<Brand> brands) async {
    try {
      final batch = _firestore.batch();
      final brandsRef = _userDocRef.collection('brands');

      for (final brand in brands) {
        final docRef = brandsRef.doc(brand.id?.toString() ?? 'temp_${DateTime.now().millisecondsSinceEpoch}');
        batch.set(docRef, {
          'id': brand.id,
          'name': brand.name,
          'syncedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      debugPrint('Brands synced to cloud: ${brands.length}');
    } catch (e, stackTrace) {
      debugPrint('Error syncing brands to cloud: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Firestore'dan tüm markaları indirir
  Future<List<Brand>> syncBrandsFromCloud() async {
    try {
      final snapshot = await _userDocRef
          .collection('brands')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Brand(
          id: data['id'] as int?,
          name: data['name'] as String,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error syncing brands from cloud: $e');
      rethrow;
    }
  }

  // ========== STOCK HISTORY SYNC ==========

  /// Tüm stok geçmişini Firestore'a yükler
  Future<void> syncStockHistoryToCloud(List<StockHistory> history) async {
    if (history.isEmpty) {
      debugPrint('No stock history to sync');
      return;
    }

    try {
      final batch = _firestore.batch();
      final historyRef = _userDocRef.collection('stock_history');
      int addedCount = 0;

      for (final item in history) {
        if (item.id == null) {
          debugPrint('Warning: Stock history without ID skipped');
          continue;
        }
        
        final docRef = historyRef.doc(item.id.toString());
        batch.set(docRef, {
          'id': item.id,
          'productId': item.productId,
          'type': item.type,
          'amount': item.amount,
          'date': item.date,
          'note': item.note,
          'syncedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        addedCount++;
      }

      if (addedCount > 0) {
        await batch.commit();
        debugPrint('Stock history synced to cloud: $addedCount');
      } else {
        debugPrint('No stock history to sync (all skipped due to missing IDs)');
      }
    } catch (e, stackTrace) {
      debugPrint('Error syncing stock history to cloud: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Firestore'dan tüm stok geçmişini indirir
  Future<List<StockHistory>> syncStockHistoryFromCloud() async {
    try {
      final snapshot = await _userDocRef
          .collection('stock_history')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return StockHistory(
          id: data['id'] as int?,
          productId: data['productId'] as int,
          type: data['type'] as String,
          amount: data['amount'] as int,
          date: data['date'] as String,
          note: data['note'] as String?,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error syncing stock history from cloud: $e');
      rethrow;
    }
  }

  // ========== FULL SYNC ==========

  /// Tüm verileri Firestore'a yükler (tam senkronizasyon)
  Future<void> syncAllToCloud({
    required List<Product> products,
    required List<models.Category> categories,
    required List<Brand> brands,
    required List<StockHistory> stockHistory,
  }) async {
    try {
      // Önce parent document'i oluştur (subcollection'ların görünmesi için gerekli)
      await _userDocRef.set({
        'createdAt': FieldValue.serverTimestamp(),
        'lastSyncTime': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Tüm verileri sırayla senkronize et (paralel değil, güvenli olsun)
      if (!categories.isEmpty) {
        await syncCategoriesToCloud(categories);
      }
      if (!brands.isEmpty) {
        await syncBrandsToCloud(brands);
      }
      if (!products.isEmpty) {
        await syncProductsToCloud(products);
      }
      if (!stockHistory.isEmpty) {
        await syncStockHistoryToCloud(stockHistory);
      }

      // Son senkronizasyon zamanını kaydet
      await _userDocRef.collection('data').doc('metadata').set({
        'lastSyncTime': FieldValue.serverTimestamp(),
        'syncedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('All data synced to cloud successfully');
      debugPrint('Products: ${products.length}, Categories: ${categories.length}, Brands: ${brands.length}, Stock History: ${stockHistory.length}');
    } catch (e, stackTrace) {
      debugPrint('Error syncing all data to cloud: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Son senkronizasyon zamanını döndürür
  Future<DateTime?> getLastSyncTime() async {
    try {
      final doc = await _userDocRef.collection('data').doc('metadata').get();
      if (doc.exists) {
        final timestamp = doc.data()?['lastSyncTime'] as Timestamp?;
        return timestamp?.toDate();
      }
      return null;
    } catch (e) {
      debugPrint('Error getting last sync time: $e');
      return null;
    }
  }

  /// Kullanıcının tüm verilerini Firestore'dan siler
  Future<void> deleteAllUserData() async {
    try {
      final collections = ['products', 'categories', 'brands', 'stock_history'];
      
      for (final collection in collections) {
        final snapshot = await _userDocRef
            .collection(collection)
            .get();
        
        final batch = _firestore.batch();
        for (final doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }

      // Data dokümanını da sil
      await _userDocRef.collection('data').doc('metadata').delete();
      
      debugPrint('All user data deleted from cloud');
    } catch (e) {
      debugPrint('Error deleting user data: $e');
      rethrow;
    }
  }
}

