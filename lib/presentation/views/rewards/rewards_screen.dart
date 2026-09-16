import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';
import '../../widgets/common/dashed_container.dart';
import '../../widgets/common/dotted_divider.dart';
import '../../widgets/common/screen_header.dart';

/// Rewards screen matching Figma Node 143:3009.
/// Pixel-perfect visual fidelity with Figma, strictly following zero setState() policy.
class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const SkyHeaderBackground(height: 250),
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(
                bottom: 110.0,
              ), // Floating nav bar clearance
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(r, context),
                  const SizedBox(height: 16.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: _buildBalanceCard(r),
                  ),
                  const SizedBox(height: 16.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: _buildTierCard(r),
                  ),
                  const SizedBox(height: 24.0),
                  _buildSpendPointsSection(r),
                  const SizedBox(height: 24.0),
                  _buildYourCodesSection(r),
                  const SizedBox(height: 24.0),
                  _buildPiecesEarningSection(r),
                  const SizedBox(height: 24.0),
                  _buildEarningLogsSection(r),
                  const SizedBox(height: 20.0),
                  _buildFooterDisclaimer(r),
                  const SizedBox(height: 16.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 1. Header (Clean title and avatar, no divider per Figma Node 143:3009)
  // ===========================================================================
  Widget _buildHeader(Responsive r, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Rewards',
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(24.0),
              fontWeight: FontWeight.w700,
              color: AppColors.white,
              height: 1.2,
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
            behavior: HitTestBehavior.opaque,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                const CircleAvatar(
                  radius: 20.0,
                  backgroundImage: AssetImage(AppConstants.avatar),
                  backgroundColor: Colors.transparent,
                ),
                Container(
                  width: 12.0,
                  height: 12.0,
                  decoration: BoxDecoration(
                    color: AppColors.greenMetric,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2.0),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 2. Balance Card (Horizontal alignment, soft gradient & border)
  // ===========================================================================
  Widget _buildBalanceCard(Responsive r) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.rewardsBalanceCard,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppColors.rewardsTierCardBorder, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                "2,350",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(30.0),
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 8.0),
              Text(
                "BALANCE",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(11.0),
                  fontWeight: FontWeight.w500,
                  color: AppColors.tertiary,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14.0,
              vertical: 6.0,
            ),
            decoration: BoxDecoration(
              color: AppColors.cyanLight,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Text(
              "11–day streak",
              style: GoogleFonts.plusJakartaSans(
                fontSize: r.font(12.0),
                fontWeight: FontWeight.w500,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 3. Bronze Member Tier Card
  // ===========================================================================
  Widget _buildTierCard(Responsive r) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.rewardsTierCard,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppColors.rewardsTierCardBorder, width: 1.0),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Bronze member",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: r.font(14.0),
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(width: 6.0),
                  Container(
                    padding: EdgeInsets.all(7),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "2x",
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
              Text(
                "2,150 to Silver",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(10.0),
                  fontWeight: FontWeight.w500,
                  color: AppColors.tertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14.0),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child: LinearProgressIndicator(
              value: 0.35,
              backgroundColor: AppColors.white,
              color: AppColors.primary,
              minHeight: 3.0,
            ),
          ),
          const SizedBox(height: 12.0),
          Text(
            "Free UK delivery on every order",
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(12.0),
              fontWeight: FontWeight.w500,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 14.0),
          DottedDivider(
            color: AppColors.secondary,
            dashWidth: 3.0,
            dashSpace: 3.0,
            thickness: 0.5,
          ),
          const SizedBox(height: 12.0),
          Text(
            "Next · Silver unlocks early access to every drop and first refusal on limited colourways",
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(10.0),
              fontWeight: FontWeight.w500,
              color: AppColors.tertiary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 4. Spend Your Points Section
  // ===========================================================================
  Widget _buildSpendPointsSection(Responsive r) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Spend your points",
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(14.0),
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            "Earning and spending are free for everyone. Members earn at double rate and reach the two reserved rewards.",
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(10.0),
              fontWeight: FontWeight.w500,
              color: AppColors.tertiary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12.0),
          // 800 - Activewear piece
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: AppColors.primary, width: 0.5),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                Text(
                  "800",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: r.font(14.0),
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      "10% off any Activewear piece",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: r.font(12.0),
                        fontWeight: FontWeight.w400,
                        color: AppColors.tertiary,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppGradients.primary,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    "REDEEM",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: r.font(12.0),
                      fontWeight: FontWeight.w500,
                      color: AppColors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12.0),
          // 1200 - Free UK delivery (Redeemed)
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: AppColors.rewardsRedeemedBorder,
                width: 0.5,
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Row(
              children: [
                Text(
                  "1200",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: r.font(14.0),
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      "Free UK delivery, next order",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: r.font(12.0),
                        fontWeight: FontWeight.w400,
                        color: AppColors.tertiary,
                      ),
                    ),
                  ),
                ),
                Text(
                  "REDEEMED",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: r.font(12.0),
                    fontWeight: FontWeight.w500,
                    color: AppColors.rewardsRedeemedText,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 5. Your Codes Section (Full-width stacked cards with dashed borders)
  // ===========================================================================
  Widget _buildYourCodesSection(Responsive r) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Your codes",
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(14.0),
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 12.0),
          // Code 1: Free UK delivery
          DashedContainer(
            color: AppColors.rewardsCodeBorder,
            borderRadius: BorderRadius.circular(12.0),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Free UK delivery, next order",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: r.font(12.0),
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                    ),
                    Text(
                      "EHG-LSRZ",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: r.font(12.0),
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6.0),
                Text(
                  "Use at checkout on ehgsmartwellness.com",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: r.font(10.0),
                    fontWeight: FontWeight.w400,
                    color: AppColors.tertiary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12.0),
          // Code 2: 10% off any Activewear piece
          DashedContainer(
            color: AppColors.rewardsCodeBorder,
            borderRadius: BorderRadius.circular(12.0),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "10% off any Activewear piece",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: r.font(12.0),
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                    ),
                    Text(
                      "EHG-DUV5",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: r.font(12.0),
                        fontWeight: FontWeight.w500,
                        color: AppColors.rewardsCodeOrange,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6.0),
                Text(
                  "Use at checkout on ehgsmartwellness.com",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: r.font(10.0),
                    fontWeight: FontWeight.w400,
                    color: AppColors.tertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 6. Your Pieces Are Earning (Cyan BRONZE tag & progress)
  // ===========================================================================
  Widget _buildPiecesEarningSection(Responsive r) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Your pieces are earning",
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(14.0),
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 14.0),
          _buildPieceEarningItem(
            r: r,
            title: "High Rise Flared Yoga Pants",
            tier: "BRONZE",
            progress: 0.60,
            subtitle: "47 wears · 3 to Silver",
          ),
          const SizedBox(height: 12.0),
          _buildPieceEarningItem(
            r: r,
            title: "Heavyweight Tank Top",
            tier: "BRONZE",
            progress: 0.60,
            subtitle: "22 wears · 28 to Silver",
          ),
        ],
      ),
    );
  }

  Widget _buildPieceEarningItem({
    required Responsive r,
    required String title,
    required String tier,
    required double progress,
    required String subtitle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            offset: const Offset(0, 4),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(12.0),
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                ),
              ),
              Text(
                tier,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(10.0),
                  fontWeight: FontWeight.w600,
                  color: AppColors.cyanLight,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          ClipRRect(
            borderRadius: BorderRadius.circular(3.0),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFF1F5F9),
              color: AppColors.cyanLight,
              minHeight: 2.0,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            subtitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(10.0),
              fontWeight: FontWeight.w400,
              color: AppColors.tertiary,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 7. How You Earned Today Section
  // ===========================================================================
  Widget _buildEarningLogsSection(Responsive r) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "How you earned today",
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(14.0),
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 14.0),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              children: [
                _buildLogItem(
                  r: r,
                  title: "Redeemed: Free UK delivery, next order",
                  amount: "-1200",
                  isPositive: false,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.divider.withValues(alpha: 0.6),
                  ),
                ),
                _buildLogItem(
                  r: r,
                  title: "Redeemed: 10% off any Activewear piece",
                  amount: "-800",
                  isPositive: false,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.divider.withValues(alpha: 0.6),
                  ),
                ),
                _buildLogItem(
                  r: r,
                  title: "Journal saved",
                  amount: "+120",
                  isPositive: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogItem({
    required Responsive r,
    required String title,
    required String amount,
    required bool isPositive,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: r.font(12.0),
                fontWeight: FontWeight.w400,
                color: AppColors.tertiary,
              ),
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(10),
              fontWeight: FontWeight.w600,
              color: isPositive ? AppColors.primary : AppColors.systemRed,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 8. Footer Disclaimer
  // ===========================================================================
  Widget _buildFooterDisclaimer(Responsive r) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Text(
        "Points never expire and there is no subscription. Codes issued here apply at checkout on your Shopify store.",
        textAlign: TextAlign.left,
        style: GoogleFonts.plusJakartaSans(
          fontSize: r.font(10.0),
          fontWeight: FontWeight.w400,
          color: AppColors.tertiary,
          height: 1.4,
        ),
      ),
    );
  }
}
