import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';

/// Zone selection card with interactive buttons for Z1 through Z5.
/// Fully reactive with strictly zero setState.
class TrainingZoneCard extends StatelessWidget {
  final int? selectedZone;
  final ValueChanged<int>? onZoneSelected;
  final ValueNotifier<int>? selectedZoneNotifier;

  const TrainingZoneCard({
    super.key,
    this.selectedZone,
    this.onZoneSelected,
    this.selectedZoneNotifier,
  }) : assert(selectedZone != null || selectedZoneNotifier != null,
            'Either selectedZone or selectedZoneNotifier must be provided');

  static String zoneName(int zone) {
    const names = ['Easy', 'Steady', 'Moderate', 'Hard', 'Peak'];
    final idx = (zone - 1).clamp(0, 4);
    return names[idx];
  }

  static String zoneDescription(int zone) {
    const descriptions = [
      'Aerobic and sustainable. This is the range that builds an engine without costing you tomorrow.',
      'Controlled and comfortable. This is the range that builds endurance without costing you tomorrow.',
      'Steady and focused. This is the range that improves your fitness while staying sustainable.',
      'Challenging and strong. Use this range for short efforts with enough recovery between them.',
      'High intensity. Keep this range brief and return to an easier zone when you need to recover.',
    ];
    final idx = (zone - 1).clamp(0, 4);
    return descriptions[idx];
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final media = MediaQuery.sizeOf(context);

    Widget content(int current) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Zone $current · ${zoneName(current)}',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.primary,
            fontSize: r.font(12.5),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: (media.height * 0.010).clamp(6.0, 10.0)),
        Row(
          children: List.generate(5, (index) {
            final zone = index + 1;
            final isSelected = zone == current;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  onZoneSelected?.call(zone);
                  selectedZoneNotifier?.value = zone;
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  margin: EdgeInsets.only(right: zone == 5 ? 0 : 5),
                  padding: EdgeInsets.symmetric(
                    vertical: (media.height * 0.009).clamp(6.0, 9.0),
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : (context.isDark
                            ? context.inputFill
                            : AppColors.primaryLight),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Z$zone',
                    style: GoogleFonts.plusJakartaSans(
                      color: isSelected
                          ? AppColors.white
                          : AppColors.primary,
                      fontSize: r.font(12.5),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 14,
        vertical: (media.height * 0.014).clamp(10.0, 14.0),
      ),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.cardBorder,
          width: 1.0,
        ),
        boxShadow: context.isDark
            ? []
            : [
                BoxShadow(
                  color: AppColors.shadowNavy.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: selectedZoneNotifier != null
          ? ValueListenableBuilder<int>(
              valueListenable: selectedZoneNotifier!,
              builder: (context, val, _) => content(val),
            )
          : content(selectedZone ?? 1),
    );
  }
}
