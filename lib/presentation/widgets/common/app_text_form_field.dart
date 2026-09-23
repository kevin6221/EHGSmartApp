import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';

/// Centralized, production-grade text form field matching the EHG design system.
/// Supports reactive dynamic styling (borders, fills, and text weights) based on user input,
/// eliminating repetitive boilerplate across the application while preserving exact visual fidelity.
class AppTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final FocusNode? focusNode;
  final String? hintText;
  final String? labelText;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final BorderRadius? borderRadius;
  final double borderWidth;
  final double focusedBorderWidth;
  final Color? borderColor;
  final Color? activeBorderColor;
  final Color? focusedBorderColor;
  final Color? fillColor;
  final Color? activeFillColor;
  final Color? textColor;
  final Color? activeTextColor;
  final FontWeight textWeight;
  final FontWeight activeTextWeight;
  final double fontSize;
  final TextStyle? hintStyle;
  final TextStyle? style;
  final TextAlign textAlign;
  final TextCapitalization textCapitalization;
  final EdgeInsetsGeometry? contentPadding;
  final Color cursorColor;
  final bool hasBorder;
  final bool reactToInput;

  const AppTextFormField({
    super.key,
    this.controller,
    this.initialValue,
    this.focusNode,
    this.hintText,
    this.labelText,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.inputFormatters,
    this.borderRadius,
    this.borderWidth = 0.8,
    this.focusedBorderWidth = 1.0,
    this.borderColor,
    this.activeBorderColor,
    this.focusedBorderColor,
    this.fillColor,
    this.activeFillColor,
    this.textColor,
    this.activeTextColor,
    this.textWeight = FontWeight.w400,
    this.activeTextWeight = FontWeight.w600,
    this.fontSize = 14.0,
    this.hintStyle,
    this.style,
    this.textAlign = TextAlign.start,
    this.textCapitalization = TextCapitalization.none,
    this.contentPadding,
    this.cursorColor = AppColors.primary,
    this.hasBorder = true,
    this.reactToInput = true,
  });

  @override
  Widget build(BuildContext context) {
    final ctrl = controller;
    if (reactToInput && ctrl != null) {
      return ValueListenableBuilder<TextEditingValue>(
        valueListenable: ctrl,
        builder: (context, value, _) {
          final isTextEntered = value.text.trim().isNotEmpty;
          return _buildField(context, isTextEntered: isTextEntered);
        },
      );
    }

    final initVal = initialValue;
    final isTextEntered = (initVal != null && initVal.trim().isNotEmpty) ||
        (ctrl != null && ctrl.text.trim().isNotEmpty);
    return _buildField(context, isTextEntered: isTextEntered);
  }

  Widget _buildField(BuildContext context, {required bool isTextEntered}) {
    final effectiveRadius = borderRadius ?? BorderRadius.circular(8.0);
    final effectiveBorderColor = isTextEntered
        ? (activeBorderColor ?? AppColors.primary)
        : (borderColor ?? context.inputBorder);
    final effectiveFocusedBorderColor = focusedBorderColor ?? AppColors.primary;
    final effectiveFillColor = isTextEntered
        ? (activeFillColor ?? (context.isDark ? AppColors.midnightSurface : AppColors.profileInputFill))
        : (fillColor ?? (context.isDark ? AppColors.midnightBackground : AppColors.white));
    final effectiveTextColor = isTextEntered
        ? (activeTextColor ?? AppColors.primary)
        : (textColor ?? context.textPrimary);
    final effectiveTextWeight = isTextEntered ? activeTextWeight : textWeight;

    final effectiveStyle = style ??
        GoogleFonts.plusJakartaSans(
          fontSize: fontSize,
          fontWeight: effectiveTextWeight,
          color: effectiveTextColor,
        );

    final effectiveHintStyle = hintStyle ??
        GoogleFonts.plusJakartaSans(
          fontSize: fontSize,
          fontWeight: FontWeight.w400,
          color: context.textSecondary,
        );

    InputBorder? effectiveBorder;
    InputBorder? effectiveEnabledBorder;
    InputBorder? effectiveFocusedBorder;

    if (!hasBorder) {
      effectiveBorder = InputBorder.none;
      effectiveEnabledBorder = InputBorder.none;
      effectiveFocusedBorder = InputBorder.none;
    } else {
      effectiveEnabledBorder = OutlineInputBorder(
        borderRadius: effectiveRadius,
        borderSide: BorderSide(
          color: effectiveBorderColor,
          width: borderWidth,
        ),
      );

      effectiveFocusedBorder = OutlineInputBorder(
        borderRadius: effectiveRadius,
        borderSide: BorderSide(
          color: effectiveFocusedBorderColor,
          width: focusedBorderWidth,
        ),
      );

      effectiveBorder = OutlineInputBorder(
        borderRadius: effectiveRadius,
        borderSide: BorderSide(
          color: effectiveBorderColor,
          width: borderWidth,
        ),
      );
    }

    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      focusNode: focusNode,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      textAlign: textAlign,
      textCapitalization: textCapitalization,
      cursorColor: cursorColor,
      style: effectiveStyle,
      decoration: InputDecoration(
        filled: true,
        fillColor: effectiveFillColor,
        contentPadding: contentPadding,
        hintText: hintText,
        labelText: labelText,
        hintStyle: effectiveHintStyle,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        enabledBorder: effectiveEnabledBorder,
        focusedBorder: effectiveFocusedBorder,
        border: effectiveBorder,
      ),
    );
  }
}
