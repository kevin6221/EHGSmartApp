import 'package:flutter/material.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/responsive.dart';

/// 4 Core Button Variants defined in Figma Brand Guide (Node 2:575).
enum AppButtonVariant {
  /// Primary solid #3E83C8 (or optional gradient) with white text.
  primary,

  /// Secondary white #FFFFFF background with #1F2937 dark text.
  secondary,

  /// Inverted dark slate #1F2937 background with white text.
  inverted,

  /// Outlined transparent background with #3E83C8 border and text.
  outlined,
}

/// Common action button matching Figma Brand Guide (Node 2:575).
///
/// Variants:
/// - [AppButtonVariant.primary]: Fill #3E83C8, Text #FFFFFF
/// - [AppButtonVariant.secondary]: Fill #FFFFFF, Text #1F2937, Border #E5E7EB
/// - [AppButtonVariant.inverted]: Fill #1F2937, Text #FFFFFF
/// - [AppButtonVariant.outlined]: Border #3E83C8 (1.5px), Text #3E83C8
class AppButton extends StatelessWidget {
  /// Dynamic text label displayed on the button.
  final String text;

  /// Callback executed when user taps the button.
  final VoidCallback? onPressed;

  /// Button variant defined in the brand guide.
  final AppButtonVariant variant;

  /// Whether to display the trailing arrow icon (defaults to true).
  final bool showArrow;

  /// Custom trailing icon widget if overriding default arrow.
  final Widget? trailingIcon;

  /// Custom leading icon widget.
  final Widget? leadingIcon;

  /// Custom leading SVG asset path.
  final String? leadingSvg;

  /// Custom trailing SVG asset path.
  final String? trailingSvg;

  /// Button height (defaults to Figma standard 48.0).
  final double? height;

  /// Button width (defaults to full width `double.infinity`).
  final double width;

  /// Custom gradient override (e.g. AppColors.primaryGradient).
  final Gradient? gradient;

  /// Whether to apply primary gradient on primary variant.
  final bool useGradient;

  /// Custom solid background color override.
  final Color? backgroundColor;

  /// Text and icon color override.
  final Color? textColor;

  /// Custom gradient override when disabled.
  final Gradient? disabledGradient;

  /// Custom background color override when disabled.
  final Color? disabledBackgroundColor;

  /// Custom text and icon color override when disabled.
  final Color? disabledTextColor;

  /// Font size (defaults to 16.0).
  final double fontSize;

  /// Font weight (defaults to 600 SemiBold).
  final FontWeight fontWeight;

  /// Corner radius (defaults to 12.0).
  final BorderRadiusGeometry? borderRadius;

  /// Custom border override.
  final BoxBorder? border;

  /// Whether to render the soft drop shadow.
  final bool hasShadow;

  /// Displays a loading spinner when true.
  final bool isLoading;

  /// Internal padding.
  final EdgeInsetsGeometry? padding;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.showArrow = true,
    this.trailingIcon,
    this.leadingIcon,
    this.leadingSvg,
    this.trailingSvg,
    this.height = 48.0,
    this.width = double.infinity,
    this.gradient,
    this.useGradient = true,
    this.backgroundColor,
    this.textColor,
    this.disabledGradient,
    this.disabledBackgroundColor,
    this.disabledTextColor,
    this.fontSize = 16.0,
    this.fontWeight = FontWeight.w600,
    this.borderRadius,
    this.border,
    this.hasShadow = true,
    this.isLoading = false,
    this.padding,
  });

  /// Factory constructor for Primary variant.
  const AppButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.showArrow = true,
    this.trailingIcon,
    this.leadingIcon,
    this.leadingSvg,
    this.trailingSvg,
    this.height = 48.0,
    this.width = double.infinity,
    this.gradient,
    this.useGradient = false,
    this.backgroundColor,
    this.textColor,
    this.disabledGradient,
    this.disabledBackgroundColor,
    this.disabledTextColor,
    this.fontSize = 16.0,
    this.fontWeight = FontWeight.w600,
    this.borderRadius,
    this.border,
    this.hasShadow = true,
    this.isLoading = false,
    this.padding,
  }) : variant = AppButtonVariant.primary;

  /// Factory constructor for Secondary variant (#FFFFFF with #1F2937 text).
  const AppButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.showArrow = false,
    this.trailingIcon,
    this.leadingIcon,
    this.leadingSvg,
    this.trailingSvg,
    this.height = 48.0,
    this.width = double.infinity,
    this.fontSize = 16.0,
    this.fontWeight = FontWeight.w600,
    this.borderRadius,
    this.isLoading = false,
    this.padding,
  }) : variant = AppButtonVariant.secondary,
       gradient = null,
       useGradient = false,
       backgroundColor = null,
       textColor = null,
       disabledGradient = null,
       disabledBackgroundColor = null,
       disabledTextColor = null,
       border = null,
       hasShadow = true;

  /// Factory constructor for Inverted variant (#1F2937 with white text).
  const AppButton.inverted({
    super.key,
    required this.text,
    this.onPressed,
    this.showArrow = false,
    this.trailingIcon,
    this.leadingIcon,
    this.leadingSvg,
    this.trailingSvg,
    this.height = 48.0,
    this.width = double.infinity,
    this.fontSize = 16.0,
    this.fontWeight = FontWeight.w600,
    this.borderRadius,
    this.isLoading = false,
    this.padding,
  }) : variant = AppButtonVariant.inverted,
       gradient = null,
       useGradient = false,
       backgroundColor = null,
       textColor = null,
       disabledGradient = null,
       disabledBackgroundColor = null,
       disabledTextColor = null,
       border = null,
       hasShadow = false;

  /// Factory constructor for Outlined variant (transparent with #3E83C8 border and text).
  const AppButton.outlined({
    super.key,
    required this.text,
    this.onPressed,
    this.showArrow = false,
    this.trailingIcon,
    this.leadingIcon,
    this.leadingSvg,
    this.trailingSvg,
    this.height = 48.0,
    this.width = double.infinity,
    this.fontSize = 16.0,
    this.fontWeight = FontWeight.w600,
    this.borderRadius,
    this.isLoading = false,
    this.padding,
  }) : variant = AppButtonVariant.outlined,
       gradient = null,
       useGradient = false,
       backgroundColor = null,
       textColor = null,
       disabledGradient = null,
       disabledBackgroundColor = null,
       disabledTextColor = null,
       border = null,
       hasShadow = false;

  @override
  Widget build(BuildContext context) {
    final effectiveHeight =
        height ?? (context.responsive.height * 0.058).clamp(44.0, 52.0);
    final effectiveRadius = borderRadius ?? BorderRadius.circular(12.0);
    final bool isEnabled = onPressed != null && !isLoading;

    // Resolve Colors based on Brand Guide Variant
    Color resolvedBg;
    Color resolvedText;
    BoxBorder? resolvedBorder = border;
    Gradient? resolvedGradient;
    List<BoxShadow>? resolvedShadow;

    switch (variant) {
      case AppButtonVariant.primary:
        resolvedBg = backgroundColor ?? AppColors.primary;
        resolvedText = textColor ?? AppColors.white;
        if (gradient != null) {
          resolvedGradient = gradient;
        } else if (useGradient && backgroundColor == null) {
          resolvedGradient = AppColors.primaryGradient;
        }
        if (hasShadow && isEnabled) {
          resolvedShadow = [
            BoxShadow(
              color: AppColors.primaryElectric.withValues(alpha: 0.40),
              blurRadius: 18,
              offset: const Offset(0, 4),
            ),
          ];
        }
        break;

      case AppButtonVariant.secondary:
        resolvedBg = backgroundColor ?? AppColors.surface;
        resolvedText = textColor ?? AppColors.secondary;
        resolvedBorder =
            border ?? Border.all(color: AppColors.border, width: 1);
        if (hasShadow && isEnabled) {
          resolvedShadow = [
            BoxShadow(
              color: AppColors.shadowNavy.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ];
        }
        break;

      case AppButtonVariant.inverted:
        resolvedBg = backgroundColor ?? AppColors.secondary;
        resolvedText = textColor ?? AppColors.white;
        break;

      case AppButtonVariant.outlined:
        resolvedBg = backgroundColor ?? AppColors.transparent;
        resolvedText = textColor ?? AppColors.primary;
        resolvedBorder =
            border ?? Border.all(color: AppColors.primary, width: 1.5);
        break;
    }

    final effectiveColor = isEnabled
        ? (resolvedGradient == null ? resolvedBg : null)
        : (disabledGradient != null
              ? null
              : (disabledBackgroundColor ?? AppColors.border));
    final effectiveGradient = isEnabled ? resolvedGradient : disabledGradient;
    final effectiveTextColor = isEnabled
        ? resolvedText
        : (disabledTextColor ?? AppColors.textMuted);

    return Container(
      width: width,
      height: effectiveHeight,
      decoration: BoxDecoration(
        color: effectiveColor,
        gradient: effectiveGradient,
        borderRadius: effectiveRadius,
        border: resolvedBorder,
        boxShadow: resolvedShadow,
      ),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          borderRadius: effectiveRadius is BorderRadius
              ? effectiveRadius
              : BorderRadius.circular(12.0),
          onTap: isEnabled ? onPressed : null,
          child: Padding(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          effectiveTextColor,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (leadingSvg != null) ...[
                          AppSvgIcon(
                            leadingSvg!,
                            size: 20,
                            color: effectiveTextColor,
                          ),
                          const SizedBox(width: 10),
                        ] else if (leadingIcon != null) ...[
                          leadingIcon!,
                          const SizedBox(width: 10),
                        ],
                        Flexible(
                          child: Text(
                            text,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.buttonText.copyWith(
                              color: effectiveTextColor,
                              fontSize: fontSize,
                              fontWeight: fontWeight,
                            ),
                          ),
                        ),
                        if (trailingSvg != null) ...[
                          const SizedBox(width: 10),
                          AppSvgIcon(
                            trailingSvg!,
                            size: 20,
                            color: effectiveTextColor,
                          ),
                        ] else if (trailingIcon != null) ...[
                          const SizedBox(width: 10),
                          trailingIcon!,
                        ] else if (showArrow) ...[
                          const SizedBox(width: 10),
                          AppSvgIcon(
                            AppIcons.arrowForward,
                            size: 20,
                            color: effectiveTextColor,
                          ),
                        ],
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
