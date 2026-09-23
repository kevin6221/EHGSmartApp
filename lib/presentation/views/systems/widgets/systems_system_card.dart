import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';
import '../../../widgets/common/dotted_divider.dart';

/// Single responsibility card component for the four systems (Move, Recover, Mind, Fuel).
class SystemsCardTemplate extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final String sectionKey;
  final ValueNotifier<String?> expandedSystemNotifier;
  final List<String> details;
  final Responsive r;

  const SystemsCardTemplate({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.sectionKey,
    required this.expandedSystemNotifier,
    required this.details,
    required this.r,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: expandedSystemNotifier,
      builder: (context, expandedSection, _) {
        final isExpanded = expandedSection == sectionKey;
        return _buildCard(
          context: context,
          isExpanded: isExpanded,
          onTap: _toggleExpansion,
        );
      },
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isExpanded
            ? (context.isDark ? AppColors.midnightSurface : null)
            : context.cardBackground,
        gradient: isExpanded
            ? (context.isDark ? null : AppGradients.recoverCard)
            : null,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: context.cardBorder, width: 1.0),
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
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row(
                children: [
                  Container(
                    width: 40.0,
                    height: 40.0,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: context.isDark
                          ? AppColors.midnightBackground
                          : AppColors.systemCardBgLight,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: context.cardBorder,
                        width: 1.0,
                      ),
                    ),
                    child: AppSvgIcon(
                      icon,
                      size: 24.0,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: _titleStyle(context)),
                        const SizedBox(height: 4.0),
                        Text(subtitle, style: _subtitleStyle(context)),
                      ],
                    ),
                  ),
                  RotatedBox(
                    quarterTurns: isExpanded ? 1 : 0,
                    child: const AppSvgIcon(
                      AppIcons.chevronRight,
                      color: AppColors.primary,
                      size: 20.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: DottedDivider(
                color: context.cardBorder,
                dashWidth: 3.0,
                dashSpace: 3.0,
                thickness: 0.5,
              ),
            ),
            ...details.map(
              (detail) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14.0,
                  vertical: 8.0,
                ),
                child: Text(detail, style: _detailStyle(context)),
              ),
            ),
            const SizedBox(height: 4.0),
          ],
        ],
      ),
    );
  }

  void _toggleExpansion() {
    expandedSystemNotifier.value = sectionKey;
  }

  TextStyle _titleStyle(BuildContext context) => GoogleFonts.plusJakartaSans(
    fontSize: r.font(14.0),
    fontWeight: FontWeight.w600,
    color: context.textPrimary,
  );

  TextStyle _subtitleStyle(BuildContext context) => GoogleFonts.plusJakartaSans(
    fontSize: r.font(12.0),
    fontWeight: FontWeight.w400,
    color: context.textSecondary,
  );

  TextStyle _detailStyle(BuildContext context) => GoogleFonts.plusJakartaSans(
    fontSize: r.font(10.0),
    fontWeight: FontWeight.w400,
    color: context.textPrimary,
  );
}

/// Expandable Recover system card with interactive lead status and sub-action items.
class SystemsRecoverCard extends StatelessWidget {
  final ValueNotifier<String?> expandedSystemNotifier;
  final Responsive r;

  const SystemsRecoverCard({
    super.key,
    required this.expandedSystemNotifier,
    required this.r,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: expandedSystemNotifier,
      builder: (context, expandedSection, _) {
        final isExpanded = expandedSection == 'recover';
        return Container(
          decoration: BoxDecoration(
            color: isExpanded
                ? (context.isDark ? AppColors.midnightSurface : null)
                : context.cardBackground,
            gradient: isExpanded
                ? (context.isDark ? null : AppGradients.recoverCard)
                : null,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: context.isDark ? context.cardBorder : AppColors.systemCardBorder,
              width: 1.0,
            ),
            boxShadow: context.isDark
                ? []
                : [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.04),
                      blurRadius: 10.0,
                      offset: const Offset(0.0, 3.0),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => expandedSystemNotifier.value = 'recover',
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Row(
                    children: [
                      Container(
                        width: 40.0,
                        height: 40.0,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: context.isDark ? AppColors.midnightBackground : AppColors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const AppSvgIcon(
                          AppIcons.recoverPerson,
                          size: 24.0,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Recover',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: r.font(14.0),
                                    fontWeight: FontWeight.w600,
                                    color: context.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                    vertical: 3.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.cyanLight,
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  child: Text(
                                    'Leads today',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: r.font(10.0),
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              'Mobility, sleep, soft tissue',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: r.font(12.0),
                                fontWeight: FontWeight.w400,
                                color: context.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      RotatedBox(
                        quarterTurns: isExpanded ? 1 : 0,
                        child: const AppSvgIcon(
                          AppIcons.chevronRight,
                          color: AppColors.primary,
                          size: 20.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isExpanded) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: DottedDivider(
                    color: context.cardBorder,
                    dashWidth: 3.0,
                    dashSpace: 3.0,
                    thickness: 0.5,
                  ),
                ),
                const SizedBox(height: 4.0),
                _buildActionItemRow(
                  context: context,
                  title: 'Full mobility flow · 20 min',
                  r: r,
                ),
                _buildActionItemRow(
                  context: context,
                  title: 'Foam roll: calves & hamstrings · 8 min',
                  r: r,
                ),
                _buildActionItemRow(
                  context: context,
                  title: 'Sleep wind-down · 12 min',
                  r: r,
                ),
                const SizedBox(height: 4.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: DottedDivider(
                    color: context.cardBorder,
                    dashWidth: 3.0,
                    dashSpace: 3.0,
                    thickness: 0.5,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14.0, 8.0, 14.0, 12.0),
                  child: Text(
                    'Your gear: Boxy Piping T-Shirt · Foam Roller · Massage Ball',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: r.font(10.0),
                      fontWeight: FontWeight.w500,
                      color: context.textSecondary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  static Widget _buildActionItemRow({
    required BuildContext context,
    required String title,
    required Responsive r,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: r.font(10.0),
                fontWeight: FontWeight.w400,
                color: context.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: () {},
            behavior: HitTestBehavior.opaque,
            child: Text(
              'START',
              style: GoogleFonts.plusJakartaSans(
                fontSize: r.font(12.0),
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
