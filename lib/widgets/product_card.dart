import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/settings_provider.dart';
import '../utils/constants.dart';
import '../l10n/app_localizations.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;
  final bool isSelectionMode;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
    this.isSelectionMode = false,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildProductImage(
    String imagePath,
    bool isCriticalStock, {
    double size = 32,
  }) {
    final isNetworkImage =
        imagePath.startsWith('http://') || imagePath.startsWith('https://');

    if (isNetworkImage) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.inventory_2_rounded,
            color: isCriticalStock
                ? AppConstants.criticalStockColor
                : AppConstants.primaryColor,
            size: size,
          );
        },
      );
    } else {
      final file = File(imagePath);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.inventory_2_rounded,
              color: isCriticalStock
                  ? AppConstants.criticalStockColor
                  : AppConstants.primaryColor,
              size: size,
            );
          },
        );
      } else {
        return Icon(
          Icons.inventory_2_rounded,
          color: isCriticalStock
              ? AppConstants.criticalStockColor
              : AppConstants.primaryColor,
          size: size,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCriticalStock =
        widget.product.stock <=
        context.watch<SettingsProvider>().lowStockThreshold;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: widget.isSelected
                ? Border.all(color: AppConstants.primaryColor, width: 2.5)
                : isCriticalStock
                ? Border.all(
                    color: AppConstants.criticalStockColor.withOpacity(0.4),
                    width: 2,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: widget.isSelected
                    ? AppConstants.primaryColor.withOpacity(0.2)
                    : isCriticalStock
                    ? AppConstants.criticalStockColor.withOpacity(0.1)
                    : Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                blurRadius: widget.isSelected ? 20 : 16,
                offset: const Offset(0, 6),
                spreadRadius: widget.isSelected ? 2 : 0,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              onLongPress: widget.onLongPress,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    // Selection Checkbox
                    if (widget.isSelectionMode)
                      Padding(
                        padding: const EdgeInsets.only(right: 14),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: widget.isSelected
                                ? AppConstants.primaryColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: widget.isSelected
                                  ? AppConstants.primaryColor
                                  : Colors.grey[400]!,
                              width: 2,
                            ),
                          ),
                          child: widget.isSelected
                              ? const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 18,
                                )
                              : null,
                        ),
                      ),

                    // Product Image
                    Hero(
                      tag: 'product_${widget.product.id}',
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isCriticalStock
                                ? [
                                    AppConstants.criticalStockColor.withOpacity(
                                      0.15,
                                    ),
                                    AppConstants.criticalStockColor.withOpacity(
                                      0.08,
                                    ),
                                  ]
                                : [
                                    AppConstants.primaryColor.withOpacity(0.15),
                                    AppConstants.secondaryColor.withOpacity(
                                      0.08,
                                    ),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: widget.product.imagePath != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: _buildProductImage(
                                  widget.product.imagePath!,
                                  isCriticalStock,
                                  size: 32,
                                ),
                              )
                            : Icon(
                                Icons.inventory_2_rounded,
                                color: isCriticalStock
                                    ? AppConstants.criticalStockColor
                                    : AppConstants.primaryColor,
                                size: 32,
                              ),
                      ),
                    ),
                    const SizedBox(width: 18),

                    // Product Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name & Critical Badge
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.product.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? Colors.white
                                        : AppConstants.neutralDark,
                                    letterSpacing: -0.3,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isCriticalStock)
                                Container(
                                  margin: const EdgeInsets.only(left: 10),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppConstants.criticalStockColor
                                            .withOpacity(0.2),
                                        AppConstants.criticalStockColor
                                            .withOpacity(0.1),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.warning_amber_rounded,
                                        size: 12,
                                        color: AppConstants.criticalStockColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        context.tr('critical'),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color:
                                              AppConstants.criticalStockColor,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Barcode
                          if (widget.product.barcode != null) ...[
                            Row(
                              children: [
                                Icon(
                                  Icons.qr_code_rounded,
                                  size: 15,
                                  color: isDark
                                      ? Colors.grey[500]
                                      : Colors.grey[500],
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    widget.product.barcode!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                          ],

                          // Stock Info
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: isCriticalStock
                                      ? AppConstants.criticalStockColor
                                            .withOpacity(0.12)
                                      : AppConstants.successColor.withOpacity(
                                          0.12,
                                        ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.inventory_2_rounded,
                                      size: 14,
                                      color: isCriticalStock
                                          ? AppConstants.criticalStockColor
                                          : AppConstants.successColor,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${context.tr('stock')}: ${widget.product.stock}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: isCriticalStock
                                            ? AppConstants.criticalStockColor
                                            : AppConstants.successColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Price
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppConstants.successColor.withOpacity(0.15),
                            AppConstants.successColor.withOpacity(0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${widget.product.salePrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppConstants.successColor,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            context.watch<SettingsProvider>().currencySymbol,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppConstants.successColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Premium Grid Product Card
class ProductGridCard extends StatefulWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const ProductGridCard({
    super.key,
    required this.product,
    this.onTap,
    this.onLongPress,
  });

  @override
  State<ProductGridCard> createState() => _ProductGridCardState();
}

class _ProductGridCardState extends State<ProductGridCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildProductImage(
    String imagePath,
    bool isCriticalStock, {
    double size = 40,
  }) {
    final isNetworkImage =
        imagePath.startsWith('http://') || imagePath.startsWith('https://');

    if (isNetworkImage) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.inventory_2_rounded,
            color: isCriticalStock
                ? AppConstants.criticalStockColor
                : AppConstants.primaryColor,
            size: size,
          );
        },
      );
    } else {
      final file = File(imagePath);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.inventory_2_rounded,
              color: isCriticalStock
                  ? AppConstants.criticalStockColor
                  : AppConstants.primaryColor,
              size: size,
            );
          },
        );
      } else {
        return Icon(
          Icons.inventory_2_rounded,
          color: isCriticalStock
              ? AppConstants.criticalStockColor
              : AppConstants.primaryColor,
          size: size,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCriticalStock =
        widget.product.stock <=
        context.watch<SettingsProvider>().lowStockThreshold;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: isCriticalStock
                ? Border.all(
                    color: AppConstants.criticalStockColor.withOpacity(0.4),
                    width: 2,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: isCriticalStock
                    ? AppConstants.criticalStockColor.withOpacity(0.15)
                    : Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              onLongPress: widget.onLongPress,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image
                    Expanded(
                      flex: 3,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isCriticalStock
                                ? [
                                    AppConstants.criticalStockColor.withOpacity(
                                      0.15,
                                    ),
                                    AppConstants.criticalStockColor.withOpacity(
                                      0.08,
                                    ),
                                  ]
                                : [
                                    AppConstants.primaryColor.withOpacity(0.15),
                                    AppConstants.secondaryColor.withOpacity(
                                      0.08,
                                    ),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: widget.product.imagePath != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: _buildProductImage(
                                        widget.product.imagePath!,
                                        isCriticalStock,
                                        size: 40,
                                      ),
                                    )
                                  : Icon(
                                      Icons.inventory_2_rounded,
                                      color: isCriticalStock
                                          ? AppConstants.criticalStockColor
                                          : AppConstants.primaryColor,
                                      size: 40,
                                    ),
                            ),
                            if (isCriticalStock)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppConstants.criticalStockColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Product Name
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? Colors.white
                                  : AppConstants.neutralDark,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),

                          // Stock Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isCriticalStock
                                  ? AppConstants.criticalStockColor.withOpacity(
                                      0.12,
                                    )
                                  : AppConstants.successColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${context.tr('stock')}: ${widget.product.stock}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isCriticalStock
                                    ? AppConstants.criticalStockColor
                                    : AppConstants.successColor,
                              ),
                            ),
                          ),
                          const Spacer(),

                          // Price
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppConstants.successColor.withOpacity(0.15),
                                  AppConstants.successColor.withOpacity(0.08),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${context.watch<SettingsProvider>().currencySymbol}${widget.product.salePrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppConstants.successColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
