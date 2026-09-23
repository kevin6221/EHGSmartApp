import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/app_text_form_field.dart';

/// Card for order number or email verification on the Wardrobe screen.
class WardrobeOrderUnlockCard extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onUnlock;

  const WardrobeOrderUnlockCard({
    super.key,
    required this.controller,
    this.onUnlock,
  });

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: context.isDark ? AppColors.midnightSurface : null,
        gradient: context.isDark ? null : AppGradients.membershipCard,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: context.isDark
              ? AppColors.midnightBorder
              : AppColors.primary.withValues(alpha: 0.40),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowNavy.withValues(alpha: 0.04),
            blurRadius: 10.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order number or email',
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(10.0),
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8.0),

          // White text input field
          AppTextFormField(
            controller: controller,
            hasBorder: true,
            hintText: 'Enter order number or email',
            fontSize: r.font(14.5),
            borderRadius: BorderRadius.circular(8.0),
            borderWidth: 0.3,
            fillColor: context.inputFill,
            activeFillColor: context.inputFill,
            borderColor: context.inputBorder,
            textWeight: FontWeight.w600,
            activeTextWeight: FontWeight.w600,
            textColor: context.textPrimary,
            activeTextColor: context.textPrimary,
            hintStyle: GoogleFonts.plusJakartaSans(
              fontSize: r.font(12.0),
              color: context.textMuted,
            ),
          ),
          const SizedBox(height: 12.0),

          // Unlock my pieces button
          AppButton(
            text: 'Unlock my pieces',
            showArrow: false,
            useGradient: true,
            hasShadow: false,
            height: (screenHeight * 0.050).clamp(40.0, 44.0),
            borderRadius: BorderRadius.circular(10.0),
            fontSize: r.font(13.5),
            fontWeight: FontWeight.w600,
            onPressed: onUnlock ??
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Verifying order ${controller.text.trim()}...',
                      ),
                    ),
                  );
                },
          ),
          const SizedBox(height: 10.0),

          // Helper note
          Text(
            'Demo · try EHG-1042 or EHG-1088. We check it against your EHG store and Amazon orders — nothing to scan.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(11.0),
              fontWeight: FontWeight.w400,
              color: context.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
