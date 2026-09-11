import 'package:equatable/equatable.dart';

import '../../../data/models/user_profile_model.dart';

enum ProfileStatus { initial, loading, loaded, error }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final UserProfileModel? data;
  final String? errorMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.data,
    this.errorMessage,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    UserProfileModel? data,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, data, errorMessage];
}
