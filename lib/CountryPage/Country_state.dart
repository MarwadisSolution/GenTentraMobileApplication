// Country Profile State
// Represents immutable UI states for the Country Profile Screen.

import 'Country_model.dart';

/// Enum representing the current loading state.
enum CountryProfileStatus { initial, loading, success, failure }

/// [STATE] CountryProfileState holds the active CountryModel, error message,
/// active country ID, and status enum.
class CountryProfileState {
  final CountryProfileStatus status;
  final CountryModel? country;
  final String? errorMessage;
  final int? countryId;

  const CountryProfileState({
    this.status = CountryProfileStatus.initial,
    this.country,
    this.errorMessage,
    this.countryId,
  });

  /// Returns a copy of this state with updated fields.
  CountryProfileState copyWith({
    CountryProfileStatus? status,
    CountryModel? country,
    String? errorMessage,
    int? countryId,
  }) {
    return CountryProfileState(
      status: status ?? this.status,
      country: country ?? this.country,
      errorMessage: errorMessage ?? this.errorMessage,
      countryId: countryId ?? this.countryId,
    );
  }
}

// Aliases for compatibility
typedef PoliticianProfileStatus = CountryProfileStatus;
typedef PoliticianProfileState = CountryProfileState;
