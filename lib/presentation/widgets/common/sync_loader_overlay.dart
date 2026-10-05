import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_animations.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';

/// Premium sync loader overlay inspired by QWatch Pro.
///
/// Renders a glassmorphic frosted overlay on top of the HomeScreen
/// with concentric pulsing rings around the EHG logo and a status message.
class SyncLoaderOverlay extends StatefulWidget {
  /// Optional status message shown below the loader rings.
  final String statusMessage;

  const SyncLoaderOverlay({
    super.key,
    this.statusMessage = 'Syncing your data…',
  });

  @override
  State<SyncLoaderOverlay> createState() => _SyncLoaderOverlayState();
}

class _SyncLoaderOverlayState extends State<SyncLoaderOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _rotateController;
  late final AnimationController _fadeController;

  late final Animation<double> _pulse1;
  late final Animation<double> _pulse2;
  late final Animation<double> _pulse3;
  late final Animation<double> _rotation;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();

    // Concentric ring pulse animation (2.4s cycle)
    _pulseController = AnimationController(
      vsync: this,
      duration: AppDurations.splashPulse,
    )..repeat();

    // Outer ring slow rotation (8s cycle)
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // Fade-in for the whole overlay
    _fadeController = AnimationController(
      vsync: this,
      duration: AppDurations.pageTransition,
    )..forward();

    // Staggered pulses for each ring
    _pulse1 = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );
    _pulse2 = Tween<double>(begin: 0.90, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: const Interval(0.15, 0.75, curve: Curves.easeInOut),
      ),
    );
    _pulse3 = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: const Interval(0.3, 0.9, curve: Curves.easeInOut),
      ),
    );

    _rotation = CurvedAnimation(
      parent: _rotateController,
      curve: Curves.linear,
    );

    _fadeIn = CurvedAnimation(
      parent: _fadeController,
      curve: AppCurves.chartEase,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Ring dimensions scaled to screen
    final double outerRingSize = (r.width * 0.52).clamp(180.0, 240.0);
    final double middleRingSize = outerRingSize * 0.78;
    final double innerRingSize = outerRingSize * 0.56;
    final double logoSize = outerRingSize * 0.28;

    return FadeTransition(
      opacity: _fadeIn,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: isDark
                ? AppColors.midnightBackground.withValues(alpha: 0.72)
                : AppColors.background.withValues(alpha: 0.70),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Concentric pulsing rings with logo
                SizedBox(
                  width: outerRingSize,
                  height: outerRingSize,
                  child: AnimatedBuilder(
                    animation: Listenable.merge([
                      _pulseController,
                      _rotateController,
                    ]),
                    builder: (context, _) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer ring (rotating + pulsing)
                          Transform.scale(
                            scale: _pulse3.value,
                            child: RotationTransition(
                              turns: _rotation,
                              child: CustomPaint(
                                size: Size(outerRingSize, outerRingSize),
                                painter: _SyncRingPainter(
                                  color: isDark
                                      ? AppColors.primarySky.withValues(alpha: 0.22)
                                      : AppColors.primarySky.withValues(alpha: 0.18),
                                  strokeWidth: 2.0,
                                  dashGapRatio: 0.3,
                                ),
                              ),
                            ),
                          ),

                          // Middle ring (pulsing)
                          Transform.scale(
                            scale: _pulse2.value,
                            child: Container(
                              width: middleRingSize,
                              height: middleRingSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.primary.withValues(alpha: 0.32)
                                      : AppColors.primary.withValues(alpha: 0.24),
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),

                          // Inner ring (pulsing + subtle glow)
                          Transform.scale(
                            scale: _pulse1.value,
                            child: Container(
                              width: innerRingSize,
                              height: innerRingSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.primaryCyan.withValues(alpha: 0.45)
                                      : AppColors.primary.withValues(alpha: 0.38),
                                  width: 2.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.12),
                                    blurRadius: 24.0,
                                    spreadRadius: 4.0,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Center logo container with crisp badge and brand gradient logo
                          Container(
                            width: logoSize + 24.0,
                            height: logoSize + 24.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark
                                  ? AppColors.midnightSurface
                                  : AppColors.white,
                              border: Border.all(
                                color: isDark
                                    ? AppColors.midnightBorder
                                    : AppColors.primaryLight,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: isDark ? 0.35 : 0.16,
                                  ),
                                  blurRadius: 18.0,
                                  spreadRadius: 2.0,
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: ShaderMask(
                              shaderCallback: (Rect bounds) =>
                                  AppGradients.primaryLogo.createShader(bounds),
                              blendMode: BlendMode.srcIn,
                              child: SvgPicture.asset(
                                AppIcons.ehgLogo,
                                height: 40,
                                width: 40,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                SizedBox(height: r.hp(0.035)),

                // Status message
                Text(
                  widget.statusMessage,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: r.font(15.0),
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.midnightTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),

                SizedBox(height: r.hp(0.012)),

                // Subtle animated dots row
                _SyncDots(
                  color: isDark
                      ? AppColors.primaryCyan
                      : AppColors.primary,
                  controller: _pulseController,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter for the outer dashed/dotted rotating ring.
class _SyncRingPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashGapRatio;

  _SyncRingPainter({
    required this.color,
    required this.strokeWidth,
    this.dashGapRatio = 0.3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const int segments = 36;
    final double segmentAngle = (2 * math.pi) / segments;
    final double dashAngle = segmentAngle * (1.0 - dashGapRatio);

    for (int i = 0; i < segments; i++) {
      final startAngle = i * segmentAngle;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        dashAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SyncRingPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth;
}

/// Animated 3-dot progress indicator for sync status.
class _SyncDots extends StatelessWidget {
  final Color color;
  final AnimationController controller;

  const _SyncDots({required this.color, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            // Staggered opacity for each dot
            final double phase = (controller.value + (i * 0.25)) % 1.0;
            final double opacity = (math.sin(phase * math.pi)).clamp(0.2, 1.0);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3.0),
              child: Container(
                width: 6.0,
                height: 6.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: opacity),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
