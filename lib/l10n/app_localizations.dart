import 'package:flutter/material.dart';
import 'app_en.dart';
import 'app_tr.dart';

/// Application localization class
class AppLocalizations {
  final Locale locale;
  
  AppLocalizations(this.locale);
  
  /// Supported locales
  static const supportedLocales = [
    Locale('en', 'US'),
    Locale('tr', 'TR'),
  ];
  
  /// Get the localization instance from context
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }
  
  /// Localization delegate
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
  
  /// Get translations based on language code
  static Map<String, String> _getTranslations(String languageCode) {
    switch (languageCode) {
      case 'tr':
        return appTr;
      case 'en':
      default:
        return appEn;
    }
  }
  
  late final Map<String, String> _translations = _getTranslations(locale.languageCode);
  
  /// Translate a key
  String translate(String key) {
    return _translations[key] ?? key;
  }
  
  /// Shorthand for translate
  String tr(String key) => translate(key);
  
  /// Get current language name
  String get currentLanguageName {
    switch (locale.languageCode) {
      case 'tr':
        return 'Türkçe';
      case 'en':
      default:
        return 'English';
    }
  }
  
  /// Get language name by code
  static String getLanguageName(String code) {
    switch (code) {
      case 'tr':
        return 'Türkçe';
      case 'en':
      default:
        return 'English';
    }
  }
  
  /// Get language flag by code
  static String getLanguageFlag(String code) {
    switch (code) {
      case 'tr':
        return '🇹🇷';
      case 'en':
      default:
        return '🇬🇧';
    }
  }
}

/// Localization delegate
class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  
  @override
  bool isSupported(Locale locale) {
    return ['en', 'tr'].contains(locale.languageCode);
  }
  
  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }
  
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

/// Extension for easy access
extension AppLocalizationsExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  String tr(String key) => l10n.translate(key);
}

