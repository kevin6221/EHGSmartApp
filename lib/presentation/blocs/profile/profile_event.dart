import 'package:equatable/equatable.dart';

import '../../../data/models/user_profile_model.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfileEvent extends ProfileEvent {}

class UpdateAppearanceEvent extends ProfileEvent {
  final AppearanceTheme theme;
  const UpdateAppearanceEvent(this.theme);

  @override
  List<Object?> get props => [theme];
}

class UpdateUnitSystemEvent extends ProfileEvent {
  final UnitSystem unitSystem;
  const UpdateUnitSystemEvent(this.unitSystem);

  @override
  List<Object?> get props => [unitSystem];
}

class ToggleNotificationEvent extends ProfileEvent {
  final String key;
  final bool value;
  const ToggleNotificationEvent(this.key, this.value);

  @override
  List<Object?> get props => [key, value];
}
