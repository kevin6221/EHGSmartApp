import 'package:flutter_bloc/flutter_bloc.dart';

import 'navigation_event.dart';
import 'navigation_state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(const NavigationState(activeIndex: 0)) {
    on<TabChangedEvent>((event, emit) {
      emit(NavigationState(activeIndex: event.newIndex));
    });
  }
}
