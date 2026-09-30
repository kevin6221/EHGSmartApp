import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_animations.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/engine/recommendation_engine.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';
import '../../../helpers/vitals_card_calculator.dart';
import '../../../widgets/common/app_card.dart';
import '../../../widgets/painters/trend_wave_painter.dart';
import 'vitals_interpretation_section.dart';

/// Single unified card containing Blood Pressure Trend and Skin Temperature rows
/// with smooth sine waves and open circular beads matching Figma Node 75:1819 / 119:1654.
///
/// Expandable to reveal dynamic "What it is", "Your reading", and "Do this" actionable interpretation.
class VitalsTwinTrendCards extends StatefulWidget {
  final String bloodPressure;
  final double skinTempDiff;
  final VoidCallback? onBloodPressureTap;
  final VoidCallback? onSkinTempTap;
  final ValueNotifier<bool>? isBpExpandedNotifier;
  final ValueNotifier<bool>? isSkinTempExpandedNotifier;

  const VitalsTwinTrendCards({
    super.key,
    required this.bloodPressure,
    this.skinTempDiff = 0.0,
    this.onBloodPressureTap,
    this.onSkinTempTap,
    this.isBpExpandedNotifier,
    this.isSkinTempExpandedNotifier,
  });

  @override
  State<VitalsTwinTrendCards> createState() => _VitalsTwinTrendCardsState();
}

class _VitalsTwinTrendCardsState extends State<VitalsTwinTrendCards>
    with TickerProviderStateMixin {
  late final ValueNotifier<bool> _bpExpandedNotifier;
  // late final ValueNotifier<bool> _skinTempExpandedNotifier;
  bool _internalBpAllocated = false;
  // bool _internalSkinTempAllocated = false;

  late final AnimationController _bpAnimController;
  late final Animation<double> _bpHeightFactor;

  // Skin temp not supported by hardware - controller commented out
  // late final AnimationController _skinTempAnimController;
  // late final Animation<double> _skinTempHeightFactor;

  @override
  void initState() {
    super.initState();
    if (widget.isBpExpandedNotifier != null) {
      _bpExpandedNotifier = widget.isBpExpandedNotifier!;
    } else {
      _bpExpandedNotifier = ValueNotifier<bool>(false);
      _internalBpAllocated = true;
    }

    _bpAnimController = AnimationController(
      duration: AppDurations.cardExpand,
      vsync: this,
    );
    _bpHeightFactor = CurvedAnimation(
      parent: _bpAnimController,
      curve: Curves.fastOutSlowIn,
    );
    if (_bpExpandedNotifier.value) {
      _bpAnimController.value = 1.0;
    }
    _bpExpandedNotifier.addListener(_handleBpChange);
  }

  void _handleBpChange() {
    if (_bpExpandedNotifier.value) {
      _bpAnimController.forward();
    } else {
      _bpAnimController.reverse();
    }
  }

  @override
  void didUpdateWidget(covariant VitalsTwinTrendCards oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isBpExpandedNotifier != null &&
        widget.isBpExpandedNotifier != _bpExpandedNotifier) {
      _bpExpandedNotifier.removeListener(_handleBpChange);
      if (_internalBpAllocated) {
        _bpExpandedNotifier.dispose();
        _internalBpAllocated = false;
      }
      _bpExpandedNotifier = widget.isBpExpandedNotifier!;
      _bpExpandedNotifier.addListener(_handleBpChange);
      if (_bpExpandedNotifier.value) {
        _bpAnimController.forward();
      } else {
        _bpAnimController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _bpExpandedNotifier.removeListener(_handleBpChange);
    _bpAnimController.dispose();
    if (_internalBpAllocated) {
      _bpExpandedNotifier.dispose();
    }
    super.dispose();
  }

  void _toggleBp() {
    if (widget.onBloodPressureTap != null) {
      widget.onBloodPressureTap!();
    } else {
      _bpExpandedNotifier.value = !_bpExpandedNotifier.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final dims = VitalsCardDimensions.fromResponsive(r);
    final waveWidth = (r.width * 0.26).clamp(80.0, 110.0);
    final waveHeight = (r.height * 0.05).clamp(38.0, 50.0);

    final bpRec = RecommendationEngine.getBloodPressureRecommendation(
      widget.bloodPressure,
    );
    // Skin temperature not supported by hardware - commented out
    // final skinTempRec = RecommendationEngine.getSkinTempRecommendation(
    //   widget.skinTempDiff,
    // );

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
            onTap: _toggleBp,
            borderRadius: BorderRadius.circular(12.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
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
                                (widget.bloodPressure.isNotEmpty &&
                                        widget.bloodPressure != '0/0' &&
                                        widget.bloodPressure != '--/--')
                                    ? widget.bloodPressure
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
          ),

          // Blood Pressure Expanded Interpretation
          AnimatedBuilder(
            animation: _bpHeightFactor,
            builder: (context, _) {
              if (_bpAnimController.isDismissed && !_bpExpandedNotifier.value) {
                return const SizedBox.shrink();
              }
              return ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: _bpHeightFactor.value,
                  child: VitalsInterpretationSection(
                    whatItIs: bpRec.whatItIs,
                    yourReading: bpRec.yourReading,
                    doThis: bpRec.doThis,
                  ),
                ),
              );
            },
          ),

          /*
          SizedBox(height: (r.height * 0.024).clamp(16.0, 24.0)),

          // 2. Skin Temperature Trend Row
          InkWell(
            onTap: _toggleSkinTemp,
            borderRadius: BorderRadius.circular(12.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
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
                                widget.skinTempDiff != 0.0
                                    ? '${widget.skinTempDiff > 0 ? '+' : ''}${widget.skinTempDiff.toStringAsFixed(1)}°C'
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
          ),

          // Skin Temp Expanded Interpretation
          AnimatedBuilder(
            animation: _skinTempHeightFactor,
            builder: (context, _) {
              if (_skinTempAnimController.isDismissed &&
                  !_skinTempExpandedNotifier.value) {
                return const SizedBox.shrink();
              }
              return ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: _skinTempHeightFactor.value,
                  child: VitalsInterpretationSection(
                    whatItIs: skinTempRec.whatItIs,
                    yourReading: skinTempRec.yourReading,
                    doThis: skinTempRec.doThis,
                  ),
                ),
              );
            },
          ),
          */
        ],
      ),
    );
  }
}
