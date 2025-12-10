import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../utils/app_icons.dart';
import '../widgets/custom_appbar.dart';
import '../l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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

          // Veritabanı
          _SettingsSection(
            title: context.tr('data_management'),
            children: [
              _SettingsTile(
                icon: AppIcons.backup,
                title: context.tr('backup_database'),
                subtitle: context.tr('backup'),
                onTap: () {
                  Navigator.pushNamed(context, AppConstants.routeReports);
                },
              ),
              _SettingsTile(
                icon: AppIcons.restore,
                title: context.tr('restore_database'),
                subtitle: context.tr('restore'),
                onTap: () {
                  Navigator.pushNamed(context, AppConstants.routeReports);
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

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
                    authProvider.user?.email ?? context.tr('offline_mode'),
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
