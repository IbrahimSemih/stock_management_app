import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/category_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/constants.dart';
import '../utils/app_icons.dart';
import '../widgets/premium_widgets.dart';
import '../l10n/app_localizations.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await context.read<ProductProvider>().loadAllProducts();
              await context.read<CategoryProvider>().loadCategories();
            },
            color: AppConstants.primaryColor,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Premium App Bar
                SliverToBoxAdapter(child: _buildHeader(context)),

                // Content
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Welcome Banner
                      _buildWelcomeBanner(context),
                      const SizedBox(height: 28),

                      // Stats Section
                      _buildStatsSection(context),
                      const SizedBox(height: 28),

                      // Quick Actions
                      _buildQuickActionsSection(context),
                      const SizedBox(height: 28),

                      // Recent Products
                      _buildRecentProductsSection(context),
                      const SizedBox(height: 28),

                      // Critical Stock
                      _buildCriticalStockSection(context),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Row(
        children: [
          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dashboard',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppConstants.neutralDark,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  _getGreeting(context),
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Notifications
          PremiumIconButton(icon: AppIcons.notifications, onPressed: () {}),
          const SizedBox(width: 12),

          // Settings Menu
          PopupMenuButton(
            icon: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                AppIcons.more,
                color: isDark
                    ? AppConstants.primaryLight
                    : AppConstants.primaryColor,
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            offset: const Offset(0, 56),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        AppIcons.settings,
                        size: 18,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      context.tr('settings'),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.pushNamed(context, AppConstants.routeSettings);
                },
              ),
              PopupMenuItem(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppConstants.errorColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        AppIcons.logout,
                        size: 18,
                        color: AppConstants.errorColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      context.tr('logout'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppConstants.errorColor,
                      ),
                    ),
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
    );
  }

  String _getGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    if (hour < 12) return context.tr('good_morning');
    if (hour < 18) return context.tr('good_afternoon');
    return context.tr('good_evening');
  }

  Widget _buildWelcomeBanner(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final userName =
        user?.displayName ?? user?.email?.split('@')[0] ?? context.tr('user');

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2563EB), Color(0xFF7C3AED), Color(0xFF9333EA)],
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryColor.withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 12),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Pattern
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 40,
            bottom: -30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.warehouse_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            userName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                '${context.tr('welcome')}! 👋',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.tr('app_slogan'),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final settings = context.watch<SettingsProvider>();
    final products = productProvider.products;

    final totalProducts = products.length;
    final totalStock = products.fold<int>(
      0,
      (sum, product) => sum + product.stock,
    );
    final criticalProducts = products
        .where((p) => p.stock <= settings.lowStockThreshold)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PremiumSectionHeader(title: context.tr('dashboard')),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: Row(
            children: [
              Expanded(
                child: PremiumStatCard(
                  icon: AppIcons.products,
                  title: context.tr('total_products'),
                  value: totalProducts.toString(),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF10B981), Color(0xFF059669)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppConstants.successColor.withOpacity(0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  AppIcons.faShoppingCart,
                                  color: Colors.white.withOpacity(0.9),
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    context.tr('stock'),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white.withOpacity(0.9),
                                      fontWeight: FontWeight.w600,
                                      height: 1.2,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              totalStock.toString(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: criticalProducts > 0
                                ? [
                                    const Color(0xFFEF4444),
                                    const Color(0xFFDC2626),
                                  ]
                                : [
                                    const Color(0xFF6B7280),
                                    const Color(0xFF4B5563),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (criticalProducts > 0
                                          ? AppConstants.errorColor
                                          : Colors.grey)
                                      .withOpacity(0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  AppIcons.criticalStock,
                                  color: Colors.white.withOpacity(0.9),
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    context.tr('critical_stock'),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white.withOpacity(0.9),
                                      fontWeight: FontWeight.w600,
                                      height: 1.2,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              criticalProducts.toString(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PremiumSectionHeader(title: context.tr('quick_actions')),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.15,
          children: [
            PremiumActionCard(
              icon: AppIcons.addProduct,
              title: context.tr('add_product'),
              subtitle: context.tr('add_first_product'),
              color: AppConstants.primaryColor,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppConstants.routeProductEdit,
                  arguments: {'productId': null},
                );
              },
            ),
            PremiumActionCard(
              icon: AppIcons.stockIn,
              title: context.tr('stock_in'),
              subtitle: context.tr('add_stock'),
              color: AppConstants.successColor,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppConstants.routeStockEntry,
                  arguments: {'type': AppConstants.stockTypeIn},
                );
              },
            ),
            PremiumActionCard(
              icon: AppIcons.stockOut,
              title: context.tr('stock_out'),
              subtitle: context.tr('remove_stock'),
              color: AppConstants.warningColor,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppConstants.routeStockEntry,
                  arguments: {'type': AppConstants.stockTypeOut},
                );
              },
            ),
            PremiumActionCard(
              icon: AppIcons.barcode,
              title: context.tr('scan_barcode'),
              subtitle: context.tr('barcode'),
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
    final settings = context.watch<SettingsProvider>();
    final products = productProvider.products;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (products.isEmpty) {
      return PremiumEmptyState(
        icon: AppIcons.products,
        title: context.tr('no_products'),
        subtitle: context.tr('add_first_product'),
        actionText: context.tr('add_product'),
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
        PremiumSectionHeader(
          title: context.tr('recent_products'),
          actionText: context.tr('see_all'),
          actionIcon: Icons.arrow_forward_rounded,
          onActionTap: () {
            Navigator.pushNamed(context, AppConstants.routeProducts);
          },
        ),
        const SizedBox(height: 16),
        ...recentProducts.asMap().entries.map((entry) {
          final index = entry.key;
          final product = entry.value;

          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 400 + (index * 100)),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: PremiumCard(
              margin: const EdgeInsets.only(bottom: 12),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppConstants.routeProductDetail,
                  arguments: {'productId': product.id},
                );
              },
              child: Row(
                children: [
                  // Product Icon
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppConstants.primaryColor.withOpacity(0.15),
                          AppConstants.secondaryColor.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      AppIcons.products,
                      color: AppConstants.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Product Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? Colors.white
                                : AppConstants.neutralDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.inventory_2_rounded,
                              size: 14,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${context.tr('stock')}: ${product.stock}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Price Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppConstants.successColor.withOpacity(0.15),
                          AppConstants.successColor.withOpacity(0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${settings.currencySymbol}${product.salePrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppConstants.successColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCriticalStockSection(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final settings = context.watch<SettingsProvider>();
    final products = productProvider.products;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final criticalProducts = products
        .where((p) => p.stock <= settings.lowStockThreshold)
        .toList();

    if (criticalProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PremiumSectionHeader(
          title: context.tr('critical_stock'),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppConstants.criticalStockColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              AppIcons.criticalStock,
              color: AppConstants.criticalStockColor,
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...criticalProducts.asMap().entries.map((entry) {
          final index = entry.key;
          final product = entry.value;

          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 400 + (index * 100)),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? AppConstants.criticalStockColor.withOpacity(0.1)
                    : AppConstants.criticalStockColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppConstants.criticalStockColor.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
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
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Warning Icon
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppConstants.criticalStockColor.withOpacity(
                              0.15,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.warning_amber_rounded,
                            color: AppConstants.criticalStockColor,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Product Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? Colors.white
                                      : AppConstants.neutralDark,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppConstants.criticalStockColor
                                          .withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${context.tr('stock')}: ${product.stock}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppConstants.criticalStockColor,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Add Stock Button
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppConstants.criticalStockColor,
                                Color(0xFFB91C1C),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppConstants.criticalStockColor
                                    .withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppConstants.routeStockEntry,
                                  arguments: {
                                    'productId': product.id,
                                    'type': AppConstants.stockTypeIn,
                                  },
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.add_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      context.tr('add'),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
