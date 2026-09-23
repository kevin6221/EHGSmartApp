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

class OnboardingScreen4 extends StatefulWidget {
  const OnboardingScreen4({super.key});

  @override
  State<OnboardingScreen4> createState() => _OnboardingScreen4State();
}

class _OnboardingScreen4State extends State<OnboardingScreen4> {
  static const int _minAge = 13;
  static const int _maxAge = 100;
  static const int _defaultAge = 32;
  static const double _itemExtent = 48.0;

  late final FixedExtentScrollController _scrollController;
  late final ValueNotifier<int> _selectedAge;

  @override
  void initState() {
    super.initState();
    final cubitAge = context.read<OnboardingCubit>().state.userAge;
    final profileAge = context.read<ProfileBloc>().state.data?.age;
    final initialAge = (cubitAge > 0 && cubitAge != _defaultAge)
        ? cubitAge
        : (profileAge != null && profileAge > 0 ? profileAge : _defaultAge);

    _selectedAge = ValueNotifier<int>(initialAge);
    _scrollController = FixedExtentScrollController(
      initialItem: (initialAge - _minAge).clamp(0, _maxAge - _minAge),
    );

    SecureStorageService().getUserAge().then((savedAge) {
      if (mounted &&
          savedAge != null &&
          savedAge >= _minAge &&
          savedAge <= _maxAge) {
        if (_selectedAge.value != savedAge) {
          _selectedAge.value = savedAge;
          _scrollController
              .jumpToItem((savedAge - _minAge).clamp(0, _maxAge - _minAge));
          try {
            context.read<OnboardingCubit>().setUserAge(savedAge);
          } catch (_) {}
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _selectedAge.dispose();
    super.dispose();
  }

  void _onContinuePressed() {
    try {
      final age = _selectedAge.value;
      context.read<OnboardingCubit>().setUserAge(age);
      SecureStorageService().saveUserAge(age);
      context.read<ProfileBloc>().add(UpdateAgeEvent(age));
    } catch (_) {}
    Navigator.pushNamed(context, AppRoutes.onboarding5);
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const OnboardingProgressBar(
                            padding: EdgeInsets.only(top: 12.0, bottom: 8.0),
                          ),

                          SizedBox(
                            height: (constraints.maxHeight * 0.090).clamp(
                              16.0,
                              40.0,
                            ),
                          ),

                          Text(
                            'How old are you?',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: (screenWidth * 0.08).clamp(24.0, 30.0),
                              fontWeight: FontWeight.w700,
                              height: 38.0 / 30.0,
                              letterSpacing: -0.39,
                              color: context.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 16.0),

                          Text(
                            'Your age helps EHG personalize your heart-rate zones and wellness insights for you.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: (screenWidth * 0.042).clamp(14.0, 16.0),
                              fontWeight: FontWeight.w400,
                              height: 25.6 / 16.0,
                              letterSpacing: 0.0,
                              color: context.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const Spacer(),

                          SizedBox(
                            height: (constraints.maxHeight * 0.24).clamp(
                              150.0,
                              240.0,
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Selected item highlight container
                                Container(
                                  height: _itemExtent,
                                  decoration: BoxDecoration(
                                    color: context.isDark
                                        ? context.cardBackground
                                        : AppColors.inputFilledBackground,
                                    borderRadius: BorderRadius.circular(16.0),
                                    border: Border.all(
                                      color: context.isDark
                                          ? context.cardBorder
                                          : AppColors.primary,
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                                NotificationListener<ScrollNotification>(
                                  onNotification: (notification) {
                                    if (notification
                                        is ScrollUpdateNotification) {
                                      final index =
                                          _scrollController.selectedItem;
                                      final age = index + _minAge;
                                      if (_selectedAge.value != age) {
                                        _selectedAge.value = age;
                                      }
                                    }
                                    return false;
                                  },
                                  child: ListWheelScrollView.useDelegate(
                                    controller: _scrollController,
                                    itemExtent: _itemExtent,
                                    perspective: 0.003,
                                    diameterRatio: 3.0,
                                    physics: const FixedExtentScrollPhysics(),
                                    onSelectedItemChanged: (index) {
                                      _selectedAge.value = index + _minAge;
                                    },
                                    childDelegate: ListWheelChildBuilderDelegate(
                                      childCount: _maxAge - _minAge + 1,
                                      builder: (context, index) {
                                        final age = index + _minAge;
                                        return ValueListenableBuilder<int>(
                                          valueListenable: _selectedAge,
                                          builder: (context, selected, _) {
                                            final isSelected = age == selected;
                                            final distance = (age - selected)
                                                .abs();
                                            double fontSize;
                                            FontWeight fontWeight;
                                            Color color;

                                            if (isSelected) {
                                              fontSize = 20.0;
                                              fontWeight = FontWeight.w600;
                                              color = AppColors.primary;
                                            } else if (distance == 1) {
                                              fontSize = 16.0;
                                              fontWeight = FontWeight.w500;
                                              color = AppColors.textSecondary;
                                            } else {
                                              fontSize = 12.0;
                                              fontWeight = FontWeight.w500;
                                              color = AppColors.textSecondary
                                                  .withValues(alpha: 0.5);
                                            }

                                            return Center(
                                              child: Text(
                                                '$age',
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                      fontSize: fontSize,
                                                      fontWeight: fontWeight,
                                                      color: color,
                                                    ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Spacer(),

                          ValueListenableBuilder<int>(
                            valueListenable: _selectedAge,
                            builder: (context, age, _) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    AppIcons.cakeIcon,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(width: 8.0),
                                  Text(
                                    "I'm $age years of age",
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w500,
                                      color: context.textPrimary,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),

                          const SizedBox(height: 24.0),

                          AppButton(
                            text: 'Continue',
                            onPressed: _onContinuePressed,
                          ),

                          const SizedBox(height: 16.0),

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
