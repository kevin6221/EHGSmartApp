import 'package:equatable/equatable.dart';

abstract class VitalsEvent extends Equatable {
  const VitalsEvent();

  @override
  List<Object?> get props => [];
}

class LoadVitalsEvent extends VitalsEvent {}
