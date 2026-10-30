// Country Page Data & Barrel Exports
// Centralizes route strings, navigation helpers, UI label constants, and
// barrel exports for the Country Profile module.
import 'package:flutter/material.dart';
import 'Country_screen.dart';

// [BARREL EXPORTS] Allows external files to import all CountryPage components via this single file.
export 'Country_api.dart';
export 'Country_bloc.dart';
export 'Country_event.dart';
export 'Country_model.dart';
export 'Country_screen.dart';
export 'Country_state.dart';

class CountryPageData {
  static const String routeName = '/country-profile';

  /// [NAVIGATION HELPER] Convenient method to open the CountryProfileScreen
  /// from anywhere in the app (e.g. from drawer, cards, search).
  static Future<T?> navigateTo<T>(
    BuildContext context, {
    required int countryId,
    String? name,
  }) {
    return Navigator.push<T>(
      context,
      MaterialPageRoute(
        builder: (_) => CountryProfileScreen(
          countryId: countryId,
          countryName: name,
        ),
      ),
    );
  }

  // Header & Info Labels
  static const String states = "STATES";
  static const String unionTerritories = "UNION TERRITORIES";
  static const String capitalCity = "Capital City";
  static const String capital = "CAPITAL";
  static const String population = "POPULATION";
  static const String president = "PRESIDENT";
  static const String primeMinister = "PRIME MINISTER";
  static const String dateOfIndependence = "DATE OF INDEPENDENCE";
  static const String nationalAnthem = "NATIONAL ANTHEM";
  static const String cultureAndTradition = "CULTURE & TRADITION";
  static const String economy = "ECONOMY";
  static const String generalInfo = "GENERAL INFORMATION";
  static const String placesToVisit = "PLACES TO VISIT";
  static const String nationalSymbols = "NATIONAL SYMBOLS";

  // Section tabs
  static const String infoTab = "INFO";
  static const String flagEmblemTab = "FLAG / EMBLEM";
  static const String placesTab = "FLAG / EMBLEM";
  static const String geographicTab = "GEOGRAPHIC";

  // SVG Icons from Assets
  static const String arrow = "Assets/arrow.svg";
  static const String favoriteIcon = "Assets/PartyPage/favourite.svg";

  // CountryPage SVGs
  static const String capitalIcon = "Assets/CountryPage/Capital.svg";
  static const String nationalAnthemIcon = "Assets/CountryPage/NationalAnthem.svg";
  static const String populationIcon = "Assets/CountryPage/Population.svg";
  static const String presidentIcon = "Assets/CountryPage/President.svg";
  static const String primeMinisterIcon = "Assets/CountryPage/PrimeMinister.svg";
  static const String dateOfIndependenceIcon = "Assets/CountryPage/DateoFIndependence.svg";
  static const String orangeButtonLogo = "Assets/CountryPage/OrangeButtonLogo.svg";
  static const String mapVectorIcon = "Assets/CountryPage/OrangeButtonLogo.svg";

  // Legacy icons for compatibility
  static const String calendarIcon = "Assets/CountryPage/DateoFIndependence.svg";
  static const String anthemIcon = "Assets/CountryPage/NationalAnthem.svg";
  static const String birthPlaceIcon = "Assets/LeadershipPage/Info/BirthPlace.svg";
}

// Aliases for compatibility
typedef PoliticianPageData = CountryPageData;
