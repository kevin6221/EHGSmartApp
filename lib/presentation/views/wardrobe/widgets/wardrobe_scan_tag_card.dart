import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';
import '../../../widgets/wardrobe/animated_tag_scanner.dart';

/// Interactive scan-the-tag card embedding the concentric animated ripple scanner.
class WardrobeScanTagCard extends StatelessWidget {
  const WardrobeScanTagCard({super.key});

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final ringOuter = (r.width * 0.38).clamp(130.0, 160.0);
    final ringMid = (r.width * 0.28).clamp(95.0, 120.0);
    final ringInner = (r.width * 0.18).clamp(62.0, 80.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: context.cardBorder, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowNavy.withValues(alpha: 0.03),
            blurRadius: 8.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Scan the tag',
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(10.0),
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 14.0),

          // Animated concentric scanning rings with sticky center NFC tag scanner
          Center(
            child: AnimatedTagScannerRings(
              ringOuter: ringOuter,
              ringMid: ringMid,
              ringInner: ringInner,
            ),
          ),
          const SizedBox(height: 12.0),

          Center(
            child: Text(
              'Hold near Tag',
              style: GoogleFonts.plusJakartaSans(
                fontSize: r.font(12.0),
                fontWeight: FontWeight.w400,
                color: context.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
