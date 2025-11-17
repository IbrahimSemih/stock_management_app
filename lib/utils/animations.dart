import 'package:flutter/material.dart';

class AppAnimations {
  // Page transitions
  static Route<T> fadeRoute<T extends Object?>(
    Widget page, {
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  static Route<T> slideRoute<T extends Object?>(
    Widget page, {
    RouteSettings? settings,
    AxisDirection direction = AxisDirection.right,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        Offset begin;
        Offset end = Offset.zero;

        switch (direction) {
          case AxisDirection.up:
            begin = const Offset(0, 1);
            break;
          case AxisDirection.down:
            begin = const Offset(0, -1);
            break;
          case AxisDirection.left:
            begin = const Offset(1, 0);
            break;
          case AxisDirection.right:
            begin = const Offset(-1, 0);
            break;
        }

        return SlideTransition(
          position: Tween<Offset>(begin: begin, end: end).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
          ),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  static Route<T> scaleRoute<T extends Object?>(
    Widget page, {
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}

// Animation extensions
extension AnimationExtension on Widget {
  Widget fadeIn({
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeIn,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: this,
    );
  }

  Widget slideIn({
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOut,
    Offset offset = const Offset(0, 20),
  }) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween(begin: offset, end: Offset.zero),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: value,
          child: child,
        );
      },
      child: this,
    );
  }

  Widget scaleIn({
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOut,
    double begin = 0.8,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: begin, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: this,
    );
  }
}

