import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/database/app_database.dart';
import 'core/routes/app_router.dart';
import 'core/security/secure_storage_service.dart';
import 'core/sync/health_sync_manager.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'data/models/band_device_model.dart';
import 'data/repositories/band_repository.dart';
import 'data/repositories/wellness_repository.dart';
import 'presentation/blocs/band/band_bloc.dart';
import 'presentation/blocs/band/band_event.dart';
import 'presentation/blocs/band/band_state.dart';
import 'presentation/blocs/navigation/navigation_bloc.dart';
import 'presentation/blocs/onboarding/onboarding_cubit.dart';
import 'data/models/user_profile_model.dart';
import 'presentation/blocs/profile/profile_state.dart';
import 'presentation/blocs/profile/profile_bloc.dart';
import 'presentation/blocs/profile/profile_event.dart';
import 'presentation/blocs/training/training_bloc.dart';
import 'presentation/blocs/training/training_event.dart';
import 'presentation/blocs/vitals/vitals_bloc.dart';
import 'presentation/blocs/vitals/vitals_event.dart';
import 'presentation/blocs/wellness/wellness_bloc.dart';
import 'presentation/blocs/wellness/wellness_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SecureStorageService().ensureFreshInstallState();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: AppColors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const EHGWellnessApp());
}

class EHGWellnessApp extends StatefulWidget {
  const EHGWellnessApp({super.key});

  @override
  State<EHGWellnessApp> createState() => _EHGWellnessAppState();
}

class _EHGWellnessAppState extends State<EHGWellnessApp> {
  late final AppDatabase _appDatabase;
  late final SecureStorageService _secureStorage;
  late final WellnessRepository _wellnessRepository;
  late final BandRepository _bandRepository;
  late final HealthSyncManager _healthSyncManager;
  late final WellnessBloc _wellnessBloc;
  late final BandBloc _bandBloc;
  late final AppLifecycleListener _lifecycleListener;
  StreamSubscription<BandState>? _bandStateSubscription;

  @override
  void initState() {
    super.initState();
    _appDatabase = AppDatabase();
    _secureStorage = SecureStorageService();
    _healthSyncManager = HealthSyncManager(secureStorage: _secureStorage);
    _wellnessRepository = WellnessRepository(
      database: _appDatabase,
      secureStorage: _secureStorage,
    );
    _bandRepository = BandRepository(
      database: _appDatabase,
      secureStorage: _secureStorage,
    );
    _wellnessBloc = WellnessBloc(repository: _wellnessRepository)
      ..add(const LoadWellnessDataEvent());
    _bandBloc = BandBloc(
      repository: _bandRepository,
      wellnessBloc: _wellnessBloc,
    )..add(AutoReconnectBandEvent());

    _bandStateSubscription = _bandBloc.stream.listen((bandState) {
      if (bandState.status == BandConnectionStatus.connected) {
        _healthSyncManager.performColdStartSync(
          bandRepo: _bandRepository,
          wellnessRepo: _wellnessRepository,
        ).then((synced) {
          if (synced && mounted) {
            _wellnessBloc.add(const LoadWellnessDataEvent());
          }
        });
      }
    });

    _lifecycleListener = AppLifecycleListener(
      onResume: () {
        debugPrint('📱 [APP LIFECYCLE] App resumed - checking band connection...');
        if (_bandBloc.state.status != BandConnectionStatus.connected) {
          _bandBloc.add(AutoReconnectBandEvent());
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
    _bandRepository.dispose();
    _appDatabase.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<WellnessRepository>.value(value: _wellnessRepository),
        RepositoryProvider<BandRepository>.value(value: _bandRepository),
        RepositoryProvider<HealthSyncManager>.value(value: _healthSyncManager),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<WellnessBloc>.value(value: _wellnessBloc),
          BlocProvider<BandBloc>.value(value: _bandBloc),
          BlocProvider<NavigationBloc>(create: (_) => NavigationBloc()),
          BlocProvider<VitalsBloc>(
            create: (_) =>
                VitalsBloc(
                  repository: _wellnessRepository,
                  bandRepository: _bandRepository,
                )..add(LoadVitalsEvent()),
          ),
          BlocProvider<TrainingBloc>(
            create: (_) =>
                TrainingBloc(
                  repository: _wellnessRepository,
                  bandRepository: _bandRepository,
                )..add(LoadTrainingDataEvent()),
          ),
          BlocProvider<ProfileBloc>(
            create: (_) =>
                ProfileBloc(repository: _wellnessRepository)
                  ..add(LoadProfileEvent()),
          ),
          BlocProvider<OnboardingCubit>(create: (_) => OnboardingCubit()),
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
            );
          },
        ),
      ),
    );
  }
}
