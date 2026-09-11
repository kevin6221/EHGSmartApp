import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/wellness_data_model.dart';
import '../../../widgets/common/app_card.dart';

enum _SegmentType { sleep, hrv, rest, stress }

class _BarSegment {
  final double height;
  final _SegmentType type;
  const _BarSegment(this.height, this.type);
}

/// Exact 15 timeline bar columns extracted from Figma node 118:917 (Group 1376157171)
const List<List<_BarSegment>> _timelineColumns = [
  [_BarSegment(15.0, _SegmentType.hrv), _BarSegment(19.7, _SegmentType.sleep), _BarSegment(17.7, _SegmentType.hrv)],
  [_BarSegment(22.5, _SegmentType.hrv), _BarSegment(9.2, _SegmentType.sleep), _BarSegment(29.0, _SegmentType.hrv)],
  [_BarSegment(13.8, _SegmentType.rest), _BarSegment(5.0, _SegmentType.sleep), _BarSegment(17.9, _SegmentType.hrv)],
  [_BarSegment(34.7, _SegmentType.hrv), _BarSegment(26.3, _SegmentType.sleep), _BarSegment(21.0, _SegmentType.stress)],
  [_BarSegment(7.9, _SegmentType.hrv), _BarSegment(19.7, _SegmentType.sleep), _BarSegment(20.4, _SegmentType.rest)],
  [_BarSegment(34.7, _SegmentType.hrv), _BarSegment(14.5, _SegmentType.sleep), _BarSegment(14.7, _SegmentType.rest)],
  [_BarSegment(44.3, _SegmentType.hrv), _BarSegment(9.2, _SegmentType.sleep), _BarSegment(25.6, _SegmentType.rest)],
  [_BarSegment(21.2, _SegmentType.hrv), _BarSegment(31.3, _SegmentType.sleep), _BarSegment(5.6, _SegmentType.stress)],
  [_BarSegment(25.7, _SegmentType.hrv), _BarSegment(14.5, _SegmentType.sleep), _BarSegment(18.8, _SegmentType.rest)],
  [_BarSegment(42.3, _SegmentType.hrv), _BarSegment(20.7, _SegmentType.sleep), _BarSegment(22.4, _SegmentType.hrv)],
  [_BarSegment(12.3, _SegmentType.rest), _BarSegment(14.5, _SegmentType.sleep), _BarSegment(37.7, _SegmentType.sleep)],
  [_BarSegment(22.1, _SegmentType.hrv), _BarSegment(18.6, _SegmentType.sleep), _BarSegment(18.8, _SegmentType.sleep)],
  [_BarSegment(33.1, _SegmentType.hrv), _BarSegment(14.5, _SegmentType.sleep), _BarSegment(9.6, _SegmentType.sleep)],
  [_BarSegment(44.3, _SegmentType.hrv), _BarSegment(12.4, _SegmentType.sleep), _BarSegment(20.3, _SegmentType.sleep)],
  [_BarSegment(18.4, _SegmentType.hrv), _BarSegment(17.6, _SegmentType.sleep), _BarSegment(23.0, _SegmentType.hrv)],
];

/// Card showing Readiness score, timeline bars, and key sub-metrics (Sleep, HRV, Rest HR, Stress).
/// Pixel-perfect implementation matching Figma node 118:917 specs.
class HomeReadinessCard extends StatelessWidget {
  final WellnessDataModel data;
  final VoidCallback? onTap;

  const HomeReadinessCard({
    super.key,
    required this.data,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16.0),
      borderRadius: BorderRadius.circular(22.0),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
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
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${data.readinessScore}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 28.0,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    data.readinessTag,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF4FE),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'READINESS',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 10.0,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 2.0),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 14.0,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14.0),

          // Divider Line (Line 6 in Figma)
          Container(
            height: 0.5,
            color: const Color(0xFFE2E8F0),
          ),
          const SizedBox(height: 14.0),

          // 4 Dot Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _DotLegend(color: Color(0xFF1976D2), label: 'Sleep'),
              _DotLegend(color: Color(0xFF56A7FC), label: 'HRV'),
              _DotLegend(color: Color(0xFF6AD61F), label: 'Rest'),
              _DotLegend(color: Color(0xFFE72151), label: 'Stress'),
            ],
          ),
          const SizedBox(height: 16.0),

          // 15-Column Pill Timeline Chart
          RepaintBoundary(
            child: SizedBox(
              height: 106.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: _timelineColumns.map((col) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: col.map((seg) {
                      Color color;
                      switch (seg.type) {
                        case _SegmentType.sleep:
                          color = const Color(0xFF1976D2);
                          break;
                        case _SegmentType.hrv:
                          color = const Color(0xFF56A7FC);
                          break;
                        case _SegmentType.rest:
                          color = const Color(0xFF6AD61F);
                          break;
                        case _SegmentType.stress:
                          color = const Color(0xFFE72151);
                          break;
                      }

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 2.0),
                        width: 5.2,
                        height: seg.height,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(2.6),
                        ),
                      );
                    }).toList(),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 18.0),

          // 2x2 Sub-metric Grid Tiles
          Row(
            children: [
              Expanded(
                child: _buildTile(
                  title: 'Sleep',
                  value: data.sleepDetail,
                  bgColor: const Color(0xFFEFF6FF),
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: _buildTile(
                  title: 'HRV',
                  value: '${data.hrvMs}ms',
                  bgColor: const Color(0xFFEFF6FF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          Row(
            children: [
              Expanded(
                child: _buildTile(
                  title: 'Rest HR',
                  value: '${data.restHr}',
                  bgColor: const Color(0xFFF0FDF4),
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: _buildTile(
                  title: 'Stress',
                  value: '${data.stressScore}',
                  bgColor: const Color(0xFFFFF1F2),
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
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFF4B5563),
              fontWeight: FontWeight.w500,
              fontSize: 12.0,
            ),
          ),
          const SizedBox(height: 4.0),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16.0,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1F2937),
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

  const _DotLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8.0,
          height: 8.0,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6.0),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11.0,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF4B5563),
          ),
        ),
      ],
    );
  }
}
