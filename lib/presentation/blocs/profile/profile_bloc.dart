import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/user_profile_model.dart';
import '../../../data/repositories/wellness_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final WellnessRepository repository;

  ProfileBloc({required this.repository}) : super(const ProfileState()) {
    on<LoadProfileEvent>((event, emit) async {
      emit(state.copyWith(status: ProfileStatus.loading));
      try {
        await repository.loadUserProfile();
        final data = repository.getUserProfile();
        emit(state.copyWith(status: ProfileStatus.loaded, data: data));
      } catch (e) {
        emit(
          state.copyWith(
            status: ProfileStatus.error,
            errorMessage: e.toString(),
          ),
        );
      }
    });

    on<UpdateUsernameEvent>((event, emit) async {
      final current = state.data ?? repository.getUserProfile();
      final updated = current.copyWith(username: event.username);
      emit(state.copyWith(data: updated, status: ProfileStatus.loaded));
      await repository.saveUserProfile(updated);
    });

    on<UpdateAppearanceEvent>((event, emit) async {
      final current = state.data ?? repository.getUserProfile();
      final updated = current.copyWith(appearance: event.theme);
      emit(state.copyWith(data: updated, status: ProfileStatus.loaded));
      await repository.saveUserProfile(updated);
    });

    on<UpdateUnitSystemEvent>((event, emit) async {
      final current = state.data ?? repository.getUserProfile();
      final updated = current.copyWith(unitSystem: event.unitSystem);
      emit(state.copyWith(data: updated, status: ProfileStatus.loaded));
      await repository.saveUserProfile(updated);
    });

    on<ToggleNotificationEvent>((event, emit) async {
      final current = state.data ?? repository.getUserProfile();
      UserProfileModel updated = current;
      switch (event.key) {
        case 'dailyPlan':
          updated = current.copyWith(dailyPlanReminder: event.value);
          break;
        case 'hydration':
          updated = current.copyWith(hydrationNudges: event.value);
          break;
        case 'journey':
          updated = current.copyWith(journeyDays: event.value);
          break;
        case 'sleep':
          updated = current.copyWith(sleepWindDown: event.value);
          break;
      }
      emit(state.copyWith(data: updated, status: ProfileStatus.loaded));
      await repository.saveUserProfile(updated);
    });

    on<UpdateAgeEvent>((event, emit) async {
      final current = state.data ?? repository.getUserProfile();
      final updated = current.copyWith(age: event.age);
      emit(state.copyWith(data: updated, status: ProfileStatus.loaded));
      await repository.saveUserProfile(updated);
    });

    on<UpdateWeightEvent>((event, emit) async {
      final current = state.data ?? repository.getUserProfile();
      final updated = current.copyWith(weight: event.weight);
      emit(state.copyWith(data: updated, status: ProfileStatus.loaded));
      await repository.saveUserProfile(updated);
    });
  }
}
