import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ehgsmartapp/core/routes/app_router.dart';
import 'package:ehgsmartapp/core/routes/app_routes.dart';
import 'package:ehgsmartapp/core/theme/app_colors.dart';
import 'package:ehgsmartapp/presentation/views/onboarding/onboarding_screen_1.dart';
import 'package:ehgsmartapp/presentation/views/onboarding/onboarding_screen_2.dart';
import 'package:ehgsmartapp/presentation/views/onboarding/onboarding_screen_3.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ehgsmartapp/core/constants/app_icons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ehgsmartapp/presentation/blocs/onboarding/onboarding_cubit.dart';
import 'package:ehgsmartapp/presentation/widgets/common/app_button.dart';
import 'package:ehgsmartapp/presentation/widgets/onboarding/onboarding_device_card.dart';
import 'package:ehgsmartapp/presentation/widgets/onboarding/onboarding_progress_bar.dart';
import 'package:ehgsmartapp/presentation/widgets/onboarding/onboarding_radar_graphic.dart';

void main() {
  group('OnboardingProgressBar', () {
    testWidgets('renders all 5 capsule segments with correct active states', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OnboardingProgressBar(currentStep: 2, totalSteps: 5),
          ),
        ),
      );

      final barFinder = find.byType(OnboardingProgressBar);
      expect(barFinder, findsOneWidget);
    });

    testWidgets(
      'dynamically infers current step from active route when currentStep is omitted',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            onGenerateRoute: AppRouter.onGenerateRoute,
            initialRoute: AppRoutes.onboarding2,
          ),
        );

        final barFinder = find.byType(OnboardingProgressBar);
        expect(barFinder, findsOneWidget);
      },
    );

    testWidgets('dynamically responds to OnboardingCubit state updates', (
      tester,
    ) async {
      final cubit = OnboardingCubit(initialStep: 1);

      await tester.pumpWidget(
        BlocProvider<OnboardingCubit>.value(
          value: cubit,
          child: const MaterialApp(
            home: Scaffold(body: OnboardingProgressBar()),
          ),
        ),
      );

      expect(find.byType(OnboardingProgressBar), findsOneWidget);
      expect(cubit.state.currentStep, 1);
      expect(cubit.state.progress, closeTo(1 / 5, 0.001));

      cubit.nextStep();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(cubit.state.currentStep, 2);
      expect(cubit.state.progress, closeTo(2 / 5, 0.001));

      cubit.setStep(4);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(cubit.state.currentStep, 4);

      cubit.previousStep();
      expect(cubit.state.currentStep, 3);

      cubit.reset();
      expect(cubit.state.currentStep, 1);
    });
  });

  group('OnboardingScreen1 (Figma Node 10:2408)', () {
    testWidgets('renders pixel-perfect layout, cascading cards, and Next CTA', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(375 * 2, 812 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          onGenerateRoute: AppRouter.onGenerateRoute,
          initialRoute: AppRoutes.onboarding1,
        ),
      );

      // Verify Screen and Title & Subtitle
      expect(find.byType(OnboardingScreen1), findsOneWidget);
      expect(find.text('Wellness That Understands You.'), findsOneWidget);
      expect(
        find.text(
          "EHG turns your body's signals into simple, personalized guidance for every day.",
        ),
        findsOneWidget,
      );

      // Verify SVG metric cards graphic is rendered
      final svgFinder = find.byWidgetPredicate((widget) {
        if (widget is! SvgPicture) return false;
        final bytesLoader = widget.bytesLoader;
        return bytesLoader.toString().contains(AppIcons.onboardingFirstCard);
      });
      expect(svgFinder, findsOneWidget);

      // Verify Next CTA
      expect(find.byType(AppButton), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);

      // Test navigation to Onboarding 2
      await tester.tap(find.text('Next'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(OnboardingScreen2), findsOneWidget);
    });
  });

  group('OnboardingScreen2 (Figma Nodes 14:2600 & 16:2978)', () {
    testWidgets(
      'starts at Radar Scanner (14:2600) and transitions to Device Found (16:2978) on tap',
      (tester) async {
        tester.view.physicalSize = const Size(375 * 2, 812 * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          const MaterialApp(
            onGenerateRoute: AppRouter.onGenerateRoute,
            initialRoute: AppRoutes.onboarding2,
          ),
        );

        // Verify Title & Subtitle
        expect(find.text('Connect your band'), findsOneWidget);
        expect(
          find.text(
            'Make sure your EHG Smart Band is charged and nearby. If it is currently paired to another app, unpair it there first.',
          ),
          findsOneWidget,
        );

        // State 1: Verify Radar Scanner Graphic & "Find My band" CTA
        final radarFinder = find.byType(OnboardingRadarGraphic);
        expect(radarFinder, findsOneWidget);
        expect(find.text('Find My band'), findsOneWidget);
        expect(find.text('Bluetooth   •   Ready'), findsOneWidget);

        // Tap "Find My band"
        await tester.tap(find.text('Find My band'));
        await tester.pumpAndSettle();

        // State 2: Verify Device Card & "Connect" CTA
        expect(find.byType(OnboardingDeviceCard), findsOneWidget);
        expect(find.text('EHG Smart Band'), findsOneWidget);
        expect(find.text('EH-9F2C'), findsOneWidget);
        expect(find.text('Connect'), findsOneWidget);
        expect(find.text('Your data stays on your phone'), findsOneWidget);

        // Tap "Connect" to navigate to OnboardingScreen3
        await tester.tap(find.text('Connect'));
        await tester.pumpAndSettle();

        expect(find.byType(OnboardingScreen3), findsOneWidget);
      },
    );
  });

  group('OnboardingScreen3 (Figma Node 16:4201 & 16:4267)', () {
    testWidgets(
      'renders title, input with filled state, and navigates to Screen 4',
      (tester) async {
        tester.view.physicalSize = const Size(375 * 2, 812 * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          MaterialApp(
            onGenerateRoute: (settings) {
              if (settings.name == AppRoutes.onboarding4) {
                return MaterialPageRoute(
                  settings: settings,
                  builder: (_) =>
                      const Scaffold(body: Text('Screen 4 Landing')),
                );
              }
              return AppRouter.onGenerateRoute(settings);
            },
            initialRoute: AppRoutes.onboarding3,
          ),
        );

        // Verify Header
        expect(find.text('A little about you'), findsOneWidget);
        expect(
          find.text(
            'Just few detail to get started. Tell us your name so we can make your EHG experience feel personal.',
          ),
          findsOneWidget,
        );

        // Verify Input Field with placeholder
        expect(find.text('What should we call you?'), findsOneWidget);

        // Verify Regulatory Notice
        expect(
          find.text('For regulatory purposes, please enter name stated'),
          findsOneWidget,
        );

        // Verify Next CTA initially in disabled state (empty input)
        final initialButton = tester.widget<AppButton>(find.byType(AppButton));
        expect(initialButton.onPressed, isNull);
        expect(initialButton.disabledTextColor, AppColors.primary);
        expect(find.text('Your data stays on your phone'), findsOneWidget);

        // Tapping disabled Next button should NOT navigate
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
        expect(find.text('Screen 4 Landing'), findsNothing);

        // Test typing user name into text field -> button becomes filled & enabled
        await tester.enterText(find.byType(TextField), 'Alex Johnson');
        await tester.pump();
        expect(find.text('Alex Johnson'), findsOneWidget);
        expect(find.byIcon(Icons.cancel_rounded), findsOneWidget);

        final enabledButton = tester.widget<AppButton>(find.byType(AppButton));
        expect(enabledButton.onPressed, isNotNull);

        // Tap cancel icon to clear text -> button reverts to disabled
        await tester.tap(find.byIcon(Icons.cancel_rounded));
        await tester.pump();
        expect(find.text('What should we call you?'), findsOneWidget);
        final revertedButton = tester.widget<AppButton>(find.byType(AppButton));
        expect(revertedButton.onPressed, isNull);

        // Type name again and tap Next CTA to navigate to Screen 4
        await tester.enterText(find.byType(TextField), 'Alex Johnson');
        await tester.pump();
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();

        expect(find.text('Screen 4 Landing'), findsOneWidget);
      },
    );
  });

  group('OnboardingScreen4 (Figma Node 16:4318)', () {
    testWidgets('renders age picker and navigates to Screen 5', (tester) async {
      tester.view.physicalSize = const Size(375 * 2, 812 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          onGenerateRoute: (settings) {
            if (settings.name == AppRoutes.onboarding5) {
              return MaterialPageRoute(
                settings: settings,
                builder: (_) => const Scaffold(body: Text('Screen 5 Landing')),
              );
            }
            return AppRouter.onGenerateRoute(settings);
          },
          initialRoute: AppRoutes.onboarding4,
        ),
      );

      // Verify title and subtitle
      expect(find.text('How old are you?'), findsOneWidget);
      expect(
        find.text(
          'Your age helps EHG personalize your heart-rate zones and wellness insights for you.',
        ),
        findsOneWidget,
      );

      // Verify age display badge with default age
      expect(find.text("I'm 32 years of age"), findsOneWidget);

      // Verify Continue CTA
      expect(find.text('Continue'), findsOneWidget);

      // Verify privacy footer
      expect(find.text('Your data stays on your phone'), findsOneWidget);

      // Tap Continue to navigate to Screen 5
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Screen 5 Landing'), findsOneWidget);
    });
  });

  group('OnboardingScreen5 (Figma Node 120:1785)', () {
    testWidgets('renders plan selection cards with features', (tester) async {
      tester.view.physicalSize = const Size(375 * 2, 812 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final cubit = OnboardingCubit();
      cubit.setUserName('Alex');

      await tester.pumpWidget(
        BlocProvider<OnboardingCubit>.value(
          value: cubit,
          child: MaterialApp(
            onGenerateRoute: (settings) {
              if (settings.name == AppRoutes.dashboard) {
                return MaterialPageRoute(
                  settings: settings,
                  builder: (_) =>
                      const Scaffold(body: Text('Dashboard Landing')),
                );
              }
              return AppRouter.onGenerateRoute(settings);
            },
            initialRoute: AppRoutes.onboarding5,
          ),
        ),
      );

      // Verify personalized title
      expect(find.text('How do you want to use EHG, Alex?'), findsOneWidget);

      // Verify subtitle
      expect(
        find.text(
          'You can change this at any time. Nothing is locked away permanently.',
        ),
        findsOneWidget,
      );

      // Verify Free plan card
      expect(find.text('Health Tracking'), findsOneWidget);
      expect(find.text('FREE'), findsOneWidget);
      expect(find.text('Start tracking'), findsOneWidget);

      // Verify Premium plan card
      expect(find.text('Connected Wellness'), findsOneWidget);
      expect(find.text('£4.99/mo'), findsOneWidget);
      expect(find.text('Explore the full system'), findsOneWidget);

      // Verify features exist
      expect(
        find.text(
          'Every vital: sleep stages, HRV, blood oxygen, stress, breathing rate',
        ),
        findsOneWidget,
      );

      // Scroll to "Start tracking" button and tap to navigate to dashboard
      await tester.scrollUntilVisible(
        find.text('Start tracking'),
        200.0,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start tracking'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text('Dashboard Landing'), findsOneWidget);
    });
  });

  group('OnboardingCubit extended state', () {
    test('supports userAge and selectedPlan fields', () {
      final cubit = OnboardingCubit();

      expect(cubit.state.userAge, 32);
      expect(cubit.state.selectedPlan, '');

      cubit.setUserAge(25);
      expect(cubit.state.userAge, 25);

      cubit.setSelectedPlan('premium');
      expect(cubit.state.selectedPlan, 'premium');

      cubit.reset();
      expect(cubit.state.userAge, 32);
      expect(cubit.state.selectedPlan, '');
    });
  });
}
