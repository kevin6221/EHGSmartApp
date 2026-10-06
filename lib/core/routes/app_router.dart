import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants/app_animations.dart';
import '../../presentation/views/dashboard/main_screen.dart';
import '../../presentation/views/onboarding/onboarding_screen_1.dart';
import '../../presentation/views/onboarding/onboarding_screen_2.dart';
import '../../presentation/views/onboarding/onboarding_screen_3.dart';
import '../../presentation/views/onboarding/onboarding_screen_4.dart';
import '../../presentation/views/onboarding/onboarding_screen_5.dart';
import '../../presentation/views/onboarding/welcome_screen_1.dart';
import '../../presentation/views/onboarding/welcome_screen_2.dart';
import '../../presentation/views/splash/splash_screen.dart';
import '../../presentation/views/train/train_screen.dart';
import '../../presentation/views/train/training_session_screen.dart';
import '../../presentation/views/membership/membership_screen.dart';
import '../../presentation/views/systems/systems_screen.dart';
import '../../presentation/views/journal/journal_screen.dart';
import '../../presentation/views/rewards/rewards_screen.dart';
import '../../presentation/views/wardrobe/unlock_wardrobe_screen.dart';
import '../../presentation/views/profile/profile_screen.dart';
import '../../presentation/views/profile/profile_notifications_screen.dart';
import '../../presentation/views/details/workout_session_detail_screen.dart';
import '../database/app_database.dart';
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
          duration: AppDurations.pageTransition,
        );

      case AppRoutes.welcome2:
        return _buildRoute(
          page: const WelcomeScreen2(),
          settings: settings,
          transitionType: TransitionType.slideRight,
          duration: AppDurations.pageTransition,
        );

      case AppRoutes.onboarding1:
        return _buildRoute(
          page: const OnboardingScreen1(),
          settings: settings,
          transitionType: TransitionType.slideRight,
          duration: AppDurations.pageTransition,
        );

      case AppRoutes.onboarding2:
        return _buildRoute(
          page: const OnboardingScreen2(),
          settings: settings,
          transitionType: TransitionType.slideRight,
          duration: AppDurations.pageTransition,
        );

      case AppRoutes.onboarding3:
        return _buildRoute(
          page: const OnboardingScreen3(),
          settings: settings,
          transitionType: TransitionType.slideRight,
          duration: AppDurations.pageTransition,
        );

      case AppRoutes.onboarding4:
        return _buildRoute(
          page: const OnboardingScreen4(),
          settings: settings,
          transitionType: TransitionType.slideRight,
          duration: AppDurations.pageTransition,
        );

      case AppRoutes.onboarding5:
        return _buildRoute(
          page: const OnboardingScreen5(),
          settings: settings,
          transitionType: TransitionType.slideRight,
          duration: AppDurations.pageTransition,
        );

      case AppRoutes.dashboard:
        return _buildRoute(
          page: const MainScreen(),
          settings: settings,
          transitionType: TransitionType.fade,
          duration: AppDurations.pageTransitionSlow,
        );

      case AppRoutes.train:
        return _buildRoute(
          page: const TrainScreen(),
          settings: settings,
          transitionType: TransitionType.slideRight,
          duration: AppDurations.pageTransition,
        );

      case AppRoutes.trainingSession:
        return _buildRoute(
          page: const TrainingSessionScreen(),
          settings: settings,
          transitionType: TransitionType.slideUp,
          duration: AppDurations.pageTransition,
        );

      case AppRoutes.membership:
        return _buildRoute(
          page: const MembershipScreen(),
          settings: settings,
          transitionType: TransitionType.slideRight,
          duration: AppDurations.pageTransition,
        );

      case AppRoutes.unlockWardrobe:
        return _buildRoute(
          page: const UnlockWardrobeScreen(),
          settings: settings,
          transitionType: TransitionType.slideRight,
          duration: AppDurations.pageTransition,
        );

      case AppRoutes.systems:
        return _buildRoute(
          page: const SystemsScreen(),
          settings: settings,
          transitionType: TransitionType.slideRight,
          duration: AppDurations.pageTransition,
        );

      case AppRoutes.journal:
        return _buildRoute(
          page: const JournalScreen(),
          settings: settings,
          transitionType: TransitionType.slideRight,
          duration: AppDurations.pageTransition,
        );

      case AppRoutes.rewards:
        return _buildRoute(
          page: const RewardsScreen(),
          settings: settings,
          transitionType: TransitionType.slideRight,
          duration: AppDurations.pageTransition,
        );

      case AppRoutes.profile:
        return _buildRoute(
          page: const ProfileScreen(),
          settings: settings,
          transitionType: TransitionType.slideRight,
          duration: AppDurations.pageTransition,
        );

      case AppRoutes.notifications:
        return _buildRoute(
          page: const ProfileNotificationsScreen(),
          settings: settings,
          transitionType: TransitionType.slideRight,
          duration: AppDurations.pageTransition,
        );

      case AppRoutes.workoutSessionDetail:
        final session = settings.arguments as WorkoutSession?;
        return _buildRoute(
          page: WorkoutSessionDetailScreen(session: session),
          settings: settings,
          transitionType: TransitionType.slideRight,
          duration: AppDurations.pageTransition,
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

  static Route<dynamic> _buildRoute({
    required Widget page,
    required RouteSettings settings,
    TransitionType transitionType = TransitionType.fade,
    Duration duration = AppDurations.cardExpand,
  }) {
    // For slide transitions, CupertinoPageRoute provides native iOS interactive
    // edge swipe-to-back ('CupertinoBackGestureController') with native spring physics.
    if (transitionType == TransitionType.slideRight) {
      return CupertinoPageRoute<dynamic>(
        settings: settings,
        builder: (context) => page,
      );
    }

    if (transitionType == TransitionType.slideUp) {
      return CupertinoPageRoute<dynamic>(
        settings: settings,
        fullscreenDialog: true,
        builder: (context) => page,
      );
    }

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
          case TransitionType.slideUp:
          case TransitionType.none:
            return child;
        }
      },
    );
  }
}

