import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';
import '../../models/product.dart';
import '../../utils/constants.dart';

class ProductEditScreen extends StatefulWidget {
  final int? productId;
  final String? barcode;

  const ProductEditScreen({super.key, this.productId, this.barcode});

  @override
  State<ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends State<ProductEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _stockController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _salePriceController = TextEditingController();
  final _descriptionController = TextEditingController();

  int? _selectedCategoryId;
  String? _imagePath;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.productId != null) {
      _loadProduct();
    } else {
      _loadDefaultCategory();
      if (widget.barcode != null) {
        _barcodeController.text = widget.barcode!;
      }
    }
  }

  Future<void> _loadProduct() async {
    final productProvider = context.read<ProductProvider>();
    final product = productProvider.findById(widget.productId!);

    if (product != null) {
      setState(() {
        _nameController.text = product.name;
        _barcodeController.text = product.barcode ?? '';
        _stockController.text = product.stock.toString();
        _purchasePriceController.text = product.purchasePrice.toString();
        _salePriceController.text = product.salePrice.toString();
        _descriptionController.text = product.description ?? '';
        _selectedCategoryId = product.categoryId;
        _imagePath = product.imagePath;
      });
    }
  }

  Future<void> _loadDefaultCategory() async {
    final categoryProvider = context.read<CategoryProvider>();
    await categoryProvider.loadCategories();
    if (categoryProvider.categories.isNotEmpty) {
      setState(() {
        _selectedCategoryId = categoryProvider.categories.first.id;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _imagePath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Resim seçilirken hata: $e')));
      }
    }
  }

  Future<void> _scanBarcode() async {
    final result = await Navigator.pushNamed(
      context,
      AppConstants.routeBarcodeScan,
    );

    if (result != null && result is String) {
      setState(() {
        _barcodeController.text = result;
      });
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir kategori seçin')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final now = DateTime.now().toIso8601String();
    final product = Product(
      id: widget.productId,
      name: _nameController.text.trim(),
      barcode: _barcodeController.text.trim().isEmpty
          ? null
          : _barcodeController.text.trim(),
      categoryId: _selectedCategoryId!,
      stock: int.tryParse(_stockController.text) ?? 0,
      purchasePrice: double.tryParse(_purchasePriceController.text) ?? 0.0,
      salePrice: double.tryParse(_salePriceController.text) ?? 0.0,
      imagePath: _imagePath,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      createdAt: widget.productId != null
          ? (context
                    .read<ProductProvider>()
                    .findById(widget.productId!)
                    ?.createdAt ??
                now)
          : now,
      updatedAt: now,
    );

    final productProvider = context.read<ProductProvider>();
    if (widget.productId != null) {
      await productProvider.updateProduct(product);
    } else {
      await productProvider.addProduct(product);
    }

    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.productId != null ? 'Ürün güncellendi' : 'Ürün eklendi',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _barcodeController.dispose();
    _stockController.dispose();
    _purchasePriceController.dispose();
    _salePriceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productId != null ? 'Ürün Düzenle' : 'Ürün Ekle'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(icon: const Icon(Icons.check), onPressed: _saveProduct),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Image Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _imagePath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(_imagePath!),
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.image,
                              size: 64,
                              color: Colors.grey,
                            ),
                          ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Kamera'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Galeri'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Ürün Adı *',
                prefixIcon: Icon(Icons.inventory_2),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen ürün adını girin';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Barcode
            TextFormField(
              controller: _barcodeController,
              decoration: InputDecoration(
                labelText: 'Barkod',
                prefixIcon: const Icon(Icons.qr_code),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: _scanBarcode,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Category
            DropdownButtonFormField<int>(
              value: _selectedCategoryId,
              decoration: const InputDecoration(
                labelText: 'Kategori *',
                prefixIcon: Icon(Icons.category),
              ),
              items: categoryProvider.categories.map((category) {
                return DropdownMenuItem<int>(
                  value: category.id,
                  child: Text(category.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategoryId = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Lütfen bir kategori seçin';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Stock
            TextFormField(
              controller: _stockController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Stok Miktarı *',
                prefixIcon: Icon(Icons.inventory_2),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen stok miktarını girin';
                }
                if (int.tryParse(value) == null) {
                  return 'Geçerli bir sayı girin';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Purchase Price
            TextFormField(
              controller: _purchasePriceController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Alış Fiyatı *',
                prefixIcon: Icon(Icons.shopping_bag),
                suffixText: '₺',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen alış fiyatını girin';
                }
                if (double.tryParse(value) == null) {
                  return 'Geçerli bir fiyat girin';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Sale Price
            TextFormField(
              controller: _salePriceController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Satış Fiyatı *',
                prefixIcon: Icon(Icons.sell),
                suffixText: '₺',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen satış fiyatını girin';
                }
                if (double.tryParse(value) == null) {
                  return 'Geçerli bir fiyat girin';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Açıklama',
                prefixIcon: Icon(Icons.description),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveProduct,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(widget.productId != null ? 'Güncelle' : 'Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}
