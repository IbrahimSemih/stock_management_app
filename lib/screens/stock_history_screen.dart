import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/stock_history_provider.dart';
import '../providers/product_provider.dart';
import '../models/stock_history.dart';
import '../utils/constants.dart';
import '../utils/app_icons.dart';
import '../widgets/custom_appbar.dart';

class StockHistoryScreen extends StatefulWidget {
  final int? productId;

  const StockHistoryScreen({
    super.key,
    this.productId,
  });

  @override
  State<StockHistoryScreen> createState() => _StockHistoryScreenState();
}

class _StockHistoryScreenState extends State<StockHistoryScreen> {
  String _filterType = 'all'; // 'all', 'IN', 'OUT'
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StockHistoryProvider>().loadHistory(
            productId: widget.productId,
          );
    });
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _refreshHistory();
    }
  }

  void _refreshHistory() {
    context.read<StockHistoryProvider>().loadHistory(
          productId: widget.productId,
        );
  }

  List<StockHistory> _getFilteredHistory(List<StockHistory> history) {
    var filtered = history;

    // Type filter
    if (_filterType != 'all') {
      filtered = filtered.where((h) => h.type == _filterType).toList();
    }

    // Date range filter
    if (_startDate != null && _endDate != null) {
      filtered = filtered.where((h) {
        final date = DateTime.tryParse(h.date);
        if (date == null) return false;
        return date.isAfter(_startDate!.subtract(const Duration(days: 1))) &&
            date.isBefore(_endDate!.add(const Duration(days: 1)));
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final historyProvider = context.watch<StockHistoryProvider>();
    final productProvider = context.watch<ProductProvider>();
    final allHistory = historyProvider.history;
    final filteredHistory = _getFilteredHistory(allHistory);

    return Scaffold(
      appBar: CustomAppBar(
        title: widget.productId != null
            ? 'Ürün Stok Geçmişi'
            : 'Stok Geçmişi',
        showThemeToggle: false,
      ),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Type filter
                Row(
                  children: [
                    Expanded(
                      child: FilterChip(
                        label: const Text('Tümü'),
                        selected: _filterType == 'all',
                        onSelected: (selected) {
                          setState(() => _filterType = 'all');
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilterChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(AppIcons.stockIn, size: 16),
                            const SizedBox(width: 4),
                            const Text('Giriş'),
                          ],
                        ),
                        selected: _filterType == 'IN',
                        onSelected: (selected) {
                          setState(() => _filterType = 'IN');
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilterChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(AppIcons.stockOut, size: 16),
                            const SizedBox(width: 4),
                            const Text('Çıkış'),
                          ],
                        ),
                        selected: _filterType == 'OUT',
                        onSelected: (selected) {
                          setState(() => _filterType = 'OUT');
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Date range filter
                OutlinedButton.icon(
                  onPressed: () => _selectDateRange(context),
                  icon: const Icon(AppIcons.calendar),
                  label: Text(
                    _startDate != null && _endDate != null
                        ? '${DateFormat('dd/MM/yyyy').format(_startDate!)} - ${DateFormat('dd/MM/yyyy').format(_endDate!)}'
                        : 'Tarih Aralığı Seç',
                  ),
                ),
                if (_startDate != null && _endDate != null)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _startDate = null;
                        _endDate = null;
                      });
                      _refreshHistory();
                    },
                    child: const Text('Filtreyi Temizle'),
                  ),
              ],
            ),
          ),

          // History List
          Expanded(
            child: historyProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredHistory.isEmpty
                    ? _buildEmptyState(context)
                    : RefreshIndicator(
                        onRefresh: () async {
                          await context.read<StockHistoryProvider>().loadHistory(
                                productId: widget.productId,
                              );
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredHistory.length,
                          itemBuilder: (context, index) {
                            final historyItem = filteredHistory[index];
                            final product = productProvider.findById(
                              historyItem.productId,
                            );
                            return _buildHistoryCard(context, historyItem, product?.name);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            AppIcons.stockHistory,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Stok geçmişi bulunamadı',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Henüz stok hareketi yapılmamış',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(
    BuildContext context,
    StockHistory historyItem,
    String? productName,
  ) {
    final isIn = historyItem.type == 'IN';
    final date = DateTime.tryParse(historyItem.date);
    final formattedDate = date != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(date)
        : historyItem.date;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isIn
                ? AppConstants.successColor.withOpacity(0.1)
                : AppConstants.warningColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isIn ? AppIcons.stockIn : AppIcons.stockOut,
            color: isIn
                ? AppConstants.successColor
                : AppConstants.warningColor,
          ),
        ),
        title: Text(
          productName ?? 'Ürün #${historyItem.productId}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(formattedDate),
            if (historyItem.note != null && historyItem.note!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                historyItem.note!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isIn
                ? AppConstants.successColor.withOpacity(0.1)
                : AppConstants.warningColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${isIn ? '+' : '-'}${historyItem.amount}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isIn
                  ? AppConstants.successColor
                  : AppConstants.warningColor,
            ),
          ),
        ),
      ),
    );
  }
}

