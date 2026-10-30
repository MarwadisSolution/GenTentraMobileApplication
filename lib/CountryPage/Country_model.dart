// Country Profile Data Models
// Defines all response data structures for the Country Profile screen
// corresponding to backend endpoints under `/api/v1/civic/`.
// Includes defensive parsers to handle string-encoded booleans/integers from API.

import 'package:flutter/material.dart';

/// [DEFENSIVE PARSER] Safely parses integers whether returned as `num` or `String`.
/// Prevents runtime cast exceptions if the API returns stringified IDs or counts.
int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim());
  return null;
}

/// [DEFENSIVE PARSER] Safely parses booleans.
/// Handles `bool`, `num` (0 or 1), or `String` ("true", "false", "yes", "no", "y", "n").
/// Resolves the runtime error: "type 'String' is not a subtype of type 'bool?' in type cast".
bool _parseBool(dynamic value, {bool defaultValue = false}) {
  if (value == null) return defaultValue;
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final lower = value.trim().toLowerCase();
    if (lower == 'true' || lower == 'yes' || lower == '1' || lower == 'y') {
      return true;
    }
    if (lower == 'false' || lower == 'no' || lower == '0' || lower == 'n') {
      return false;
    }
  }
  return defaultValue;
}

/// [UI MODEL] Represents prominent national leadership cards (President, Prime Minister,
/// Defence Minister, Home Minister) matching the vertical portrait cards in the reference design.
class NationalLeader {
  final String title;
  final String name;
  final String tenure;
  final String badge;
  final String imageUrl;
  final String? partyLogo;

  const NationalLeader({
    required this.title,
    required this.name,
    required this.tenure,
    required this.badge,
    required this.imageUrl,
    this.partyLogo,
  });

  factory NationalLeader.fromJson(Map<String, dynamic> json) {
    return NationalLeader(
      title: json['title']?.toString() ?? '',
      name: (json['name'] ?? json['leaderName'])?.toString() ?? '',
      tenure: json['tenure']?.toString() ?? '',
      badge: json['badge']?.toString() ?? '',
      imageUrl: (json['imageUrl'] ?? json['photoUrl'])?.toString() ?? '',
      partyLogo: json['partyLogo']?.toString(),
    );
  }
}

/// [UI MODEL] Represents horizontal cards under the "OTHER CABINETS" section
/// with customized pastel card background colors.
class CabinetMinister {
  final String firstName;
  final String lastName;
  final String imageUrl;
  final Color backgroundColor;

  const CabinetMinister({
    required this.firstName,
    required this.lastName,
    required this.imageUrl,
    required this.backgroundColor,
  });

  factory CabinetMinister.fromJson(Map<String, dynamic> json) {
    Color parseColor(dynamic c) {
      if (c is int) return Color(c);
      if (c is String) {
        final hex = c.replaceAll('#', '').trim();
        final val = int.tryParse(hex, radix: 16);
        if (val != null) {
          if (hex.length <= 6) return Color(val | 0xFF000000);
          return Color(val);
        }
      }
      return const Color(0xFFFF5252);
    }

    return CabinetMinister(
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      imageUrl: (json['imageUrl'] ?? json['photoUrl'])?.toString() ?? '',
      backgroundColor: parseColor(json['backgroundColor']),
    );
  }
}

/// [MODEL] PlaceView - Represents a tourist attraction, landmark, or historical place
/// returned by `/api/v1/civic/places` or hydrated within `placesToVisit`.
class PlaceView {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;
  final int? ownerId;
  final String? category; // 'COUNTRY', 'STATE', 'CITY'

  const PlaceView({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.ownerId,
    this.category,
  });

  factory PlaceView.fromJson(Map<String, dynamic> json) {
    return PlaceView(
      id: _parseInt(json['id']) ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      ownerId: _parseInt(json['ownerId']),
      category: json['category']?.toString(),
    );
  }
}

/// [MODEL] PlacesToVisit - Wrapper for country places with display toggle and description.
class PlacesToVisit {
  final String? description;
  final bool showDetails;
  final List<PlaceView> places;

  const PlacesToVisit({
    this.description,
    this.showDetails = true,
    this.places = const [],
  });

  factory PlacesToVisit.fromJson(Map<String, dynamic> json) {
    final List<PlaceView> placesList = [];
    final rawPlaces = json['place'] ?? json['places'];
    if (rawPlaces != null && rawPlaces is List) {
      for (final p in rawPlaces) {
        if (p is Map) {
          placesList.add(PlaceView.fromJson(Map<String, dynamic>.from(p)));
        }
      }
    }
    return PlacesToVisit(
      description: json['description']?.toString(),
      showDetails: _parseBool(json['showDetails'], defaultValue: true),
      places: placesList,
    );
  }
}

/// [MODEL] SymbolView - Represents civic and national symbols (Flag, Map, Emblem, Symbol, Logo)
/// returned by `/api/v1/civic/symbols`.
class SymbolView {
  final int id;
  final String? ownerType; // 'COUNTRY', 'STATE', 'PARTY', 'CONSTITUENCY'
  final int? ownerId;
  final String? kind; // 'FLAG', 'MAP', 'EMBLEM', 'SYMBOL', 'LOGO'
  final List<String> urls;
  final String? label;
  final bool isDefault;
  final bool downloadable;

  const SymbolView({
    required this.id,
    this.ownerType,
    this.ownerId,
    this.kind,
    this.urls = const [],
    this.label,
    this.isDefault = false,
    this.downloadable = false,
  });

  factory SymbolView.fromJson(Map<String, dynamic> json) {
    List<String> urlsList = [];
    final rawUrls = json['urls'] ?? json['partyLogo'] ?? json['url'];
    if (rawUrls != null && rawUrls is List) {
      urlsList = rawUrls.map((e) => e.toString()).toList();
    } else if (rawUrls is String && rawUrls.isNotEmpty) {
      urlsList = [rawUrls];
    }
    return SymbolView(
      id: _parseInt(json['id']) ?? 0,
      ownerType: json['ownerType']?.toString(),
      ownerId: _parseInt(json['ownerId']),
      kind: json['kind']?.toString(),
      urls: urlsList,
      label: (json['label'] ?? json['logoDescription'])?.toString(),
      isDefault: _parseBool(json['isDefault'], defaultValue: false),
      downloadable: _parseBool(
        json['downloadable'] ?? json['downloadEnabled'],
        defaultValue: false,
      ),
    );
  }
}

/// [MODEL] CountryModel - Main Country Profile entity containing all overview data,
/// leadership, places, symbols, and national metadata.
class CountryModel {
  final int id;
  final String name;
  final String? capital;
  final int? numericCode;
  final String? registrationCode;
  final int? unionTerritories;
  final String? statesCount;
  final String? population;
  final String? president;
  final String? primeMinister;
  final String? independenceDay;
  final String? nationalAnthem;
  final String? info;
  final String? cultureAndTradition;
  final String? economy;
  final List<String> bannerImages;
  final PlacesToVisit? placesToVisit;
  final List<SymbolView> symbols;
  final List<NationalLeader> leaders;
  final List<CabinetMinister> otherCabinets;

  const CountryModel({
    required this.id,
    required this.name,
    this.capital,
    this.numericCode,
    this.registrationCode,
    this.unionTerritories,
    this.statesCount,
    this.population,
    this.president,
    this.primeMinister,
    this.independenceDay,
    this.nationalAnthem,
    this.info,
    this.cultureAndTradition,
    this.economy,
    this.bannerImages = const [],
    this.placesToVisit,
    this.symbols = const [],
    this.leaders = const [],
    this.otherCabinets = const [],
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    // Parse banner images array
    final List<String> banners = [];
    final rawBanners = json['bannerImages'];
    if (rawBanners != null && rawBanners is List) {
      for (final b in rawBanners) {
        banners.add(b.toString());
      }
    }

    // Parse hydrated places
    PlacesToVisit? places;
    if (json['placesToVisit'] != null && json['placesToVisit'] is Map) {
      places = PlacesToVisit.fromJson(
        Map<String, dynamic>.from(json['placesToVisit'] as Map),
      );
    }

    // Parse national symbols
    List<SymbolView> symbolsList = [];
    final rawSymbols = json['symbols'];
    if (rawSymbols != null && rawSymbols is List) {
      symbolsList = rawSymbols
          .whereType<Map>()
          .map(
            (e) => SymbolView.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList();
    }

    // Safely extract leader names whether represented as String or Map
    String? parseLeader(dynamic val) {
      if (val == null) return null;
      if (val is Map) {
        return (val['name'] ?? val['title'] ?? val['leaderName'])?.toString();
      }
      return val.toString();
    }

    final parsedName = json['name']?.toString() ?? '';
    final parsedPresident = parseLeader(json['president']);
    final parsedPrimeMinister = parseLeader(json['primeMinister']);

    // Parse leaders if present in json
    List<NationalLeader> leadersList = [];
    final rawLeaders = json['leaders'] ?? json['nationalLeaders'];
    if (rawLeaders != null && rawLeaders is List) {
      for (final l in rawLeaders) {
        if (l is Map) {
          leadersList.add(NationalLeader.fromJson(Map<String, dynamic>.from(l)));
        }
      }
    }

    // Parse otherCabinets if present in json
    List<CabinetMinister> cabinetsList = [];
    final rawCabinets = json['otherCabinets'] ??
        json['otherCabinate'] ??
        json['cabinets'] ??
        json['cabinetMinisters'];
    if (rawCabinets != null && rawCabinets is List) {
      for (final c in rawCabinets) {
        if (c is Map) {
          cabinetsList.add(CabinetMinister.fromJson(Map<String, dynamic>.from(c)));
        }
      }
    }

    return CountryModel(
      id: _parseInt(json['id']) ?? 0,
      name: parsedName,
      capital: json['capital']?.toString(),
      numericCode: _parseInt(json['numericCode']),
      registrationCode: json['registrationCode']?.toString(),
      unionTerritories: _parseInt(json['unionTerritories']),
      statesCount: json['states']?.toString() ?? json['statesCount']?.toString(),
      population: json['population']?.toString(),
      president: parsedPresident,
      primeMinister: parsedPrimeMinister,
      independenceDay: json['independenceDay']?.toString(),
      nationalAnthem: json['nationalAnthem']?.toString(),
      info: json['info']?.toString(),
      cultureAndTradition: json['cultureAndTradition']?.toString(),
      economy: json['economy']?.toString(),
      bannerImages: banners,
      placesToVisit: places,
      symbols: symbolsList,
      leaders: leadersList,
      otherCabinets: cabinetsList,
    );
  }

  CountryModel copyWith({
    int? id,
    String? name,
    String? capital,
    int? numericCode,
    String? registrationCode,
    int? unionTerritories,
    String? statesCount,
    String? population,
    String? president,
    String? primeMinister,
    String? independenceDay,
    String? nationalAnthem,
    String? info,
    String? cultureAndTradition,
    String? economy,
    List<String>? bannerImages,
    PlacesToVisit? placesToVisit,
    List<SymbolView>? symbols,
    List<NationalLeader>? leaders,
    List<CabinetMinister>? otherCabinets,
  }) {
    return CountryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      capital: capital ?? this.capital,
      numericCode: numericCode ?? this.numericCode,
      registrationCode: registrationCode ?? this.registrationCode,
      unionTerritories: unionTerritories ?? this.unionTerritories,
      statesCount: statesCount ?? this.statesCount,
      population: population ?? this.population,
      president: president ?? this.president,
      primeMinister: primeMinister ?? this.primeMinister,
      independenceDay: independenceDay ?? this.independenceDay,
      nationalAnthem: nationalAnthem ?? this.nationalAnthem,
      info: info ?? this.info,
      cultureAndTradition: cultureAndTradition ?? this.cultureAndTradition,
      economy: economy ?? this.economy,
      bannerImages: bannerImages ?? this.bannerImages,
      placesToVisit: placesToVisit ?? this.placesToVisit,
      symbols: symbols ?? this.symbols,
      leaders: leaders ?? this.leaders,
      otherCabinets: otherCabinets ?? this.otherCabinets,
    );
  }
}
