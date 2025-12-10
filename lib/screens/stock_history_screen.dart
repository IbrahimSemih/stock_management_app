import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/stock_history_provider.dart';
import '../providers/product_provider.dart';
import '../models/stock_history.dart';
import '../utils/constants.dart';
import '../utils/app_icons.dart';
import '../widgets/custom_appbar.dart';
import '../l10n/app_localizations.dart';

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
        title: context.tr('stock_history'),
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
                      child: _buildFilterButton(
                        context: context,
                        label: context.tr('all'),
                        icon: Icons.check,
                        isSelected: _filterType == 'all',
                        color: Theme.of(context).primaryColor,
                        onTap: () => setState(() => _filterType = 'all'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildFilterButton(
                        context: context,
                        label: context.tr('stock_in'),
                        icon: AppIcons.stockIn,
                        isSelected: _filterType == 'IN',
                        color: AppConstants.successColor,
                        onTap: () => setState(() => _filterType = 'IN'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildFilterButton(
                        context: context,
                        label: context.tr('stock_out'),
                        icon: AppIcons.stockOut,
                        isSelected: _filterType == 'OUT',
                        color: AppConstants.warningColor,
                        onTap: () => setState(() => _filterType = 'OUT'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Date range filter
                Column(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _selectDateRange(context),
                      icon: const Icon(AppIcons.calendar),
                      label: Text(context.tr('custom_range')),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        side: BorderSide(
                          color: _startDate != null && _endDate != null
                              ? Theme.of(context).primaryColor
                              : Colors.grey.withOpacity(0.5),
                          width: _startDate != null && _endDate != null ? 2 : 1,
                        ),
                        backgroundColor: _startDate != null && _endDate != null
                            ? Theme.of(context).primaryColor.withOpacity(0.1)
                            : null,
                      ),
                    ),
                    if (_startDate != null && _endDate != null) ...[
                      const SizedBox(height: 10),
                      _buildSelectedDateRangeChip(context),
                    ],
                  ],
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
            context.tr('no_stock_history'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr('empty_history'),
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDateRangeChip(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final startFormatted = DateFormat('dd MMM').format(_startDate!);
    final endFormatted = DateFormat('dd MMM yyyy').format(_endDate!);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withOpacity(0.15),
            primaryColor.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: primaryColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.date_range,
            size: 18,
            color: primaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            '$startFormatted  →  $endFormatted',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: () {
              setState(() {
                _startDate = null;
                _endDate = null;
              });
              _refreshHistory();
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                size: 16,
                color: Colors.red[400],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.15) : Colors.grey.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.grey.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? color : Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? color : Colors.grey[700],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
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
          productName ?? '${context.tr('product')} #${historyItem.productId}',
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

