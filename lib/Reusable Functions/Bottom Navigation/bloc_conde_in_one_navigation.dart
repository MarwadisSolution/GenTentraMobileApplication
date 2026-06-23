import 'package:flutter_bloc/flutter_bloc.dart';

///----Event
abstract class BottomNavEvent{}
class SelectBottomNavItemEvent extends BottomNavEvent{
  final int index;
  SelectBottomNavItemEvent(this.index);
}

///-----State
class BottomNavState{
  final int selectedIndex;
  const BottomNavState({
    this.selectedIndex=0,
});
  BottomNavState copyWith({
    int? selectedIndex,
}){
    return BottomNavState(
      selectedIndex: selectedIndex??this.selectedIndex,
    );
  }
}
///-----Bloc

class BottomNavBloc extends Bloc<BottomNavEvent, BottomNavState>{
  BottomNavBloc():super(const BottomNavState()){
    on<SelectBottomNavItemEvent>(_onSelectBottomNavItem);
  }
  void _onSelectBottomNavItem(
      SelectBottomNavItemEvent event,
      Emitter<BottomNavState> emit,
      ){
    emit(
      state.copyWith(selectedIndex: event.index,)
    );
  }
}
