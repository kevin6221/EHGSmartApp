import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';
import '../../../../data/models/wellness_data_model.dart';
import '../../../widgets/charts/wave_chart.dart';

/// Section showing the animated "Your day so far" wave chart.
/// Sits directly on the background surface without an enclosing card, matching Figma node 118:917.
class HomeDayWaveSection extends StatelessWidget {
  final List<DayChartPoint> points;
  final Animation<double> animation;

  const HomeDayWaveSection({
    super.key,
    required this.points,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your day so far',
          style: GoogleFonts.plusJakartaSans(
            fontSize: r.font(16.0),
            fontWeight: FontWeight.w700,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(height: 12.0),
        AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            return WaveChart(
              points: points,
              animationProgress: animation.value,
            );
          },
        ),
      ],
    );
  }
}
