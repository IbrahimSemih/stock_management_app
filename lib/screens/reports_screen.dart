import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/export_service.dart';
import '../providers/product_provider.dart';
import '../providers/category_provider.dart';
import '../providers/brand_provider.dart';
import '../providers/stock_history_provider.dart';
import '../utils/constants.dart';
import '../widgets/custom_appbar.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _isExporting = false;

  Future<void> _exportToExcel() async {
    setState(() => _isExporting = true);
    try {
      final filePath = await ExportService.exportToExcel();
      await ExportService.shareFile(filePath);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Excel dosyası oluşturuldu ve paylaşıldı'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _exportToPDF() async {
    setState(() => _isExporting = true);
    try {
      final filePath = await ExportService.exportToPDF();
      await ExportService.shareFile(filePath);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF dosyası oluşturuldu ve paylaşıldı'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _backupDatabase() async {
    setState(() => _isExporting = true);
    try {
      final backupPath = await ExportService.backupDatabase();
      await ExportService.shareFile(backupPath);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veritabanı yedeklendi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _restoreDatabase() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['db'],
    );

    if (result == null || result.files.single.path == null) {
      return;
    }

    final filePath = result.files.single.path!;

    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Veritabanını Geri Yükle'),
        content: const Text(
          'Mevcut veritabanı silinecek ve seçilen yedek yüklenecek. Bu işlem geri alınamaz. Devam etmek istediğinize emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Geri Yükle'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isExporting = true);
    try {
      await ExportService.restoreDatabase(filePath);
      
      // Provider'ları yeniden yükle
      if (mounted) {
        await context.read<ProductProvider>().loadAllProducts();
        await context.read<CategoryProvider>().loadCategories();
        await context.read<BrandProvider>().loadBrands();
        await context.read<StockHistoryProvider>().loadHistory();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veritabanı geri yüklendi ve yenilendi.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Veritabanı geri yükleme hatası: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Raporlar ve Yedekleme',
      ),
      body: _isExporting
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Export Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dışa Aktarma',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        _ReportActionCard(
                          icon: Icons.table_chart,
                          title: 'Excel\'e Aktar',
                          description: 'Tüm ürün listesini Excel formatında dışa aktar',
                          color: AppConstants.successColor,
                          onTap: _exportToExcel,
                        ),
                        const SizedBox(height: 12),
                        _ReportActionCard(
                          icon: Icons.picture_as_pdf,
                          title: 'PDF Rapor Oluştur',
                          description: 'Stok raporunu PDF formatında oluştur',
                          color: AppConstants.errorColor,
                          onTap: _exportToPDF,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Stock Reports Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Stok Raporları',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        _ReportActionCard(
                          icon: Icons.today,
                          title: 'Günlük Stok Hareket Raporu',
                          description: 'Bugünkü stok giriş ve çıkışlarını görüntüle',
                          color: AppConstants.primaryColor,
                          onTap: () => _showDailyReport(context),
                        ),
                        const SizedBox(height: 12),
                        _ReportActionCard(
                          icon: Icons.calendar_month,
                          title: 'Aylık Stok Hareket Raporu',
                          description: 'Bu ayın stok hareket raporunu görüntüle',
                          color: AppConstants.secondaryColor,
                          onTap: () => _showMonthlyReport(context),
                        ),
                        const SizedBox(height: 12),
                        _ReportActionCard(
                          icon: Icons.trending_up,
                          title: 'En Çok Hareket Gören Ürünler',
                          description: 'En fazla stok hareketi olan ürünleri listele',
                          color: AppConstants.accentColor,
                          onTap: () => _showMostActiveProducts(context),
                        ),
                        const SizedBox(height: 12),
                        _ReportActionCard(
                          icon: Icons.calculate,
                          title: 'Stok Değeri Raporu',
                          description: 'Toplam stok değerini hesapla (adet × alış fiyatı)',
                          color: AppConstants.warningColor,
                          onTap: () => _showStockValueReport(context),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Backup Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Yedekleme',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        _ReportActionCard(
                          icon: Icons.backup,
                          title: 'Veritabanını Yedekle',
                          description: 'Tüm verilerinizin yedeğini alın',
                          color: AppConstants.primaryColor,
                          onTap: _backupDatabase,
                        ),
                        const SizedBox(height: 12),
                        _ReportActionCard(
                          icon: Icons.restore,
                          title: 'Veritabanını Geri Yükle',
                          description: 'Daha önce aldığınız yedeği geri yükleyin',
                          color: AppConstants.warningColor,
                          onTap: _restoreDatabase,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Info Card
                Card(
                  color: Colors.blue.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.blue),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Dışa aktarılan dosyalar paylaşım menüsü ile başka uygulamalara gönderilebilir.',
                            style: TextStyle(color: Colors.blue[900]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _showDailyReport(BuildContext context) async {
    final stockHistoryProvider = context.read<StockHistoryProvider>();
    final productProvider = context.read<ProductProvider>();
    
    // History'yi yükle
    await stockHistoryProvider.loadHistory();
    
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => _StockReportDialog(
        title: 'Günlük Stok Hareket Raporu',
        dateRange: DateTimeRange(
          start: DateTime.now().copyWith(hour: 0, minute: 0, second: 0),
          end: DateTime.now(),
        ),
        stockHistoryProvider: stockHistoryProvider,
        productProvider: productProvider,
      ),
    );
  }

  Future<void> _showMonthlyReport(BuildContext context) async {
    final stockHistoryProvider = context.read<StockHistoryProvider>();
    final productProvider = context.read<ProductProvider>();
    final now = DateTime.now();
    
    // History'yi yükle
    await stockHistoryProvider.loadHistory();
    
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => _StockReportDialog(
        title: 'Aylık Stok Hareket Raporu',
        dateRange: DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: now,
        ),
        stockHistoryProvider: stockHistoryProvider,
        productProvider: productProvider,
      ),
    );
  }

  Future<void> _showMostActiveProducts(BuildContext context) async {
    final stockHistoryProvider = context.read<StockHistoryProvider>();
    final productProvider = context.read<ProductProvider>();
    
    // History'yi yükle
    await stockHistoryProvider.loadHistory();
    
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => _MostActiveProductsDialog(
        stockHistoryProvider: stockHistoryProvider,
        productProvider: productProvider,
      ),
    );
  }

  void _showStockValueReport(BuildContext context) {
    final productProvider = context.read<ProductProvider>();
    final products = productProvider.products;
    
    double totalValue = 0;
    for (var product in products) {
      totalValue += product.stock * product.purchasePrice;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stok Değeri Raporu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Toplam Ürün Sayısı: ${products.length}'),
            const SizedBox(height: 8),
            Text('Toplam Stok Miktarı: ${products.fold<int>(0, (sum, p) => sum + p.stock)}'),
            const SizedBox(height: 8),
            Text(
              'Toplam Stok Değeri: ${totalValue.toStringAsFixed(2)} ₺',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppConstants.successColor,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Hesaplama: Stok Miktarı × Alış Fiyatı',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }
}

class _StockReportDialog extends StatelessWidget {
  final String title;
  final DateTimeRange dateRange;
  final StockHistoryProvider stockHistoryProvider;
  final ProductProvider productProvider;

  const _StockReportDialog({
    required this.title,
    required this.dateRange,
    required this.stockHistoryProvider,
    required this.productProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<StockHistoryProvider>(
      builder: (context, provider, _) {
        final allHistory = provider.history;
    final filteredHistory = allHistory.where((h) {
      final date = DateTime.tryParse(h.date);
      if (date == null) return false;
      return date.isAfter(dateRange.start.subtract(const Duration(days: 1))) &&
          date.isBefore(dateRange.end.add(const Duration(days: 1)));
    }).toList();

    int totalIn = 0;
    int totalOut = 0;
    for (var h in filteredHistory) {
      if (h.type == 'IN') {
        totalIn += h.amount;
      } else {
        totalOut += h.amount;
      }
    }

    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tarih Aralığı: ${DateFormat('dd/MM/yyyy').format(dateRange.start)} - ${DateFormat('dd/MM/yyyy').format(dateRange.end)}'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Card(
                      color: AppConstants.successColor.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            const Text('Toplam Giriş', style: TextStyle(fontSize: 12)),
                            Text(
                              '$totalIn',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppConstants.successColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Card(
                      color: AppConstants.warningColor.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            const Text('Toplam Çıkış', style: TextStyle(fontSize: 12)),
                            Text(
                              '$totalOut',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppConstants.warningColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Toplam Hareket: ${filteredHistory.length}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Kapat'),
        ),
      ],
    );
      },
    );
  }
}

class _MostActiveProductsDialog extends StatelessWidget {
  final StockHistoryProvider stockHistoryProvider;
  final ProductProvider productProvider;

  const _MostActiveProductsDialog({
    required this.stockHistoryProvider,
    required this.productProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<StockHistoryProvider>(
      builder: (context, provider, _) {
        final allHistory = provider.history;
        final products = productProvider.products;
        
        // Ürün bazında hareket sayısını hesapla
        final Map<int, int> productActivityCount = {};
        for (var h in allHistory) {
          productActivityCount[h.productId] = (productActivityCount[h.productId] ?? 0) + 1;
        }
        
        // En çok hareket gören ürünleri sırala
        final sortedProducts = productActivityCount.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        
        final topProducts = sortedProducts.take(10).toList();

        return AlertDialog(
          title: const Text('En Çok Hareket Gören Ürünler'),
          content: Container(
            width: double.maxFinite,
            constraints: const BoxConstraints(maxHeight: 600),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: topProducts.isEmpty
                    ? [
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('Henüz stok hareketi yok'),
                        ),
                      ]
                    : topProducts.map((entry) {
                        final product = products.firstWhere(
                          (p) => p.id == entry.key,
                          orElse: () => products.first,
                        );
                        // Bu ürünün tüm hareketlerini al
                        final productMovements = allHistory
                            .where((h) => h.productId == entry.key)
                            .toList()
                          ..sort((a, b) => b.date.compareTo(a.date));
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                              child: Text(
                                '${topProducts.indexOf(entry) + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppConstants.primaryColor,
                                ),
                              ),
                            ),
                            title: Text(
                              product.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${entry.value} hareket'),
                                Text(
                                  'Stok: ${product.stock}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            trailing: const Icon(Icons.expand_more),
                            children: [
                              if (productMovements.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text('Hareket geçmişi bulunamadı'),
                                )
                              else
                                ...productMovements.map((movement) {
                                  final date = DateTime.tryParse(movement.date);
                                  final formattedDate = date != null
                                      ? DateFormat('dd/MM/yyyy HH:mm').format(date)
                                      : movement.date;
                                  final isIn = movement.type == 'IN';
                                  
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 4,
                                    ),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: (isIn
                                          ? AppConstants.successColor
                                          : AppConstants.warningColor)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: (isIn
                                            ? AppConstants.successColor
                                            : AppConstants.warningColor)
                                            .withOpacity(0.3),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: (isIn
                                                ? AppConstants.successColor
                                                : AppConstants.warningColor)
                                                .withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Icon(
                                            isIn ? Icons.add : Icons.remove,
                                            size: 16,
                                            color: isIn
                                                ? AppConstants.successColor
                                                : AppConstants.warningColor,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    isIn ? 'Giriş' : 'Çıkış',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: isIn
                                                          ? AppConstants.successColor
                                                          : AppConstants.warningColor,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    '${isIn ? '+' : '-'}${movement.amount}',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                      color: isIn
                                                          ? AppConstants.successColor
                                                          : AppConstants.warningColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                formattedDate,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              if (movement.note != null &&
                                                  movement.note!.isNotEmpty) ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  movement.note!,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey[600],
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                            ],
                          ),
                        );
                      }).toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kapat'),
            ),
          ],
        );
      },
    );
  }
}

class _ReportActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _ReportActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color),
          ],
        ),
      ),
    );
  }
}

