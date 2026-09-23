import 'package:flutter/material.dart';

import '../../../core/theme/responsive.dart';
import '../../widgets/common/screen_header.dart';
import 'widgets/rewards_balance_card.dart';
import 'widgets/rewards_codes_section.dart';
import 'widgets/rewards_history_section.dart';
import 'widgets/rewards_pieces_section.dart';
import 'widgets/rewards_spend_section.dart';
import 'widgets/rewards_tier_card.dart';

/// Rewards screen matching Figma Node 143:3009.
/// Modularized into clean, reusable presentation components adhering strictly to zero setState().
class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);
    final headerHeight = (r.height * 0.32).clamp(240.0, 300.0);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          SkyHeaderBackground(height: headerHeight),
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
                  // 1. Header (Clean title and avatar, no divider per Figma Node 143:3009)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: r.horizontalPadding),
                    child: const ScreenHeader(
                      title: 'Rewards',
                      showAvatar: true,
                      showBackButton: true,
                      showOnlineIndicator: true,
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // 2. Balance Card
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: r.horizontalPadding),
                    child: RewardsBalanceCard(r: r),
                  ),
                  const SizedBox(height: 16.0),

                  // 3. Bronze Tier Progress Card
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: r.horizontalPadding),
                    child: RewardsTierCard(r: r),
                  ),
                  const SizedBox(height: 24.0),

                  // 4. Spend Points Section
                  RewardsSpendSection(r: r),
                  const SizedBox(height: 24.0),

                  // 5. Your Codes Section
                  RewardsCodesSection(r: r),
                  const SizedBox(height: 24.0),

                  // 6. Your Pieces Are Earning Section
                  RewardsPiecesSection(r: r),
                  const SizedBox(height: 24.0),

                  // 7. How You Earned Today & Footer Disclaimer
                  RewardsHistorySection(r: r),
                  const SizedBox(height: 16.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
