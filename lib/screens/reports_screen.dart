import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/export_service.dart';
import '../providers/product_provider.dart';
import '../providers/category_provider.dart';
import '../providers/brand_provider.dart';
import '../providers/stock_history_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/constants.dart';
import '../widgets/custom_appbar.dart';
import '../l10n/app_localizations.dart';

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
          SnackBar(
            content: Text(context.tr('excel_created')),
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
      final settings = context.read<SettingsProvider>();
      final filePath = await ExportService.exportToPDF(
        currencySymbol: settings.currencySymbol,
      );
      await ExportService.shareFile(filePath);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('pdf_created')),
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
          SnackBar(
            content: Text(context.tr('database_backed_up')),
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
    // FileType.any kullanıyoruz çünkü .db uzantısı için standart MIME type yok
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      withData: true, // Dosya içeriğini direkt al (cache sorunu için)
    );

    if (result == null || result.files.single.path == null) {
      return;
    }

    final filePath = result.files.single.path!;
    final fileName = result.files.single.name;
    
    // Dosya uzantısını kontrol et
    if (!fileName.toLowerCase().endsWith('.db')) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('select_db_file')),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('restore_database')),
        content: Text(context.tr('restore_warning')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(context.tr('restore')),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isExporting = true);
    try {
      // withData: true ile bytes direkt alınıyor
      final bytes = result.files.single.bytes;
      
      if (bytes != null && bytes.isNotEmpty) {
        // Bytes ile geri yükle (daha güvenilir)
        await ExportService.restoreDatabaseFromBytes(bytes);
      } else {
        // Bytes yoksa dosya yolunu kullan (fallback)
        await ExportService.restoreDatabase(filePath);
      }
      
      // Provider'ları yeniden yükle
      if (mounted) {
        await context.read<ProductProvider>().loadAllProducts();
        await context.read<CategoryProvider>().loadCategories();
        await context.read<BrandProvider>().loadBrands();
        await context.read<StockHistoryProvider>().loadHistory();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('database_restored')),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        appBar: CustomAppBar(
          title: context.tr('reports'),
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
                          context.tr('export_section'),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        _ReportActionCard(
                          icon: Icons.table_chart,
                          title: context.tr('export_to_excel'),
                          description: context.tr('export_to_excel_desc'),
                          color: AppConstants.successColor,
                          onTap: _exportToExcel,
                        ),
                        const SizedBox(height: 12),
                        _ReportActionCard(
                          icon: Icons.picture_as_pdf,
                          title: context.tr('export_to_pdf'),
                          description: context.tr('export_to_pdf_desc'),
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
                          context.tr('stock_reports'),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        _ReportActionCard(
                          icon: Icons.today,
                          title: context.tr('daily_stock_report'),
                          description: context.tr('daily_stock_report_desc'),
                          color: AppConstants.primaryColor,
                          onTap: () => _showDailyReport(context),
                        ),
                        const SizedBox(height: 12),
                        _ReportActionCard(
                          icon: Icons.calendar_month,
                          title: context.tr('monthly_stock_report'),
                          description: context.tr('monthly_stock_report_desc'),
                          color: AppConstants.secondaryColor,
                          onTap: () => _showMonthlyReport(context),
                        ),
                        const SizedBox(height: 12),
                        _ReportActionCard(
                          icon: Icons.trending_up,
                          title: context.tr('most_active_products'),
                          description: context.tr('most_active_products_desc'),
                          color: AppConstants.accentColor,
                          onTap: () => _showMostActiveProducts(context),
                        ),
                        const SizedBox(height: 12),
                        _ReportActionCard(
                          icon: Icons.calculate,
                          title: context.tr('stock_value_report'),
                          description: context.tr('stock_value_report_desc'),
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
                          context.tr('backup_section'),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        _ReportActionCard(
                          icon: Icons.backup,
                          title: context.tr('backup_database'),
                          description: context.tr('backup_database_desc'),
                          color: AppConstants.primaryColor,
                          onTap: _backupDatabase,
                        ),
                        const SizedBox(height: 12),
                        _ReportActionCard(
                          icon: Icons.restore,
                          title: context.tr('restore_database'),
                          description: context.tr('restore_database_desc'),
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
                            context.tr('export_info'),
                            style: TextStyle(color: Colors.blue[900]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
      builder: (ctx) => _StockReportDialog(
        title: context.tr('daily_stock_report'),
        dateRange: DateTimeRange(
          start: DateTime.now().copyWith(hour: 0, minute: 0, second: 0),
          end: DateTime.now(),
        ),
        stockHistoryProvider: stockHistoryProvider,
        productProvider: productProvider,
        parentContext: context,
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
      builder: (ctx) => _StockReportDialog(
        title: context.tr('monthly_stock_report'),
        dateRange: DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: now,
        ),
        stockHistoryProvider: stockHistoryProvider,
        productProvider: productProvider,
        parentContext: context,
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
      builder: (ctx) => _MostActiveProductsDialog(
        stockHistoryProvider: stockHistoryProvider,
        productProvider: productProvider,
        parentContext: context,
      ),
    );
  }

  void _showStockValueReport(BuildContext context) {
    final productProvider = context.read<ProductProvider>();
    final settings = context.read<SettingsProvider>();
    final products = productProvider.products;
    
    double totalValue = 0;
    for (var product in products) {
      totalValue += product.stock * product.purchasePrice;
    }
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('stock_value_report')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${context.tr('total_product_count')}: ${products.length}'),
            const SizedBox(height: 8),
            Text('${context.tr('total_stock_quantity')}: ${products.fold<int>(0, (sum, p) => sum + p.stock)}'),
            const SizedBox(height: 8),
            Text(
              '${context.tr('total_stock_value')}: ${settings.currencySymbol}${totalValue.toStringAsFixed(2)}',
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
              context.tr('calculation_note'),
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
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr('close')),
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
  final BuildContext parentContext;

  const _StockReportDialog({
    required this.title,
    required this.dateRange,
    required this.stockHistoryProvider,
    required this.productProvider,
    required this.parentContext,
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
              Text('${parentContext.tr('date_range')}: ${DateFormat('dd/MM/yyyy').format(dateRange.start)} - ${DateFormat('dd/MM/yyyy').format(dateRange.end)}'),
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
                            Text(parentContext.tr('total_in'), style: const TextStyle(fontSize: 12)),
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
                            Text(parentContext.tr('total_out'), style: const TextStyle(fontSize: 12)),
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
                '${parentContext.tr('total_movements')}: ${filteredHistory.length}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(parentContext.tr('close')),
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
  final BuildContext parentContext;

  const _MostActiveProductsDialog({
    required this.stockHistoryProvider,
    required this.productProvider,
    required this.parentContext,
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
          title: Text(parentContext.tr('most_active_products')),
          content: Container(
            width: double.maxFinite,
            constraints: const BoxConstraints(maxHeight: 600),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: topProducts.isEmpty
                    ? [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(parentContext.tr('no_stock_movement')),
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
                                Text('${entry.value} ${parentContext.tr('movements')}'),
                                Text(
                                  '${parentContext.tr('stock')}: ${product.stock}',
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
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(parentContext.tr('movement_history_not_found')),
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
                                                    isIn ? parentContext.tr('in_movement') : parentContext.tr('out_movement'),
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
              child: Text(parentContext.tr('close')),
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

