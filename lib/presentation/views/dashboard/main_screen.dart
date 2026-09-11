import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/navigation/navigation_bloc.dart';
import '../../blocs/navigation/navigation_event.dart';
import '../../blocs/navigation/navigation_state.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../train/train_screen.dart';
import '../vitals/vitals_screen.dart';

/// Root shell screen maintaining persistent state for all bottom navigation tabs.
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  static const List<Widget> _screens = [
    HomeScreen(),
    VitalsScreen(),
    TrainScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocSelector<NavigationBloc, NavigationState, int>(
      selector: (state) => state.activeIndex,
      builder: (context, activeIndex) {
        return Scaffold(
          extendBody: true,
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: IndexedStack(index: activeIndex, children: _screens),
            ),
          ),
          bottomNavigationBar: CustomBottomNavBar(
            activeIndex: activeIndex,
            onTabSelected: (index) {
              context.read<NavigationBloc>().add(TabChangedEvent(index));
            },
          ),
        );
      },
    );
  }
}
