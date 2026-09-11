import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Section outlining data & privacy policies, data export/deletion controls, and medical disclaimer.
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Data & privacy',
              style: AppTypography.titleLarge.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: onExportData,
                  icon: const Icon(
                    Icons.file_upload_outlined,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 14),
                IconButton(
                  onPressed: onDeleteData,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 20,
                    color: AppColors.stress,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Your vitals, sleep and journal are stored on this phone and are not uploaded to us or anyone else. The band works entirely over Bluetooth with no account required.',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            'EHG SmartWellness v1.0 · The Smart Band is a wellness tracker,\nnot a medical device.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textMuted,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
