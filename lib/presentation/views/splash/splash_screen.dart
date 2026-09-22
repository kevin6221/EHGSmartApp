import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_animations.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/repositories/band_repository.dart';
import '../../blocs/band/band_bloc.dart';
import '../../widgets/common/figma_circular_loader.dart';
import '../../widgets/splash/splash_pulsing_rings.dart';

/// Full-screen branding splash screen matching Figma Node 10:2334.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(AppDurations.splashDelay, _navigateToNext);
  }

  Future<void> _navigateToNext() async {
    if (!mounted) return;
    try {
      final bandRepo = context.read<BandRepository>();
      final bandBloc = context.read<BandBloc>();
      final prefs = await SharedPreferences.getInstance();

      final hasCachedDevice = prefs.getString('ehg_cached_device') != null ||
          bandRepo.lastPairedDevice != null;
      final isConnected =
          bandBloc.state.isConnected || bandRepo.currentConnectedDevice != null;
      final onboardingDone = prefs.getBool('ehg_onboarding_completed') ?? false;

      if (!mounted) return;

      if (isConnected || hasCachedDevice || onboardingDone) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
        return;
      }
    } catch (_) {}

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.welcome1);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;
    final screenHeight = media.size.height;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            AppConstants.splashBg,
            fit: BoxFit.cover,
            cacheWidth: (screenWidth * 2).toInt(),
          ),
          const Align(
            alignment: Alignment(0, -0.30),
            child: SplashPulsingRings(),
          ),
          Positioned(
            bottom: screenHeight * 0.08,
            left: 0,
            right: 0,
            child: const Center(child: FigmaCircularLoader(size: 56)),
          ),
        ],
      ),
    );
  }
}
