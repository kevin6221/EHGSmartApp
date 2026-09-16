import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';

/// Stopwatch / Elapsed timer card for the active workout recording session.
class TrainingTimerCard extends StatelessWidget {
  final int elapsedSeconds;

  const TrainingTimerCard({
    super.key,
    required this.elapsedSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final media = MediaQuery.sizeOf(context);
    final totalSeconds = 16080 + elapsedSeconds;
    final duration = Duration(seconds: totalSeconds);
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    final timer = '$hours : $minutes : $seconds';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: (media.width * 0.06).clamp(18.0, 24.0),
        vertical: (media.height * 0.022).clamp(14.0, 20.0),
      ),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        gradient: AppGradients.timerCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary,
          width: 0.5,
        ),
      ),
      child: Text(
        timer,
        style: GoogleFonts.plusJakartaSans(
          color: AppColors.primary,
          fontSize: r.font(30),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
