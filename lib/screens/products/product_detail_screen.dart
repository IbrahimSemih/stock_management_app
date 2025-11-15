import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';
import '../../models/category.dart';
import '../../models/stock_history.dart';
import '../../services/db_helper.dart';
import '../../utils/constants.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  List<StockHistory> _stockHistory = [];
  bool _isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    _loadStockHistory();
  }

  Future<void> _loadStockHistory() async {
    final db = DBHelper.instance;
    final rows = await db.query(
      'stock_history',
      where: 'product_id = ?',
      whereArgs: [widget.productId],
      orderBy: 'date DESC',
    );
    setState(() {
      _stockHistory = rows.map((r) => StockHistory.fromMap(r)).toList();
      _isLoadingHistory = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final product = productProvider.findById(widget.productId);

    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ürün Detayı')),
        body: const Center(child: Text('Ürün bulunamadı')),
      );
    }

    final category = categoryProvider.categories.firstWhere(
      (c) => c.id == product.categoryId,
      orElse: () => Category(id: 0, name: 'Kategori Yok'),
    );

    final isCriticalStock =
        product.stock <= AppConstants.criticalStockThreshold;
    final dateFormat = DateFormat(AppConstants.dateTimeFormat);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: product.imagePath != null
                  ? Image.network(
                      product.imagePath!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppConstants.primaryColor.withOpacity(0.1),
                          child: const Icon(
                            Icons.inventory_2,
                            size: 80,
                            color: AppConstants.primaryColor,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: AppConstants.primaryColor.withOpacity(0.1),
                      child: const Icon(
                        Icons.inventory_2,
                        size: 80,
                        color: AppConstants.primaryColor,
                      ),
                    ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppConstants.routeProductEdit,
                    arguments: {'productId': product.id},
                  );
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Category
                  Chip(
                    label: Text(category.name),
                    avatar: const Icon(Icons.category, size: 18),
                  ),
                  const SizedBox(height: 16),

                  // Stock Info Card
                  Card(
                    color: isCriticalStock
                        ? AppConstants.criticalStockColor.withOpacity(0.1)
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _InfoItem(
                            icon: Icons.inventory_2,
                            label: 'Stok',
                            value: '${product.stock}',
                            color: isCriticalStock
                                ? AppConstants.criticalStockColor
                                : AppConstants.successColor,
                          ),
                          _InfoItem(
                            icon: Icons.shopping_bag,
                            label: 'Alış Fiyatı',
                            value:
                                '${product.purchasePrice.toStringAsFixed(2)} ₺',
                            color: AppConstants.primaryColor,
                          ),
                          _InfoItem(
                            icon: Icons.sell,
                            label: 'Satış Fiyatı',
                            value: '${product.salePrice.toStringAsFixed(2)} ₺',
                            color: AppConstants.successColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Barcode/QR Code
                  if (product.barcode != null) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Barkod / QR Kod',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: QrImageView(
                                data: product.barcode!,
                                version: QrVersions.auto,
                                size: 150,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Center(
                              child: Text(
                                product.barcode!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Description
                  if (product.description != null &&
                      product.description!.isNotEmpty) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Açıklama',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(product.description!),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Dates
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _DateRow(
                            label: 'Oluşturulma',
                            date: dateFormat.format(
                              DateTime.parse(product.createdAt),
                            ),
                          ),
                          const Divider(),
                          _DateRow(
                            label: 'Son Güncelleme',
                            date: dateFormat.format(
                              DateTime.parse(product.updatedAt),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppConstants.routeStockEntry,
                              arguments: {
                                'productId': product.id,
                                'type': AppConstants.stockTypeIn,
                              },
                            );
                          },
                          icon: const Icon(Icons.input),
                          label: const Text('Stok Giriş'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.successColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppConstants.routeStockEntry,
                              arguments: {
                                'productId': product.id,
                                'type': AppConstants.stockTypeOut,
                              },
                            );
                          },
                          icon: const Icon(Icons.output),
                          label: const Text('Stok Çıkış'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.warningColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Stock History
                  Text(
                    'Stok Hareket Geçmişi',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _isLoadingHistory
                      ? const Center(child: CircularProgressIndicator())
                      : _stockHistory.isEmpty
                      ? Card(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Center(
                              child: Text(
                                'Henüz stok hareketi yok',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _stockHistory.length,
                          itemBuilder: (context, index) {
                            final history = _stockHistory[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      history.type == AppConstants.stockTypeIn
                                      ? AppConstants.successColor.withOpacity(
                                          0.1,
                                        )
                                      : AppConstants.warningColor.withOpacity(
                                          0.1,
                                        ),
                                  child: Icon(
                                    history.type == AppConstants.stockTypeIn
                                        ? Icons.input
                                        : Icons.output,
                                    color:
                                        history.type == AppConstants.stockTypeIn
                                        ? AppConstants.successColor
                                        : AppConstants.warningColor,
                                  ),
                                ),
                                title: Text(
                                  history.type == AppConstants.stockTypeIn
                                      ? 'Stok Giriş'
                                      : 'Stok Çıkış',
                                ),
                                subtitle: Text(
                                  dateFormat.format(
                                    DateTime.parse(history.date),
                                  ),
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${history.type == AppConstants.stockTypeIn ? '+' : '-'}${history.amount}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            history.type ==
                                                AppConstants.stockTypeIn
                                            ? AppConstants.successColor
                                            : AppConstants.warningColor,
                                      ),
                                    ),
                                    if (history.note != null)
                                      Text(
                                        history.note!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}

class _DateRow extends StatelessWidget {
  final String label;
  final String date;

  const _DateRow({required this.label, required this.date});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600])),
        Text(date, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
