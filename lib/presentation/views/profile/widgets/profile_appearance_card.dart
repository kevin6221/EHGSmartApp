import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/models/user_profile_model.dart';
import '../../../widgets/common/app_card.dart';

/// Card allowing selection of theme mode and unit system preferences.
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
    return AppCard(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF0F172A).withValues(alpha: 0.04),
          blurRadius: 14,
          offset: const Offset(0, 3),
        ),
      ],
      child: Column(
        children: [
          Row(
            children: [
              _buildRadioOption(
                label: 'Midnight',
                isSelected: appearance == AppearanceTheme.midnight,
                onTap: () => onAppearanceChanged(AppearanceTheme.midnight),
              ),
              _buildRadioOption(
                label: 'Day Light',
                isSelected: appearance == AppearanceTheme.dayLight,
                onTap: () => onAppearanceChanged(AppearanceTheme.dayLight),
              ),
              _buildRadioOption(
                label: 'System',
                isSelected: appearance == AppearanceTheme.system,
                onTap: () => onAppearanceChanged(AppearanceTheme.system),
              ),
            ],
          ),
          const Divider(height: 24, color: AppColors.borderLight),
          Row(
            children: [
              _buildRadioOption(
                label: 'Metric KM, KG',
                isSelected: unitSystem == UnitSystem.metric,
                onTap: () => onUnitSystemChanged(UnitSystem.metric),
              ),
              _buildRadioOption(
                label: 'Imperial MI, LB',
                isSelected: unitSystem == UnitSystem.imperial,
                onTap: () => onUnitSystemChanged(UnitSystem.imperial),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRadioOption({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.textMuted,
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: isSelected
                  ? Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
