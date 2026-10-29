// Country Profile Events
// Defines user interactions and lifecycle events for CountryProfileBloc.

abstract class CountryProfileEvent {
  const CountryProfileEvent();
}

/// [EVENT] Dispatched to trigger initial loading or retry of a country profile.
class FetchCountryProfileEvent extends CountryProfileEvent {
  final int countryId;
  const FetchCountryProfileEvent(this.countryId);
}

/// [EVENT] Dispatched on pull-to-refresh to update existing country profile data.
class RefreshCountryProfileEvent extends CountryProfileEvent {
  final int countryId;
  const RefreshCountryProfileEvent(this.countryId);
}

// Aliases for compatibility
typedef PoliticianProfileEvent = CountryProfileEvent;
typedef FetchPoliticianProfileEvent = FetchCountryProfileEvent;
typedef RefreshPoliticianProfileEvent = RefreshCountryProfileEvent;
