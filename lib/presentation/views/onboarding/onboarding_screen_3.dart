import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/security/secure_storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';
import '../../blocs/onboarding/onboarding_cubit.dart';
import '../../blocs/profile/profile_bloc.dart';
import '../../blocs/profile/profile_event.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/onboarding/onboarding_progress_bar.dart';

class OnboardingScreen3 extends StatefulWidget {
  const OnboardingScreen3({super.key});

  @override
  State<OnboardingScreen3> createState() => _OnboardingScreen3State();
}

class _OnboardingScreen3State extends State<OnboardingScreen3> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final cubitName = context.read<OnboardingCubit>().state.userName;
    final profileName = context.read<ProfileBloc>().state.data?.username;
    final initialName = cubitName.trim().isNotEmpty
        ? cubitName.trim()
        : (profileName != null && profileName.trim().isNotEmpty
            ? profileName.trim()
            : '');
    _nameController = TextEditingController(text: initialName);
    _nameController.addListener(() {
      try {
        context.read<OnboardingCubit>().setUserName(_nameController.text);
      } catch (_) {}
    });

    if (initialName.isEmpty) {
      SecureStorageService().getUserName().then((savedName) {
        if (mounted &&
            savedName != null &&
            savedName.trim().isNotEmpty &&
            _nameController.text.isEmpty) {
          _nameController.text = savedName.trim();
          try {
            context.read<OnboardingCubit>().setUserName(savedName.trim());
          } catch (_) {}
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    final enteredName = _nameController.text.trim();
    if (enteredName.isNotEmpty) {
      SecureStorageService().saveUserName(enteredName);
      context.read<ProfileBloc>().add(UpdateUsernameEvent(enteredName));
    }
    Navigator.pushNamed(context, AppRoutes.onboarding4);
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final screenWidth = r.width;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppColors.transparent,
        statusBarIconBrightness:
            context.isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness:
            context.isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bottomInset = MediaQuery.of(context).padding.bottom;
              final bottomSpacing = bottomInset > 0 ? 14.0 : 20.0;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _nameController,
                        builder: (context, nameValue, _) {
                          final bool isTextEntered = nameValue.text
                              .trim()
                              .isNotEmpty;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const OnboardingProgressBar(
                                padding: EdgeInsets.only(
                                  top: 12.0,
                                  bottom: 8.0,
                                ),
                              ),

                              SizedBox(
                                height: (constraints.maxHeight * 0.090).clamp(
                                  16.0,
                                  40.0,
                                ),
                              ),
                              // Title (Figma Node 16:4220)
                              Text(
                                'A little about you',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: (screenWidth * 0.08).clamp(
                                    24.0,
                                    30.0,
                                  ),
                                  fontWeight: FontWeight.w700,
                                  height: 38.0 / 30.0,
                                  letterSpacing: -0.39,
                                  color: context.textPrimary,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 16.0),

                              Text(
                                'Just few detail to get started. Tell us your name so we can make your EHG experience feel personal.',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: (screenWidth * 0.042).clamp(
                                    14.0,
                                    16.0,
                                  ),
                                  fontWeight: FontWeight.w400,
                                  height: 25.6 / 16.0,
                                  letterSpacing: 0.0,
                                  color: context.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(
                                height: (constraints.maxHeight * 0.1).clamp(
                                  24.0,
                                  64.0,
                                ),
                              ),

                              Center(
                                child: TextFormField(
                                  controller: _nameController,
                                  textAlign: TextAlign.center,
                                  textCapitalization: TextCapitalization.words,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 20.0,
                                    fontWeight: isTextEntered
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: isTextEntered
                                        ? AppColors.primary
                                        : context.textPrimary,
                                  ),
                                  cursorColor: AppColors.primary,
                                  decoration: InputDecoration(
                                    hintText: 'What should we call you?',
                                    filled: true,
                                    fillColor: isTextEntered
                                        ? context.inputFill
                                        : AppColors.transparent,
                                    hintStyle: GoogleFonts.plusJakartaSans(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: -0.22,
                                      color: context.textSecondary,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24.0),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SvgPicture.asset(
                                    AppIcons.onboardingUser,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(height: 12.0),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                    ),
                                    child: Text(
                                      'For regulatory purposes, please enter name stated',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: (screenWidth * 0.042).clamp(
                                          14.0,
                                          16.0,
                                        ),
                                        fontWeight: FontWeight.w400,
                                        height: 25.6 / 16.0,
                                        color: context.textSecondary,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),

                              const Spacer(),

                              // Next CTA — disabled when empty, filled when text entered
                              AppButton(
                                text: 'Next',
                                onPressed: isTextEntered
                                    ? _onNextPressed
                                    : null,
                                disabledGradient:
                                    AppGradients.disabledPrimary,
                                disabledTextColor: AppColors.primary,
                                hasShadow: isTextEntered,
                              ),

                              const SizedBox(height: 16.0),

                              // Privacy footer
                              Text(
                                'Your data stays on your phone',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w400,
                                  height: 19.2 / 12.0,
                                  color: context.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              SizedBox(height: bottomSpacing),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
