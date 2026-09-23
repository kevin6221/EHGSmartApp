import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';

/// Section detailing daily points earnings and redemptions history, plus footer disclaimer.
class RewardsHistorySection extends StatelessWidget {
  final Responsive r;

  const RewardsHistorySection({super.key, required this.r});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: r.horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How you earned today',
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(14.0),
              fontWeight: FontWeight.w600,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 14.0),
          Container(
            decoration: BoxDecoration(
              color: context.cardBackground,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: context.cardBorder),
            ),
            child: Column(
              children: [
                _buildLogItem(
                  context: context,
                  r: r,
                  title: 'Redeemed: Free UK delivery, next order',
                  amount: '-1200',
                  isPositive: false,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Divider(
                    height: 1.0,
                    thickness: 1.0,
                    color: context.cardBorder,
                  ),
                ),
                _buildLogItem(
                  context: context,
                  r: r,
                  title: 'Redeemed: 10% off any Activewear piece',
                  amount: '-800',
                  isPositive: false,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Divider(
                    height: 1.0,
                    thickness: 1.0,
                    color: context.cardBorder,
                  ),
                ),
                _buildLogItem(
                  context: context,
                  r: r,
                  title: 'Journal saved',
                  amount: '+120',
                  isPositive: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20.0),
          Text(
            'Points never expire and there is no subscription. Codes issued here apply at checkout on your Shopify store.',
            textAlign: TextAlign.left,
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(10.0),
              fontWeight: FontWeight.w400,
              color: context.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogItem({
    required BuildContext context,
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
                color: context.textPrimary,
              ),
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(10.0),
              fontWeight: FontWeight.w600,
              color: isPositive ? AppColors.primary : AppColors.systemRed,
            ),
          ),
        ],
      ),
    );
  }
}
