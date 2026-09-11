import 'package:equatable/equatable.dart';

/// State representing the dynamic progress of the onboarding flow.
class OnboardingState extends Equatable {
  final int currentStep;
  final int totalSteps;
  final bool isBandFound;
  final String userName;
  final int userAge;
  final String selectedPlan;

  const OnboardingState({
    this.currentStep = 1,
    this.totalSteps = 5,
    this.isBandFound = false,
    this.userName = '',
    this.userAge = 32,
    this.selectedPlan = '',
  });

  /// The fractional progress between 0.0 and 1.0.
  double get progress => (currentStep / totalSteps).clamp(0.0, 1.0);

  /// Whether user has entered a valid non-empty name.
  bool get isNameValid => userName.trim().isNotEmpty;

  OnboardingState copyWith({
    int? currentStep,
    int? totalSteps,
    bool? isBandFound,
    String? userName,
    int? userAge,
    String? selectedPlan,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      totalSteps: totalSteps ?? this.totalSteps,
      isBandFound: isBandFound ?? this.isBandFound,
      userName: userName ?? this.userName,
      userAge: userAge ?? this.userAge,
      selectedPlan: selectedPlan ?? this.selectedPlan,
    );
  }

  @override
  List<Object?> get props => [
    currentStep,
    totalSteps,
    isBandFound,
    userName,
    userAge,
    selectedPlan,
  ];
}
