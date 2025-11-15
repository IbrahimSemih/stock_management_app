import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../utils/app_icons.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final bool showThemeToggle;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.showThemeToggle = false,
  });

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final List<Widget> finalActions = [];

    // Tema değişim butonu ekle
    if (showThemeToggle) {
      finalActions.add(
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              settingsProvider.themeMode == ThemeMode.dark
                  ? AppIcons.lightMode
                  : AppIcons.darkMode,
            ),
            onPressed: () {
              settingsProvider.setThemeMode(
                settingsProvider.themeMode == ThemeMode.dark
                    ? ThemeMode.light
                    : ThemeMode.dark,
              );
            },
            tooltip: settingsProvider.themeMode == ThemeMode.dark
                ? 'Açık Tema'
                : 'Koyu Tema',
          ),
        ),
      );
    }

    // Kullanıcının eklediği action'ları ekle
    if (actions != null) {
      finalActions.addAll(actions!);
    }

    return AppBar(
      title: Text(title),
      centerTitle: centerTitle,
      leading: leading,
      actions: finalActions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
