import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

/// Status bar stilini otomatik olarak ayarlayan wrapper
Widget _wrapWithStatusBar(Widget child, BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ),
    child: child,
  );
}

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppConstants.routeSplash:
        return MaterialPageRoute(
          builder: (context) => _wrapWithStatusBar(const SplashScreen(), context),
        );
      case AppConstants.routeOnboarding:
        return AppAnimations.slideRoute(
          Builder(builder: (context) => _wrapWithStatusBar(const OnboardingScreen(), context)),
          settings: settings,
        );
      case AppConstants.routeLogin:
        return AppAnimations.slideRoute(
          Builder(builder: (context) => _wrapWithStatusBar(const LoginScreen(), context)),
          settings: settings,
        );
      case AppConstants.routeDashboard:
        return AppAnimations.slideRoute(
          Builder(builder: (context) => _wrapWithStatusBar(const MainNavigation(initialIndex: 0), context)),
          settings: settings,
        );
      case AppConstants.routeProducts:
        return AppAnimations.slideRoute(
          Builder(builder: (context) => _wrapWithStatusBar(const MainNavigation(initialIndex: 1), context)),
          settings: settings,
        );
      case AppConstants.routeProductDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return AppAnimations.slideRoute(
          Builder(builder: (context) => _wrapWithStatusBar(
            ProductDetailScreen(productId: args?['productId'] as int),
            context,
          )),
          settings: settings,
        );
      case AppConstants.routeProductEdit:
        final args = settings.arguments as Map<String, dynamic>?;
        return AppAnimations.slideRoute(
          Builder(builder: (context) => _wrapWithStatusBar(
            ProductEditScreen(
              productId: args?['productId'] as int?,
              barcode: args?['barcode'] as String?,
            ),
            context,
          )),
          settings: settings,
        );
      case AppConstants.routeBarcodeScan:
        return AppAnimations.slideRoute(
          Builder(builder: (context) => _wrapWithStatusBar(const BarcodeScanScreen(), context)),
          settings: settings,
        );
      case AppConstants.routeStockEntry:
        final args = settings.arguments as Map<String, dynamic>?;
        return AppAnimations.slideRoute(
          Builder(builder: (context) => _wrapWithStatusBar(
            StockEntryScreen(
              productId: args?['productId'] as int?,
              type: args?['type'] as String? ?? AppConstants.stockTypeIn,
            ),
            context,
          )),
          settings: settings,
        );
      case AppConstants.routeCategories:
        return AppAnimations.slideRoute(
          Builder(builder: (context) => _wrapWithStatusBar(const MainNavigation(initialIndex: 2), context)),
          settings: settings,
        );
      case AppConstants.routeBrands:
        return AppAnimations.slideRoute(
          Builder(builder: (context) => _wrapWithStatusBar(const BrandsScreen(), context)),
          settings: settings,
        );
      case AppConstants.routeReports:
        return AppAnimations.slideRoute(
          Builder(builder: (context) => _wrapWithStatusBar(const MainNavigation(initialIndex: 3), context)),
          settings: settings,
        );
      case AppConstants.routeSettings:
        return AppAnimations.slideRoute(
          Builder(builder: (context) => _wrapWithStatusBar(const SettingsScreen(), context)),
          settings: settings,
        );
      case AppConstants.routeStockHistory:
        final args = settings.arguments as Map<String, dynamic>?;
        return AppAnimations.slideRoute(
          Builder(builder: (context) => _wrapWithStatusBar(
            StockHistoryScreen(
              productId: args?['productId'] as int?,
            ),
            context,
          )),
          settings: settings,
        );
      case AppConstants.routeProfile:
        return AppAnimations.slideRoute(
          Builder(builder: (context) => _wrapWithStatusBar(const ProfileScreen(), context)),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (context) => _wrapWithStatusBar(
            Scaffold(
              body: Center(child: Text('Sayfa bulunamadı: ${settings.name}')),
            ),
            context,
          ),
        );
    }
  }
}
