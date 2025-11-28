import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../providers/product_provider.dart';
import '../models/category.dart';
import '../utils/app_icons.dart';
import '../utils/constants.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/premium_widgets.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

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
        appBar: const CustomAppBar(title: 'Kategoriler'),
        body: Consumer<CategoryProvider>(
          builder: (context, categoryProvider, _) {
            if (categoryProvider.categories.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(AppIcons.categories, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Henüz kategori eklenmemiş',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: categoryProvider.categories.length,
              itemBuilder: (context, index) {
                final category = categoryProvider.categories[index];
                return _CategoryCard(category: category);
              },
            );
          },
        ),
        floatingActionButton: PremiumFABGroup(
          items: [
            PremiumFABItem(
              text: 'Markalar',
              icon: Icons.business_rounded,
              gradient: const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFF9333EA)],
              ),
              shadowColor: AppConstants.secondaryColor,
              onPressed: () {
                Navigator.pushNamed(context, AppConstants.routeBrands);
              },
            ),
            PremiumFABItem(
              text: 'Kategori Ekle',
              icon: Icons.add_rounded,
              onPressed: () => _showAddCategoryDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Kategori'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: 'Kategori adı',
            labelText: 'Kategori Adı',
          ),
          autofocus: true,
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              _addCategory(context, value.trim());
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (textController.text.trim().isNotEmpty) {
                _addCategory(context, textController.text.trim());
              }
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  Future<void> _addCategory(BuildContext context, String name) async {
    final category = Category(name: name);
    await context.read<CategoryProvider>().addCategory(category);
    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Kategori eklendi')));
    }
  }
}

class _CategoryCard extends StatelessWidget {
  final Category category;

  const _CategoryCard({required this.category});

  int _getProductCount(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    return productProvider.products
        .where((product) => product.categoryId == category.id)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final productCount = _getProductCount(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.withOpacity(0.1),
          child: const Icon(AppIcons.categories, color: Colors.blue),
        ),
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('$productCount ürün'),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: const Row(
                children: [
                  Icon(AppIcons.editProduct, size: 20),
                  SizedBox(width: 8),
                  Text('Düzenle'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: const Row(
                children: [
                  Icon(AppIcons.deleteProduct, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Sil', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) async {
            if (value == 'edit') {
              _showEditDialog(context);
            } else if (value == 'delete') {
              _showDeleteDialog(context);
            }
          },
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final textController = TextEditingController(text: category.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kategori Düzenle'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: 'Kategori adı',
            labelText: 'Kategori Adı',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (textController.text.trim().isNotEmpty) {
                final updatedCategory = Category(
                  id: category.id,
                  name: textController.text.trim(),
                );
                await context.read<CategoryProvider>().updateCategory(
                  updatedCategory,
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Kategori güncellendi')),
                  );
                }
              }
            },
            child: const Text('Güncelle'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kategoriyi Sil'),
        content: Text(
          '${category.name} kategorisini silmek istediğinize emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              await context.read<CategoryProvider>().deleteCategory(
                category.id!,
              );
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Kategori silindi')),
                );
              }
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
