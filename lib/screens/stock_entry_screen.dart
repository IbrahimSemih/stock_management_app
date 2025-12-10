import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/product_provider.dart';
import '../utils/constants.dart';
import '../l10n/app_localizations.dart';

class StockEntryScreen extends StatefulWidget {
  final int? productId;
  final String type; // 'IN' or 'OUT'

  const StockEntryScreen({
    super.key,
    this.productId,
    required this.type,
  });

  @override
  State<StockEntryScreen> createState() => _StockEntryScreenState();
}

class _StockEntryScreenState extends State<StockEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  int? _selectedProductId;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.productId != null) {
      _selectedProductId = widget.productId;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveStockEntry() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedProductId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir ürün seçin')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final amount = int.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geçerli bir miktar girin')),
      );
      return;
    }

    final productProvider = context.read<ProductProvider>();
    final product = productProvider.findById(_selectedProductId!);

    if (product != null) {
      // Stok çıkış için kontrol
      if (widget.type == AppConstants.stockTypeOut &&
          product.stock < amount) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Yetersiz stok! Mevcut stok: ${product.stock}',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      await productProvider.changeStock(
        _selectedProductId!,
        amount,
        widget.type,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );

      setState(() => _isLoading = false);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.type == AppConstants.stockTypeIn
                  ? 'Stok girişi yapıldı'
                  : 'Stok çıkışı yapıldı',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final isStockIn = widget.type == AppConstants.stockTypeIn;

    return Scaffold(
      appBar: AppBar(
        title: Text(isStockIn ? context.tr('stock_in') : context.tr('stock_out')),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Product Selection (if not provided)
            if (widget.productId == null) ...[
              DropdownButtonFormField<int>(
                value: _selectedProductId,
                decoration: InputDecoration(
                  labelText: '${context.tr('product')} *',
                  prefixIcon: const Icon(Icons.inventory_2),
                  suffixIcon: _selectedProductId != null
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _selectedProductId = null;
                            });
                          },
                        )
                      : null,
                ),
                items: productProvider.products.map((product) {
                  return DropdownMenuItem<int>(
                    value: product.id,
                    child: Text('${product.name} (${context.tr('stock')}: ${product.stock})'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProductId = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return context.tr('required_field');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
            ] else ...[
              // Show selected product info
              Card(
                child: ListTile(
                  leading: const Icon(Icons.inventory_2),
                  title: Text(
                    productProvider.findById(widget.productId!)?.name ?? '',
                  ),
                  subtitle: Text(
                    '${context.tr('stock')}: ${productProvider.findById(widget.productId!)?.stock ?? 0}',
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Amount
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '${context.tr('quantity')} *',
                prefixIcon: Icon(isStockIn ? Icons.add : Icons.remove),
                helperText: widget.productId != null
                    ? '${context.tr('stock')}: ${productProvider.findById(widget.productId!)?.stock ?? 0}'
                    : null,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return context.tr('enter_valid_quantity');
                }
                final amount = int.tryParse(value);
                if (amount == null || amount <= 0) {
                  return context.tr('enter_valid_quantity');
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Date
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: '${context.tr('date')} *',
                  prefixIcon: const Icon(Icons.calendar_today),
                ),
                child: Text(
                  DateFormat(AppConstants.dateFormat).format(_selectedDate),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Note
            TextFormField(
              controller: _noteController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: context.tr('note'),
                prefixIcon: const Icon(Icons.note),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveStockEntry,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: isStockIn
                    ? AppConstants.successColor
                    : AppConstants.warningColor,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      isStockIn ? context.tr('add_stock') : context.tr('remove_stock'),
                      style: const TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

