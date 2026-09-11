import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';

/// Card showing the overall wellness score with trend indicator, activity tags,
/// and interactive full detailed expanded view matching Figma node 60:289 (Home >> Expanded).
/// Implements zero setState using ValueNotifier and ValueListenableBuilder.
class HomeWellnessScoreCard extends StatelessWidget {
  final int score;
  final String scoreChange;
  final bool isNegativeChange;
  final ValueNotifier<bool>? isExpandedNotifier;
  final VoidCallback? onTap;

  HomeWellnessScoreCard({
    super.key,
    required this.score,
    this.scoreChange = '↓ 3',
    this.isNegativeChange = true,
    this.isExpandedNotifier,
    this.onTap,
  }) : _internalExpanded = isExpandedNotifier ?? ValueNotifier<bool>(false);

  final ValueNotifier<bool> _internalExpanded;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _internalExpanded,
      builder: (context, isExpanded, _) {
        return GestureDetector(
          onTap: () {
            _internalExpanded.value = !_internalExpanded.value;
            onTap?.call();
          },
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22.0),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFB5D7F2),
                  Color(0xFFEFFBFF),
                  Colors.white,
                ],
                stops: [0.0, 0.54, 1.0],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: AppColors.primary,
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8.0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: isExpanded
                ? _buildExpandedView(context)
                : _buildCollapsedView(context),
          ),
        );
      },
    );
  }

  // --- 1. Collapsed View (Figma 118:917 / Rectangle 126, height 84) ---
  Widget _buildCollapsedView(BuildContext context) {
    return Row(
      children: [
        // Score badge (56x56 with 12px radius)
        Container(
          width: 56.0,
          height: 56.0,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: AppColors.primary,
              width: 0.5,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            '$score',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 28.0,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              height: 1.0,
            ),
          ),
        ),
        const SizedBox(width: 14.0),

        // Details column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Row: "Wellness Score" + "↓ 3" + "from yesterday"
              Row(
                children: [
                  Text(
                    'Wellness Score',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(width: 6.0),
                  Text(
                    scoreChange,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                      color: isNegativeChange
                          ? const Color(0xFFFF383C)
                          : AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    'from yesterday',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.0,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF4B5563).withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),

              // Bottom Row: Move & Recover pills + Chevron
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const AppSvgIcon(
                        AppIcons.runner,
                        size: 15.0,
                        color: Color(0xFF0EA5E9),
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        'Move',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF4B5563),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Container(
                        width: 4.0,
                        height: 4.0,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      const AppSvgIcon(
                        AppIcons.vitals,
                        size: 15.0,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        'Recover',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF4B5563),
                        ),
                      ),
                    ],
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 22.0,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- 2. Expanded Detail View (Figma Node 60:289, height ~571) ---
  Widget _buildExpandedView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top section: Concentric Rings on left, 2x2 Pillar Legend on right, Chevron up
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Concentric Rings Graphic with Center Score & Status
            SizedBox(
              width: 140.0,
              height: 140.0,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(140.0, 140.0),
                    painter: _ConcentricRingsPainter(),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$score',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 28.0,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1F2937),
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        'Depleted',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF4B5563),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14.0),

            // Right: 2x2 Pillar Legend + Chevron
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Wellness Score',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_up_rounded,
                        size: 22.0,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),
                  Row(
                    children: [
                      Expanded(
                        child: _buildLegendItem(
                          color: const Color(0xFF3E50C8),
                          label: 'Move',
                          score: 36,
                        ),
                      ),
                      Expanded(
                        child: _buildLegendItem(
                          color: const Color(0xFF3E83C8),
                          label: 'Recover',
                          score: 73,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    children: [
                      Expanded(
                        child: _buildLegendItem(
                          color: const Color(0xFF1CB6E3),
                          label: 'Mind',
                          score: 30,
                        ),
                      ),
                      Expanded(
                        child: _buildLegendItem(
                          color: const Color(0xFF861CE3),
                          label: 'Fuel',
                          score: 31,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14.0),

        // Divider (Line 11 in Figma)
        Container(
          height: 1.0,
          color: const Color(0xFF4B5563).withValues(alpha: 0.15),
        ),
        const SizedBox(height: 14.0),

        // 4 Pillar Breakdown Rows (Figma 60:289)
        _buildPillarRow(
          score: 36,
          scoreColor: const Color(0xFF3E50C8),
          title: 'Move',
          fraction: 0.36,
          insight: 'Movement is your weakest pillar today.',
        ),
        const SizedBox(height: 12.0),
        _buildPillarRow(
          score: 73,
          scoreColor: const Color(0xFF3E83C8),
          title: 'Recover',
          fraction: 0.73,
          insight: 'Short sleep is holding this down.',
        ),
        const SizedBox(height: 12.0),
        _buildPillarRow(
          score: 30,
          scoreColor: const Color(0xFF1CB6E3),
          title: 'Mind',
          fraction: 0.30,
          insight: 'Stress load is elevated. Five minutes of breathing moves this.',
        ),
        const SizedBox(height: 12.0),
        _buildPillarRow(
          score: 31,
          scoreColor: const Color(0xFF861CE3),
          title: 'Fuel',
          fraction: 0.31,
          insight: 'Hydration is the quickest win available to you.',
        ),
        const SizedBox(height: 14.0),

        // Divider (Line 31 in Figma)
        Container(
          height: 1.0,
          color: const Color(0xFF4B5563).withValues(alpha: 0.15),
        ),
        const SizedBox(height: 10.0),

        // Footer explanation note (Figma 60:289)
        Text(
          'Your Wellness Score is the average of the four systems, recalculated as the day goes on. Drink water, finish a session or log a breathing exercise and watch it move.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10.0,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF4B5563),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required int score,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8.0,
          height: 8.0,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5.0),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.0,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(width: 4.0),
        Text(
          '$score',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildPillarRow({
    required int score,
    required Color scoreColor,
    required String title,
    required double fraction,
    required String insight,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '$score',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18.0,
                fontWeight: FontWeight.w700,
                color: scoreColor,
              ),
            ),
            const SizedBox(width: 8.0),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1F2937),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5.0),
        // Progress Bar
        ClipRRect(
          borderRadius: BorderRadius.circular(2.0),
          child: Container(
            height: 3.0,
            width: double.infinity,
            color: scoreColor.withValues(alpha: 0.15),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: fraction.clamp(0.0, 1.0),
              child: Container(
                height: 3.0,
                color: scoreColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 5.0),
        Text(
          insight,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11.0,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF4B5563),
          ),
        ),
      ],
    );
  }
}

/// Custom painter for the 4 concentric donut arcs matching Figma 60:289.
class _ConcentricRingsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    const rings = [
      // 1. Move (Outer-most: #3E50C8, score 36)
      _RingSpec(radius: 64.0, strokeWidth: 5.0, color: Color(0xFF3E50C8), sweepPercent: 0.36, startAngle: -math.pi / 2),
      // 2. Recover (#3E83C8, score 73)
      _RingSpec(radius: 54.0, strokeWidth: 5.0, color: Color(0xFF3E83C8), sweepPercent: 0.73, startAngle: -math.pi / 2),
      // 3. Mind (#1CB6E3, score 30)
      _RingSpec(radius: 44.0, strokeWidth: 5.0, color: Color(0xFF1CB6E3), sweepPercent: 0.30, startAngle: -math.pi / 2),
      // 4. Fuel (Inner-most: #861CE3, score 31)
      _RingSpec(radius: 34.0, strokeWidth: 5.0, color: Color(0xFF861CE3), sweepPercent: 0.31, startAngle: -math.pi / 2),
    ];

    for (final ring in rings) {
      // Background track
      final trackPaint = Paint()
        ..color = ring.color.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = ring.strokeWidth;

      canvas.drawCircle(center, ring.radius, trackPaint);

      // Active arc
      final activePaint = Paint()
        ..color = ring.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = ring.strokeWidth
        ..strokeCap = StrokeCap.round;

      final rect = Rect.fromCircle(center: center, radius: ring.radius);
      final sweepAngle = 2 * math.pi * ring.sweepPercent;
      canvas.drawArc(rect, ring.startAngle, sweepAngle, false, activePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RingSpec {
  final double radius;
  final double strokeWidth;
  final Color color;
  final double sweepPercent;
  final double startAngle;

  const _RingSpec({
    required this.radius,
    required this.strokeWidth,
    required this.color,
    required this.sweepPercent,
    required this.startAngle,
  });
}
