import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';
import '../../../../data/models/user_profile_model.dart';
import '../../../widgets/common/app_card.dart';

/// Selection cards for theme mode and unit system preferences (Figma Nodes 75:2952 & 75:2966).
class ProfileAppearanceCard extends StatelessWidget {
  final AppearanceTheme appearance;
  final UnitSystem unitSystem;
  final ValueChanged<AppearanceTheme> onAppearanceChanged;
  final ValueChanged<UnitSystem> onUnitSystemChanged;

  const ProfileAppearanceCard({
    super.key,
    required this.appearance,
    required this.unitSystem,
    required this.onAppearanceChanged,
    required this.onUnitSystemChanged,
  });

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return Column(
      children: [
        // 1. Theme Selector Card (Figma Node 75:2952, h=44, cr=12)
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12.0),
          borderRadius: BorderRadius.circular(12.0),
          border: const Border.fromBorderSide(BorderSide.none),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowNavy.withValues(alpha: 0.03),
              blurRadius: 8.0,
              offset: const Offset(0, 4),
            ),
          ],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildRadioOption(
                label: 'Midnight',
                isSelected: appearance == AppearanceTheme.midnight,
                onTap: () => onAppearanceChanged(AppearanceTheme.midnight),
                fontSize: r.font(12.0),
              ),
              _buildRadioOption(
                label: 'Day Light',
                isSelected: appearance == AppearanceTheme.dayLight,
                onTap: () => onAppearanceChanged(AppearanceTheme.dayLight),
                fontSize: r.font(12.0),
              ),
              _buildRadioOption(
                label: 'System',
                isSelected: appearance == AppearanceTheme.system,
                onTap: () => onAppearanceChanged(AppearanceTheme.system),
                fontSize: r.font(12.0),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12.0),

        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12.0),
          borderRadius: BorderRadius.circular(12.0),
          border: const Border.fromBorderSide(BorderSide.none),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowNavy.withValues(alpha: 0.03),
              blurRadius: 8.0,
              offset: const Offset(0, 4),
            ),
          ],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildRadioOption(
                label: 'Metric KM, KG',
                isSelected: unitSystem == UnitSystem.metric,
                onTap: () => onUnitSystemChanged(UnitSystem.metric),
                fontSize: r.font(12.0),
              ),
              _buildRadioOption(
                label: 'Imperial MI, LB',
                isSelected: unitSystem == UnitSystem.imperial,
                onTap: () => onUnitSystemChanged(UnitSystem.imperial),
                fontSize: r.font(12.0),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRadioOption({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required double fontSize,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16.0,
              height: 16.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.borderLight,
                  width: 1.0,
                ),
              ),
              alignment: Alignment.center,
              child: isSelected
                  ? Container(
                      width: 10.0,
                      height: 10.0,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8.0),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.secondary,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  fontSize: fontSize,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
