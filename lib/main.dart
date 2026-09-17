import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/routes/app_router.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/wellness_repository.dart';
import 'presentation/blocs/navigation/navigation_bloc.dart';
import 'presentation/blocs/onboarding/onboarding_cubit.dart';
import 'presentation/blocs/profile/profile_bloc.dart';
import 'presentation/blocs/profile/profile_event.dart';
import 'presentation/blocs/training/training_bloc.dart';
import 'presentation/blocs/training/training_event.dart';
import 'presentation/blocs/vitals/vitals_bloc.dart';
import 'presentation/blocs/vitals/vitals_event.dart';
import 'presentation/blocs/wellness/wellness_bloc.dart';
import 'presentation/blocs/wellness/wellness_event.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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

class EHGWellnessApp extends StatelessWidget {
  const EHGWellnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    final wellnessRepository = WellnessRepository();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<WellnessRepository>.value(value: wellnessRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<NavigationBloc>(create: (_) => NavigationBloc()),
          BlocProvider<WellnessBloc>(
            create: (_) =>
                WellnessBloc(repository: wellnessRepository)
                  ..add(LoadWellnessDataEvent()),
          ),
          BlocProvider<VitalsBloc>(
            create: (_) =>
                VitalsBloc(repository: wellnessRepository)
                  ..add(LoadVitalsEvent()),
          ),
          BlocProvider<TrainingBloc>(
            create: (_) =>
                TrainingBloc(repository: wellnessRepository)
                  ..add(LoadTrainingDataEvent()),
          ),
          BlocProvider<ProfileBloc>(
            create: (_) =>
                ProfileBloc(repository: wellnessRepository)
                  ..add(LoadProfileEvent()),
          ),
          BlocProvider<OnboardingCubit>(create: (_) => OnboardingCubit()),
        ],
        child: MaterialApp(
          title: 'EHG Smart App',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          initialRoute: AppRouter.initialRoute,
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      ),
    );
  }
}
