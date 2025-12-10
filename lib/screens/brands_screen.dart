import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/brand_provider.dart';
import '../providers/product_provider.dart';
import '../models/brand.dart';
import '../utils/app_icons.dart';
import '../widgets/custom_appbar.dart';
import '../l10n/app_localizations.dart';

class BrandsScreen extends StatelessWidget {
  const BrandsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: context.tr('brands')),
      body: Consumer<BrandProvider>(
        builder: (context, brandProvider, _) {
          if (brandProvider.brands.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.branding_watermark, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    context.tr('empty_brands'),
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: brandProvider.brands.length,
            itemBuilder: (context, index) {
              final brand = brandProvider.brands[index];
              return _BrandCard(brand: brand);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'brands_fab',
        onPressed: () => _showAddBrandDialog(context),
        icon: const Icon(AppIcons.add),
        label: Text(context.tr('add_brand')),
      ),
    );
  }

  void _showAddBrandDialog(BuildContext context) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('add_brand')),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(
            hintText: context.tr('brand_name'),
            labelText: context.tr('brand_name'),
          ),
          autofocus: true,
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              _addBrand(context, ctx, value.trim());
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
                _addBrand(context, ctx, textController.text.trim());
              }
            },
            child: Text(context.tr('add')),
          ),
        ],
      ),
    );
  }

  Future<void> _addBrand(BuildContext context, BuildContext dialogContext, String name) async {
    try {
      final brand = Brand(name: name);
      await context.read<BrandProvider>().addBrand(brand);
      if (dialogContext.mounted) {
        Navigator.pop(dialogContext);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('brand_added'))),
        );
      }
    } catch (e) {
      if (dialogContext.mounted) {
        Navigator.pop(dialogContext);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${context.tr('error')}: $e')),
        );
      }
    }
  }
}

class _BrandCard extends StatelessWidget {
  final Brand brand;

  const _BrandCard({required this.brand});

  int _getProductCount(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    return productProvider.products
        .where((product) => product.brandId == brand.id)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final productCount = _getProductCount(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.purple.withOpacity(0.1),
          child: const Icon(Icons.branding_watermark, color: Colors.purple),
        ),
        title: Text(
          brand.name,
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
    final textController = TextEditingController(text: brand.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('edit_brand')),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(
            hintText: context.tr('brand_name'),
            labelText: context.tr('brand_name'),
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
                final updatedBrand = Brand(
                  id: brand.id,
                  name: textController.text.trim(),
                );
                await context.read<BrandProvider>().updateBrand(
                  updatedBrand,
                );
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.tr('brand_updated'))),
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
        title: Text(context.tr('delete_brand')),
        content: Text(context.tr('delete_brand_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr('cancel')),
          ),
          TextButton(
            onPressed: () async {
              try {
                await context.read<BrandProvider>().deleteBrand(
                  brand.id!,
                );
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.tr('brand_deleted'))),
                  );
                }
              } catch (e) {
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${context.tr('error')}: $e')),
                  );
                }
              }
            },
            child: Text(context.tr('delete'), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

