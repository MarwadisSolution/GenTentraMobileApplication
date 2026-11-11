// Country Page Data & Barrel Exports
// Centralizes route strings, navigation helpers, UI label constants, and
// barrel exports for the Country Profile module.
import 'package:flutter/material.dart';
import 'Country_Flag_Page.dart';
import 'Country_Geo_Page.dart';
import 'Country_Info_Page.dart';
import 'Country_PlacesToVisit_Page.dart';
import 'Country_model.dart';
import 'Country_screen.dart';

// [BARREL EXPORTS] Allows external files to import all CountryPage components via this single file.
export 'Country_api.dart';
export 'Country_bloc.dart';
export 'Country_event.dart';
export 'Country_model.dart';
export 'Country_screen.dart';
export 'Country_state.dart';
export 'india_map_widget.dart';
export 'Country_Info_Page.dart';
export 'Country_Flag_Page.dart';
export 'Country_Geo_Page.dart';
export 'Country_PlacesToVisit_Page.dart';
export 'reusable_functions.dart';

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

  // Section tabs
  static const String infoTab = "INFO";
  static const String flagEmblemTab = "FLAG / EMBLEM";
  static const String geographicTab = "GEOGRAPHIC";
  static const String placesTab = "PLACES TO VISIT";

  /// [TAB ROUTING HELPER] Routes tab index to the respective page component
  /// matching Party page tab routing pattern exactly.
  static Widget buildTabContent({
    required int index,
    required CountryModel country,
  }) {
    switch (index) {
      case 0:
        return CountryInfoPage(country: country);
      case 1:
        return CountryFlagPage(country: country);
      case 2:
        return CountryGeoPage(country: country);
      case 3:
        return CountryPlacesToVisitPage(country: country);
      default:
        return const SizedBox.shrink();
    }
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
  static const String indianFlagSvg = "Assets/CountryPage/indian_flag.svg";
  static const String indianEmblemPng = "Assets/CountryPage/indian_emblem.png";
  static const String mapVectorIcon = "Assets/CountryPage/OrangeButtonLogo.svg";

  // Geographic Section SVGs
  static const String geographicAreaIcon = "Assets/CountryPage/Geographich_Area.svg";
  static const String geographicRegistrationCodeIcon = "Assets/CountryPage/Registration_code.svg";
  static const String geographicPopulationIcon = "Assets/CountryPage/geographic_population.svg";
  static const String geographicMapFabIcon = "Assets/CountryPage/OrangeButtonLogo.svg";

  // Legacy icons for compatibility
  static const String calendarIcon = "Assets/CountryPage/DateoFIndependence.svg";
  static const String anthemIcon = "Assets/CountryPage/NationalAnthem.svg";
  static const String birthPlaceIcon = "Assets/LeadershipPage/Info/BirthPlace.svg";
}

// Aliases for compatibility
typedef PoliticianPageData = CountryPageData;
