import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../utils/app_icons.dart';
import '../widgets/custom_appbar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Ayarlar',
        showThemeToggle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Tema Ayarları
          _SettingsSection(
            title: 'Görünüm',
            children: [
              _SettingsTile(
                icon: AppIcons.darkMode,
                title: 'Tema',
                subtitle: _getThemeModeText(settingsProvider.themeMode),
                trailing: _ThemeModeSelector(),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Bildirimler
          _SettingsSection(
            title: 'Bildirimler',
            children: [
              _SettingsTile(
                icon: AppIcons.notifications,
                title: 'Bildirimleri Aç',
                subtitle: 'Stok uyarıları ve bildirimler',
                trailing: Switch(
                  value: true, // TODO: SettingsProvider'a eklenebilir
                  onChanged: (value) {
                    // TODO: Bildirim ayarı kaydedilebilir
                  },
                ),
              ),
              _SettingsTile(
                icon: AppIcons.criticalStock,
                title: 'Düşük Stok Uyarıları',
                subtitle: 'Kritik stok seviyesinde bildirim',
                trailing: Switch(
                  value: true, // TODO: SettingsProvider'a eklenebilir
                  onChanged: (value) {
                    // TODO: Kritik stok uyarısı ayarı kaydedilebilir
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Veritabanı
          _SettingsSection(
            title: 'Veri Yönetimi',
            children: [
              _SettingsTile(
                icon: AppIcons.backup,
                title: 'Veritabanını Yedekle',
                subtitle: 'Tüm verilerinizin yedeğini alın',
                onTap: () {
                  Navigator.pushNamed(context, AppConstants.routeReports);
                },
              ),
              _SettingsTile(
                icon: AppIcons.restore,
                title: 'Veritabanını Geri Yükle',
                subtitle: 'Daha önce aldığınız yedeği geri yükleyin',
                onTap: () {
                  Navigator.pushNamed(context, AppConstants.routeReports);
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Uygulama Bilgileri
          _SettingsSection(
            title: 'Uygulama',
            children: [
              _SettingsTile(
                icon: AppIcons.info,
                title: 'Versiyon',
                subtitle: AppConstants.appVersion,
                trailing: const Icon(Icons.chevron_right, size: 20),
              ),
              _SettingsTile(
                icon: AppIcons.appLogo,
                title: 'Uygulama Adı',
                subtitle: AppConstants.appName,
                trailing: const Icon(Icons.chevron_right, size: 20),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Çıkış
          _SettingsSection(
            title: 'Hesap',
            children: [
              _SettingsTile(
                icon: AppIcons.logout,
                title: 'Çıkış Yap',
                subtitle: authProvider.user?.email ?? 'Offline Mod',
                isDestructive: true,
                onTap: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Çıkış Yap'),
                      content: const Text('Çıkış yapmak istediğinize emin misiniz?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('İptal'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('Çıkış Yap'),
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

  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Açık Tema';
      case ThemeMode.dark:
        return 'Koyu Tema';
      case ThemeMode.system:
        return 'Sistem Varsayılanı';
    }
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

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
        Card(
          child: Column(
            children: children,
          ),
        ),
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
          color: isDestructive
              ? Colors.red
              : Theme.of(context).primaryColor,
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
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right, size: 20) : null),
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
      itemBuilder: (context) => [
        PopupMenuItem(
          value: ThemeMode.light,
          child: Row(
            children: [
              Icon(
                AppIcons.lightMode,
                size: 20,
                color: settingsProvider.themeMode == ThemeMode.light
                    ? Theme.of(context).primaryColor
                    : null,
              ),
              const SizedBox(width: 12),
              Text(
                'Açık Tema',
                style: TextStyle(
                  fontWeight: settingsProvider.themeMode == ThemeMode.light
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              if (settingsProvider.themeMode == ThemeMode.light)
                const Spacer(),
              if (settingsProvider.themeMode == ThemeMode.light)
                Icon(
                  Icons.check,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
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
                    ? Theme.of(context).primaryColor
                    : null,
              ),
              const SizedBox(width: 12),
              Text(
                'Koyu Tema',
                style: TextStyle(
                  fontWeight: settingsProvider.themeMode == ThemeMode.dark
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              if (settingsProvider.themeMode == ThemeMode.dark)
                const Spacer(),
              if (settingsProvider.themeMode == ThemeMode.dark)
                Icon(
                  Icons.check,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
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
                    ? Theme.of(context).primaryColor
                    : null,
              ),
              const SizedBox(width: 12),
              Text(
                'Sistem Varsayılanı',
                style: TextStyle(
                  fontWeight: settingsProvider.themeMode == ThemeMode.system
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              if (settingsProvider.themeMode == ThemeMode.system)
                const Spacer(),
              if (settingsProvider.themeMode == ThemeMode.system)
                Icon(
                  Icons.check,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

