import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/screen_header.dart';

/// Unlock your wardrobe screen matching Figma Node 142:1543.
/// Features order verification, NFC tag scanning, active unlocked apparel,
/// care symbols, and locked collection pieces.
class UnlockWardrobeScreen extends StatefulWidget {
  const UnlockWardrobeScreen({super.key});

  @override
  State<UnlockWardrobeScreen> createState() => _UnlockWardrobeScreenState();
}

class _UnlockWardrobeScreenState extends State<UnlockWardrobeScreen> {
  // Controller for the order number or email input
  late final TextEditingController _orderController;

  @override
  void initState() {
    super.initState();
    _orderController = TextEditingController(text: 'EH-9F2C');
  }

  @override
  void dispose() {
    _orderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final media = MediaQuery.sizeOf(context);
    final screenHeight = media.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: Stack(
        children: [
          // Sky header gradient background fading smoothly to white
          SkyHeaderBackground(
            height: screenHeight * 0.38,
            stops: const [0.0, 0.85],
          ),

          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                r.horizontalPadding,
                r.verticalPadding,
                r.horizontalPadding,
                110.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Top Header Row: Back button, Title, Online Avatar
                  _buildHeaderRow(context, r),

                  // Subtle divider under top bar matching Figma
                  Padding(
                    padding: const EdgeInsets.only(top: 14.0, bottom: 20.0),
                    child: Container(
                      height: 1.0,
                      color: AppColors.white.withValues(alpha: 0.35),
                    ),
                  ),

                  // 2. Headline & Subtitle
                  Text(
                    'Every EHG piece carries its own programmes. Confirm what you own with your order number and they open straight away — including anything you have bought before.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: r.font(16.0),
                      fontWeight: FontWeight.w400,
                      color: AppColors.tertiary,
                      height: 1.45,
                    ),
                  ),
                  SizedBox(height: (screenHeight * 0.024).clamp(16.0, 22.0)),

                  // 3. Card 1: Order Number / Email Unlock Card
                  _buildOrderUnlockCard(context, r, screenHeight),
                  SizedBox(height: (screenHeight * 0.020).clamp(14.0, 18.0)),

                  // 4. Card 2: "Scan the tag" Card
                  _buildScanTagCard(context, r, screenHeight),
                  SizedBox(height: (screenHeight * 0.028).clamp(20.0, 26.0)),

                  // 5. Section: "Your pieces"
                  _buildSectionHeader(
                    title: 'Your pieces',
                    badgeText: '2 VERIFIED',
                    badgeColor: AppColors.greenMetric,
                    r: r,
                  ),
                  SizedBox(height: (screenHeight * 0.014).clamp(10.0, 14.0)),

                  // Active Piece 1: High Rise Flared Yoga Pants (Expanded)
                  _buildYogaPantsCard(context, r, screenHeight),
                  SizedBox(height: (screenHeight * 0.016).clamp(12.0, 16.0)),

                  // Active Piece 2: Cotton Earth Tone T-Shirt (Verified)
                  _buildCottonTShirtCard(context, r),
                  SizedBox(height: (screenHeight * 0.030).clamp(22.0, 28.0)),

                  // 6. Section: "Not yours yet"
                  _buildSectionHeader(
                    title: 'Not yours yet',
                    badgeText: '2 LOCKED',
                    badgeColor: AppColors.tertiary,
                    r: r,
                  ),
                  SizedBox(height: (screenHeight * 0.014).clamp(10.0, 14.0)),

                  // Locked Piece 1: Heavyweight Tank Top
                  _buildLockedCard(
                    title: 'Heavyweight Tank Top',
                    subtitle: '3 programmes inside',
                    r: r,
                  ),
                  SizedBox(height: (screenHeight * 0.014).clamp(10.0, 14.0)),

                  // Locked Piece 2: Boxy Piping T-Shirt
                  _buildLockedCard(
                    title: 'Boxy Piping T-Shirt',
                    subtitle: '4 programmes inside',
                    r: r,
                  ),
                  SizedBox(height: (screenHeight * 0.025).clamp(18.0, 24.0)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context, Responsive r) {
    final avatarDim = (r.width * 0.11).clamp(38.0, 44.0);
    final dotDim = (avatarDim * 0.25).clamp(9.0, 11.0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Unlock your wardrobe',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.white,
            fontSize: r.font(20.0),
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
          behavior: HitTestBehavior.opaque,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: avatarDim,
                height: avatarDim,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage(AppConstants.avatar),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 1,
                child: Container(
                  width: dotDim,
                  height: dotDim,
                  decoration: BoxDecoration(
                    color: AppColors.greenMetric,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderUnlockCard(
    BuildContext context,
    Responsive r,
    double screenHeight,
  ) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: AppGradients.membershipCard,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.40),
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
          TextField(
            controller: _orderController,
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(14.5),
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Enter order number or email',
              hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: r.font(12.0),
                color: AppColors.textSecondary,
              ),
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
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Verifying order ${_orderController.text.trim()}...',
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
              color: AppColors.tertiary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanTagCard(
    BuildContext context,
    Responsive r,
    double screenHeight,
  ) {
    final ringOuter = (r.width * 0.38).clamp(130.0, 160.0);
    final ringMid = (r.width * 0.28).clamp(95.0, 120.0);
    final ringInner = (r.width * 0.18).clamp(62.0, 80.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppColors.border, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowNavy.withValues(alpha: 0.03),
            blurRadius: 8.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Scan the tag',
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(10.0),
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 14.0),

          // Concentric pulsing rings with center NFC tag scanner
          Center(
            child: SizedBox(
              width: ringOuter,
              height: ringOuter,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer soft circle
                  Container(
                    width: ringOuter,
                    height: ringOuter,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFEFF9FD),
                    ),
                  ),
                  // Middle circle
                  Container(
                    width: ringMid,
                    height: ringMid,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFCEF0FA),
                    ),
                  ),
                  // Inner vibrant circle with SVG
                  Container(
                    width: ringInner,
                    height: ringInner,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF75D5F1),
                    ),
                    alignment: Alignment.center,
                    child: const AppSvgIcon(
                      AppIcons.tagScanner,
                      size: 26.0,
                      color: AppColors.tertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12.0),

          Center(
            child: Text(
              'Hold near Tag',
              style: GoogleFonts.plusJakartaSans(
                fontSize: r.font(12.0),
                fontWeight: FontWeight.w400,
                color: AppColors.tertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String badgeText,
    required Color badgeColor,
    required Responsive r,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: r.font(14.0),
            fontWeight: FontWeight.w600,
            color: AppColors.secondary,
          ),
        ),
        Text(
          badgeText,
          style: GoogleFonts.plusJakartaSans(
            fontSize: r.font(10.0),
            fontWeight: FontWeight.w600,
            color: badgeColor,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildYogaPantsCard(
    BuildContext context,
    Responsive r,
    double screenHeight,
  ) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: AppColors.primarySky.withValues(alpha: 0.45),
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
          // Header info row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge icon container
              Container(
                width: 44.0,
                height: 44.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE8F7FC),
                  border: Border.all(
                    color: AppColors.primarySky.withValues(alpha: 0.25),
                    width: 1.0,
                  ),
                ),
                alignment: Alignment.center,
                child: const AppSvgIcon(
                  AppIcons.wardrobePieceBadge,
                  size: 22.0,
                  color: AppColors.cyanAccent,
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'High Rise Flared Yoga Pants',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: r.font(14),
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    Text(
                      'EHG Performance · Move system',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: r.font(12.0),
                        fontWeight: FontWeight.w500,
                        color: AppColors.recoverPillar,
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    Text(
                      '72% nylon · 28% elastane',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: r.font(10.0),
                        fontWeight: FontWeight.w500,
                        color: AppColors.tertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),

          // Care icons row
          Row(
            children: [
              _buildCareIcon(AppIcons.careWash),
              const SizedBox(width: 10.0),
              _buildCareIcon(AppIcons.careBleach),
              const SizedBox(width: 10.0),
              _buildCareIcon(AppIcons.careDry),
              const SizedBox(width: 10.0),
              _buildCareIcon(AppIcons.careIron),
            ],
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Divider(
              color: AppColors.divider,
              height: 1.0,
              thickness: 0.8,
            ),
          ),

          // Status subtitle
          Text(
            'Unlocked · 47 wears · Bronze',
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(10.0),
              fontWeight: FontWeight.w500,
              color: AppColors.tertiary,
            ),
          ),
          const SizedBox(height: 10.0),

          // 4 Programme bullet points with blue star
          _buildProgrammeItem('30-day Pilates programme', r),
          _buildProgrammeItem('Lower body challenge', r),
          _buildProgrammeItem('Stretch library', r),
          _buildProgrammeItem('Mobility tracker', r),
          const SizedBox(height: 14.0),

          // Full-width button: Unlock 90 days Free
          AppButton(
            text: 'Unlock 90 days Free',
            showArrow: false,
            useGradient: true,
            hasShadow: false,
            height: (screenHeight * 0.050).clamp(40.0, 44.0),
            borderRadius: BorderRadius.circular(10.0),
            fontSize: r.font(14.0),
            fontWeight: FontWeight.w600,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('90 days free membership unlocked!'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCareIcon(String svgPath) {
    return Container(
      width: 32.0,
      height: 32.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      alignment: Alignment.center,
      child: AppSvgIcon(svgPath, size: 16.0, color: AppColors.tertiary),
    );
  }

  Widget _buildProgrammeItem(String title, Responsive r) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const AppSvgIcon(
            AppIcons.blueStar,
            size: 14.0,
            color: AppColors.primarySky,
          ),
          const SizedBox(width: 10.0),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(10.0),
              fontWeight: FontWeight.w500,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCottonTShirtCard(BuildContext context, Responsive r) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppColors.border, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowNavy.withValues(alpha: 0.03),
            blurRadius: 8.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Circular Badge
          Container(
            width: 44.0,
            height: 44.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE8F7FC),
              border: Border.all(
                color: AppColors.primarySky.withValues(alpha: 0.25),
                width: 1.0,
              ),
            ),
            alignment: Alignment.center,
            child: const AppSvgIcon(
              AppIcons.wardrobePieceBadge,
              size: 22.0,
              color: AppColors.cyanAccent,
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cotton Earth Tone T-Shirt',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: r.font(14.0),
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 3.0),
                Text(
                  'EHG Core · Move system',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: r.font(12.0),
                    fontWeight: FontWeight.w500,
                    color: AppColors.primarySky,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8.0),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppSvgIcon(
                AppIcons.check,
                size: 12.0,
                color: AppColors.greenMetric,
              ),
              const SizedBox(width: 4.0),
              Text(
                'VERIFIED',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(10.0),
                  fontWeight: FontWeight.w600,
                  color: AppColors.greenMetric,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLockedCard({
    required String title,
    required String subtitle,
    required Responsive r,
  }) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Circular Muted Badge
          Container(
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.white,
              border: Border.all(color: AppColors.border, width: 1.0),
            ),
            alignment: Alignment.center,
            child: const AppSvgIcon(
              AppIcons.wardrobePieceBadge,
              size: 20.0,
              color: AppColors.tertiary,
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: r.font(14.0),
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: r.font(12.0),
                    fontWeight: FontWeight.w500,
                    color: AppColors.tertiary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8.0),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppSvgIcon(
                AppIcons.lock,
                size: 13.0,
                color: AppColors.tertiary,
              ),
              const SizedBox(width: 4.0),
              Text(
                'LOCKED',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(10.0),
                  fontWeight: FontWeight.w600,
                  color: AppColors.tertiary,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
