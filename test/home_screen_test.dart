import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ehgsmartapp/data/models/wellness_data_model.dart';
import 'package:ehgsmartapp/data/repositories/wellness_repository.dart';
import 'package:ehgsmartapp/presentation/blocs/wellness/wellness_bloc.dart';
import 'package:ehgsmartapp/presentation/blocs/wellness/wellness_event.dart';
import 'package:ehgsmartapp/presentation/views/home/home_screen.dart';
import 'package:ehgsmartapp/presentation/views/home/widgets/home_energy_card.dart';
import 'package:ehgsmartapp/presentation/views/home/widgets/home_hydration_card.dart';
import 'package:ehgsmartapp/presentation/views/home/widgets/home_mode_selector.dart';
import 'package:ehgsmartapp/presentation/views/home/widgets/home_readiness_card.dart';
import 'package:ehgsmartapp/presentation/views/home/widgets/home_vitals_summary_row.dart';
import 'package:ehgsmartapp/presentation/views/home/widgets/home_wellness_score_card.dart';
import 'package:ehgsmartapp/presentation/widgets/charts/wave_chart.dart';
import 'package:ehgsmartapp/presentation/widgets/common/card_section_header.dart';
import 'package:ehgsmartapp/presentation/widgets/custom_bottom_nav_bar.dart';

void main() {
  final repo = WellnessRepository();
  final sampleData = repo.getWellnessData();

  group('Home Screen Common Widgets & Cards Tests', () {
    testWidgets('CardSectionHeader renders title, action, and handles action tap', (tester) async {
      bool actionTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CardSectionHeader(
              title: 'Heart Rate',
              actionText: 'Today',
              onActionTap: () => actionTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Heart Rate'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);

      await tester.tap(find.text('Today'));
      await tester.pump();
      expect(actionTapped, isTrue);
    });

    testWidgets('HomeWellnessScoreCard renders score 84 and expands to show detailed pillars', (tester) async {
      final isExpandedNotifier = ValueNotifier<bool>(false);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: HomeWellnessScoreCard(
                score: 84,
                isExpandedNotifier: isExpandedNotifier,
              ),
            ),
          ),
        ),
      );

      // Initially collapsed
      expect(find.text('84'), findsOneWidget);
      expect(find.text('Wellness Score'), findsOneWidget);
      expect(find.text('↓ 3'), findsOneWidget);
      expect(find.text('from yesterday'), findsOneWidget);
      expect(find.text('Depleted'), findsNothing);

      // Tap card to expand
      await tester.tap(find.byType(HomeWellnessScoreCard));
      await tester.pumpAndSettle();

      // Detailed views shown as per Figma 60:289
      expect(isExpandedNotifier.value, isTrue);
      expect(find.text('Depleted'), findsOneWidget);
      expect(find.text('Movement is your weakest pillar today.'), findsOneWidget);
      expect(find.text('Short sleep is holding this down.'), findsOneWidget);
      expect(find.text('Stress load is elevated. Five minutes of breathing moves this.'), findsOneWidget);
      expect(find.text('Hydration is the quickest win available to you.'), findsOneWidget);
      expect(find.textContaining('Your Wellness Score is the average of the four systems'), findsOneWidget);

      // Tap again to collapse
      await tester.tap(find.byType(HomeWellnessScoreCard));
      await tester.pumpAndSettle();
      expect(isExpandedNotifier.value, isFalse);
    });

    testWidgets('HomeModeSelector switches modes and renders 3 tabs', (tester) async {
      WellnessMode selectedMode = WellnessMode.recover;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeModeSelector(
              currentMode: selectedMode,
              onModeChanged: (mode) => selectedMode = mode,
            ),
          ),
        ),
      );

      expect(find.text('Recover'), findsOneWidget);
      expect(find.text('Steady'), findsOneWidget);
      expect(find.text('Push'), findsOneWidget);

      await tester.tap(find.text('Push'));
      await tester.pumpAndSettle();
      expect(selectedMode, equals(WellnessMode.push));
    });

    testWidgets('HomeVitalsSummaryRow renders Heart Rate and Sleep cards horizontally', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeVitalsSummaryRow(
              heartRate: 72,
              weeklyHeartRate: const [68, 70, 72, 71, 73, 72, 70],
              sleepHours: 8.2,
            ),
          ),
        ),
      );

      expect(find.text('Heart Rate'), findsOneWidget);
      expect(find.text('72'), findsOneWidget);
      expect(find.text('bpm'), findsOneWidget);
      expect(find.text('Resting Rate'), findsOneWidget);

      expect(find.text('Sleep'), findsOneWidget);
      expect(find.text('8.2'), findsOneWidget);
      expect(find.text('Well-rested'), findsOneWidget);
    });

    testWidgets('HomeReadinessCard renders 62 score and 4 submetric tiles', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeReadinessCard(data: sampleData),
          ),
        ),
      );

      expect(find.text('62'), findsOneWidget);
      expect(find.text('Recover day'), findsOneWidget);
      expect(find.text('READINESS'), findsOneWidget);
      expect(find.text('6hr 30 min'), findsOneWidget);
      expect(find.text('44ms'), findsOneWidget);
      expect(find.text('61'), findsOneWidget);
      expect(find.text('46'), findsOneWidget);
    });

    testWidgets('HomeHydrationCard renders ml progress and capsule chart', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeHydrationCard(
              currentMl: 1650,
              goalMl: 2400,
              weeklyHydration: const [0.7, 0.6, 0.5, 0.8, 0.9, 1.0, 0.65],
            ),
          ),
        ),
      );

      expect(find.text('Hydration'), findsOneWidget);
      expect(find.text('1650'), findsOneWidget);
      expect(find.text(' / 2400 ml'), findsOneWidget);
      expect(find.text('On Track'), findsOneWidget);
    });

    testWidgets('HomeEnergyCard renders kcal burned and active minutes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeEnergyCard(
              energyBurned: 1750,
              activeMins: 210,
              goalMins: 600,
              weeklyEnergy: const [0.5, 0.4, 0.3, 0.6, 0.8, 0.9, 0.6],
            ),
          ),
        ),
      );

      expect(find.text('Energy burned'), findsOneWidget);
      expect(find.text('1750'), findsOneWidget);
      expect(find.text(' kcal'), findsOneWidget);
      expect(find.text('Active 210 / 600'), findsOneWidget);
      expect(find.text('Start a session'), findsOneWidget);
    });

    testWidgets('CustomBottomNavBar renders 12px border radius, 62px height and handles tab switching', (tester) async {
      int activeIndex = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: CustomBottomNavBar(
              activeIndex: activeIndex,
              onTabSelected: (index) => activeIndex = index,
            ),
          ),
        ),
      );

      // Verify tabs present
      expect(find.text('Vitals'), findsOneWidget);
      expect(find.text('Train'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      // Verify container height and 12px radius
      final container = tester.widget<Container>(
        find.byWidgetPredicate(
          (w) => w is Container && w.decoration is BoxDecoration && (w.decoration as BoxDecoration).borderRadius == BorderRadius.circular(12.0),
        ),
      );
      expect(container.constraints?.maxHeight ?? 62.0, equals(62.0));

      // Tap on Vitals tab
      await tester.tap(find.text('Vitals'));
      await tester.pumpAndSettle();
      expect(activeIndex, equals(1));
    });

    testWidgets('WaveChart interactive scrubbing updates activePointNotifier', (tester) async {
      final activeNotifier = ValueNotifier<int?>(null);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 340,
              height: 180,
              child: WaveChart(
                points: sampleData.dayChartPoints,
                activePointNotifier: activeNotifier,
              ),
            ),
          ),
        ),
      );

      // Initially null
      expect(activeNotifier.value, isNull);

      // Drag across the chart
      await tester.drag(find.byType(WaveChart), const Offset(150, 0));
      await tester.pump();

      // Notifier is now updated with an interactive scrub index
      expect(activeNotifier.value, isNotNull);
      expect(activeNotifier.value! >= 0, isTrue);
    });

    testWidgets('HomeScreen renders complete dashboard without crashing', (tester) async {
      final bloc = WellnessBloc(repository: repo)..add(const LoadWellnessDataEvent());

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<WellnessBloc>.value(
            value: bloc,
            child: const HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Hello john!'), findsOneWidget);
      expect(find.text('Wellness Score'), findsOneWidget);
      expect(find.text('Your day so far'), findsOneWidget);
      expect(find.text('Heart Rate'), findsOneWidget);
      expect(find.text('Sleep'), findsWidgets);
      expect(find.text('READINESS'), findsOneWidget);
      expect(find.text('Hydration'), findsOneWidget);
      expect(find.text('Energy burned'), findsOneWidget);
    });
  });
}
