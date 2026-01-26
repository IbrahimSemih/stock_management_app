import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';
import '../utils/app_icons.dart';
import '../screens/dashboard_screen.dart';
import '../screens/products/products_list_screen.dart';
import '../screens/categories_screen.dart';
import '../screens/stock_history_screen.dart';
import '../screens/reports_screen.dart';
import '../l10n/app_localizations.dart';

class MainNavigation extends StatefulWidget {
  final int initialIndex;

  const MainNavigation({super.key, this.initialIndex = 0});

  @override
  State<MainNavigation> createState() => MainNavigationState();
}

class MainNavigationState extends State<MainNavigation>
    with SingleTickerProviderStateMixin {
  late int _currentIndex;
  late final List<Widget> _screens;
  late AnimationController _fabAnimationController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _screens = [
      const DashboardScreen(),
      const ProductsListScreen(),
      const CategoriesScreen(),
      const StockHistoryScreen(),
      const ReportsScreen(),
    ];

    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
      _fabAnimationController.reset();
      _fabAnimationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: isDark
            ? const Color(0xFF0F172A)
            : Colors.white,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: _screens),
        extendBody: true,
        bottomNavigationBar: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.4 : 0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
                spreadRadius: -4,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    icon: AppIcons.dashboard,
                    label: context.tr('dashboard'),
                    index: 0,
                    isDark: isDark,
                  ),
                  _buildNavItem(
                    icon: AppIcons.products,
                    label: context.tr('products'),
                    index: 1,
                    isDark: isDark,
                  ),
                  _buildNavItem(
                    icon: AppIcons.categories,
                    label: context.tr('categories'),
                    index: 2,
                    isDark: isDark,
                  ),
                  _buildNavItem(
                    icon: Icons.history_rounded,
                    label: context.tr('stock_history'),
                    index: 3,
                    isDark: isDark,
                  ),
                  _buildNavItem(
                    icon: AppIcons.reports,
                    label: context.tr('reports'),
                    index: 4,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isDark,
  }) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 14 : 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppConstants.primaryColor.withOpacity(0.15),
                    AppConstants.secondaryColor.withOpacity(0.08),
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                size: isSelected ? 24 : 22,
                color: isSelected
                    ? AppConstants.primaryColor
                    : (isDark ? Colors.grey[500] : Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppConstants.primaryColor
                    : (isDark ? Colors.grey[500] : Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
