import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Status bar stilini otomatik olarak ayarlayan wrapper widget
/// AnnotatedRegion kullanarak her sayfa için status bar stilini günceller
class StatusBarWrapper extends StatelessWidget {
  final Widget child;

  const StatusBarWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDarkMode 
            ? Brightness.light 
            : Brightness.dark,
        statusBarBrightness: isDarkMode 
            ? Brightness.dark 
            : Brightness.light,
        systemNavigationBarColor: isDarkMode
            ? const Color(0xFF0F172A)
            : Colors.white,
        systemNavigationBarIconBrightness:
            isDarkMode ? Brightness.light : Brightness.dark,
      ),
      child: child,
    );
  }
}
