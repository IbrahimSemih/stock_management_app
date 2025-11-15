import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/category_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../utils/app_icons.dart';
import '../widgets/custom_appbar.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Dashboard',
        actions: [
          IconButton(
            icon: const Icon(AppIcons.notifications),
            onPressed: () {},
            tooltip: 'Bildirimler',
          ),
          PopupMenuButton(
            icon: const Icon(AppIcons.more),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(AppIcons.settings, size: 20),
                    SizedBox(width: 12),
                    Text('Ayarlar'),
                  ],
                ),
                onTap: () {
                  Navigator.pushNamed(context, AppConstants.routeSettings);
                },
              ),
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(AppIcons.logout, size: 20, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Çıkış Yap', style: TextStyle(color: Colors.red)),
                  ],
                ),
                onTap: () async {
                  await context.read<AuthProvider>().signOut();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(
                      context,
                      AppConstants.routeLogin,
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<ProductProvider>().loadAllProducts();
          await context.read<CategoryProvider>().loadCategories();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              _buildWelcomeSection(context),
              const SizedBox(height: 24),

              // Stats Cards
              _buildStatsSection(context),
              const SizedBox(height: 24),

              // Quick Actions
              _buildQuickActionsSection(context),
              const SizedBox(height: 24),

              // Recent Products
              _buildRecentProductsSection(context),
              const SizedBox(height: 24),

              // Critical Stock Products
              _buildCriticalStockSection(context),
            ],
          ),
        ),
      ),
      drawer: _buildDrawer(context),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 123, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppConstants.primaryColor, AppConstants.secondaryColor],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hoş Geldiniz! 👋',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Stok yönetiminizi kolaylaştıralım',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final products = productProvider.products;

    final totalProducts = products.length;
    final totalStock = products.fold<int>(
      0,
      (sum, product) => sum + product.stock,
    );
    final criticalProducts = products
        .where((p) => p.stock <= AppConstants.criticalStockThreshold)
        .length;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: AppIcons.products,
            title: 'Toplam Ürün',
            value: totalProducts.toString(),
            color: AppConstants.primaryColor,
            gradient: LinearGradient(
              colors: [
                AppConstants.primaryColor.withOpacity(0.8),
                AppConstants.primaryColor,
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: AppIcons.faShoppingCart,
            title: 'Toplam Stok',
            value: totalStock.toString(),
            color: AppConstants.secondaryColor,
            gradient: LinearGradient(
              colors: [
                AppConstants.secondaryColor.withOpacity(0.8),
                AppConstants.secondaryColor,
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: AppIcons.criticalStock,
            title: 'Kritik Stok',
            value: criticalProducts.toString(),
            color: AppConstants.criticalStockColor,
            gradient: LinearGradient(
              colors: [
                AppConstants.criticalStockColor.withOpacity(0.8),
                AppConstants.criticalStockColor,
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hızlı İşlemler',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.4,
          children: [
            _QuickActionCard(
              icon: AppIcons.addProduct,
              title: 'Ürün Ekle',
              subtitle: 'Yeni ürün ekle',
              color: AppConstants.primaryColor,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppConstants.routeProductEdit,
                  arguments: {'productId': null},
                );
              },
            ),
            _QuickActionCard(
              icon: AppIcons.stockIn,
              title: 'Stok Giriş',
              subtitle: 'Stok artır',
              color: AppConstants.successColor,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppConstants.routeStockEntry,
                  arguments: {'type': AppConstants.stockTypeIn},
                );
              },
            ),
            _QuickActionCard(
              icon: AppIcons.stockOut,
              title: 'Stok Çıkış',
              subtitle: 'Stok azalt',
              color: AppConstants.warningColor,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppConstants.routeStockEntry,
                  arguments: {'type': AppConstants.stockTypeOut},
                );
              },
            ),
            _QuickActionCard(
              icon: AppIcons.barcode,
              title: 'Barkod Tara',
              subtitle: 'Hızlı tarama',
              color: AppConstants.accentColor,
              onTap: () {
                Navigator.pushNamed(context, AppConstants.routeBarcodeScan);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentProductsSection(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final products = productProvider.products;

    if (products.isEmpty) {
      return _buildEmptyState(
        context,
        icon: AppIcons.products,
        title: 'Henüz ürün yok',
        subtitle: 'İlk ürününüzü ekleyerek başlayın',
        actionText: 'Ürün Ekle',
        onAction: () {
          Navigator.pushNamed(
            context,
            AppConstants.routeProductEdit,
            arguments: {'productId': null},
          );
        },
      );
    }

    final recentProducts = products.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Son Eklenenler',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, AppConstants.routeProducts);
              },
              icon: const Icon(AppIcons.arrowRight, size: 14),
              label: const Text('Tümünü Gör'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...recentProducts.asMap().entries.map((entry) {
          final index = entry.key;
          final product = entry.value;
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 300 + (index * 50)),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppConstants.primaryColor.withOpacity(0.2),
                        AppConstants.primaryColor.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    AppIcons.products,
                    color: AppConstants.primaryColor,
                  ),
                ),
                title: Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text('Stok: ${product.stock}'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${product.salePrice.toStringAsFixed(2)} ₺',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppConstants.successColor,
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppConstants.routeProductDetail,
                    arguments: {'productId': product.id},
                  );
                },
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCriticalStockSection(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final products = productProvider.products;

    final criticalProducts = products
        .where((p) => p.stock <= AppConstants.criticalStockThreshold)
        .toList();

    if (criticalProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppConstants.criticalStockColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                AppIcons.criticalStock,
                color: AppConstants.criticalStockColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Kritik Stoktaki Ürünler',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppConstants.criticalStockColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...criticalProducts.asMap().entries.map((entry) {
          final index = entry.key;
          final product = entry.value;
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 300 + (index * 50)),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: AppConstants.criticalStockColor.withOpacity(0.05),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppConstants.criticalStockColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    AppIcons.criticalStock,
                    color: AppConstants.criticalStockColor,
                  ),
                ),
                title: Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Stok: ${product.stock}',
                  style: const TextStyle(
                    color: AppConstants.criticalStockColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: FilledButton.icon(
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
                  icon: const Icon(AppIcons.add, size: 18),
                  label: const Text('Ekle'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppConstants.criticalStockColor,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionText,
    required VoidCallback onAction,
  }) {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(AppIcons.add),
                label: Text(actionText),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppConstants.primaryColor,
                  AppConstants.secondaryColor,
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        AppIcons.appLogo,
                        size: 28,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      AppConstants.appName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Stok Yönetim Sistemi',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _DrawerItem(
                  icon: AppIcons.dashboard,
                  title: 'Dashboard',
                  onTap: () => Navigator.pop(context),
                ),
                _DrawerItem(
                  icon: AppIcons.products,
                  title: 'Ürünler',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppConstants.routeProducts);
                  },
                ),
                _DrawerItem(
                  icon: AppIcons.categories,
                  title: 'Kategoriler',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppConstants.routeCategories);
                  },
                ),
                _DrawerItem(
                  icon: AppIcons.reports,
                  title: 'Raporlar',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppConstants.routeReports);
                  },
                ),
                const Divider(height: 32),
                _DrawerItem(
                  icon: AppIcons.settings,
                  title: 'Ayarlar',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppConstants.routeSettings);
                  },
                ),
                _DrawerItem(
                  icon: AppIcons.logout,
                  title: 'Çıkış Yap',
                  isDestructive: true,
                  onTap: () async {
                    Navigator.pop(context);
                    await context.read<AuthProvider>().signOut();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(
                        context,
                        AppConstants.routeLogin,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final Gradient? gradient;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.2), width: 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 26),
                ),
                const SizedBox(height: 10),
                Flexible(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 2),
                Flexible(
                  child: Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : null),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : null,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
