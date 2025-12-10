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
import '../l10n/app_localizations.dart';

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
        appBar: CustomAppBar(title: context.tr('categories')),
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
                      context.tr('empty_categories'),
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
              text: context.tr('brands'),
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
              text: context.tr('add_category'),
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
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('add_category')),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(
            hintText: context.tr('category_name'),
            labelText: context.tr('category_name'),
          ),
          autofocus: true,
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              _addCategory(context, ctx, value.trim());
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              if (textController.text.trim().isNotEmpty) {
                _addCategory(context, ctx, textController.text.trim());
              }
            },
            child: Text(context.tr('add')),
          ),
        ],
      ),
    );
  }

  Future<void> _addCategory(BuildContext context, BuildContext dialogContext, String name) async {
    final category = Category(name: name);
    await context.read<CategoryProvider>().addCategory(category);
    if (dialogContext.mounted) {
      Navigator.pop(dialogContext);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('category_added'))),
      );
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
        subtitle: Text('$productCount ${context.tr('items')}'),
        trailing: PopupMenuButton(
          itemBuilder: (ctx) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  const Icon(AppIcons.editProduct, size: 20),
                  const SizedBox(width: 8),
                  Text(context.tr('edit')),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(AppIcons.deleteProduct, size: 20, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(context.tr('delete'), style: const TextStyle(color: Colors.red)),
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
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('edit_category')),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(
            hintText: context.tr('category_name'),
            labelText: context.tr('category_name'),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr('cancel')),
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
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.tr('category_updated'))),
                  );
                }
              }
            },
            child: Text(context.tr('update')),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('delete_category')),
        content: Text(context.tr('delete_category_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr('cancel')),
          ),
          TextButton(
            onPressed: () async {
              await context.read<CategoryProvider>().deleteCategory(
                category.id!,
              );
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.tr('category_deleted'))),
                );
              }
            },
            child: Text(context.tr('delete'), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
