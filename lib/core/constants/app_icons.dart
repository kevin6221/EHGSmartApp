import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppIcons {
  AppIcons._();

  static const String logo = 'assets/icons/ehg_logo.svg';
  static const String ehgLogo = logo;
  static const String activity = 'assets/icons/activity.svg';
  static const String profile = 'assets/icons/profile.svg';
  static const String band = 'assets/icons/band.svg';
  static const String shield = 'assets/icons/shield.svg';
  static const String chevronRight = 'assets/icons/chevron_right.svg';
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
  static const String heartPlus = 'assets/icons/heart_plus.svg';
  static const String heartPulse = 'assets/icons/heart_pulse.svg';
  static const String runningMan = 'assets/icons/running_man.svg';
  static const String sleepZ = 'assets/icons/sleep_z.svg';
  static const String waterGlass = 'assets/icons/water_glass.svg';
  static const String energyBurn = 'assets/icons/energy_burn.svg';
  static const String rightArrowChevron = 'assets/icons/right_arrow_chevron.svg';
  static const String burnGrey = 'assets/icons/burn_grey.svg';
  static const String heartGrey = 'assets/icons/heart_grey.svg';
  static const String restingLounger = 'assets/icons/resting_lounger.svg';
  static const String lotusFlower = 'assets/icons/lotus_flower.svg';
  static const String bloodDroplets = 'assets/icons/blood_droplets.svg';
  static const String stressVital = 'assets/icons/stress_vital.svg';
  static const String upArrowBlue = 'assets/icons/down_arrow_blue.svg';
  static const String downArrowBlue = 'assets/icons/up_arrow_blue.svg';
  static const String targetDart = 'assets/icons/target_dart.svg';
  static const String watchDevice = 'assets/icons/watch_device.svg';
  static const String layersFolded = 'assets/icons/layers_folded.svg';
  static const String playButton = 'assets/icons/play_icon.svg';
  static const String runningManIcon = 'assets/icons/running_man.svg';
  static const String trainFlame = 'assets/icons/train_flame.svg';
  static const String profileVerify = 'assets/icons/profile_verify.svg';
  static const String deleteIcon = 'assets/icons/delete_icon.svg';
  static const String shareIcon = 'assets/icons/share_icon.svg';
  static const String selectorArrows = 'assets/icons/selector_arrows.svg';
  static const String buttonRightArrow = 'assets/icons/button_right_arrow.svg';
  static const String connectIcon = 'assets/icons/connect_icon.svg';
  static const String searchIcon = 'assets/icons/search_icon.svg';
  static const String tagScanner = 'assets/icons/tag_scanner.svg';
  static const String wardrobePieceBadge = 'assets/icons/wardrobe_piece_badge.svg';
  static const String careWash = 'assets/icons/care_wash.svg';
  static const String careBleach = 'assets/icons/care_bleach.svg';
  static const String careDry = 'assets/icons/care_dry.svg';
  static const String careIron = 'assets/icons/care_iron.svg';
  static const String lock = 'assets/icons/lock.svg';
  static const String journal = 'assets/icons/journal.svg';
  static const String rewards = 'assets/icons/rewards.svg';
  static const String systems = layersFolded;
  static const String recoverPerson = 'assets/icons/recover_person.svg';
  static const String mindBreath = 'assets/icons/mind_breath.svg';
  static const String singleDrop = 'assets/icons/single_drop.svg';
  static const String redCross = 'assets/icons/red_cross.svg';
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
