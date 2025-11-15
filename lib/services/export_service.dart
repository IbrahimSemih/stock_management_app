import 'dart:io';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../services/db_helper.dart';
import '../utils/constants.dart';

class ExportService {
  static final DBHelper _db = DBHelper.instance;

  // Excel Export
  static Future<String> exportToExcel() async {
    final excel = Excel.createExcel();
    excel.delete('Sheet1');
    final sheet = excel['Ürünler'];

    // Headers
    sheet.appendRow([
      TextCellValue('ID'),
      TextCellValue('Ürün Adı'),
      TextCellValue('Barkod'),
      TextCellValue('Kategori'),
      TextCellValue('Stok'),
      TextCellValue('Alış Fiyatı'),
      TextCellValue('Satış Fiyatı'),
      TextCellValue('Açıklama'),
      TextCellValue('Oluşturulma Tarihi'),
    ]);

    // Get products
    final productRows = await _db.query('products', orderBy: 'name');
    final categoryRows = await _db.query('categories');

    final categories = <int, String>{};
    for (var row in categoryRows) {
      categories[row['id'] as int] = row['name'] as String;
    }

    // Add products
    for (var row in productRows) {
      final categoryId = row['category_id'] as int?;
      final categoryName = categoryId != null
          ? categories[categoryId] ?? 'N/A'
          : 'N/A';

      sheet.appendRow([
        IntCellValue(row['id'] as int),
        TextCellValue(row['name'] as String),
        TextCellValue(row['barcode'] as String? ?? ''),
        TextCellValue(categoryName),
        IntCellValue(row['stock'] as int),
        DoubleCellValue((row['purchase_price'] as num).toDouble()),
        DoubleCellValue((row['sale_price'] as num).toDouble()),
        TextCellValue(row['description'] as String? ?? ''),
        TextCellValue(row['created_at'] as String),
      ]);
    }

    // Save file
    final directory = await getApplicationDocumentsDirectory();
    final fileName =
        'smartstock_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(excel.encode()!);

    return filePath;
  }

  // PDF Export
  static Future<String> exportToPDF() async {
    final pdf = pw.Document();

    // Get products
    final productRows = await _db.query('products', orderBy: 'name');
    final categoryRows = await _db.query('categories');

    final categories = <int, String>{};
    for (var row in categoryRows) {
      categories[row['id'] as int] = row['name'] as String;
    }

    final products = productRows.map((row) {
      final categoryId = row['category_id'] as int?;
      final categoryName = categoryId != null
          ? categories[categoryId] ?? 'N/A'
          : 'N/A';

      return {
        'id': row['id'],
        'name': row['name'] as String,
        'barcode': row['barcode'] as String? ?? '',
        'category': categoryName,
        'stock': row['stock'] as int,
        'purchasePrice': (row['purchase_price'] as num).toDouble(),
        'salePrice': (row['sale_price'] as num).toDouble(),
      };
    }).toList();

    // Build PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  AppConstants.appName,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  DateFormat(AppConstants.dateFormat).format(DateTime.now()),
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            'Stok Raporu',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 20),
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              // Header
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Ürün Adı',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Kategori',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Stok',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Satış Fiyatı',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ],
              ),
              // Rows
              ...products.map(
                (product) => pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(product['name'] as String),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(product['category'] as String),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('${product['stock']}'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        '${(product['salePrice'] as double).toStringAsFixed(2)} ₺',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            'Toplam Ürün Sayısı: ${products.length}',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            'Toplam Stok: ${products.fold<int>(0, (sum, p) => sum + (p['stock'] as int))}',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );

    // Save file
    final directory = await getApplicationDocumentsDirectory();
    final fileName =
        'smartstock_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    return filePath;
  }

  // Share file
  static Future<void> shareFile(String filePath) async {
    await Share.shareXFiles([XFile(filePath)]);
  }

  // Database Backup
  static Future<String> backupDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final dbPath = '${directory.path}/${AppConstants.dbName}';
    final sourceFile = File(dbPath);

    if (!await sourceFile.exists()) {
      throw Exception('Veritabanı dosyası bulunamadı');
    }

    final backupFileName =
        'smartstock_backup_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.db';
    final backupPath = '${directory.path}/$backupFileName';

    await sourceFile.copy(backupPath);

    return backupPath;
  }

  // Database Restore
  static Future<void> restoreDatabase(String backupPath) async {
    final directory = await getApplicationDocumentsDirectory();
    final dbPath = '${directory.path}/${AppConstants.dbName}';
    final sourceFile = File(backupPath);

    if (!await sourceFile.exists()) {
      throw Exception('Yedek dosyası bulunamadı');
    }

    // Close existing database connection
    // Note: This is a simplified approach. In production, you should properly close DB connections.
    await sourceFile.copy(dbPath);
  }
}
