import 'package:equatable/equatable.dart';

class NavigationState extends Equatable {
  final int activeIndex;

  const NavigationState({this.activeIndex = 0});

  @override
  List<Object?> get props => [activeIndex];
}
