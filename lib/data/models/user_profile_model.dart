import 'package:equatable/equatable.dart';

enum AppearanceTheme { midnight, dayLight, system }

enum UnitSystem { metric, imperial }

class UserProfileModel extends Equatable {
  final String email;
  final String username;
  final int age;
  final int weight;
  final AppearanceTheme appearance;
  final UnitSystem unitSystem;
  final bool dailyPlanReminder;
  final bool hydrationNudges;
  final bool journeyDays;
  final bool sleepWindDown;
  final String bandModel;
  final String bandId;
  final String bandBatteryDays;

  const UserProfileModel({
    required this.email,
    required this.username,
    required this.age,
    required this.weight,
    required this.appearance,
    required this.unitSystem,
    required this.dailyPlanReminder,
    required this.hydrationNudges,
    required this.journeyDays,
    required this.sleepWindDown,
    required this.bandModel,
    required this.bandId,
    required this.bandBatteryDays,
  });

  UserProfileModel copyWith({
    String? email,
    String? username,
    int? age,
    int? weight,
    AppearanceTheme? appearance,
    UnitSystem? unitSystem,
    bool? dailyPlanReminder,
    bool? hydrationNudges,
    bool? journeyDays,
    bool? sleepWindDown,
    String? bandModel,
    String? bandId,
    String? bandBatteryDays,
  }) {
    return UserProfileModel(
      email: email ?? this.email,
      username: username ?? this.username,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      appearance: appearance ?? this.appearance,
      unitSystem: unitSystem ?? this.unitSystem,
      dailyPlanReminder: dailyPlanReminder ?? this.dailyPlanReminder,
      hydrationNudges: hydrationNudges ?? this.hydrationNudges,
      journeyDays: journeyDays ?? this.journeyDays,
      sleepWindDown: sleepWindDown ?? this.sleepWindDown,
      bandModel: bandModel ?? this.bandModel,
      bandId: bandId ?? this.bandId,
      bandBatteryDays: bandBatteryDays ?? this.bandBatteryDays,
    );
  }

  @override
  List<Object?> get props => [
    email,
    username,
    age,
    weight,
    appearance,
    unitSystem,
    dailyPlanReminder,
    hydrationNudges,
    journeyDays,
    sleepWindDown,
    bandModel,
    bandId,
    bandBatteryDays,
  ];
}
