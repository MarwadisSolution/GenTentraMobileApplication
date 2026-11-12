import 'package:flutter/material.dart';

/// [DEFENSIVE PARSER] Safely parses integers whether returned as `num` or `String`.
/// Prevents runtime cast exceptions if the API returns stringified IDs or counts.
int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim());
  return null;
}

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
    String parseImg(dynamic raw) {
      if (raw == null) return '';
      if (raw is String) return raw.trim();
      if (raw is Map) {
        return (raw['url'] ?? raw['imageUrl'] ?? raw['photoUrl'] ?? raw['path'])?.toString().trim() ?? '';
      }
      return raw.toString().trim();
    }

    final rawImage = json['imageUrl'] ??
        json['photoUrl'] ??
        json['imagePath'] ??
        json['mediaUrl'] ??
        json['photo'] ??
        json['image'] ??
        json['picture'] ??
        json['profileUrl'] ??
        json['avatar'];

    final String name = (json['name'] ??
            json['leaderName'] ??
            json['personName'] ??
            json['fullName'] ??
            json['ministerName'] ??
            ((json['firstName'] != null)
                ? "${json['firstName']} ${json['lastName'] ?? ''}".trim()
                : ''))
        .toString()
        .trim();

    final String title = (json['title'] ??
            json['designation'] ??
            json['role'] ??
            json['position'] ??
            json['category'] ??
            json['type'] ??
            '')
        .toString()
        .trim();

    final String badge = (json['badge'] ??
            json['tag'] ??
            json['label'] ??
            (title.isNotEmpty ? title : ''))
        .toString()
        .trim();

    return NationalLeader(
      title: title,
      name: name,
      tenure: (json['tenure'] ?? json['term'] ?? json['period'] ?? json['duration'] ?? '').toString().trim(),
      badge: badge,
      imageUrl: parseImg(rawImage),
      partyLogo: (json['partyLogo'] ?? json['partyImage'] ?? json['partySymbol'])?.toString().trim(),
    );
  }
}

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

    String parseImg(dynamic raw) {
      if (raw == null) return '';
      if (raw is String) return raw.trim();
      if (raw is Map) {
        return (raw['url'] ?? raw['imageUrl'] ?? raw['photoUrl'] ?? raw['path'])?.toString().trim() ?? '';
      }
      return raw.toString().trim();
    }

    final rawImage = json['imageUrl'] ??
        json['photoUrl'] ??
        json['imagePath'] ??
        json['mediaUrl'] ??
        json['photo'] ??
        json['image'] ??
        json['picture'] ??
        json['profileUrl'] ??
        json['avatar'];

    String first = (json['firstName'] ?? json['name'] ?? json['ministerName'] ?? '').toString().trim();
    String last = (json['lastName'] ?? json['surname'] ?? '').toString().trim();
    if (last.isEmpty && first.contains(' ')) {
      final parts = first.split(' ');
      first = parts.first;
      last = parts.sublist(1).join(' ');
    }

    return CabinetMinister(
      firstName: first,
      lastName: last,
      imageUrl: parseImg(rawImage),
      backgroundColor: parseColor(json['backgroundColor']),
    );
  }
}

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

/// returned by `/api/v1/civic/symbols`.
class SymbolView {
  final int id;
  final String? ownerType; // 'COUNTRY', 'STATE', 'PARTY', 'CONSTITUENCY'
  final int? ownerId;
  final String? kind; // 'FLAG', 'MAP', 'EMBLEM', 'SYMBOL', 'LOGO'
  final List<String> urls;
  final String? label;
  final String? description;
  final bool isDefault;
  final bool downloadable;

  const SymbolView({
    required this.id,
    this.ownerType,
    this.ownerId,
    this.kind,
    this.urls = const [],
    this.label,
    this.description,
    this.isDefault = false,
    this.downloadable = false,
  });

  SymbolView copyWith({
    int? id,
    String? ownerType,
    int? ownerId,
    String? kind,
    List<String>? urls,
    String? label,
    String? description,
    bool? isDefault,
    bool? downloadable,
  }) {
    return SymbolView(
      id: id ?? this.id,
      ownerType: ownerType ?? this.ownerType,
      ownerId: ownerId ?? this.ownerId,
      kind: kind ?? this.kind,
      urls: urls ?? this.urls,
      label: label ?? this.label,
      description: description ?? this.description,
      isDefault: isDefault ?? this.isDefault,
      downloadable: downloadable ?? this.downloadable,
    );
  }

  factory SymbolView.fromJson(Map<String, dynamic> json) {
    List<String> urlsList = [];
    final rawUrls = json['urls'] ??
        json['partyLogo'] ??
        json['images'] ??
        json['url'] ??
        json['symbolUrl'] ??
        json['imageUrl'] ??
        json['flagUrl'] ??
        json['emblemUrl'] ??
        json['mediaUrl'];
    if (rawUrls != null && rawUrls is List) {
      urlsList = rawUrls.map((e) => e.toString()).toList();
    } else if (rawUrls is String && rawUrls.isNotEmpty) {
      urlsList = [rawUrls];
    }

    final rawDesc = json['description'] ??
        json['logoDescription'] ??
        json['details'] ??
        json['info'] ??
        json['content'];
    final rawLabel = json['label'] ??
        json['name'] ??
        json['title'] ??
        json['symbolName'];

    String? parsedLabel;
    String? parsedDesc;

    if (rawDesc != null && rawDesc.toString().isNotEmpty) {
      parsedDesc = rawDesc.toString();
      parsedLabel = rawLabel?.toString();
    } else if (rawLabel != null) {
      final labelStr = rawLabel.toString();
      // If label is long paragraph, treat as description
      if (labelStr.length > 50 || labelStr.contains('\n')) {
        parsedDesc = labelStr;
        parsedLabel = json['kind']?.toString() ?? json['type']?.toString();
      } else {
        parsedLabel = labelStr;
      }
    }

    return SymbolView(
      id: _parseInt(json['id']) ?? 0,
      ownerType: json['ownerType']?.toString(),
      ownerId: _parseInt(json['ownerId']),
      kind: (json['kind'] ?? json['type'] ?? json['category'])?.toString(),
      urls: urlsList,
      label: parsedLabel,
      description: parsedDesc,
      isDefault: _parseBool(json['isDefault'], defaultValue: false),
      downloadable: _parseBool(
        json['downloadable'] ?? json['downloadEnabled'],
        defaultValue: false,
      ),
    );
  }
}

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
  final String? area;
  final String? geographicDescription;
  final String? president;
  final String? primeMinister;
  final String? defenceMinister;
  final String? homeMinister;
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
    this.area,
    this.geographicDescription,
    this.president,
    this.primeMinister,
    this.defenceMinister,
    this.homeMinister,
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
    final rawSymbols = json['symbols'] ?? json['symbol'] ?? json['nationalSymbols'];
    if (rawSymbols != null && rawSymbols is List) {
      symbolsList = rawSymbols
          .whereType<Map>()
          .map(
            (e) => SymbolView.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList();
    } else if (rawSymbols != null && rawSymbols is Map) {
      final items = rawSymbols['items'] ??
          rawSymbols['content'] ??
          rawSymbols['symbols'] ??
          rawSymbols['data'] ??
          [rawSymbols];
      if (items is List) {
        symbolsList = items
            .whereType<Map>()
            .map((e) => SymbolView.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    }

    // Direct flag / emblem fallback in json if symbols array wasn't provided
    if (symbolsList.isEmpty) {
      final flagUrl = (json['flagUrl'] ?? (json['flag'] is Map ? json['flag']['url'] : json['flag']))?.toString();
      if (flagUrl != null && flagUrl.isNotEmpty) {
        symbolsList.add(SymbolView(
          id: 1,
          kind: 'FLAG',
          label: json['flagTitle']?.toString() ?? 'Flag',
          urls: [flagUrl],
          description: json['flagDescription']?.toString() ?? json['flagDesc']?.toString(),
          downloadable: true,
        ));
      }
      final emblemUrl = (json['emblemUrl'] ?? (json['emblem'] is Map ? json['emblem']['url'] : json['emblem']))?.toString();
      if (emblemUrl != null && emblemUrl.isNotEmpty) {
        symbolsList.add(SymbolView(
          id: 2,
          kind: 'EMBLEM',
          label: json['emblemTitle']?.toString() ?? 'Emblem',
          urls: [emblemUrl],
          description: json['emblemDescription']?.toString() ?? json['emblemDesc']?.toString(),
          downloadable: true,
        ));
      }
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
      area: json['area']?.toString() ??
          json['totalArea']?.toString() ??
          json['geographicArea']?.toString() ??
          json['areaSqKm']?.toString(),
      geographicDescription: json['geographicDescription']?.toString() ??
          json['geography']?.toString() ??
          json['geographic']?.toString() ??
          json['geoDescription']?.toString() ??
          json['geographyDescription']?.toString() ??
          json['geographicInfo']?.toString(),
      president: parsedPresident,
      primeMinister: parsedPrimeMinister,
      defenceMinister: parsedDefenceMinister,
      homeMinister: parsedHomeMinister,
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
    String? area,
    String? geographicDescription,
    String? president,
    String? primeMinister,
    String? defenceMinister,
    String? homeMinister,
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
      area: area ?? this.area,
      geographicDescription: geographicDescription ?? this.geographicDescription,
      president: president ?? this.president,
      primeMinister: primeMinister ?? this.primeMinister,
      defenceMinister: defenceMinister ?? this.defenceMinister,
      homeMinister: homeMinister ?? this.homeMinister,
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
