import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';
import '../../../helpers/vitals_card_calculator.dart';
import '../../../widgets/common/app_card.dart';
import '../../../widgets/painters/trend_wave_painter.dart';

/// Single unified card containing Blood Pressure Trend and Skin Temperature rows
/// with smooth sine waves and open circular beads matching Figma Node 75:1819 / 119:1654.
class VitalsTwinTrendCards extends StatelessWidget {
  final String bloodPressure;
  final double skinTempDiff;
  final VoidCallback? onBloodPressureTap;
  final VoidCallback? onSkinTempTap;

  const VitalsTwinTrendCards({
    super.key,
    required this.bloodPressure,
    required this.skinTempDiff,
    this.onBloodPressureTap,
    this.onSkinTempTap,
  });

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final dims = VitalsCardDimensions.fromResponsive(r);
    final waveWidth = (r.width * 0.26).clamp(80.0, 110.0);
    final waveHeight = (r.height * 0.05).clamp(38.0, 50.0);

    return AppCard(
      padding: EdgeInsets.symmetric(
        horizontal: dims.cardPadding,
        vertical: (r.height * 0.02).clamp(16.0, 22.0),
      ),
      borderRadius: BorderRadius.circular(dims.cardRadius),
      boxShadow: [
        BoxShadow(
          color: AppColors.shadowNavy.withValues(alpha: 0.04),
          blurRadius: 16.0,
          offset: const Offset(0, 4),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Blood Pressure Trend Row
          InkWell(
            onTap: onBloodPressureTap,
            borderRadius: BorderRadius.circular(12.0),
            child: Row(
              children: [
                SizedBox(
                  width: waveWidth,
                  height: waveHeight,
                  child: const RepaintBoundary(
                    child: CustomPaint(
                      painter: TrendWavePainter(
                        waveColor: AppColors.primary,
                        isUpTrend: true,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: (r.width * 0.05).clamp(14.0, 24.0)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              (bloodPressure.isNotEmpty && bloodPressure != '0/0' && bloodPressure != '--/--')
                                  ? bloodPressure
                                  : '--',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: r.font(25.0),
                                fontWeight: FontWeight.w600,
                                color: context.textPrimary,
                                height: 1.1,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6.0),
                          SvgPicture.asset(
                            AppIcons.downArrowBlue,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'Blood pressure trend',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: r.font(13.0),
                          fontWeight: FontWeight.w400,
                          color: context.textSecondary,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: (r.height * 0.024).clamp(16.0, 24.0)),

          // 2. Skin Temperature Trend Row
          InkWell(
            onTap: onSkinTempTap,
            borderRadius: BorderRadius.circular(12.0),
            child: Row(
              children: [
                SizedBox(
                  width: waveWidth,
                  height: waveHeight,
                  child: const RepaintBoundary(
                    child: CustomPaint(
                      painter: TrendWavePainter(
                        waveColor: AppColors.cyanAccent,
                        isUpTrend: false,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: (r.width * 0.05).clamp(14.0, 24.0)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              skinTempDiff != 0.0 ? '${skinTempDiff > 0 ? '+' : ''}$skinTempDiff°C' : '--',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: r.font(25.0),
                                fontWeight: FontWeight.w600,
                                color: context.textPrimary,
                                height: 1.1,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6.0),
                          SvgPicture.asset(
                            AppIcons.upArrowBlue,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'Skin temperature',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: r.font(13.0),
                          fontWeight: FontWeight.w400,
                          color: context.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
