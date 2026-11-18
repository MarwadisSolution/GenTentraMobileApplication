import 'package:flutter_bloc/flutter_bloc.dart';
import 'Country_api.dart';
import 'State_event.dart';
import 'State_state.dart';

class StateProfileBloc extends Bloc<StateProfileEvent, StateProfileState> {
  final CountryProfileRepository repository;

  StateProfileBloc({CountryProfileRepository? repository})
      : repository = repository ?? CountryProfileRepository(),
        super(const StateProfileState()) {
    on<FetchStateProfileEvent>(_onFetchStateProfile);
    on<RefreshStateProfileEvent>(_onRefreshStateProfile);
  }

  Future<void> _onFetchStateProfile(
    FetchStateProfileEvent event,
    Emitter<StateProfileState> emit,
  ) async {
    emit(
      state.copyWith(
        status: StateProfileStatus.loading,
        stateId: event.stateId,
        errorMessage: null,
      ),
    );

    try {
      final stateData = await repository.fetchStateProfile(event.stateId);
      emit(
        state.copyWith(
          status: StateProfileStatus.success,
          state: stateData,
          stateId: event.stateId,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: StateProfileStatus.failure,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
          stateId: event.stateId,
        ),
      );
    }
  }

  Future<void> _onRefreshStateProfile(
    RefreshStateProfileEvent event,
    Emitter<StateProfileState> emit,
  ) async {
    try {
      final stateData = await repository.fetchStateProfile(event.stateId);
      emit(
        state.copyWith(
          status: StateProfileStatus.success,
          state: stateData,
          stateId: event.stateId,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: StateProfileStatus.failure,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
          stateId: event.stateId,
        ),
      );
    }
  }
}
