import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_animations.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';
import '../../../helpers/vitals_card_calculator.dart';

/// Reusable expandable & collapsible metric card for Vitals dashboard.
///
/// Provides a 60fps butter-smooth transition without jarring color or background flash effects.
/// When expanded, cleanly reveals "What it is", "Your reading", and the gradient "Do this" callout banner.
class VitalsExpandableMetricCard extends StatefulWidget {
  final String? svgIcon;
  final IconData? iconData;
  final Color iconColor;
  final String title;
  final String value;
  final String unit;
  final String status;
  final Widget chart;
  final bool showWeekdays;
  final String whatItIs;
  final String yourReading;
  final String doThis;
  final ValueNotifier<bool>? isExpandedNotifier;
  final VoidCallback? onExpandChanged;
  final VoidCallback? onTap;

  const VitalsExpandableMetricCard({
    super.key,
    this.svgIcon,
    this.iconData,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.unit,
    required this.status,
    required this.chart,
    this.showWeekdays = true,
    required this.whatItIs,
    required this.yourReading,
    required this.doThis,
    this.isExpandedNotifier,
    this.onExpandChanged,
    this.onTap,
  }) : assert(
          svgIcon != null || iconData != null,
          'Either svgIcon or iconData must be provided',
        );

  static const List<String> _weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  State<VitalsExpandableMetricCard> createState() =>
      _VitalsExpandableMetricCardState();
}

class _VitalsExpandableMetricCardState extends State<VitalsExpandableMetricCard>
    with SingleTickerProviderStateMixin {
  late final ValueNotifier<bool> _expandedNotifier;
  bool _internalNotifierAllocated = false;
  late final AnimationController _animController;
  late final Animation<double> _heightFactor;

  @override
  void initState() {
    super.initState();
    if (widget.isExpandedNotifier != null) {
      _expandedNotifier = widget.isExpandedNotifier!;
    } else {
      _expandedNotifier = ValueNotifier<bool>(false);
      _internalNotifierAllocated = true;
    }
    _animController = AnimationController(
      duration: AppDurations.cardExpand,
      vsync: this,
    );
    _heightFactor = CurvedAnimation(
      parent: _animController,
      curve: Curves.fastOutSlowIn,
    );
    if (_expandedNotifier.value) {
      _animController.value = 1.0;
    }
    _expandedNotifier.addListener(_handleNotifierChange);
  }

  void _handleNotifierChange() {
    if (_expandedNotifier.value) {
      _animController.forward();
    } else {
      _animController.reverse();
    }
  }

  @override
  void didUpdateWidget(covariant VitalsExpandableMetricCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpandedNotifier != null &&
        widget.isExpandedNotifier != _expandedNotifier) {
      _expandedNotifier.removeListener(_handleNotifierChange);
      if (_internalNotifierAllocated) {
        _expandedNotifier.dispose();
        _internalNotifierAllocated = false;
      }
      _expandedNotifier = widget.isExpandedNotifier!;
      _expandedNotifier.addListener(_handleNotifierChange);
      if (_expandedNotifier.value) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _expandedNotifier.removeListener(_handleNotifierChange);
    _animController.dispose();
    if (_internalNotifierAllocated) {
      _expandedNotifier.dispose();
    }
    super.dispose();
  }

  void _toggleExpanded() {
    if (widget.onTap != null) {
      widget.onTap!();
    } else {
      _expandedNotifier.value = !_expandedNotifier.value;
      widget.onExpandChanged?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final dims = VitalsCardDimensions.fromResponsive(r);

    return AnimatedBuilder(
      animation: _heightFactor,
      builder: (context, _) {
        final progress = _heightFactor.value;
        final isClosed = _animController.isDismissed && !_expandedNotifier.value;

        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: context.cardBackground,
            borderRadius: BorderRadius.circular(dims.cardRadius),
            boxShadow: context.isDark
                ? []
                : [
                    BoxShadow(
                      color: AppColors.shadowNavy.withValues(alpha: 0.04),
                      blurRadius: 16.0,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Stack(
              children: [
                // 1. Collapsed subtle border layer (cross-fades out as card expands)
                if (progress < 1.0)
                  Positioned.fill(
                    child: Opacity(
                      opacity: (1.0 - progress).clamp(0.0, 1.0),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(dims.cardRadius),
                          border: Border.all(
                            color: context.cardBorder,
                            width: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),

                // 2. Figma Node 119:1442 Expanded Gradient & Primary Blue Border (cross-fades in)
                if (progress > 0.0)
                  Positioned.fill(
                    child: Opacity(
                      opacity: progress.clamp(0.0, 1.0),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(dims.cardRadius),
                          gradient: context.isDark
                              ? null
                              : AppGradients.vitalsExpandedCard,
                          color: context.isDark ? context.cardBackground : null,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),

                // 3. Card Content & Tap Handler
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _toggleExpanded,
                    borderRadius: BorderRadius.circular(dims.cardRadius),
                    child: Padding(
                      padding: EdgeInsets.all(dims.cardPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 1. Header (Icon + Title)
                          Row(
                            children: [
                              if (widget.svgIcon != null)
                                AppSvgIcon(
                                  widget.svgIcon!,
                                  size: 18.0,
                                  color: widget.iconColor,
                                )
                              else
                                Icon(widget.iconData,
                                    size: 18.0, color: widget.iconColor),
                              const SizedBox(width: 8.0),
                              Expanded(
                                child: Text(
                                  widget.title,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: dims.titleFontSize,
                                    fontWeight: FontWeight.w600,
                                    color: context.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: dims.itemSpacing),

                          // 2. Metrics & Chart Row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Value & Status
                              Expanded(
                                flex: 5,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            widget.value,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: dims.valueFontSize,
                                              fontWeight: FontWeight.w700,
                                              color: context.textPrimary,
                                              height: 1.0,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 4.0),
                                        Text(
                                          widget.unit,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: dims.unitFontSize,
                                            fontWeight: FontWeight.w500,
                                            color: context.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4.0),
                                    Text(
                                      widget.status,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: dims.subtitleFontSize,
                                        fontWeight: FontWeight.w400,
                                        color: context.textSecondary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12.0),

                              // Side Chart + Weekdays
                              Expanded(
                                flex: 5,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    widget.chart,
                                    if (widget.showWeekdays) ...[
                                      const SizedBox(height: 4.0),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: VitalsExpandableMetricCard
                                            ._weekdays
                                            .map(
                                              (d) => Text(
                                                d,
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                  fontSize: 10.0,
                                                  fontWeight: FontWeight.w400,
                                                  color: context.textSecondary,
                                                ),
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),

                          // 3. Smooth Expanded Content (Figma Node 119:1442)
                          if (!isClosed)
                            ClipRect(
                              child: Align(
                                alignment: Alignment.topCenter,
                                heightFactor: progress,
                                child: _buildExpandedDetails(r, dims),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
      },
    );
  }

  Widget _buildExpandedDetails(Responsive r, VitalsCardDimensions dims) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: dims.itemSpacing),
        // Divider
        Container(
          height: 1.0,
          color: context.dividerColor,
        ),
        SizedBox(height: dims.itemSpacing),

        // "What it is"
        Text(
          'What it is',
          style: GoogleFonts.plusJakartaSans(
            fontSize: r.font(14.0),
            fontWeight: FontWeight.w500,
            color: context.textPrimary,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          widget.whatItIs,
          style: GoogleFonts.plusJakartaSans(
            fontSize: r.font(10.0),
            fontWeight: FontWeight.w400,
            color: context.textSecondary,
            height: 1.45,
          ),
        ),
        SizedBox(height: dims.itemSpacing),

        // "Your reading"
        Text(
          'Your reading',
          style: GoogleFonts.plusJakartaSans(
            fontSize: r.font(14.0),
            fontWeight: FontWeight.w500,
            color: context.textPrimary,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          widget.yourReading,
          style: GoogleFonts.plusJakartaSans(
            fontSize: r.font(10.0),
            fontWeight: FontWeight.w400,
            color: context.textSecondary,
            height: 1.45,
          ),
        ),
        SizedBox(height: dims.itemSpacing * 1.1),

        // "Do this" Callout Banner
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: (r.width * 0.035).clamp(12.0, 16.0),
            vertical: (r.height * 0.014).clamp(10.0, 14.0),
          ),
          decoration: BoxDecoration(
            gradient: AppGradients.primary,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: AppColors.tertiary.withValues(alpha: 0.2),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.vitalsCalloutBorder,
                blurRadius: 10.0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Do this',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(14.0),
                  fontWeight: FontWeight.w500,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                widget.doThis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(10.0),
                  fontWeight: FontWeight.w400,
                  color: AppColors.vitalsCalloutSubtext,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
