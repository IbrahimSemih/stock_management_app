import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/brand_provider.dart';
import '../../utils/constants.dart';
import '../../utils/app_icons.dart';
import '../../models/product.dart';
import '../../widgets/product_card.dart';
import '../../widgets/custom_appbar.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ProductsListScreen extends StatefulWidget {
  const ProductsListScreen({super.key});

  @override
  State<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int? _selectedCategoryId;
  int? _selectedBrandId;
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    _loadViewMode();
  }

  Future<void> _loadViewMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isGridView = prefs.getString(AppConstants.keyViewMode) == 'grid';
    });
  }

  Future<void> _toggleViewMode() async {
    setState(() {
      _isGridView = !_isGridView;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.keyViewMode,
      _isGridView ? 'grid' : 'list',
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> _getFilteredProducts() {
    final productProvider = context.read<ProductProvider>();
    var products = productProvider.products;

    // Search filter
    if (_searchQuery.isNotEmpty) {
      products = products.where((product) {
        final query = _searchQuery.toLowerCase();
        return product.name.toLowerCase().contains(query) ||
            (product.barcode?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Category filter
    if (_selectedCategoryId != null) {
      products = products.where((product) {
        return product.categoryId == _selectedCategoryId;
      }).toList();
    }

    // Brand filter
    if (_selectedBrandId != null) {
      products = products.where((product) {
        return product.brandId == _selectedBrandId;
      }).toList();
    }

    return products;
  }

  void _showProductMenu(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(AppIcons.editProduct),
              title: const Text('Düzenle'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  AppConstants.routeProductEdit,
                  arguments: {'productId': product.id},
                );
              },
            ),
            ListTile(
              leading: const Icon(AppIcons.deleteProduct, color: Colors.red),
              title: const Text('Sil', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteDialog(context, product);
              },
            ),
            ListTile(
              leading: const Icon(AppIcons.stockIn),
              title: const Text('Stok Giriş'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  AppConstants.routeStockEntry,
                  arguments: {
                    'productId': product.id,
                    'type': AppConstants.stockTypeIn,
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(AppIcons.stockOut),
              title: const Text('Stok Çıkış'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  AppConstants.routeStockEntry,
                  arguments: {
                    'productId': product.id,
                    'type': AppConstants.stockTypeOut,
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(AppIcons.qrCode),
              title: const Text('QR Kod Oluştur'),
              onTap: () {
                Navigator.pop(context);
                _showQRCodeDialog(context, product);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ürünü Sil'),
        content: Text(
          '${product.name} ürününü silmek istediğinize emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              await context.read<ProductProvider>().deleteProduct(product.id!);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Ürün silindi')));
              }
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showQRCodeDialog(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QrImageView(
              data: product.barcode ?? product.id.toString(),
              version: QrVersions.auto,
              size: 200,
            ),
            const SizedBox(height: 16),
            Text('Barkod: ${product.barcode ?? product.id}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
          TextButton(
            onPressed: () async {
              // QR kod paylaşımı için görüntü oluşturulabilir
              Navigator.pop(context);
            },
            child: const Text('Paylaş'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final brandProvider = context.watch<BrandProvider>();
    final filteredProducts = _getFilteredProducts();

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Ürünler',
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(_isGridView ? AppIcons.listView : AppIcons.gridView),
              onPressed: _toggleViewMode,
              tooltip: _isGridView ? 'Liste Görünümü' : 'Grid Görünümü',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Ürün ara...',
                prefixIcon: const Icon(AppIcons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(AppIcons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _searchController.clear();
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Category Filter
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categoryProvider.categories.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  final isSelected = _selectedCategoryId == null;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: const Text('Tümü'),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategoryId = null;
                        });
                      },
                      selectedColor: AppConstants.primaryColor.withOpacity(0.2),
                      checkmarkColor: AppConstants.primaryColor,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppConstants.primaryColor
                            : Colors.grey[700],
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      avatar: isSelected
                          ? const Icon(
                              AppIcons.success,
                              size: 18,
                              color: AppConstants.primaryColor,
                            )
                          : null,
                    ),
                  );
                }
                final category = categoryProvider.categories[index - 1];
                final isSelected = _selectedCategoryId == category.id;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category.name),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategoryId = selected ? category.id : null;
                      });
                    },
                    selectedColor: AppConstants.primaryColor.withOpacity(0.2),
                    checkmarkColor: AppConstants.primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppConstants.primaryColor
                          : Colors.grey[700],
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    avatar: isSelected
                        ? const Icon(
                            Icons.check_circle_rounded,
                            size: 18,
                            color: AppConstants.primaryColor,
                          )
                        : null,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Brand Filter
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: brandProvider.brands.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  final isSelected = _selectedBrandId == null;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: const Text('Tüm Markalar'),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedBrandId = null;
                        });
                      },
                      selectedColor: AppConstants.secondaryColor.withOpacity(0.2),
                      checkmarkColor: AppConstants.secondaryColor,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppConstants.secondaryColor
                            : Colors.grey[700],
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  );
                }
                final brand = brandProvider.brands[index - 1];
                final isSelected = _selectedBrandId == brand.id;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(brand.name),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedBrandId = selected ? brand.id : null;
                      });
                    },
                    selectedColor: AppConstants.secondaryColor.withOpacity(0.2),
                    checkmarkColor: AppConstants.secondaryColor,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppConstants.secondaryColor
                          : Colors.grey[700],
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Products List/Grid
          Expanded(
            child: productProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredProducts.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _searchQuery.isNotEmpty
                                  ? AppIcons.search
                                  : AppIcons.products,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'Arama sonucu bulunamadı'
                                : 'Henüz ürün eklenmemiş',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'Farklı bir arama terimi deneyin'
                                : 'İlk ürününüzü ekleyerek başlayın',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (_searchQuery.isEmpty) ...[
                            const SizedBox(height: 24),
                            FilledButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  AppConstants.routeProductEdit,
                                  arguments: {'productId': null},
                                );
                              },
                              icon: const Icon(AppIcons.addProduct),
                              label: const Text('Ürün Ekle'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                : _isGridView
                ? GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return _buildGridCard(context, product);
                    },
                  )
                : ListView.builder(
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return ProductCard(
                        product: product,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppConstants.routeProductDetail,
                            arguments: {'productId': product.id},
                          );
                        },
                        onLongPress: () {
                          _showProductMenu(context, product);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'products_fab',
        onPressed: () {
          Navigator.pushNamed(
            context,
            AppConstants.routeProductEdit,
            arguments: {'productId': null},
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Ürün Ekle',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppConstants.primaryColor,
      ),
    );
  }

  Widget _buildGridCard(BuildContext context, Product product) {
    final isCriticalStock =
        product.stock <= AppConstants.criticalStockThreshold;

    return Card(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              AppConstants.routeProductDetail,
              arguments: {'productId': product.id},
            );
          },
          onLongPress: () {
            _showProductMenu(context, product);
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: isCriticalStock
                  ? Border.all(
                      color: AppConstants.criticalStockColor.withOpacity(0.3),
                      width: 1.5,
                    )
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppConstants.primaryColor.withOpacity(0.2),
                          AppConstants.primaryColor.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppConstants.primaryColor.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: product.imagePath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              product.imagePath!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  AppIcons.products,
                                  color: AppConstants.primaryColor,
                                  size: 40,
                                );
                              },
                            ),
                          )
                        : const Icon(
                            Icons.inventory_2_rounded,
                            color: AppConstants.primaryColor,
                            size: 40,
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                // Name
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                // Stock
                Row(
                  children: [
                    Icon(
                      Icons.inventory_2_rounded,
                      size: 12,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Stok: ',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      '${product.stock}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isCriticalStock
                            ? AppConstants.criticalStockColor
                            : AppConstants.successColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Price
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppConstants.successColor.withOpacity(0.1),
                        AppConstants.successColor.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${product.salePrice.toStringAsFixed(2)} ₺',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.successColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
