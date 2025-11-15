import 'package:flutter/material.dart';
import '../utils/app_icons.dart';
import '../screens/dashboard_screen.dart';
import '../screens/products/products_list_screen.dart';
import '../screens/categories_screen.dart';
import '../screens/reports_screen.dart';

class MainNavigation extends StatefulWidget {
  final int initialIndex;

  const MainNavigation({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _currentIndex;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _screens = [
      const DashboardScreen(),
      const ProductsListScreen(),
      const CategoriesScreen(),
      const ReportsScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(AppIcons.dashboard),
            selectedIcon: Icon(AppIcons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(AppIcons.products),
            selectedIcon: Icon(AppIcons.products),
            label: 'Ürünler',
          ),
          NavigationDestination(
            icon: Icon(AppIcons.categories),
            selectedIcon: Icon(AppIcons.categories),
            label: 'Kategoriler',
          ),
          NavigationDestination(
            icon: Icon(AppIcons.reports),
            selectedIcon: Icon(AppIcons.reports),
            label: 'Raporlar',
          ),
        ],
      ),
    );
  }
}

