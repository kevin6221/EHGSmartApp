import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/app_text_form_field.dart';

/// Interactive Check-In card for the Journal screen (Figma Node 143:2654).
/// Strictly zero setState - reactive input via ValueNotifier.
class JournalCheckInCard extends StatelessWidget {
  final ValueNotifier<int> energyNotifier;
  final ValueNotifier<String> wordNotifier;
  final TextEditingController textController;
  final VoidCallback? onSave;

  const JournalCheckInCard({
    super.key,
    required this.energyNotifier,
    required this.wordNotifier,
    required this.textController,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "How was your energy today?",
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(12.0),
              fontWeight: FontWeight.w400,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 10.0),
          ValueListenableBuilder<int>(
            valueListenable: energyNotifier,
            builder: (context, selectedEnergy, _) {
              return Row(
                children: List.generate(4, (index) {
                  final energyLevel = index + 1;
                  final isSelected = selectedEnergy == energyLevel;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => energyNotifier.value = energyLevel,
                      child: Container(
                        margin: EdgeInsets.only(right: index < 3 ? 10.0 : 0.0),
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.routineInputFill,
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.routineInputBorder,
                            width: 1.0,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$energyLevel',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: r.font(14.0),
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.white
                                : AppColors.secondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
          const SizedBox(height: 20.0),
          Text(
            "Which word fits?",
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(12.0),
              fontWeight: FontWeight.w400,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 12.0),
          ValueListenableBuilder<String>(
            valueListenable: wordNotifier,
            builder: (context, selectedWord, _) {
              const words = ['Clear', 'Clam', 'Flat', 'Wired', 'Heavy'];
              return Wrap(
                spacing: 8.0,
                runSpacing: 10.0,
                children: words.map((word) {
                  final isSelected = selectedWord == word;
                  return GestureDetector(
                    onTap: () => wordNotifier.value = word,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 10.0,
                      ),
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
                        word,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: r.font(12.0),
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isSelected
                              ? AppColors.white
                              : AppColors.tertiary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 20.0),
          Text(
            "What stressed you, and what helped?",
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(12.0),
              fontWeight: FontWeight.w400,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 8.0),
          AppTextFormField(
            controller: textController,
            maxLines: 4,
            fontSize: r.font(14.0),
            contentPadding: const EdgeInsets.all(16.0),
            hintText: 'Enter here...',
            borderRadius: BorderRadius.circular(10.0),
            fillColor: AppColors.routineInputFill,
            activeFillColor: AppColors.routineInputFill,
            borderColor: AppColors.routineInputBorder,
            activeBorderColor: AppColors.primary,
            borderWidth: 0.8,
            focusedBorderWidth: 1.0,
          ),
          const SizedBox(height: 16.0),
          AppButton(
            text: 'Save entry · +120',
            onPressed: onSave ?? () {},
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 10.0,
            ),
            useGradient: true,
            borderRadius: BorderRadius.circular(8.0),
            fontSize: r.font(14.0),
            fontWeight: FontWeight.w600,
            hasShadow: false,
          ),
        ],
      ),
    );
  }
}
