import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_animations.dart';
import '../../core/constants/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/responsive.dart';
import '../helpers/nav_bar_calculator.dart';

/// Exact custom curved silhouette path with symmetric beveled curves on top and bottom,
/// matching the exact curve on both left and right sides.
Path getCurvedNavBarPath(Rect rect) {
  final h = rect.height;

  // Symmetric inset and control offsets for both top and bottom curves
  final inset = 0.3214 * h;
  final dx = (18.0 / 168.0) * h;
  final dy = (12.0 / 168.0) * h;

  final path = Path();
  // 1. Top horizontal line
  path.moveTo(rect.left + inset, rect.top);
  path.lineTo(rect.right - inset, rect.top);

  // 2. Top-Right curve & shoulder slant
  path.cubicTo(
    rect.right - inset + dx,
    rect.top,
    rect.right,
    rect.top + 0.5 * h - dy,
    rect.right,
    rect.top + 0.5 * h,
  );

  // 3. Bottom-Right curve (symmetric mirror of top-right curve)
  path.cubicTo(
    rect.right,
    rect.top + 0.5 * h + dy,
    rect.right - inset + dx,
    rect.bottom,
    rect.right - inset,
    rect.bottom,
  );

  // 4. Bottom horizontal line
  path.lineTo(rect.left + inset, rect.bottom);

  // 5. Bottom-Left curve (symmetric mirror of top-left curve)
  path.cubicTo(
    rect.left + inset - dx,
    rect.bottom,
    rect.left,
    rect.top + 0.5 * h + dy,
    rect.left,
    rect.top + 0.5 * h,
  );

  // 6. Top-Left curve & shoulder slant
  path.cubicTo(
    rect.left,
    rect.top + 0.5 * h - dy,
    rect.left + inset - dx,
    rect.top,
    rect.left + inset,
    rect.top,
  );

  path.close();
  return path;
}

/// Custom clipper clipping content within the exact Figma curved silhouette.
class CurvedNavBarClipper extends CustomClipper<Path> {
  const CurvedNavBarClipper();

  @override
  Path getClip(Size size) => getCurvedNavBarPath(Offset.zero & size);

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// ShapeBorder defining the exact custom curved silhouette of the floating navigation bar.
class CurvedNavBarBorder extends ShapeBorder {
  final BorderSide side;

  const CurvedNavBarBorder({
    this.side = const BorderSide(color: AppColors.navBorder, width: 0.8),
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return getCurvedNavBarPath(rect.deflate(side.width));
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return getCurvedNavBarPath(rect);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none || side.width == 0.0) return;
    final paint = side.toPaint();
    final path = getOuterPath(rect, textDirection: textDirection);
    canvas.drawPath(path, paint);
  }

  @override
  ShapeBorder scale(double t) {
    return CurvedNavBarBorder(side: side.scale(t));
  }
}

/// Data class representing an item in the custom bottom navigation bar.
class _NavTabData {
  final String label;
  final String svgPath;

  const _NavTabData({
    required this.label,
    required this.svgPath,
  });
}

/// Floating custom bottom navigation bar matching Figma design specs (Node 118:917 / 118:1226 / Rectangle 138):
/// Custom curved silhouette, dynamic responsive height, cyan-to-blue radial active circle,
/// physics-based liquid squash & stretch pill morphing, and fluid animated transition.
class CustomBottomNavBar extends StatefulWidget {
  final int activeIndex;
  final ValueChanged<int> onTabSelected;

  const CustomBottomNavBar({
    super.key,
    required this.activeIndex,
    required this.onTabSelected,
  });

  static const List<_NavTabData> _tabs = [
    _NavTabData(label: 'Activity', svgPath: AppIcons.activity),
    _NavTabData(label: 'Vitals', svgPath: AppIcons.heartGrey),
    _NavTabData(label: 'Unlock', svgPath: AppIcons.tagScanner),
    _NavTabData(label: 'Journal', svgPath: AppIcons.journal),
  ];

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  double _fromPosition = 0.0;
  double _targetPosition = 0.0;
  int _fromIndex = 0;
  int _targetIndex = 0;

  bool get _hasSelection =>
      widget.activeIndex >= 0 &&
      widget.activeIndex < CustomBottomNavBar._tabs.length;

  @override
  void initState() {
    super.initState();
    final initialIndex = _hasSelection ? widget.activeIndex : 0;
    _fromPosition = initialIndex.toDouble();
    _targetPosition = initialIndex.toDouble();
    _fromIndex = initialIndex;
    _targetIndex = initialIndex;

    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.navTabSwitch,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: AppCurves.navTabSwitch,
    );
  }

  @override
  void didUpdateWidget(covariant CustomBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeIndex != oldWidget.activeIndex) {
      final wasSelected = oldWidget.activeIndex >= 0 &&
          oldWidget.activeIndex < CustomBottomNavBar._tabs.length;
      final isSelected = _hasSelection;

      if (!wasSelected && isSelected) {
        _fromPosition = widget.activeIndex.toDouble();
        _targetPosition = widget.activeIndex.toDouble();
        _fromIndex = widget.activeIndex;
        _targetIndex = widget.activeIndex;
        _controller.value = 1.0;
      } else if (wasSelected && !isSelected) {
        _controller.value = 1.0;
      } else if (wasSelected && isSelected) {
        _animateToTab(oldWidget.activeIndex, widget.activeIndex);
      }
    }
  }

  void _animateToTab(int oldIndex, int newIndex) {
    _fromPosition = _currentPosition;
    _targetPosition = newIndex.toDouble();
    _fromIndex = oldIndex;
    _targetIndex = newIndex;

    _controller.forward(from: 0.0);
  }

  double get _currentPosition {
    return NavBarCalculator.computeCurrentPosition(
      fromPosition: _fromPosition,
      targetPosition: _targetPosition,
      progress: _animation.value,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final bottomInset = r.bottomPadding > 0 ? r.bottomPadding : 14.0;
    final dims = NavBarDimensions.compute(r.height);

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
          constraints: BoxConstraints(maxWidth: r.isTablet ? 540 : 420),
          child: Container(
            height: dims.navHeight,
            decoration: ShapeDecoration(
              color: AppColors.surface,
              shape: const CurvedNavBarBorder(
                side: BorderSide(
                  color: AppColors.divider,
                  width: 0.8,
                ),
              ),
              shadows: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.12),
                  blurRadius: 28.0,
                  offset: const Offset(0.0, 10.0),
                  spreadRadius: 0.0,
                ),
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  blurRadius: 14.0,
                  offset: const Offset(0.0, 3.0),
                ),
              ],
            ),
            child: ClipPath(
              clipper: const CurvedNavBarClipper(),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final totalWidth = constraints.maxWidth;
                  final tabWidth = NavBarCalculator.computeTabWidth(
                    totalWidth,
                    CustomBottomNavBar._tabs.length,
                  );

                  return AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      final currentPos =
                          _hasSelection ? _currentPosition : -1.0;
                      final bubbleSpec = _hasSelection
                          ? NavBarCalculator.computeBubbleSpec(
                              currentPos: currentPos,
                              fromPosition: _fromPosition,
                              targetPosition: _targetPosition,
                              progress: _animation.value,
                              tabWidth: tabWidth,
                              indicatorDim: dims.indicatorDim,
                              navHeight: dims.navHeight,
                            )
                          : null;

                      return Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.centerLeft,
                        children: [
                          // 1. Sliding Glowing Gradient Bubble with Embedded Active Icon
                          if (_hasSelection && bubbleSpec != null)
                            Positioned(
                              left: bubbleSpec.left,
                              top: bubbleSpec.top,
                              width: bubbleSpec.width,
                              height: bubbleSpec.height,
                              child: RepaintBoundary(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      bubbleSpec.borderRadius,
                                    ),
                                    gradient: AppGradients.activeNavCircle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.navActiveGlow,
                                        blurRadius: 10.0,
                                        offset: const Offset(0.0, 4.0),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: _buildActiveBubbleIcon(
                                      activeIconSize: dims.activeIconSize,
                                      progress: _animation.value,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          // 2. Interactive Navigation Tabs Track
                          Row(
                            children: List.generate(
                              CustomBottomNavBar._tabs.length,
                              (index) {
                                final tab = CustomBottomNavBar._tabs[index];
                                final inactiveOpacity = _hasSelection
                                    ? NavBarCalculator.computeInactiveOpacity(
                                        currentPos: currentPos,
                                        tabIndex: index,
                                      )
                                    : 1.0;

                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      if (!_hasSelection ||
                                          widget.activeIndex != index ||
                                          index == 2) {
                                        HapticFeedback.lightImpact();
                                        widget.onTabSelected(index);
                                      }
                                    },
                                    behavior: HitTestBehavior.opaque,
                                    child: SizedBox(
                                      height: dims.navHeight,
                                      child: Center(
                                        child: Opacity(
                                          opacity: inactiveOpacity,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              AppSvgIcon(
                                                tab.svgPath,
                                                size: dims.inactiveIconSize,
                                                color: AppColors.tertiary,
                                              ),
                                              if (tab.label.isNotEmpty) ...[
                                                const SizedBox(height: 2.0),
                                                if (!_hasSelection ||
                                                    index !=
                                                        widget.activeIndex ||
                                                    _controller.isAnimating)
                                                  Text(
                                                    tab.label,
                                                    style: GoogleFonts
                                                        .plusJakartaSans(
                                                      fontSize: r.font(9.5),
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color:
                                                          AppColors.tertiary,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.clip,
                                                  ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveBubbleIcon({
    required double activeIconSize,
    required double progress,
  }) {
    if (!_hasSelection ||
        _targetIndex < 0 ||
        _targetIndex >= CustomBottomNavBar._tabs.length) {
      return const SizedBox.shrink();
    }

    if (_fromIndex < 0 ||
        _fromIndex >= CustomBottomNavBar._tabs.length ||
        _fromIndex == _targetIndex ||
        !_controller.isAnimating) {
      return AppSvgIcon(
        CustomBottomNavBar._tabs[_targetIndex].svgPath,
        size: activeIconSize,
        color: AppColors.white,
      );
    }

    final fromTab = CustomBottomNavBar._tabs[_fromIndex];
    final toTab = CustomBottomNavBar._tabs[_targetIndex];
    final morph = NavBarCalculator.computeActiveIconMorph(progress);

    return Stack(
      alignment: Alignment.center,
      children: [
        Opacity(
          opacity: morph.fromOpacity,
          child: Transform.scale(
            scale: morph.fromScale,
            child: AppSvgIcon(
              fromTab.svgPath,
              size: activeIconSize,
              color: AppColors.white,
            ),
          ),
        ),
        Opacity(
          opacity: morph.toOpacity,
          child: Transform.scale(
            scale: morph.toScale,
            child: AppSvgIcon(
              toTab.svgPath,
              size: activeIconSize,
              color: AppColors.white,
            ),
          ),
        ),
      ],
    );
  }
}
