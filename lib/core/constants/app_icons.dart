import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppIcons {
  AppIcons._();

  static const String logo = 'assets/icons/ehg_logo.svg';
  static const String ehgLogo = logo;
  static const String activity = 'assets/icons/activity.svg';
  static const String vitals = 'assets/icons/vitals.svg';
  static const String train = 'assets/icons/train.svg';
  static const String profile = 'assets/icons/profile.svg';
  static const String runner = 'assets/icons/runner.svg';
  static const String water = 'assets/icons/water.svg';
  static const String sleep = 'assets/icons/sleep.svg';
  static const String stress = 'assets/icons/stress.svg';
  static const String band = 'assets/icons/band.svg';
  static const String play = 'assets/icons/play.svg';
  static const String shield = 'assets/icons/shield.svg';
  static const String arrowForward = 'assets/icons/arrow_forward.svg';
  static const String onboardingFirstCard =
      'assets/icons/onboarding_first_card.svg';
  static const String onboardingUser = 'assets/icons/ob_user.svg';
  static const String cakeIcon = 'assets/icons/cake.svg';
  static const String check = 'assets/icons/check.svg';
  static const String blackStar = 'assets/icons/black_star.svg';
  static const String blueStar = 'assets/icons/blue_star.svg';
  static const String diamond = 'assets/icons/diamond.svg';
  static const String heartStar = 'assets/icons/heart_star.svg';
}

class AppSvgIcon extends StatelessWidget {
  final String assetPath;
  final double? size;
  final Color? color;

  const AppSvgIcon(this.assetPath, {super.key, this.size = 20, this.color});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetPath,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
    );
  }
}
