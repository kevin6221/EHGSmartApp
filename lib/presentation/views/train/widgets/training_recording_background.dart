import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Top sky gradient background for workout recording session.
class TrainingRecordingBackground extends StatelessWidget {
  const TrainingRecordingBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: screenHeight * 0.35,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryGradientStart,
              AppColors.background.withValues(alpha: 0.0),
            ],
          ),
        ),
      ),
    );
  }
}
