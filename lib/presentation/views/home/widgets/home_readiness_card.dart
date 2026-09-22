import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';
import '../../../../data/models/wellness_data_model.dart';
import '../../../helpers/readiness_card_calculator.dart';
import '../../../widgets/common/app_card.dart';

/// Exact 15 timeline bar columns extracted from Figma node 118:917 (Group 1376157171)
const List<List<ReadinessBarSegmentDef>> _timelineColumns = [
  [
    ReadinessBarSegmentDef(15.0, ReadinessSegmentType.hrv),
    ReadinessBarSegmentDef(19.7, ReadinessSegmentType.sleep),
    ReadinessBarSegmentDef(17.7, ReadinessSegmentType.hrv),
  ],
  [
    ReadinessBarSegmentDef(22.5, ReadinessSegmentType.hrv),
    ReadinessBarSegmentDef(9.2, ReadinessSegmentType.sleep),
    ReadinessBarSegmentDef(29.0, ReadinessSegmentType.hrv),
  ],
  [
    ReadinessBarSegmentDef(13.8, ReadinessSegmentType.rest),
    ReadinessBarSegmentDef(5.0, ReadinessSegmentType.sleep),
    ReadinessBarSegmentDef(17.9, ReadinessSegmentType.hrv),
  ],
  [
    ReadinessBarSegmentDef(34.7, ReadinessSegmentType.hrv),
    ReadinessBarSegmentDef(26.3, ReadinessSegmentType.sleep),
    ReadinessBarSegmentDef(21.0, ReadinessSegmentType.stress),
  ],
  [
    ReadinessBarSegmentDef(7.9, ReadinessSegmentType.hrv),
    ReadinessBarSegmentDef(19.7, ReadinessSegmentType.sleep),
    ReadinessBarSegmentDef(20.4, ReadinessSegmentType.rest),
  ],
  [
    ReadinessBarSegmentDef(34.7, ReadinessSegmentType.hrv),
    ReadinessBarSegmentDef(14.5, ReadinessSegmentType.sleep),
    ReadinessBarSegmentDef(14.7, ReadinessSegmentType.rest),
  ],
  [
    ReadinessBarSegmentDef(44.3, ReadinessSegmentType.hrv),
    ReadinessBarSegmentDef(9.2, ReadinessSegmentType.sleep),
    ReadinessBarSegmentDef(25.6, ReadinessSegmentType.rest),
  ],
  [
    ReadinessBarSegmentDef(21.2, ReadinessSegmentType.hrv),
    ReadinessBarSegmentDef(31.3, ReadinessSegmentType.sleep),
    ReadinessBarSegmentDef(5.6, ReadinessSegmentType.stress),
  ],
  [
    ReadinessBarSegmentDef(25.7, ReadinessSegmentType.hrv),
    ReadinessBarSegmentDef(14.5, ReadinessSegmentType.sleep),
    ReadinessBarSegmentDef(18.8, ReadinessSegmentType.rest),
  ],
  [
    ReadinessBarSegmentDef(42.3, ReadinessSegmentType.hrv),
    ReadinessBarSegmentDef(20.7, ReadinessSegmentType.sleep),
    ReadinessBarSegmentDef(22.4, ReadinessSegmentType.hrv),
  ],
  [
    ReadinessBarSegmentDef(12.3, ReadinessSegmentType.rest),
    ReadinessBarSegmentDef(14.5, ReadinessSegmentType.sleep),
    ReadinessBarSegmentDef(37.7, ReadinessSegmentType.sleep),
  ],
  [
    ReadinessBarSegmentDef(22.1, ReadinessSegmentType.hrv),
    ReadinessBarSegmentDef(18.6, ReadinessSegmentType.sleep),
    ReadinessBarSegmentDef(18.8, ReadinessSegmentType.sleep),
  ],
  [
    ReadinessBarSegmentDef(33.1, ReadinessSegmentType.hrv),
    ReadinessBarSegmentDef(14.5, ReadinessSegmentType.sleep),
    ReadinessBarSegmentDef(9.6, ReadinessSegmentType.sleep),
  ],
  [
    ReadinessBarSegmentDef(44.3, ReadinessSegmentType.hrv),
    ReadinessBarSegmentDef(12.4, ReadinessSegmentType.sleep),
    ReadinessBarSegmentDef(20.3, ReadinessSegmentType.sleep),
  ],
  [
    ReadinessBarSegmentDef(18.4, ReadinessSegmentType.hrv),
    ReadinessBarSegmentDef(17.6, ReadinessSegmentType.sleep),
    ReadinessBarSegmentDef(23.0, ReadinessSegmentType.hrv),
  ],
];

/// Card showing Readiness score, timeline bars, and key sub-metrics (Sleep, HRV, Rest HR, Stress).
/// Dynamic responsive layout adhering to senior developer architecture.
class HomeReadinessCard extends StatelessWidget {
  final WellnessDataModel data;
  final VoidCallback? onTap;

  const HomeReadinessCard({super.key, required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final dims = ReadinessCardDimensions.compute(
      screenWidth: r.width,
      screenHeight: r.height,
    );

    return AppCard(
      padding: EdgeInsets.all(r.isSmall ? 12.0 : 16.0),
      borderRadius: BorderRadius.circular(22.0),
      boxShadow: [
        BoxShadow(
          color: AppColors.black.withValues(alpha: 0.03),
          blurRadius: 8.0,
          offset: const Offset(0, 4),
        ),
      ],
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Score + Status on left, "READINESS >" pill button on right
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    data.readinessScore > 0 ? '${data.readinessScore}' : '--',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: r.font(28.0),
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      height: 1.0,
                    ),
                  ),
                  SizedBox(width: dims.headerGap),
                  Text(
                    data.readinessScore > 0 ? data.readinessTag : 'No data',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: r.font(14.0),
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 5.0,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.readinessBadgeBg,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      'READINESS',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                        fontSize: r.font(12.0),
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4.0),
                  ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return AppGradients.primary.createShader(bounds);
                    },
                    blendMode: BlendMode.srcIn,
                    child: const Icon(
                      Icons.arrow_forward_ios_outlined,
                      size: 18.0,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: dims.itemSpacing),

          // Divider Line (Line 6 in Figma)
          Container(height: 0.5, color: AppColors.divider),
          SizedBox(height: dims.itemSpacing),

          // 4 Dot Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _DotLegend(color: AppColors.readinessSleep, label: 'Sleep', r: r),
              _DotLegend(color: AppColors.readinessHrv, label: 'HRV', r: r),
              _DotLegend(color: AppColors.readinessRest, label: 'Rest', r: r),
              _DotLegend(
                color: AppColors.readinessStress,
                label: 'Stress',
                r: r,
              ),
            ],
          ),
          SizedBox(height: dims.itemSpacing),
          RepaintBoundary(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final barWidth = ReadinessCardCalculator.computeBarWidth(
                  constraints.maxWidth,
                );

                return SizedBox(
                  height: dims.chartHeight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: _timelineColumns.map((colDefs) {
                      final segments =
                          ReadinessCardCalculator.computeColumnSegments(
                        columnDefs: colDefs,
                        chartHeight: dims.chartHeight,
                      );

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: segments.map((seg) {
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 2.0),
                            width: barWidth,
                            height: seg.height,
                            decoration: BoxDecoration(
                              color: seg.color,
                              borderRadius: BorderRadius.circular(barWidth / 2),
                            ),
                          );
                        }).toList(growable: false),
                      );
                    }).toList(growable: false),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: dims.itemSpacing * 1.1),

          Row(
            children: [
              Expanded(
                child: _buildTile(
                  title: 'Sleep',
                  value: data.sleepHours > 0 ? data.sleepDetail : '--',
                  accentColor: AppColors.readinessSleep,
                  tileBg: AppColors.tileSleepBg,
                  r: r,
                  dims: dims,
                ),
              ),
              SizedBox(width: dims.itemSpacing),
              Expanded(
                child: _buildTile(
                  title: 'HRV',
                  value: data.hrvMs > 0 ? '${data.hrvMs}ms' : '--',
                  accentColor: AppColors.readinessHrv,
                  tileBg: AppColors.tileHrvBg,
                  r: r,
                  dims: dims,
                ),
              ),
            ],
          ),
          SizedBox(height: dims.itemSpacing),
          Row(
            children: [
              Expanded(
                child: _buildTile(
                  title: 'Rest HR',
                  value: data.restHr > 0 ? '${data.restHr} bpm' : '--',
                  accentColor: AppColors.readinessRest,
                  tileBg: AppColors.tileGreenBg,
                  r: r,
                  dims: dims,
                ),
              ),
              SizedBox(width: dims.itemSpacing),
              Expanded(
                child: _buildTile(
                  title: 'Stress',
                  value: data.stressScore > 0 ? '${data.stressScore}' : '--',
                  accentColor: AppColors.readinessStress,
                  tileBg: AppColors.tileRoseBg,
                  r: r,
                  dims: dims,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTile({
    required String title,
    required String value,
    required Color accentColor,
    required Responsive r,
    required ReadinessCardDimensions dims,
    Color? valueColor,
    Color? tileBg,
    Gradient? gradient,
  }) {
    final effectiveGradient =
        gradient ??
        LinearGradient(
          colors: [
            tileBg ?? accentColor.withValues(alpha: 0.12),
            AppColors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dims.tilePadH,
        vertical: dims.tilePadV,
      ),
      decoration: BoxDecoration(
        gradient: effectiveGradient,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.04),
            blurRadius: 12.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.secondary,
              fontWeight: FontWeight.w500,
              fontSize: r.font(14.0),
            ),
          ),
          const SizedBox(height: 4.0),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: r.font(18.0),
                fontWeight: FontWeight.w700,
                color: valueColor ?? AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DotLegend extends StatelessWidget {
  final Color color;
  final String label;
  final Responsive r;

  const _DotLegend({required this.color, required this.label, required this.r});

  @override
  Widget build(BuildContext context) {
    final dotSize = (r.width * 0.041).clamp(12.0, 18.0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6.0),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: r.font(12.0),
            fontWeight: FontWeight.w500,
            color: AppColors.tertiary,
          ),
        ),
      ],
    );
  }
}
