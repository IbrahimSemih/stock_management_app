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
import 'utils/constants.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppConstants.routeSplash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case AppConstants.routeOnboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case AppConstants.routeLogin:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppConstants.routeDashboard:
        return MaterialPageRoute(
          builder: (_) => const MainNavigation(initialIndex: 0),
        );
      case AppConstants.routeProducts:
        return MaterialPageRoute(
          builder: (_) => const MainNavigation(initialIndex: 1),
        );
      case AppConstants.routeProductDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) =>
              ProductDetailScreen(productId: args?['productId'] as int),
        );
      case AppConstants.routeProductEdit:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ProductEditScreen(
            productId: args?['productId'] as int?,
            barcode: args?['barcode'] as String?,
          ),
        );
      case AppConstants.routeBarcodeScan:
        return MaterialPageRoute(builder: (_) => const BarcodeScanScreen());
      case AppConstants.routeStockEntry:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => StockEntryScreen(
            productId: args?['productId'] as int?,
            type: args?['type'] as String? ?? AppConstants.stockTypeIn,
          ),
        );
      case AppConstants.routeCategories:
        return MaterialPageRoute(
          builder: (_) => const MainNavigation(initialIndex: 2),
        );
      case AppConstants.routeReports:
        return MaterialPageRoute(
          builder: (_) => const MainNavigation(initialIndex: 3),
        );
      case AppConstants.routeSettings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Sayfa bulunamadı: ${settings.name}')),
          ),
        );
    }
  }
}
