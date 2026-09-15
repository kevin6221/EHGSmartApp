import 'package:ehgsmartapp/core/constants/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';
import '../../../widgets/common/app_card.dart';

/// Card prompting user to link email and secure their rewards (Figma Node 75:2775).
class ProfileRewardsCard extends StatelessWidget {
  final TextEditingController emailController;
  final VoidCallback onCreateAccount;

  const ProfileRewardsCard({
    super.key,
    required this.emailController,
    required this.onCreateAccount,
  });

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return AppCard(
      padding: const EdgeInsets.all(15.0),
      borderRadius: BorderRadius.circular(12.0),
      border: const Border.fromBorderSide(BorderSide.none),
      boxShadow: [
        BoxShadow(
          color: AppColors.shadowNavy.withValues(alpha: 0.03),
          blurRadius: 8.0,
          offset: const Offset(0, 4),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Row (Lock Radial Badge + Title)
          Row(
            children: [
              Container(
                width: 38.0,
                height: 38.0,
                decoration: const BoxDecoration(
                  gradient: AppColors.profileBadgeRadial,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    AppIcons.profileVerify,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Text(
                  'Keep your rewards safe',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    fontSize: r.font(14.0),
                    color: AppColors.secondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: emailController,
            builder: (context, nameValue, _) {
              final bool isTextEntered = nameValue.text.trim().isNotEmpty;

              return TextFormField(
                controller: emailController,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(14.0),
                  fontWeight: isTextEntered ? FontWeight.w600 : FontWeight.w400,
                  color: isTextEntered ? AppColors.primary : AppColors.textPrimary,
                ),
                cursorColor: AppColors.primary,
                decoration: InputDecoration(
                  hintText: 'You@lorem.com',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    color: AppColors.tertiary,
                    fontSize: r.font(14.0),
                    fontWeight: FontWeight.w400,
                  ),

                  border: InputBorder.none,
                ),
              );
            },
          ),
          const SizedBox(height: 12.0),

          // 3. Create Account Button (Figma Node 75:2919, h=40, cr=8, brand horizontal gradient)
          GestureDetector(
            onTap: onCreateAccount,
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 40.0,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(8.0),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Create account',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: r.font(16.0),
                      fontWeight: FontWeight.w500,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.white,
                    size: 16.0,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10.0),

          // 4. Caption
          Text(
            'No password. We send a one-time link.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(12.0),
              fontWeight: FontWeight.w400,
              color: AppColors.tertiary,
            ),
          ),
        ],
      ),
    );
  }
}
