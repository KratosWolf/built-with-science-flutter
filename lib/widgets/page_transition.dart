import 'package:flutter/material.dart';

class SlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final SlideDirection direction;

  SlidePageRoute({
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.direction = SlideDirection.rightToLeft,
    RouteSettings? settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          settings: settings,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            Offset begin;
            const Offset end = Offset.zero;
            
            switch (direction) {
              case SlideDirection.rightToLeft:
                begin = const Offset(1.0, 0.0);
                break;
              case SlideDirection.leftToRight:
                begin = const Offset(-1.0, 0.0);
                break;
              case SlideDirection.topToBottom:
                begin = const Offset(0.0, -1.0);
                break;
              case SlideDirection.bottomToTop:
                begin = const Offset(0.0, 1.0);
                break;
            }

            final tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            final offsetAnimation = animation.drive(tween);

            // Fade effect for extra smoothness
            final fadeAnimation = animation.drive(
              Tween(begin: 0.0, end: 1.0).chain(
                CurveTween(curve: Curves.easeIn),
              ),
            );

            return SlideTransition(
              position: offsetAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: child,
              ),
            );
          },
        );
}

class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final Duration duration;
  final Curve curve;

  FadePageRoute({
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeInOut,
    RouteSettings? settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          settings: settings,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final fadeAnimation = animation.drive(
              Tween(begin: 0.0, end: 1.0).chain(
                CurveTween(curve: curve),
              ),
            );

            final scaleAnimation = animation.drive(
              Tween(begin: 0.95, end: 1.0).chain(
                CurveTween(curve: Curves.easeOutCubic),
              ),
            );

            return FadeTransition(
              opacity: fadeAnimation,
              child: ScaleTransition(
                scale: scaleAnimation,
                child: child,
              ),
            );
          },
        );
}

class ScalePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final Alignment alignment;

  ScalePageRoute({
    required this.child,
    this.duration = const Duration(milliseconds: 350),
    this.curve = Curves.elasticOut,
    this.alignment = Alignment.center,
    RouteSettings? settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          settings: settings,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final scaleAnimation = animation.drive(
              Tween(begin: 0.0, end: 1.0).chain(
                CurveTween(curve: curve),
              ),
            );

            return ScaleTransition(
              scale: scaleAnimation,
              alignment: alignment,
              child: child,
            );
          },
        );
}

enum SlideDirection {
  rightToLeft,
  leftToRight,
  topToBottom,
  bottomToTop,
}

// Helper extension for easy navigation
extension NavigatorExtensions on NavigatorState {
  Future<T?> slideToPage<T extends Object?>(
    Widget page, {
    SlideDirection direction = SlideDirection.rightToLeft,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    return push<T>(SlidePageRoute<T>(
      child: page,
      direction: direction,
      duration: duration,
      curve: curve,
    ));
  }

  Future<T?> fadeToPage<T extends Object?>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 400),
    Curve curve = Curves.easeInOut,
  }) {
    return push<T>(FadePageRoute<T>(
      child: page,
      duration: duration,
      curve: curve,
    ));
  }

  Future<T?> scaleToPage<T extends Object?>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 350),
    Curve curve = Curves.elasticOut,
    Alignment alignment = Alignment.center,
  }) {
    return push<T>(ScalePageRoute<T>(
      child: page,
      duration: duration,
      curve: curve,
      alignment: alignment,
    ));
  }
}