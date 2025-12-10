import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  static const String _localeKey = 'locale';
  static const String _currencyKey = 'currency';
  static const String _currencySymbolKey = 'currency_symbol';
  static const String _lowStockThresholdKey = 'low_stock_threshold';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _lowStockAlertsKey = 'low_stock_alerts';

  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('en', 'US');
  String _currency = 'USD';
  String _currencySymbol = '\$';
  int _lowStockThreshold = 10;
  bool _notificationsEnabled = true;
  bool _lowStockAlertsEnabled = true;

  // Getters
  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  String get currency => _currency;
  String get currencySymbol => _currencySymbol;
  int get lowStockThreshold => _lowStockThreshold;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get lowStockAlertsEnabled => _lowStockAlertsEnabled;

  /// Initialize settings from SharedPreferences
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Theme Mode
    final themeModeIndex = prefs.getInt(_themeModeKey) ?? 0;
    _themeMode = ThemeMode.values[themeModeIndex];

    // Locale
    final localeCode = prefs.getString(_localeKey) ?? 'en';
    _locale = Locale(localeCode);

    // Currency
    _currency = prefs.getString(_currencyKey) ?? 'USD';
    _currencySymbol = prefs.getString(_currencySymbolKey) ?? '\$';

    // Low Stock Threshold
    _lowStockThreshold = prefs.getInt(_lowStockThresholdKey) ?? 10;

    // Notifications
    _notificationsEnabled = prefs.getBool(_notificationsEnabledKey) ?? true;
    _lowStockAlertsEnabled = prefs.getBool(_lowStockAlertsKey) ?? true;

    notifyListeners();
  }

  /// Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, mode.index);
    notifyListeners();
  }

  /// Set locale
  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
    notifyListeners();
  }

  /// Set currency
  Future<void> setCurrency(String currencyCode, String symbol) async {
    _currency = currencyCode;
    _currencySymbol = symbol;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, currencyCode);
    await prefs.setString(_currencySymbolKey, symbol);
    notifyListeners();
  }

  /// Set low stock threshold
  Future<void> setLowStockThreshold(int threshold) async {
    _lowStockThreshold = threshold;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lowStockThresholdKey, threshold);
    notifyListeners();
  }

  /// Set notifications enabled
  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, enabled);
    notifyListeners();
  }

  /// Set low stock alerts enabled
  Future<void> setLowStockAlertsEnabled(bool enabled) async {
    _lowStockAlertsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_lowStockAlertsKey, enabled);
    notifyListeners();
  }

  /// Format price with currency symbol
  String formatPrice(double price) {
    return '$_currencySymbol${price.toStringAsFixed(2)}';
  }

  /// Available currencies
  static const List<Map<String, String>> availableCurrencies = [
    {'code': 'TRY', 'symbol': '₺', 'name': 'Türk Lirası'},
    {'code': 'USD', 'symbol': '\$', 'name': 'US Dollar'},
    {'code': 'EUR', 'symbol': '€', 'name': 'Euro'},
    {'code': 'GBP', 'symbol': '£', 'name': 'British Pound'},
    {'code': 'JPY', 'symbol': '¥', 'name': 'Japanese Yen'},
    {'code': 'CNY', 'symbol': '¥', 'name': 'Chinese Yuan'},
    {'code': 'INR', 'symbol': '₹', 'name': 'Indian Rupee'},
    {'code': 'RUB', 'symbol': '₽', 'name': 'Russian Ruble'},
    {'code': 'SAR', 'symbol': 'ر.س', 'name': 'Saudi Riyal'},
    {'code': 'AED', 'symbol': 'د.إ', 'name': 'UAE Dirham'},
  ];
}
