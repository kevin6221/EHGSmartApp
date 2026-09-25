import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:google_fonts/google_fonts.dart';

import '../../blocs/band/band_bloc.dart';
import '../../blocs/band/band_event.dart';
import '../../blocs/band/band_state.dart';
import '../../blocs/navigation/navigation_bloc.dart';
import '../../blocs/navigation/navigation_event.dart';
import '../../blocs/navigation/navigation_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/band/band_permission_dialog.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../home/home_screen.dart';
import '../journal/journal_screen.dart';
import '../vitals/vitals_screen.dart';
import '../wardrobe/unlock_wardrobe_screen.dart';

/// Root shell screen maintaining persistent state for all bottom navigation tabs.
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  static const List<Widget> _screens = [
    HomeScreen(),
    VitalsScreen(),
    UnlockWardrobeScreen(),
    JournalScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<BandBloc, BandState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage && current.errorMessage != null,
      listener: (context, state) {
        final error = state.errorMessage;
        if (error == null) return;

        if (error.contains('Pairing info mismatch') ||
            error.contains('Forget This Device') ||
            error.toLowerCase().contains('pairing')) {
          BandPermissionDialog.show(
            context,
            type: BandPermissionDialogType.pairingMismatch,
            onAction: () => context.read<BandBloc>().add(OpenAppSettingsEvent()),
          );
        } else {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.systemRed,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              duration: const Duration(seconds: 4),
              content: Text(
                error,
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }
      },
      child: BlocSelector<NavigationBloc, NavigationState, int>(
        selector: (state) => state.activeIndex,
        builder: (context, activeIndex) {
          final safeIndex = activeIndex.clamp(0, _screens.length - 1);

          return Scaffold(
            extendBody: true,
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: IndexedStack(index: safeIndex, children: _screens),
              ),
            ),
            bottomNavigationBar: CustomBottomNavBar(
              activeIndex: safeIndex,
              onTabSelected: (index) {
                context.read<NavigationBloc>().add(TabChangedEvent(index));
              },
            ),
          );
        },
      ),
    );
  }
}
