import 'package:equatable/equatable.dart';

abstract class StateProfileEvent extends Equatable {
  const StateProfileEvent();

  @override
  List<Object?> get props => [];
}

class FetchStateProfileEvent extends StateProfileEvent {
  final int stateId;

  const FetchStateProfileEvent(this.stateId);

  @override
  List<Object?> get props => [stateId];
}

class RefreshStateProfileEvent extends StateProfileEvent {
  final int stateId;

  const RefreshStateProfileEvent(this.stateId);

  @override
  List<Object?> get props => [stateId];
}
