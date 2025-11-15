import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../models/category.dart';
import '../services/db_helper.dart';
import '../utils/app_icons.dart';
import '../widgets/custom_appbar.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Kategoriler'),
      body: Consumer<CategoryProvider>(
        builder: (context, categoryProvider, _) {
          if (categoryProvider.categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    AppIcons.categories,
                    size: 64,
                    color: Colors.grey[400],
                  ),
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
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'categories_fab',
        onPressed: () => _showAddCategoryDialog(context),
        icon: const Icon(AppIcons.add),
        label: const Text('Kategori Ekle'),
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

  Future<int> _getProductCount() async {
    final db = DBHelper.instance;
    final rows = await db.query(
      'products',
      where: 'category_id = ?',
      whereArgs: [category.id],
    );
    return rows.length;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _getProductCount(),
      builder: (context, snapshot) {
        final productCount = snapshot.data ?? 0;

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
      },
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
