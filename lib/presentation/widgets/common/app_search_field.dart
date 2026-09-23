import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';

/// Reusable Search and Text Input field matching Figma Brand Guide (Node 2:575).
class AppSearchField extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final String hintText;
  final bool autofocus;
  final FocusNode? focusNode;
  final double height;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;

  const AppSearchField({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.hintText = 'Search...',
    this.autofocus = false,
    this.focusNode,
    this.height = 46.0,
    this.backgroundColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final ctrl = controller;

    return Container(
      height: height,
      padding: padding,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor ?? context.inputFill,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: context.inputBorder, width: 1.0),
      ),
      child: TextField(
          controller: ctrl,
          focusNode: focusNode,
          autofocus: autofocus,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
            color: context.textPrimary,
          ),
          cursorColor: AppColors.primary,
          decoration: InputDecoration(
            isDense: true,
            filled: false,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14.0,
              vertical: 10.0,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            hintText: hintText,
            hintStyle: GoogleFonts.plusJakartaSans(
              fontSize: 14.0,
              fontWeight: FontWeight.w400,
              color: context.textMuted,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: context.textSecondary,
              size: 20.0,
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 40.0,
              minHeight: 20.0,
            ),
            suffixIcon: ctrl != null && ctrl.text.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      ctrl.clear();
                      onClear?.call();
                      onChanged?.call('');
                    },
                    child: Icon(
                      Icons.close_rounded,
                      color: context.textSecondary,
                      size: 18.0,
                    ),
                  )
                : null,
            suffixIconConstraints: const BoxConstraints(
              minWidth: 36.0,
              minHeight: 18.0,
            ),
          ),
        ),
      );
  }
}
