import 'package:flutter_bloc/flutter_bloc.dart';

abstract class DrawerEvent {}
  class SelectDrawerItemEvent extends DrawerEvent{
  final int index;
  SelectDrawerItemEvent(this.index);
  }

  ///--------State------
class DrawerState{
  final int selectedIndex;
  const DrawerState({
    this.selectedIndex=0,
});
  DrawerState copyWith({
    int? selectedIndex,
}){
    return DrawerState(
      selectedIndex: selectedIndex??this.selectedIndex,
    );
  }
}

  ///-----Bloc---------
class DrawerBloc extends Bloc<DrawerEvent, DrawerState>{
  DrawerBloc(): super(const DrawerState()){
    on<SelectDrawerItemEvent>(_onSelectDrawerItem);
  }
  void _onSelectDrawerItem(
      SelectDrawerItemEvent event,
      Emitter<DrawerState>emit,
      ){
    emit(
      state.copyWith(selectedIndex: event.index),
    );
  }
}