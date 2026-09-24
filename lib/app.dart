import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/app_dependencies.dart';
import 'core/routes/app_router.dart';
import 'core/sync/background_sync_service.dart';
import 'core/sync/health_sync_manager.dart';
import 'core/theme/app_theme.dart';
import 'data/models/band_device_model.dart';
import 'data/models/user_profile_model.dart';
import 'data/repositories/band_repository.dart';
import 'data/repositories/wellness_repository.dart';
import 'presentation/blocs/band/band_bloc.dart';
import 'presentation/blocs/band/band_event.dart';
import 'presentation/blocs/band/band_state.dart';
import 'presentation/blocs/navigation/navigation_bloc.dart';
import 'presentation/blocs/onboarding/onboarding_cubit.dart';
import 'presentation/blocs/profile/profile_bloc.dart';
import 'presentation/blocs/profile/profile_event.dart';
import 'presentation/blocs/profile/profile_state.dart';
import 'presentation/blocs/training/training_bloc.dart';
import 'presentation/blocs/training/training_event.dart';
import 'presentation/blocs/vitals/vitals_bloc.dart';
import 'presentation/blocs/vitals/vitals_event.dart';
import 'presentation/blocs/wellness/wellness_bloc.dart';
import 'presentation/blocs/wellness/wellness_event.dart';

/// Root application widget configuring dependency injection, BLoC providers,
/// lifecycle syncing, and responsive theme routing.
class EHGWellnessApp extends StatefulWidget {
  const EHGWellnessApp({super.key});

  @override
  State<EHGWellnessApp> createState() => _EHGWellnessAppState();
}

class _EHGWellnessAppState extends State<EHGWellnessApp> {
  late final AppDependencies _dependencies;
  late final WellnessBloc _wellnessBloc;
  late final BandBloc _bandBloc;
  late final AppLifecycleListener _lifecycleListener;
  StreamSubscription<BandState>? _bandStateSubscription;

  @override
  void initState() {
    super.initState();
    _dependencies = AppDependencies();

    // 1. Core dashboard & connectivity state
    _wellnessBloc = WellnessBloc(repository: _dependencies.wellnessRepository)
      ..add(const LoadWellnessDataEvent());

    _bandBloc = BandBloc(
      repository: _dependencies.bandRepository,
      wellnessBloc: _wellnessBloc,
    )..add(AutoReconnectBandEvent());

    // 2. React to band connection for cold-start health data sync
    _bandStateSubscription = _bandBloc.stream.listen((bandState) {
      if (bandState.status == BandConnectionStatus.connected) {
        _dependencies.healthSyncManager
            .performColdStartSync(
              bandRepo: _dependencies.bandRepository,
              wellnessRepo: _dependencies.wellnessRepository,
            )
            .then((synced) {
              if (synced && mounted) {
                _wellnessBloc.add(const LoadWellnessDataEvent());
              }
            });
      }
    });

    // 3. Defer heavy background sync service initialization until after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_dependencies.backgroundSyncService.initialize());
    });

    // 4. Handle app lifecycle events
    _lifecycleListener = AppLifecycleListener(
      onResume: () {
        debugPrint(
          '📱 [APP LIFECYCLE] App resumed - checking band connection...',
        );
        if (_bandBloc.state.status != BandConnectionStatus.connected) {
          _bandBloc.add(AutoReconnectBandEvent());
        } else {
          _dependencies.backgroundSyncService
              .performBackgroundSync()
              .then((synced) {
                if (synced && mounted) {
                  _wellnessBloc.add(const LoadWellnessDataEvent());
                }
              });
        }
      },
    );
  }

  @override
  void dispose() {
    _bandStateSubscription?.cancel();
    _lifecycleListener.dispose();
    _bandBloc.close();
    _wellnessBloc.close();
    _dependencies.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<WellnessRepository>(
          create: (_) => _dependencies.wellnessRepository,
        ),
        RepositoryProvider<BandRepository>(
          create: (_) => _dependencies.bandRepository,
        ),
        RepositoryProvider<HealthSyncManager>(
          create: (_) => _dependencies.healthSyncManager,
        ),
        RepositoryProvider<BackgroundSyncService>(
          create: (_) => _dependencies.backgroundSyncService,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          // Active app-wide state
          BlocProvider<WellnessBloc>.value(value: _wellnessBloc),
          BlocProvider<BandBloc>.value(value: _bandBloc),
          BlocProvider<NavigationBloc>(
            lazy: true,
            create: (_) => NavigationBloc(),
          ),
          BlocProvider<ProfileBloc>(
            create: (ctx) =>
                ProfileBloc(repository: ctx.read<WellnessRepository>())
                  ..add(LoadProfileEvent()),
          ),

          // Heavy feature-level BLoCs initialized on-demand (lazy)
          BlocProvider<VitalsBloc>(
            lazy: true,
            create: (ctx) => VitalsBloc(
              repository: ctx.read<WellnessRepository>(),
              bandRepository: ctx.read<BandRepository>(),
            )..add(LoadVitalsEvent()),
          ),
          BlocProvider<TrainingBloc>(
            lazy: true,
            create: (ctx) => TrainingBloc(
              repository: ctx.read<WellnessRepository>(),
              bandRepository: ctx.read<BandRepository>(),
            )..add(LoadTrainingDataEvent()),
          ),
          BlocProvider<OnboardingCubit>(
            lazy: true,
            create: (_) => OnboardingCubit(),
          ),
        ],
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, profileState) {
            final appearance =
                profileState.data?.appearance ?? AppearanceTheme.system;
            final themeMode = switch (appearance) {
              AppearanceTheme.midnight => ThemeMode.dark,
              AppearanceTheme.dayLight => ThemeMode.light,
              AppearanceTheme.system => ThemeMode.system,
            };

            return MaterialApp(
              title: 'EHG Smart App',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              initialRoute: AppRouter.initialRoute,
              onGenerateRoute: AppRouter.onGenerateRoute,
              navigatorObservers: [
                FirebaseAnalyticsObserver(
                  analytics: FirebaseAnalytics.instance,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
