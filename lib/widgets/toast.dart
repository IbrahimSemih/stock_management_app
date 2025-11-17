import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/app_icons.dart';

class Toast {
  static void show(
    BuildContext context,
    String message, {
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.hideCurrentSnackBar();

    Color backgroundColor;
    IconData icon;
    Color iconColor;

    switch (type) {
      case ToastType.success:
        backgroundColor = AppConstants.successColor;
        icon = AppIcons.success;
        iconColor = Colors.white;
        break;
      case ToastType.error:
        backgroundColor = AppConstants.errorColor;
        icon = AppIcons.error;
        iconColor = Colors.white;
        break;
      case ToastType.warning:
        backgroundColor = AppConstants.warningColor;
        icon = AppIcons.warning;
        iconColor = Colors.white;
        break;
      case ToastType.info:
        backgroundColor = AppConstants.primaryColor;
        icon = AppIcons.info;
        iconColor = Colors.white;
        break;
    }

    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  static void success(BuildContext context, String message) {
    show(context, message, type: ToastType.success);
  }

  static void error(BuildContext context, String message) {
    show(context, message, type: ToastType.error);
  }

  static void warning(BuildContext context, String message) {
    show(context, message, type: ToastType.warning);
  }

  static void info(BuildContext context, String message) {
    show(context, message, type: ToastType.info);
  }
}

enum ToastType {
  success,
  error,
  warning,
  info,
}

