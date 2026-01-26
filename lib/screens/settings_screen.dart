import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/sync_provider.dart';
import '../providers/product_provider.dart';
import '../providers/category_provider.dart';
import '../providers/brand_provider.dart';
import '../providers/stock_history_provider.dart';
import '../utils/constants.dart';
import '../utils/app_icons.dart';
import '../widgets/custom_appbar.dart';
import '../l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: CustomAppBar(
        title: context.tr('settings'),
        showThemeToggle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Tema Ayarları
          _SettingsSection(
            title: context.tr('appearance'),
            children: [
              _SettingsTile(
                icon: AppIcons.darkMode,
                title: context.tr('theme'),
                subtitle: _getThemeModeText(
                  settingsProvider.themeMode,
                  context,
                ),
                trailing: _ThemeModeSelector(),
              ),
              _SettingsTile(
                icon: Icons.language,
                title: context.tr('language'),
                subtitle: AppLocalizations.getLanguageName(
                  settingsProvider.locale.languageCode,
                ),
                trailing: _LanguageSelector(),
              ),
              _SettingsTile(
                icon: Icons.attach_money,
                title: context.tr('currency'),
                subtitle:
                    '${settingsProvider.currencySymbol} (${settingsProvider.currency})',
                trailing: _CurrencySelector(),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Bildirimler
          _SettingsSection(
            title: context.tr('notifications'),
            children: [
              _SettingsTile(
                icon: AppIcons.notifications,
                title: context.tr('enable_notifications'),
                subtitle: context.tr('low_stock_alerts'),
                trailing: Switch(
                  value: settingsProvider.notificationsEnabled,
                  onChanged: (value) {
                    settingsProvider.setNotificationsEnabled(value);
                  },
                ),
              ),
              _SettingsTile(
                icon: AppIcons.criticalStock,
                title: context.tr('low_stock_alerts'),
                subtitle:
                    '${context.tr('low_stock_threshold')}: ${settingsProvider.lowStockThreshold}',
                trailing: _LowStockThresholdSelector(),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Senkronizasyon (sadece giriş yapılmışsa göster)
          if (authProvider.user != null)
            _SettingsSection(
              title: context.tr('sync'),
              children: [
                _SettingsTile(
                  icon: Icons.cloud_sync,
                  title: context.tr('enable_sync'),
                  subtitle: context.tr('sync_description'),
                  trailing: Consumer<SyncProvider>(
                    builder: (context, syncProvider, _) {
                      return Switch(
                        value: syncProvider.isSyncEnabled,
                        onChanged: (value) async {
                          if (value) {
                            // Senkronizasyon açılıyor - ilk senkronizasyonu yap
                            final success = await syncProvider.toggleSync(true);
                            if (success && context.mounted) {
                              await _performInitialSync(context);
                            }
                          } else {
                            await syncProvider.toggleSync(false);
                          }
                        },
                      );
                    },
                  ),
                ),
                Consumer<SyncProvider>(
                  builder: (context, syncProvider, _) {
                    if (!syncProvider.isSyncEnabled) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      children: [
                        _SettingsTile(
                          icon: Icons.sync,
                          title: context.tr('sync_now'),
                          subtitle: syncProvider.lastSyncTime != null
                              ? '${context.tr('last_sync')}: ${_formatDateTime(syncProvider.lastSyncTime!)}'
                              : context.tr('never_synced'),
                          trailing: syncProvider.isSyncing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.chevron_right, size: 20),
                          onTap: syncProvider.isSyncing
                              ? null
                              : () => _performSync(context),
                        ),
                        if (syncProvider.syncError != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Text(
                              syncProvider.syncError!,
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),

          if (authProvider.user != null) const SizedBox(height: 24),

          // Hesap
          _SettingsSection(
            title: context.tr('account'),
            children: [
              _SettingsTile(
                icon: AppIcons.user,
                title: context.tr('profile'),
                subtitle: context.tr('edit_profile'),
                onTap: () {
                  Navigator.pushNamed(context, AppConstants.routeProfile);
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Uygulama Bilgileri
          _SettingsSection(
            title: context.tr('about'),
            children: [
              _SettingsTile(
                icon: AppIcons.info,
                title: context.tr('version'),
                subtitle: AppConstants.appVersion,
                trailing: const Icon(Icons.chevron_right, size: 20),
              ),
              _SettingsTile(
                icon: AppIcons.appLogo,
                title: context.tr('app_name'),
                subtitle: AppConstants.appName,
                trailing: const Icon(Icons.chevron_right, size: 20),
              ),
              _SettingsTile(
                icon: Icons.privacy_tip,
                title: context.tr('privacy_policy'),
                subtitle: context.tr('view_privacy_policy'),
                onTap: () => _launchUrl(AppConstants.privacyPolicyUrl),
              ),
              _SettingsTile(
                icon: Icons.description,
                title: context.tr('terms_of_service'),
                subtitle: context.tr('view_terms_of_service'),
                onTap: () => _launchUrl(AppConstants.termsOfServiceUrl),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Çıkış
          _SettingsSection(
            title: context.tr('account'),
            children: [
              _SettingsTile(
                icon: AppIcons.logout,
                title: context.tr('logout'),
                subtitle:
                    authProvider.user?.displayName ??
                    authProvider.user?.email?.split('@')[0] ??
                    context.tr('not_logged_in'),
                isDestructive: true,
                onTap: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(context.tr('logout')),
                      content: Text(context.tr('logout_confirm')),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text(context.tr('cancel')),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: Text(context.tr('logout')),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true && context.mounted) {
                    await authProvider.signOut();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(
                        context,
                        AppConstants.routeLogin,
                      );
                    }
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _getThemeModeText(ThemeMode mode, BuildContext context) {
    switch (mode) {
      case ThemeMode.light:
        return context.tr('light_theme');
      case ThemeMode.dark:
        return context.tr('dark_theme');
      case ThemeMode.system:
        return context.tr('system_default');
    }
  }

  /// İlk senkronizasyonu yapar
  Future<void> _performInitialSync(BuildContext context) async {
    final syncProvider = context.read<SyncProvider>();
    final productProvider = context.read<ProductProvider>();
    final categoryProvider = context.read<CategoryProvider>();
    final brandProvider = context.read<BrandProvider>();
    final stockHistoryProvider = context.read<StockHistoryProvider>();

    // Verileri yükle
    await Future.wait([
      productProvider.loadAllProducts(),
      categoryProvider.loadCategories(),
      brandProvider.loadBrands(),
      stockHistoryProvider.loadHistory(),
    ]);

    // Senkronizasyonu yap
    final success = await syncProvider.syncToCloud(
      products: productProvider.products,
      categories: categoryProvider.categories,
      brands: brandProvider.brands,
      stockHistory: stockHistoryProvider.history,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? context.tr('sync_success') : context.tr('sync_failed'),
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  /// Manuel senkronizasyon yapar
  Future<void> _performSync(BuildContext context) async {
    final syncProvider = context.read<SyncProvider>();
    final productProvider = context.read<ProductProvider>();
    final categoryProvider = context.read<CategoryProvider>();
    final brandProvider = context.read<BrandProvider>();
    final stockHistoryProvider = context.read<StockHistoryProvider>();

    // Verileri yükle
    await Future.wait([
      productProvider.loadAllProducts(),
      categoryProvider.loadCategories(),
      brandProvider.loadBrands(),
      stockHistoryProvider.loadHistory(),
    ]);

    // Senkronizasyonu yap
    final success = await syncProvider.syncToCloud(
      products: productProvider.products,
      categories: categoryProvider.categories,
      brands: brandProvider.brands,
      stockHistory: stockHistoryProvider.history,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? context.tr('sync_success') : context.tr('sync_failed'),
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  /// Tarih formatlar
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // URL açılamazsa kullanıcıya bilgi ver
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('URL açılamadı: $url'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _LanguageSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();

    return PopupMenuButton<String>(
      icon: const Icon(Icons.chevron_right, size: 20),
      onSelected: (String code) {
        settingsProvider.setLocale(Locale(code));
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'tr',
          child: Row(
            children: [
              Text(AppLocalizations.getLanguageFlag('tr')),
              const SizedBox(width: 12),
              Text(
                'Türkçe',
                style: TextStyle(
                  fontWeight: settingsProvider.locale.languageCode == 'tr'
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              if (settingsProvider.locale.languageCode == 'tr') ...[
                const Spacer(),
                Icon(
                  Icons.check,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ],
          ),
        ),
        PopupMenuItem(
          value: 'en',
          child: Row(
            children: [
              Text(AppLocalizations.getLanguageFlag('en')),
              const SizedBox(width: 12),
              Text(
                'English',
                style: TextStyle(
                  fontWeight: settingsProvider.locale.languageCode == 'en'
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              if (settingsProvider.locale.languageCode == 'en') ...[
                const Spacer(),
                Icon(
                  Icons.check,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _CurrencySelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();

    return PopupMenuButton<Map<String, String>>(
      icon: const Icon(Icons.chevron_right, size: 20),
      onSelected: (currency) {
        settingsProvider.setCurrency(currency['code']!, currency['symbol']!);
      },
      itemBuilder: (context) => SettingsProvider.availableCurrencies.map((
        currency,
      ) {
        final isSelected = settingsProvider.currency == currency['code'];
        return PopupMenuItem(
          value: currency,
          child: Row(
            children: [
              Text(
                currency['symbol']!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      currency['code']!,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    Text(
                      currency['name']!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _LowStockThresholdSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();

    return PopupMenuButton<int>(
      icon: const Icon(Icons.chevron_right, size: 20),
      onSelected: (value) {
        settingsProvider.setLowStockThreshold(value);
      },
      itemBuilder: (context) => [5, 10, 15, 20, 25, 50, 100].map((value) {
        final isSelected = settingsProvider.lowStockThreshold == value;
        return PopupMenuItem(
          value: value,
          child: Row(
            children: [
              Text(
                '$value',
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                context.tr('piece'),
                style: TextStyle(color: Colors.grey[600]),
              ),
              if (isSelected) ...[
                const Spacer(),
                Icon(
                  Icons.check,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 12),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Card(child: Column(children: children)),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDestructive;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive
              ? Colors.red.withOpacity(0.1)
              : Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isDestructive ? Colors.red : Theme.of(context).primaryColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDestructive ? Colors.red : null,
        ),
      ),
      subtitle: Text(subtitle),
      trailing:
          trailing ??
          (onTap != null ? const Icon(Icons.chevron_right, size: 20) : null),
      onTap: onTap,
    );
  }
}

class _ThemeModeSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();

    return PopupMenuButton<ThemeMode>(
      icon: const Icon(Icons.chevron_right, size: 20),
      onSelected: (ThemeMode mode) {
        settingsProvider.setThemeMode(mode);
      },
      itemBuilder: (ctx) => [
        PopupMenuItem(
          value: ThemeMode.light,
          child: Row(
            children: [
              Icon(
                AppIcons.lightMode,
                size: 20,
                color: settingsProvider.themeMode == ThemeMode.light
                    ? Theme.of(ctx).primaryColor
                    : null,
              ),
              const SizedBox(width: 12),
              Text(
                context.tr('light_theme'),
                style: TextStyle(
                  fontWeight: settingsProvider.themeMode == ThemeMode.light
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              if (settingsProvider.themeMode == ThemeMode.light) const Spacer(),
              if (settingsProvider.themeMode == ThemeMode.light)
                Icon(Icons.check, size: 20, color: Theme.of(ctx).primaryColor),
            ],
          ),
        ),
        PopupMenuItem(
          value: ThemeMode.dark,
          child: Row(
            children: [
              Icon(
                AppIcons.darkMode,
                size: 20,
                color: settingsProvider.themeMode == ThemeMode.dark
                    ? Theme.of(ctx).primaryColor
                    : null,
              ),
              const SizedBox(width: 12),
              Text(
                context.tr('dark_theme'),
                style: TextStyle(
                  fontWeight: settingsProvider.themeMode == ThemeMode.dark
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              if (settingsProvider.themeMode == ThemeMode.dark) const Spacer(),
              if (settingsProvider.themeMode == ThemeMode.dark)
                Icon(Icons.check, size: 20, color: Theme.of(ctx).primaryColor),
            ],
          ),
        ),
        PopupMenuItem(
          value: ThemeMode.system,
          child: Row(
            children: [
              Icon(
                Icons.brightness_auto,
                size: 20,
                color: settingsProvider.themeMode == ThemeMode.system
                    ? Theme.of(ctx).primaryColor
                    : null,
              ),
              const SizedBox(width: 12),
              Text(
                context.tr('system_default'),
                style: TextStyle(
                  fontWeight: settingsProvider.themeMode == ThemeMode.system
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              if (settingsProvider.themeMode == ThemeMode.system)
                const Spacer(),
              if (settingsProvider.themeMode == ThemeMode.system)
                Icon(Icons.check, size: 20, color: Theme.of(ctx).primaryColor),
            ],
          ),
        ),
      ],
    );
  }
}
