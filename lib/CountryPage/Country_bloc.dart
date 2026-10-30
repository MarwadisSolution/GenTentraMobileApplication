
// Country Profile BLoC
// Manages the state machine for the Country Profile Screen.
// Handles loading, success, failure, retry, and pull-to-refresh events.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'Country_api.dart';
import 'Country_event.dart';
import 'Country_state.dart';

class CountryProfileBloc
    extends Bloc<CountryProfileEvent, CountryProfileState> {
  final CountryProfileRepository repository;

  CountryProfileBloc({CountryProfileRepository? repository})
      : repository = repository ?? CountryProfileRepository(),
        super(const CountryProfileState()) {
    on<FetchCountryProfileEvent>(_onFetchCountryProfile);
    on<RefreshCountryProfileEvent>(_onRefreshCountryProfile);
  }

  /// [EVENT HANDLER] Fetches profile data for the given country ID.
  /// Emits loading -> success or failure.
  Future<void> _onFetchCountryProfile(
    FetchCountryProfileEvent event,
    Emitter<CountryProfileState> emit,
  ) async {
    emit(
      state.copyWith(
        status: CountryProfileStatus.loading,
        countryId: event.countryId,
        errorMessage: null,
      ),
    );

    try {
      final country = await repository.fetchCountryProfile(event.countryId);
      emit(
        state.copyWith(
          status: CountryProfileStatus.success,
          country: country,
          countryId: event.countryId,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CountryProfileStatus.failure,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
          countryId: event.countryId,
        ),
      );
    }
  }

  /// [EVENT HANDLER] Silently re-fetches profile data on pull-to-refresh.
  Future<void> _onRefreshCountryProfile(
    RefreshCountryProfileEvent event,
    Emitter<CountryProfileState> emit,
  ) async {
    try {
      final country = await repository.fetchCountryProfile(event.countryId);
      emit(
        state.copyWith(
          status: CountryProfileStatus.success,
          country: country,
          countryId: event.countryId,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CountryProfileStatus.failure,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
          countryId: event.countryId,
        ),
      );
    }
  }
}

// Aliases for compatibility
typedef PoliticianProfileBloc = CountryProfileBloc;
