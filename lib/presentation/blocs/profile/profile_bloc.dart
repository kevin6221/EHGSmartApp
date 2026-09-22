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
      if (state.data != null) {
        final updated = state.data!.copyWith(username: event.username);
        emit(state.copyWith(data: updated));
        await repository.saveUserProfile(updated);
      }
    });

    on<UpdateAppearanceEvent>((event, emit) {
      if (state.data != null) {
        emit(
          state.copyWith(data: state.data!.copyWith(appearance: event.theme)),
        );
      }
    });

    on<UpdateUnitSystemEvent>((event, emit) {
      if (state.data != null) {
        emit(
          state.copyWith(
            data: state.data!.copyWith(unitSystem: event.unitSystem),
          ),
        );
      }
    });

    on<ToggleNotificationEvent>((event, emit) {
      if (state.data != null) {
        final current = state.data!;
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
        emit(state.copyWith(data: updated));
      }
    });

    on<UpdateAgeEvent>((event, emit) async {
      if (state.data != null) {
        final updated = state.data!.copyWith(age: event.age);
        emit(state.copyWith(data: updated));
        await repository.saveUserProfile(updated);
      }
    });

    on<UpdateWeightEvent>((event, emit) async {
      if (state.data != null) {
        final updated = state.data!.copyWith(weight: event.weight);
        emit(state.copyWith(data: updated));
        await repository.saveUserProfile(updated);
      }
    });
  }
}
