import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/product_provider.dart';
import 'providers/category_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/auth_provider.dart';
import 'utils/constants.dart';
import 'routes.dart';

class SmartStockApp extends StatelessWidget {
  const SmartStockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (_) {
            final provider = ProductProvider();
            // Async işlemi başlat, hata oluşursa yakala
            provider.loadAllProducts().catchError((e) {
              debugPrint('Error loading products: $e');
            });
            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final provider = CategoryProvider();
            // Async işlemi başlat, hata oluşursa yakala
            provider.loadCategories().catchError((e) {
              debugPrint('Error loading categories: $e');
            });
            return provider;
          },
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.themeMode,
            initialRoute: AppConstants.routeSplash,
            onGenerateRoute: AppRoutes.generateRoute,
          );
        },
      ),
    );
  }
}
