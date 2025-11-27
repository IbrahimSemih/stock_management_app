import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static const _dbName = 'smartstock.db';
  static const _dbVersion = 2;
  static Database? _database;
  DBHelper._privateConstructor();
  static final DBHelper instance = DBHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _dbName);
    final db = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    
    // Migration sonrası kolonları kontrol et ve ekle
    await _ensureColumnsExist(db);
    
    return db;
  }

  Future<void> _ensureColumnsExist(Database db) async {
    try {
      // products tablosundaki kolonları kontrol et
      final tableInfo = await db.rawQuery('PRAGMA table_info(products)');
      final columnNames = tableInfo.map((row) => row['name'] as String).toSet();
      
      // brand_id kolonu yoksa ekle
      if (!columnNames.contains('brand_id')) {
        try {
          await db.execute('ALTER TABLE products ADD COLUMN brand_id INTEGER');
          debugPrint('brand_id kolonu eklendi');
        } catch (e) {
          debugPrint('brand_id kolonu eklenirken hata: $e');
        }
      }
      
      // model kolonu yoksa ekle
      if (!columnNames.contains('model')) {
        try {
          await db.execute('ALTER TABLE products ADD COLUMN model TEXT');
          debugPrint('model kolonu eklendi');
        } catch (e) {
          debugPrint('model kolonu eklenirken hata: $e');
        }
      }
    } catch (e) {
      debugPrint('Kolon kontrolü hatası: $e');
    }
  }

  FutureOr<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        barcode TEXT,
        category_id INTEGER,
        stock INTEGER NOT NULL DEFAULT 0,
        purchase_price REAL NOT NULL DEFAULT 0,
        sale_price REAL NOT NULL DEFAULT 0,
        image_path TEXT,
        description TEXT,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY(category_id) REFERENCES categories(id)
      );
    ''');

    await db.execute('''
      CREATE TABLE stock_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        amount INTEGER NOT NULL,
        date TEXT,
        note TEXT,
        FOREIGN KEY(product_id) REFERENCES products(id)
      );
    ''');

    await db.execute('''
      CREATE TABLE brands (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      );
    ''');

    await db.execute('''
      CREATE TABLE price_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        old_purchase_price REAL,
        new_purchase_price REAL,
        old_sale_price REAL,
        new_sale_price REAL,
        date TEXT,
        FOREIGN KEY(product_id) REFERENCES products(id)
      );
    ''');

    // Seed default category
    await db.insert('categories', {'name': 'Default'});
  }

  FutureOr<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        // Add brands table
        await db.execute('''
          CREATE TABLE IF NOT EXISTS brands (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL UNIQUE
          );
        ''');

        // Add price_history table
        await db.execute('''
          CREATE TABLE IF NOT EXISTS price_history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            product_id INTEGER NOT NULL,
            old_purchase_price REAL,
            new_purchase_price REAL,
            old_sale_price REAL,
            new_sale_price REAL,
            date TEXT,
            FOREIGN KEY(product_id) REFERENCES products(id)
          );
        ''');

        // Add brand_id and model columns to products table
        // SQLite doesn't support adding FOREIGN KEY constraints via ALTER TABLE
        // So we just add the columns without the constraint
        try {
          await db.execute('ALTER TABLE products ADD COLUMN brand_id INTEGER');
        } catch (e) {
          debugPrint('brand_id column might already exist: $e');
        }
        
        try {
          await db.execute('ALTER TABLE products ADD COLUMN model TEXT');
        } catch (e) {
          debugPrint('model column might already exist: $e');
        }
      } catch (e) {
        debugPrint('Migration error: $e');
        // Migration hatası olsa bile devam et
      }
    }
  }

  Future<int> insert(String table, Map<String, dynamic> values) async {
    final db = await database;
    return await db.insert(table, values);
  }

  Future<int> update(
    String table,
    Map<String, dynamic> values,
    String where,
    List<dynamic> whereArgs,
  ) async {
    final db = await database;
    return await db.update(table, values, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(
    String table,
    String where,
    List<dynamic> whereArgs,
  ) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
  }) async {
    final db = await database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
    );
  }

  Future<void> execute(String sql) async {
    final db = await database;
    await db.execute(sql);
  }

  // Veritabanı bağlantısını kapat ve sıfırla (restore için)
  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
