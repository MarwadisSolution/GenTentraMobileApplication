import 'package:flutter_bloc/flutter_bloc.dart';
import 'politician_model.dart';
import 'politician_profile_repository.dart';

// ============================================================================
// EVENTS
// ============================================================================

abstract class PoliticianProfileEvent {
  const PoliticianProfileEvent();
}

class FetchPoliticianProfileEvent extends PoliticianProfileEvent {
  final int politicianId;
  const FetchPoliticianProfileEvent(this.politicianId);
}

class RefreshPoliticianProfileEvent extends PoliticianProfileEvent {
  final int politicianId;
  const RefreshPoliticianProfileEvent(this.politicianId);
}

// ============================================================================
// STATES
// ============================================================================

enum PoliticianProfileStatus { initial, loading, success, failure }

class PoliticianProfileState {
  final PoliticianProfileStatus status;
  final PoliticianModel? politician;
  final String? errorMessage;
  final int? politicianId;

  const PoliticianProfileState({
    this.status = PoliticianProfileStatus.initial,
    this.politician,
    this.errorMessage,
    this.politicianId,
  });

  PoliticianProfileState copyWith({
    PoliticianProfileStatus? status,
    PoliticianModel? politician,
    String? errorMessage,
    int? politicianId,
  }) {
    return PoliticianProfileState(
      status: status ?? this.status,
      politician: politician ?? this.politician,
      errorMessage: errorMessage ?? this.errorMessage,
      politicianId: politicianId ?? this.politicianId,
    );
  }
}

// ============================================================================
// BLOC
// ============================================================================

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
