import 'package:flutter/material.dart';

import '../../presentation/views/dashboard/main_screen.dart';
import '../../presentation/views/onboarding/onboarding_screen_1.dart';
import '../../presentation/views/onboarding/onboarding_screen_2.dart';
import '../../presentation/views/onboarding/onboarding_screen_3.dart';
import '../../presentation/views/onboarding/onboarding_screen_4.dart';
import '../../presentation/views/onboarding/onboarding_screen_5.dart';
import '../../presentation/views/onboarding/welcome_screen_1.dart';
import '../../presentation/views/onboarding/welcome_screen_2.dart';
import '../../presentation/views/splash/splash_screen.dart';
import 'app_routes.dart';

/// Supported custom transition animations for route generation.
enum TransitionType { fade, slideRight, slideUp, none }

/// Centralized router managing route generation and smooth page transitions.
abstract class AppRouter {
  AppRouter._();

  /// The entry point route for the application.
  static const String initialRoute = AppRoutes.splash;

  /// Centralized route generator passed to [MaterialApp.onGenerateRoute].
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _buildRoute(
          page: const SplashScreen(),
          settings: settings,
          transitionType: TransitionType.none,
        );

      case AppRoutes.welcome1:
        return _buildRoute(
          page: const WelcomeScreen1(),
          settings: settings,
          transitionType: TransitionType.fade,
          duration: const Duration(milliseconds: 400),
        );

      case AppRoutes.welcome2:
        return _buildRoute(
          page: const WelcomeScreen2(),
          settings: settings,
          transitionType: TransitionType.slideRight,
          duration: const Duration(milliseconds: 400),
        );

      case AppRoutes.onboarding1:
        return _buildRoute(
          page: const OnboardingScreen1(),
          settings: settings,
          transitionType: TransitionType.slideRight,
          duration: const Duration(milliseconds: 400),
        );

      case AppRoutes.onboarding2:
        return _buildRoute(
          page: const OnboardingScreen2(),
          settings: settings,
          transitionType: TransitionType.slideRight,
          duration: const Duration(milliseconds: 400),
        );

      case AppRoutes.onboarding3:
        return _buildRoute(
          page: const OnboardingScreen3(),
          settings: settings,
          transitionType: TransitionType.slideRight,
          duration: const Duration(milliseconds: 400),
        );

      case AppRoutes.onboarding4:
        return _buildRoute(
          page: const OnboardingScreen4(),
          settings: settings,
          transitionType: TransitionType.slideRight,
          duration: const Duration(milliseconds: 400),
        );

      case AppRoutes.onboarding5:
        return _buildRoute(
          page: const OnboardingScreen5(),
          settings: settings,
          transitionType: TransitionType.slideRight,
          duration: const Duration(milliseconds: 400),
        );

      case AppRoutes.dashboard:
        return _buildRoute(
          page: const MainScreen(),
          settings: settings,
          transitionType: TransitionType.fade,
          duration: const Duration(milliseconds: 450),
        );

      default:
        return _buildRoute(
          page: Scaffold(
            appBar: AppBar(title: const Text('Not Found')),
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
          settings: settings,
          transitionType: TransitionType.none,
        );
    }
  }

  static PageRouteBuilder<dynamic> _buildRoute({
    required Widget page,
    required RouteSettings settings,
    TransitionType transitionType = TransitionType.fade,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<dynamic>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        switch (transitionType) {
          case TransitionType.fade:
            return FadeTransition(opacity: animation, child: child);

          case TransitionType.slideRight:
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            );

          case TransitionType.slideUp:
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0.0, 1.0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            );

          case TransitionType.none:
            return child;
        }
      },
    );
  }
}
