import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'widgets/main_navigation.dart';
import 'screens/products/product_detail_screen.dart';
import 'screens/products/product_edit_screen.dart';
import 'screens/barcode_scan_screen.dart';
import 'screens/stock_entry_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/stock_history_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/brands_screen.dart';
import 'utils/constants.dart';
import 'utils/animations.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppConstants.routeSplash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case AppConstants.routeOnboarding:
        return AppAnimations.slideRoute(
          const OnboardingScreen(),
          settings: settings,
        );
      case AppConstants.routeLogin:
        return AppAnimations.slideRoute(
          const LoginScreen(),
          settings: settings,
        );
      case AppConstants.routeDashboard:
        return AppAnimations.slideRoute(
          const MainNavigation(initialIndex: 0),
          settings: settings,
        );
      case AppConstants.routeProducts:
        return AppAnimations.slideRoute(
          const MainNavigation(initialIndex: 1),
          settings: settings,
        );
      case AppConstants.routeProductDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return AppAnimations.slideRoute(
          ProductDetailScreen(productId: args?['productId'] as int),
          settings: settings,
        );
      case AppConstants.routeProductEdit:
        final args = settings.arguments as Map<String, dynamic>?;
        return AppAnimations.slideRoute(
          ProductEditScreen(
            productId: args?['productId'] as int?,
            barcode: args?['barcode'] as String?,
          ),
          settings: settings,
        );
      case AppConstants.routeBarcodeScan:
        return AppAnimations.slideRoute(
          const BarcodeScanScreen(),
          settings: settings,
        );
      case AppConstants.routeStockEntry:
        final args = settings.arguments as Map<String, dynamic>?;
        return AppAnimations.slideRoute(
          StockEntryScreen(
            productId: args?['productId'] as int?,
            type: args?['type'] as String? ?? AppConstants.stockTypeIn,
          ),
          settings: settings,
        );
      case AppConstants.routeCategories:
        return AppAnimations.slideRoute(
          const MainNavigation(initialIndex: 2),
          settings: settings,
        );
      case AppConstants.routeBrands:
        return AppAnimations.slideRoute(
          const BrandsScreen(),
          settings: settings,
        );
      case AppConstants.routeReports:
        return AppAnimations.slideRoute(
          const MainNavigation(initialIndex: 3),
          settings: settings,
        );
      case AppConstants.routeSettings:
        return AppAnimations.slideRoute(
          const SettingsScreen(),
          settings: settings,
        );
      case AppConstants.routeStockHistory:
        final args = settings.arguments as Map<String, dynamic>?;
        return AppAnimations.slideRoute(
          StockHistoryScreen(
            productId: args?['productId'] as int?,
          ),
          settings: settings,
        );
      case AppConstants.routeProfile:
        return AppAnimations.slideRoute(
          const ProfileScreen(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Sayfa bulunamadı: ${settings.name}')),
          ),
        );
    }
  }
}
