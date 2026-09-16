import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';
import '../../widgets/common/screen_header.dart';
import 'widgets/wardrobe_order_unlock_card.dart';
import 'widgets/wardrobe_piece_list_tiles.dart';
import 'widgets/wardrobe_scan_tag_card.dart';
import 'widgets/wardrobe_section_header.dart';
import 'widgets/wardrobe_verified_piece_card.dart';

/// Unlock your wardrobe screen matching Figma Node 142:1543 / 142:1549.
/// Modular architecture with zero setState.
class UnlockWardrobeScreen extends StatefulWidget {
  const UnlockWardrobeScreen({super.key});

  @override
  State<UnlockWardrobeScreen> createState() => _UnlockWardrobeScreenState();
}

class _UnlockWardrobeScreenState extends State<UnlockWardrobeScreen> {
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
                  // 1. Top Header Row: Title & Online Avatar
                  const ScreenHeader(
                    title: 'Unlock your wardrobe',
                    titleFontSize: 20.0,
                    showAvatar: true,
                    showOnlineIndicator: true,
                  ),

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
                  WardrobeOrderUnlockCard(controller: _orderController),
                  SizedBox(height: (screenHeight * 0.020).clamp(14.0, 18.0)),

                  // 4. Card 2: "Scan the tag" Card
                  const WardrobeScanTagCard(),
                  SizedBox(height: (screenHeight * 0.028).clamp(20.0, 26.0)),

                  // 5. Section: "Your pieces"
                  const WardrobeSectionHeader(
                    title: 'Your pieces',
                    badgeText: '2 VERIFIED',
                    badgeColor: AppColors.greenMetric,
                  ),
                  SizedBox(height: (screenHeight * 0.014).clamp(10.0, 14.0)),

                  // Active Piece 1: High Rise Flared Yoga Pants (Expanded)
                  const WardrobeVerifiedPieceCard(),
                  SizedBox(height: (screenHeight * 0.016).clamp(12.0, 16.0)),

                  // Active Piece 2: Cotton Earth Tone T-Shirt (Verified)
                  const WardrobeVerifiedTShirtCard(),
                  SizedBox(height: (screenHeight * 0.030).clamp(22.0, 28.0)),

                  // 6. Section: "Not yours yet"
                  const WardrobeSectionHeader(
                    title: 'Not yours yet',
                    badgeText: '2 LOCKED',
                    badgeColor: AppColors.tertiary,
                  ),
                  SizedBox(height: (screenHeight * 0.014).clamp(10.0, 14.0)),

                  // Locked Piece 1: Heavyweight Tank Top
                  const WardrobeLockedPieceCard(
                    title: 'Heavyweight Tank Top',
                    subtitle: '3 programmes inside',
                  ),
                  SizedBox(height: (screenHeight * 0.014).clamp(10.0, 14.0)),

                  // Locked Piece 2: Boxy Piping T-Shirt
                  const WardrobeLockedPieceCard(
                    title: 'Boxy Piping T-Shirt',
                    subtitle: '4 programmes inside',
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
}
