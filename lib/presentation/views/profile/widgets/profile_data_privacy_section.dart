import 'package:ehgsmartapp/core/constants/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';

/// Section outlining data & privacy policies, data export/deletion controls, and medical disclaimer (Figma Node 82:3035).
class ProfileDataPrivacySection extends StatelessWidget {
  final VoidCallback? onExportData;
  final VoidCallback? onDeleteData;

  const ProfileDataPrivacySection({
    super.key,
    this.onExportData,
    this.onDeleteData,
  });

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Header Row (Title + Action Icons)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Data & privacy',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(14.0),
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Row(
              children: [
                SvgPicture.asset(AppIcons.shareIcon, fit: BoxFit.contain),
                const SizedBox(width: 14.0),
                SvgPicture.asset(AppIcons.deleteIcon, fit: BoxFit.contain),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10.0),

        // 2. Privacy Description Text
        Text(
          'Your vitals, sleep and journal are stored on this phone and are not uploaded to us or anyone else. The band works entirely over Bluetooth with no account required.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: r.font(12.0),
            fontWeight: FontWeight.w400,
            color: AppColors.tertiary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16.0),

        // 3. Bottom Divider Line (Figma Line 22, sw=0.5)
        const Divider(
          height: 1.0,
          thickness: 0.5,
          color: AppColors.profileDivider,
        ),
        const SizedBox(height: 16.0),

        // 4. Medical Tracker Disclaimer
        Center(
          child: Text(
            'EHG SmartWellness v1.0 · The Smart Band is a wellness tracker,\nnot a medical device.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(10.0),
              fontWeight: FontWeight.w400,
              color: AppColors.tertiary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
