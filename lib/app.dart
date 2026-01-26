import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/product_provider.dart';
import 'providers/category_provider.dart';
import 'providers/brand_provider.dart';
import 'providers/price_history_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/stock_history_provider.dart';
import 'providers/sync_provider.dart';
import 'utils/constants.dart';
import 'routes.dart';
import 'widgets/status_bar_wrapper.dart';
import 'l10n/app_localizations.dart';

class SmartStockApp extends StatelessWidget {
  const SmartStockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final provider = SettingsProvider();
            provider.loadSettings();
            return provider;
          },
        ),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // Veriler login sonrası yüklenecek, app başlangıcında yükleme yapılmayacak
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => BrandProvider()),
        ChangeNotifierProvider(create: (_) => StockHistoryProvider()),
        ChangeNotifierProvider(create: (_) => PriceHistoryProvider()),
        ChangeNotifierProvider(create: (_) => SyncProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.themeMode,
            locale: settings.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            initialRoute: AppConstants.routeSplash,
            onGenerateRoute: AppRoutes.generateRoute,
            builder: (context, child) {
              // Her sayfa için status bar wrapper ile sarmala
              return StatusBarWrapper(child: child ?? const SizedBox.shrink());
            },
          );
        },
      ),
    );
  }
}
