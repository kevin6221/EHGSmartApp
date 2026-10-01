import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';
import '../../../widgets/common/dotted_divider.dart';

/// Interactive section displaying user-saved custom routines below the Routine Builder.
/// Uses [ValueListenableBuilder] to strictly adhere to the zero setState() policy.
class SystemsSavedRoutinesSection extends StatelessWidget {
  final ValueNotifier<List<UserRoutine>> savedRoutinesNotifier;
  final Responsive r;
  final Future<void> Function(UserRoutine routine) onDeleteRoutine;

  const SystemsSavedRoutinesSection({
    super.key,
    required this.savedRoutinesNotifier,
    required this.r,
    required this.onDeleteRoutine,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<UserRoutine>>(
      valueListenable: savedRoutinesNotifier,
      builder: (context, routines, _) {
        if (routines.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Saved routines',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: r.font(14.0),
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 3.0,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Text(
                    '${routines.length} saved',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: r.font(11.0),
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14.0),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: routines.length,
              separatorBuilder: (_, _) => const SizedBox(height: 14.0),
              itemBuilder: (context, index) {
                final routine = routines[index];
                return _SavedRoutineCard(
                  key: ValueKey(routine.id),
                  routine: routine,
                  r: r,
                  onDelete: () => onDeleteRoutine(routine),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _SavedRoutineCard extends StatelessWidget {
  final UserRoutine routine;
  final Responsive r;
  final VoidCallback onDelete;

  const _SavedRoutineCard({
    super.key,
    required this.routine,
    required this.r,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final movements = _parseList(routine.movementsJson);
    final wellness = _parseList(routine.wellnessJson);
    final items = _parseItems(routine.routineItemsJson);
    final dateStr = DateFormat('MMM d, yyyy').format(routine.createdAt);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: context.isDark ? AppColors.midnightBorder : context.cardBorder,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.03),
            blurRadius: 10.0,
            offset: const Offset(0.0, 3.0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Name, Duration Pill, Delete Button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      routine.routineName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: r.font(15.0),
                        fontWeight: FontWeight.w700,
                        color: context.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4.0),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7.0,
                            vertical: 2.0,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.cyanLight.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          child: Text(
                            '${routine.durationDays} days',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: r.font(11.0),
                              fontWeight: FontWeight.w600,
                              color: AppColors.cyanLight,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          dateStr,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: r.font(11.0),
                            fontWeight: FontWeight.w400,
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const AppSvgIcon(
                  AppIcons.deleteIcon,
                  size: 18.0,
                  color: AppColors.systemRed,
                ),
                tooltip: 'Delete routine',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onDelete();
                },
              ),
            ],
          ),

          // Movements & Wellness Tags
          if (movements.isNotEmpty || wellness.isNotEmpty) ...[
            const SizedBox(height: 12.0),
            Wrap(
              spacing: 6.0,
              runSpacing: 6.0,
              children: [
                ...movements.map(
                  (m) => _buildBadge(
                    label: m,
                    color: AppColors.primary,
                    bgColor: AppColors.primary.withValues(alpha: 0.10),
                    context: context,
                  ),
                ),
                ...wellness.map(
                  (w) => _buildBadge(
                    label: w,
                    color: AppColors.cyanLight,
                    bgColor: AppColors.cyanLight.withValues(alpha: 0.10),
                    context: context,
                  ),
                ),
              ],
            ),
          ],

          // Routine items list
          if (items.isNotEmpty) ...[
            const SizedBox(height: 14.0),
            DottedDivider(
              color: context.dividerColor,
              dashWidth: 3.0,
              dashSpace: 3.0,
              thickness: 0.8,
            ),
            const SizedBox(height: 12.0),
            ...items.map((item) {
              final title = item['title'] ?? '';
              final duration = item['duration'] ?? '';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
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
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: r.font(12.0),
                          fontWeight: FontWeight.w500,
                          color: context.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      duration,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: r.font(11.5),
                        fontWeight: FontWeight.w400,
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildBadge({
    required String label,
    required Color color,
    required Color bgColor,
    required BuildContext context,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 0.8),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: r.font(11.0),
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  List<String> _parseList(String jsonStr) {
    try {
      final decoded = jsonDecode(jsonStr) as List<dynamic>?;
      return decoded?.map((e) => e.toString()).toList() ?? [];
    } catch (_) {
      return [];
    }
  }

  List<Map<String, String>> _parseItems(String jsonStr) {
    try {
      final decoded = jsonDecode(jsonStr) as List<dynamic>?;
      if (decoded == null) return [];
      return decoded.map((e) => Map<String, String>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }
}
