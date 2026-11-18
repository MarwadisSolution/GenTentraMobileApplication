import 'package:equatable/equatable.dart';
import 'State_model.dart';

enum StateProfileStatus { initial, loading, success, failure }

class StateProfileState extends Equatable {
  final StateProfileStatus status;
  final StateModel? state;
  final int? stateId;
  final String? errorMessage;

  const StateProfileState({
    this.status = StateProfileStatus.initial,
    this.state,
    this.stateId,
    this.errorMessage,
  });

  bool get isLoading => status == StateProfileStatus.loading;
  bool get isSuccess => status == StateProfileStatus.success;
  bool get isFailure => status == StateProfileStatus.failure;

  StateProfileState copyWith({
    StateProfileStatus? status,
    StateModel? state,
    int? stateId,
    String? errorMessage,
  }) {
    return StateProfileState(
      status: status ?? this.status,
      state: state ?? this.state,
      stateId: stateId ?? this.stateId,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, state, stateId, errorMessage];
}
