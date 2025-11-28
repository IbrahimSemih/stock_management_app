import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../utils/constants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final bool showThemeToggle;
  final bool isTransparent;
  final Color? backgroundColor;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.showThemeToggle = false,
    this.isTransparent = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final List<Widget> finalActions = [];

    // Theme Toggle Button
    if (showThemeToggle) {
      finalActions.add(
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                settingsProvider.setThemeMode(
                  settingsProvider.themeMode == ThemeMode.dark
                      ? ThemeMode.light
                      : ThemeMode.dark,
                );
              },
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return RotationTransition(
                      turns: Tween(begin: 0.5, end: 1.0).animate(animation),
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    );
                  },
                  child: Icon(
                    settingsProvider.themeMode == ThemeMode.dark
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    key: ValueKey(settingsProvider.themeMode),
                    color: isDark 
                        ? AppConstants.primaryLight 
                        : AppConstants.primaryColor,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // User-provided actions
    if (actions != null) {
      finalActions.addAll(actions!);
    }

    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: isDark ? Colors.white : AppConstants.neutralDark,
          letterSpacing: -0.5,
        ),
      ),
      centerTitle: centerTitle,
      leading: leading,
      actions: finalActions,
      backgroundColor: isTransparent 
          ? Colors.transparent 
          : (backgroundColor ?? (isDark ? const Color(0xFF0F172A) : Colors.white)),
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Premium Back Button for AppBar
class PremiumBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const PremiumBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed ?? () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: isDark 
                    ? AppConstants.primaryLight 
                    : AppConstants.primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Premium Action Button for AppBar
class PremiumAppBarAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool hasNotification;
  final int? notificationCount;

  const PremiumAppBarAction({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.hasNotification = false,
    this.notificationCount,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPressed,
                borderRadius: BorderRadius.circular(14),
                child: Tooltip(
                  message: tooltip ?? '',
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      icon,
                      size: 22,
                      color: isDark 
                          ? AppConstants.primaryLight 
                          : AppConstants.primaryColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (hasNotification)
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                padding: notificationCount != null
                    ? const EdgeInsets.symmetric(horizontal: 5, vertical: 2)
                    : const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppConstants.errorColor, Color(0xFFDC2626)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    width: 2,
                  ),
                ),
                child: notificationCount != null
                    ? Text(
                        notificationCount! > 99 
                            ? '99+' 
                            : notificationCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    : const SizedBox(width: 4, height: 4),
              ),
            ),
        ],
      ),
    );
  }
}
