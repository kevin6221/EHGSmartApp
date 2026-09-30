import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';
import '../../../helpers/vitals_card_calculator.dart';

/// Reusable section displaying the 3-part vitals interpretation:
/// 1. "What it is" (Plain language explanation of the physiological metric)
/// 2. "Your reading" (Dynamic contextual assessment based on user's real value)
/// 3. "Do this" (Specific sports-science / clinical action recommendation in gradient banner)
///
/// Matches Figma Node 119:1442 pixel-perfectly with responsive typography and zero hardcoded colors.
class VitalsInterpretationSection extends StatelessWidget {
  final String whatItIs;
  final String yourReading;
  final String doThis;
  final EdgeInsetsGeometry? padding;

  const VitalsInterpretationSection({
    super.key,
    required this.whatItIs,
    required this.yourReading,
    required this.doThis,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final dims = VitalsCardDimensions.fromResponsive(r);

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: dims.itemSpacing),
          // Subtle divider line
          Container(
            height: 1.0,
            color: context.dividerColor,
          ),
          SizedBox(height: dims.itemSpacing),

          // 1. "What it is"
          Text(
            'What it is',
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(14.0),
              fontWeight: FontWeight.w600,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 5.0),
          Text(
            whatItIs,
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(11.0),
              fontWeight: FontWeight.w400,
              color: context.textSecondary,
              height: 1.45,
            ),
          ),
          SizedBox(height: dims.itemSpacing),

          // 2. "Your reading"
          Text(
            'Your reading',
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(14.0),
              fontWeight: FontWeight.w600,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 5.0),
          Text(
            yourReading,
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(11.0),
              fontWeight: FontWeight.w400,
              color: context.textSecondary,
              height: 1.45,
            ),
          ),
          SizedBox(height: dims.itemSpacing * 1.1),

          // 3. "Do this" Callout Banner (Figma Node 119:1442)
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
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  doThis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: r.font(10.5),
                    fontWeight: FontWeight.w400,
                    color: AppColors.vitalsCalloutSubtext,
                    height: 1.4,
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
