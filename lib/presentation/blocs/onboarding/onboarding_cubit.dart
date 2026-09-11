import 'package:flutter_bloc/flutter_bloc.dart';

import 'onboarding_state.dart';

/// Cubit managing dynamic step progression throughout onboarding.
class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit({int initialStep = 1, int totalSteps = 5})
    : super(OnboardingState(currentStep: initialStep, totalSteps: totalSteps));

  void setStep(int step) {
    emit(state.copyWith(currentStep: step.clamp(1, state.totalSteps)));
  }

  void nextStep() {
    if (state.currentStep < state.totalSteps) {
      emit(state.copyWith(currentStep: state.currentStep + 1));
    }
  }

  void previousStep() {
    if (state.currentStep > 1) {
      emit(state.copyWith(currentStep: state.currentStep - 1));
    }
  }

  void setBandFound(bool found) {
    emit(state.copyWith(isBandFound: found));
  }

  void setUserName(String name) {
    emit(state.copyWith(userName: name));
  }

  void setUserAge(int age) {
    emit(state.copyWith(userAge: age));
  }

  void setSelectedPlan(String plan) {
    emit(state.copyWith(selectedPlan: plan));
  }

  void reset() {
    emit(
      state.copyWith(
        currentStep: 1,
        isBandFound: false,
        userName: '',
        userAge: 32,
        selectedPlan: '',
      ),
    );
  }
}
