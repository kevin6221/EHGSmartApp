import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';
import '../../../widgets/common/app_card.dart';
import '../../../widgets/common/app_text_form_field.dart';

/// Card showing profile inputs: username text field, age selector, and weight selector (Figma Node 75:2928).
class ProfileAccountCard extends StatelessWidget {
  final TextEditingController usernameController;
  final int age;
  final int weight;
  final VoidCallback? onAgeTap;
  final VoidCallback? onWeightTap;

  const ProfileAccountCard({
    super.key,
    required this.usernameController,
    required this.age,
    required this.weight,
    this.onAgeTap,
    this.onWeightTap,
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
          // 1. Username Label
          Text(
            'Username',
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(12.0),
              fontWeight: FontWeight.w400,
              color: AppColors.tertiary,
            ),
          ),
          const SizedBox(height: 8.0),

          // 2. Username Input (Figma Node 75:2929, h=40, cr=12, bg=#EFF3FF, stroke=#3E83C8 at 50%)
          AppTextFormField(
            controller: usernameController,
            hintText: 'John',
            fontSize: r.font(14.0),
          ),
          const SizedBox(height: 14.0),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Age',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: r.font(12.0),
                        fontWeight: FontWeight.w400,
                        color: AppColors.tertiary,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    _buildSelectorPill(
                      value: '$age',
                      onTap: onAgeTap,
                      fontSize: r.font(14.0),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weight',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: r.font(12.0),
                        fontWeight: FontWeight.w400,
                        color: AppColors.tertiary,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    _buildSelectorPill(
                      value: '${weight}kg',
                      onTap: onWeightTap,
                      fontSize: r.font(14.0),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorPill({
    required String value,
    required VoidCallback? onTap,
    required double fontSize,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.profileInputFill,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: AppColors.profileInputBorder, width: 0.8),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 14.0,
          vertical: 10.5,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.tertiary,
                fontSize: fontSize,
                fontWeight: FontWeight.w400,
              ),
            ),
            SvgPicture.asset(
              AppIcons.selectorArrows,
              width: 14.0,
              height: 14.0,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}
