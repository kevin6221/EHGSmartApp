import 'package:equatable/equatable.dart';

abstract class NavigationEvent extends Equatable {
  const NavigationEvent();

  @override
  List<Object?> get props => [];
}

class TabChangedEvent extends NavigationEvent {
  final int newIndex;

  const TabChangedEvent(this.newIndex);

  @override
  List<Object?> get props => [newIndex];
}
