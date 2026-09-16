import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/app_text_form_field.dart';
import '../../../widgets/common/dotted_divider.dart';
import 'systems_routine_manager.dart';

/// Interactive "Build your own routine" section on the Systems screen.
class SystemsBuildRoutineSection extends StatelessWidget {
  final TextEditingController routineNameController;
  final ValueNotifier<int> selectedDurationNotifier;
  final ValueNotifier<Set<String>> selectedMovementsNotifier;
  final ValueNotifier<Set<String>> selectedWellnessNotifier;
  final ValueNotifier<List<Map<String, String>>> activeRoutineNotifier;
  final Responsive r;

  const SystemsBuildRoutineSection({
    super.key,
    required this.routineNameController,
    required this.selectedDurationNotifier,
    required this.selectedMovementsNotifier,
    required this.selectedWellnessNotifier,
    required this.activeRoutineNotifier,
    required this.r,
  });

  void _onToggleMovement(String key) {
    final res = SystemsRoutineManager.toggleMovement(
      key: key,
      currentMovements: selectedMovementsNotifier.value,
      currentRoutines: activeRoutineNotifier.value,
    );
    selectedMovementsNotifier.value = res.movements;
    activeRoutineNotifier.value = res.routines;
  }

  void _onToggleWellness(String key) {
    final res = SystemsRoutineManager.toggleWellness(
      key: key,
      currentWellness: selectedWellnessNotifier.value,
      currentRoutines: activeRoutineNotifier.value,
    );
    selectedWellnessNotifier.value = res.wellness;
    activeRoutineNotifier.value = res.routines;
  }

  void _onRemoveRoutineItem(int index) {
    final res = SystemsRoutineManager.removeRoutineItem(
      index: index,
      currentMovements: selectedMovementsNotifier.value,
      currentWellness: selectedWellnessNotifier.value,
      currentRoutines: activeRoutineNotifier.value,
    );
    selectedMovementsNotifier.value = res.movements;
    selectedWellnessNotifier.value = res.wellness;
    activeRoutineNotifier.value = res.routines;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Build your own routine',
          style: GoogleFonts.plusJakartaSans(
            fontSize: r.font(14.0),
            fontWeight: FontWeight.w700,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(height: 14.0),

        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: AppColors.border, width: 1.0),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.02),
                blurRadius: 8.0,
                offset: const Offset(0.0, 2.0),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Routine Name Label
              Text(
                'Routine Name',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(12.0),
                  fontWeight: FontWeight.w400,
                  color: AppColors.tertiary,
                ),
              ),
              const SizedBox(height: 8.0),

              // Reusable AppTextFormField
              AppTextFormField(
                controller: routineNameController,
                hintText: 'Enter here...',
                fontSize: r.font(14.0),
                fillColor: AppColors.routineInputFill,
                activeFillColor: AppColors.routineInputFill,
                borderColor: AppColors.routineInputBorder,
                activeBorderColor: AppColors.primary,
                borderWidth: 0.8,
                focusedBorderWidth: 1.0,
                hintStyle: GoogleFonts.plusJakartaSans(
                  color: AppColors.tertiary,
                  fontSize: r.font(13.0),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 16.0),

              // Run it for duration selector
              Text(
                'Run it for',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(12.0),
                  fontWeight: FontWeight.w400,
                  color: AppColors.tertiary,
                ),
              ),
              const SizedBox(height: 10.0),
              ValueListenableBuilder<int>(
                valueListenable: selectedDurationNotifier,
                builder: (context, selectedDays, _) {
                  const durations = [7, 14, 21, 30];
                  return Row(
                    children: durations.map((days) {
                      final isSelected = selectedDays == days;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => selectedDurationNotifier.value = days,
                          behavior: HitTestBehavior.opaque,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            margin: const EdgeInsets.symmetric(horizontal: 3.0),
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.routineInputFill,
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.routineInputBorder,
                                width: 1.0,
                              ),
                            ),
                            child: Text(
                              '${days}d',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: r.font(12.5),
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? AppColors.white
                                    : AppColors.tertiary,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 16.0),

              // Add movement
              Text(
                'Add movement',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(13.0),
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 12.0),
              ValueListenableBuilder<Set<String>>(
                valueListenable: selectedMovementsNotifier,
                builder: (context, selected, _) {
                  const row1 = ['Run', 'Wlk', 'Cyc', 'Str', 'Hlt'];
                  const row2 = ['Row', 'Swm', 'Yga', 'Pil', 'Mob'];

                  return Column(
                    children: [
                      Row(
                        children: row1.map((item) {
                          return Expanded(
                            child: _buildCheckboxChip(
                              label: item,
                              isChecked: selected.contains(item),
                              onTap: () => _onToggleMovement(item),
                              r: r,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14.0),
                      Row(
                        children: row2.map((item) {
                          return Expanded(
                            child: _buildCheckboxChip(
                              label: item,
                              isChecked: selected.contains(item),
                              onTap: () => _onToggleMovement(item),
                              r: r,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20.0),

              // Add wellness
              Text(
                'Add wellness',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(13.0),
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 12.0),
              ValueListenableBuilder<Set<String>>(
                valueListenable: selectedWellnessNotifier,
                builder: (context, selected, _) {
                  const col1Flex = 37;
                  const col2Flex = 31;
                  const col3Flex = 32;

                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: col1Flex,
                            child: _buildCheckboxChip(
                              label: 'Mobile Flow',
                              isChecked: selected.contains('Mobile Flow'),
                              onTap: () => _onToggleWellness('Mobile Flow'),
                              r: r,
                            ),
                          ),
                          Expanded(
                            flex: col2Flex,
                            child: _buildCheckboxChip(
                              label: 'Foam roll',
                              isChecked: selected.contains('Foam roll'),
                              onTap: () => _onToggleWellness('Foam roll'),
                              r: r,
                            ),
                          ),
                          Expanded(
                            flex: col3Flex,
                            child: _buildCheckboxChip(
                              label: 'Sleep wind',
                              isChecked: selected.contains('Sleep wind'),
                              onTap: () => _onToggleWellness('Sleep wind'),
                              r: r,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14.0),
                      Row(
                        children: [
                          Expanded(
                            flex: col1Flex,
                            child: _buildCheckboxChip(
                              label: 'Box breathing',
                              isChecked: selected.contains('Box breathing'),
                              onTap: () => _onToggleWellness('Box breathing'),
                              r: r,
                            ),
                          ),
                          Expanded(
                            flex: col2Flex,
                            child: _buildCheckboxChip(
                              label: 'Meditation',
                              isChecked: selected.contains('Meditation'),
                              onTap: () => _onToggleWellness('Meditation'),
                              r: r,
                            ),
                          ),
                          const Spacer(flex: col3Flex),
                        ],
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20.0),

              // Active Routine Items
              ValueListenableBuilder<List<Map<String, String>>>(
                valueListenable: activeRoutineNotifier,
                builder: (context, routineItems, _) {
                  if (routineItems.isEmpty) {
                    return const SizedBox(height: 8.0);
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16.0),
                      const DottedDivider(
                        color: AppColors.divider,
                        dashWidth: 3.0,
                        dashSpace: 3.0,
                        thickness: 1.0,
                      ),
                      const SizedBox(height: 20.0),

                      Text(
                        'Your routine',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: r.font(12.0),
                          fontWeight: FontWeight.w400,
                          color: AppColors.tertiary,
                        ),
                      ),
                      const SizedBox(height: 12.0),

                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: AppColors.primary,
                            width: 0.5,
                          ),
                        ),
                        child: Column(
                          children: routineItems.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            final isLast = index == routineItems.length - 1;

                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                    vertical: 12.0,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 5.0,
                                        height: 5.0,
                                        decoration: const BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8.0),
                                      Expanded(
                                        child: Text(
                                          item['title'] ?? '',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: r.font(12.5),
                                            fontWeight: FontWeight.w400,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        item['duration'] ?? '',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: r.font(12.0),
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.secondary,
                                        ),
                                      ),
                                      const SizedBox(width: 10.0),
                                      GestureDetector(
                                        onTap: () => _onRemoveRoutineItem(index),
                                        behavior: HitTestBehavior.opaque,
                                        child: const AppSvgIcon(
                                          AppIcons.redCross,
                                          color: AppColors.systemRed,
                                          size: 16.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!isLast)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                    ),
                                    child: Divider(
                                      height: 1.0,
                                      thickness: 0.8,
                                      color: AppColors.tertiary.withValues(
                                        alpha: 0.35,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 18.0),
                    ],
                  );
                },
              ),

              // Save routine AppButton
              AppButton(
                text: 'Save routine',
                useGradient: true,
                showArrow: false,
                onPressed: () {},
                height: 46.0,
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _buildCheckboxChip({
    required String label,
    required bool isChecked,
    required VoidCallback onTap,
    required Responsive r,
  }) {
    final boxDim = r.isSmall ? 16.0 : 18.0;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: boxDim,
            height: boxDim,
            decoration: BoxDecoration(
              color: isChecked ? AppColors.primary : AppColors.transparent,
              borderRadius: BorderRadius.circular(4.0),
              border: Border.all(
                color: isChecked ? AppColors.primary : AppColors.checkboxBorder,
                width: 1.2,
              ),
            ),
            child: isChecked
                ? const Icon(
                    Icons.check_rounded,
                    size: 13.0,
                    color: AppColors.white,
                  )
                : null,
          ),
          const SizedBox(width: 7.0),
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: r.font(r.isSmall ? 11.5 : 12.5),
                fontWeight: FontWeight.w400,
                color: AppColors.tertiary,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
