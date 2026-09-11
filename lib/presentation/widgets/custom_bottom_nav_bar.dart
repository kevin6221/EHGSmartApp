import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_icons.dart';
import '../../core/theme/responsive.dart';

/// Floating custom bottom navigation bar matching Figma design specs (Node 118:1226 / Rectangle 138):
/// Height: 62.0, exact 12.0 border radius, cyan-to-blue radial active circle (38x38), and sleek shadow.
class CustomBottomNavBar extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onTabSelected;

  const CustomBottomNavBar({
    super.key,
    required this.activeIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final bottomInset = r.bottomPadding > 0 ? r.bottomPadding : 14.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        r.horizontalPadding,
        0.0,
        r.horizontalPadding,
        bottomInset,
      ),
      child: Center(
        heightFactor: 1.0,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Container(
            height: 62.0,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 24.0,
                  offset: const Offset(0.0, 8.0),
                  spreadRadius: -2.0,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: _NavItem(
                    index: 0,
                    activeIndex: activeIndex,
                    label: 'Activity',
                    svgPath: AppIcons.activity,
                    onTap: () => onTabSelected(0),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    index: 1,
                    activeIndex: activeIndex,
                    label: 'Vitals',
                    svgPath: AppIcons.vitals,
                    onTap: () => onTabSelected(1),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    index: 2,
                    activeIndex: activeIndex,
                    label: 'Train',
                    svgPath: AppIcons.train,
                    onTap: () => onTabSelected(2),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    index: 3,
                    activeIndex: activeIndex,
                    label: 'Profile',
                    svgPath: AppIcons.profile,
                    onTap: () => onTabSelected(3),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final int activeIndex;
  final String label;
  final String svgPath;
  final VoidCallback onTap;

  const _NavItem({
    required this.index,
    required this.activeIndex,
    required this.label,
    required this.svgPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = index == activeIndex;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 62.0,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: isActive
                ? Container(
                    width: 38.0,
                    height: 38.0,
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(-0.2, -0.4),
                        radius: 0.9,
                        colors: [
                          Color(0xFF01D5F1), // Cyan (Figma Ellipse 7)
                          Color(0xFF3E83C8), // Primary Blue
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x400072CE),
                          blurRadius: 8.0,
                          offset: Offset(0.0, 3.0),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: AppSvgIcon(
                      svgPath,
                      size: 19.0,
                      color: Colors.white,
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppSvgIcon(
                        svgPath,
                        size: 20.0,
                        color: const Color(0xFF4B5563),
                      ),
                      const SizedBox(height: 3.0),
                      Text(
                        label,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.0,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF4B5563),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
