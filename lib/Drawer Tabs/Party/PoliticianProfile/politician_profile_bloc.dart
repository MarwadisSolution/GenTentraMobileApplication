import 'package:flutter_bloc/flutter_bloc.dart';
import 'politician_profile_event.dart';
import 'politician_profile_repository.dart';
import 'politician_profile_state.dart';

class PoliticianProfileBloc
    extends Bloc<PoliticianProfileEvent, PoliticianProfileState> {
  final PoliticianProfileRepository repository;

  PoliticianProfileBloc({PoliticianProfileRepository? repository})
    : repository = repository ?? PoliticianProfileRepository(),
      super(const PoliticianProfileState()) {
    on<FetchPoliticianProfileEvent>(_onFetchPoliticianProfile);
    on<RefreshPoliticianProfileEvent>(_onRefreshPoliticianProfile);
  }

  Future<void> _onFetchPoliticianProfile(
    FetchPoliticianProfileEvent event,
    Emitter<PoliticianProfileState> emit,
  ) async {
    emit(
      state.copyWith(
        status: PoliticianProfileStatus.loading,
        politicianId: event.politicianId,
        errorMessage: null,
      ),
    );

    try {
      final politician = await repository.fetchPoliticianProfile(
        event.politicianId,
      );
      emit(
        state.copyWith(
          status: PoliticianProfileStatus.success,
          politician: politician,
          politicianId: event.politicianId,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PoliticianProfileStatus.failure,
          errorMessage: e.toString(),
          politicianId: event.politicianId,
        ),
      );
    }
  }

  Future<void> _onRefreshPoliticianProfile(
    RefreshPoliticianProfileEvent event,
    Emitter<PoliticianProfileState> emit,
  ) async {
    try {
      final politician = await repository.fetchPoliticianProfile(
        event.politicianId,
      );
      emit(
        state.copyWith(
          status: PoliticianProfileStatus.success,
          politician: politician,
          politicianId: event.politicianId,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PoliticianProfileStatus.failure,
          errorMessage: e.toString(),
          politicianId: event.politicianId,
        ),
      );
    }
  }
}
