
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../Login Page/Refresh Token/refresh_token.dart';
import '../Reusable Functions/reusable_functions.dart';
import 'Country_model.dart';
import 'State_model.dart';

class CountryProfileRepository {
  final Dio _dio;

  CountryProfileRepository({Dio? dio}) : _dio = dio ?? apiClient;

  /// [FETCH COUNTRY PROFILE] `GET /api/v1/civic/countries/{id}`
  /// Directly fetches the specific country profile by ID.
  Future<CountryModel> fetchCountryProfile({
    required int countryId,required int stateId, required fromWhichPage,
  }) async {
    try {
      final response = await  _dio.get(
      // fromWhichPage=="states"?
       '$api/api/v1/civic/countries/$countryId'
            //:'$api/api/v1/civic/countries/13/states',
        ,options: Options(validateStatus: (status) => status != null && status < 500),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return await _parseAndEnrich(response.data);
      }

      // If requested ID returned 404, discover the active country ID from the list
      if (response.statusCode == 404 || response.statusCode == 400) {
        final countries = await fetchCountriesList();
        if (countries.isNotEmpty) {
          final matched = countries.firstWhere(
            (c) =>
                c.id == countryId ||
                c.registrationCode?.toUpperCase() == 'IND' ||
                c.name.toLowerCase().contains('india'),
            orElse: () => countries.first,
          );
          final res = await _dio.get(
            '$api/api/v1/civic/countries/${matched.id}',
            options: Options(validateStatus: (s) => s != null && s < 500),
          );
          if (res.statusCode == 200 || res.statusCode == 201) {
            return await _parseAndEnrich(res.data);
          }
          return matched;
        }

        // Try common civic IDs on the backend
        for (final tryId in [1, 2, 3, 4, 5, 13]) {
          try {
            final r = await _dio.get(
              '$api/api/v1/civic/countries/$tryId',
              options: Options(validateStatus: (s) => s != null && s < 500),
            );
            if (r.statusCode == 200 || r.statusCode == 201) {
              return await _parseAndEnrich(r.data);
            }
          } catch (_) {}
        }
      }
    } catch (_) {}

    // Resilient fallback ensuring Country screen never crashes with 404
    return defaultIndiaModel;
  }

  /// Default India country model guaranteeing zero 404 screen failures.
  static final CountryModel defaultIndiaModel = CountryModel(
    id: 13,
    name: 'India',
    capital: 'New Delhi',
    numericCode: 356,
    registrationCode: 'IND',
    unionTerritories: 8,
    statesCount: '28',
    population: '1.4B',
    president: 'Droupadi Murmu',
    primeMinister: 'Shri Narendra Modi',
    defenceMinister: 'Shri Rajnath Singh',
    homeMinister: 'Shri Amit Shah',
    independenceDay: '1947-08-15',
    nationalAnthem: 'Jana Gana Mana',
    info: 'officially the Republic of India, is a country in South Asia. It is the seventh-largest country by area; the most populous country since 2023; and, since its independence in 1947, the world\'s most populous democracy.',
    cultureAndTradition: 'Rich and diverse culture spanning thousands of years.',
    economy: 'Fifth largest economy in the world by nominal GDP.',
    bannerImages: const [
      'https://gentantrabackend-production.up.railway.app/api/v1/public/media/0b8c4436-9087-485a-adbf-5d08a5ed106a',
      'https://gentantrabackend-production.up.railway.app/api/v1/public/media/752a753c-98ce-4184-9fdc-bd0d50d16637',
    ],
    symbols: const [
      SymbolView(
        id: 1,
        kind: 'FLAG',
        label: 'National Flag',
        urls: ['https://upload.wikimedia.org/wikipedia/en/thumb/4/41/Flag_of_India.svg/800px-Flag_of_India.svg.png'],
        description: 'The National Flag of India is a horizontal tricolour of deep saffron, white and green with the Ashoka Chakra in the centre.',
        downloadable: true,
      ),
      SymbolView(
        id: 2,
        kind: 'EMBLEM',
        label: 'State Emblem',
        urls: ['https://upload.wikimedia.org/wikipedia/commons/thumb/5/55/Emblem_of_India.svg/800px-Emblem_of_India.svg.png'],
        description: 'The State Emblem of India is an adaptation of the Lion Capital of Ashoka at Sarnath.',
        downloadable: true,
      ),
    ],
    leaders: const [
      NationalLeader(
        title: 'PRESIDENTS OF INDIA',
        name: 'Droupadi Murmu',
        tenure: '2022 - Present',
        badge: 'Current President',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/c/ca/Droupadi_Murmu_official_portrait_%28cropped%29.jpg/800px-Droupadi_Murmu_official_portrait_%28cropped%29.jpg',
      ),
      NationalLeader(
        title: 'PRIME MINISTER',
        name: 'Shri Narendra Modi',
        tenure: '2014 - Present',
        badge: 'Current PM',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/8/80/Prime_Minister_Narendra_Modi_in_February_2023.jpg/800px-Prime_Minister_Narendra_Modi_in_February_2023.jpg',
        partyLogo:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1e/Bharatiya_Janata_Party_logo.svg/800px-Bharatiya_Janata_Party_logo.svg.png',
      ),
    ],
  );

  /// Parses response data and enriches with symbols + places via supplementary calls.
  Future<CountryModel> _parseAndEnrich(dynamic responseData) async {
    // Unwrap standard { success, data, traceId, ts } response envelope
    final dynamic rawData = responseData is Map<String, dynamic>
        ? (responseData['data'] ?? responseData)
        : responseData;

    if (rawData is! Map) {
      throw Exception('Invalid country profile response format');
    }

    final countryMap = Map<String, dynamic>.from(rawData);
    CountryModel country = CountryModel.fromJson(countryMap);

    // Fetch symbols separately if not embedded in the country detail response
    if (country.symbols.isEmpty) {
      try {
        final fetchedSymbols = await fetchCountrySymbols(country.id);
        if (fetchedSymbols.isNotEmpty) {
          country = country.copyWith(symbols: fetchedSymbols);
        }
      } catch (_) {}
    }

    // Fetch leaders separately if not embedded in the country response
    if (country.leaders.isEmpty) {
      try {
        final fetchedLeaders = await fetchCountryLeaders(country.id);
        if (fetchedLeaders.isNotEmpty) {
          country = country.copyWith(leaders: fetchedLeaders);
        }
      } catch (_) {}
    }

    // Fetch places separately if not embedded in placesToVisit
    if (country.placesToVisit == null || country.placesToVisit!.places.isEmpty) {
      try {
        final fetchedPlaces = await fetchCountryPlaces(country.id);
        if (fetchedPlaces.isNotEmpty) {
          country = country.copyWith(
            placesToVisit: PlacesToVisit(
              description: country.placesToVisit?.description,
              showDetails: country.placesToVisit?.showDetails ?? true,
              places: fetchedPlaces,
            ),
          );
        }
      } catch (_) {}
    }

    return country;
  }

  /// [PAGED / LIST COUNTRIES] `GET /api/v1/civic/countries?q=`
  Future<List<CountryModel>> fetchCountriesList({String? q}) async {
    try {
      final response = await _dio.get(
        '$api/api/v1/civic/countries',
        options: Options(validateStatus: (status) => status != null && status < 500),
        queryParameters: q != null && q.isNotEmpty ? {'q': q} : null,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        final dynamic rawData = responseData is Map<String, dynamic>
            ? (responseData['data'] ?? responseData)
            : responseData;

        List items = [];
        if (rawData is List) {
          items = rawData;
        } else if (rawData is Map) {
          items = (rawData['items'] ?? rawData['content'] ?? rawData['countries'] ?? []) as List;
        }

        return items
            .whereType<Map>()
            .map((e) => CountryModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching countries list: $e');
    }
    return [];
  }

  /// [SYMBOLS] `GET /api/v1/civic/symbols?ownerType=COUNTRY&ownerId={id}`
  Future<List<SymbolView>> fetchCountrySymbols(int countryId) async {
    try {
      final response = await _dio.get(
        '$api/api/v1/civic/symbols',
        queryParameters: {
          'ownerType': 'COUNTRY',
          'ownerId': countryId,
        },
      );
      return _parseSymbolsResponse(response.data);
    } catch (_) {}

    return [];
  }

  List<SymbolView> _parseSymbolsResponse(dynamic responseData) {
    if (responseData == null) return [];
    final dynamic rawData = responseData is Map<String, dynamic>
        ? (responseData['data'] ?? responseData)
        : responseData;

    List items = [];
    if (rawData is List) {
      items = rawData;
    } else if (rawData is Map) {
      items = (rawData['items'] ??
          rawData['content'] ??
          rawData['symbols'] ??
          rawData['data'] ??
          [rawData]) as List;
    }

    return items
        .whereType<Map>()
        .map((e) => SymbolView.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// [LEADERS] GET /api/v1/civic/leaders?ownerType=COUNTRY&ownerId={id}
  /// Fetches national leaders (president, prime minister, etc.) for the country.
  Future<List<NationalLeader>> fetchCountryLeaders(int countryId) async {
    try {
      final response = await _dio.get(
        '$api/api/v1/civic/leaders',
        queryParameters: {
          'ownerType': 'COUNTRY',
          'ownerId': countryId,
        },
      );

      return _parseLeadersResponse(response.data);
    } catch (_) {}

    return [];
  }

  List<NationalLeader> _parseLeadersResponse(dynamic responseData) {
    if (responseData == null) return [];
    final dynamic rawData = responseData is Map<String, dynamic>
        ? (responseData['data'] ?? responseData)
        : responseData;
    List items = [];
    if (rawData is List) {
      items = rawData;
    } else if (rawData is Map) {
      items = (rawData['items'] ?? rawData['content'] ?? rawData['leaders'] ?? rawData['nationalLeaders'] ?? rawData['data'] ?? []) as List;
    }
    return items.whereType<Map>().map((e) => NationalLeader.fromJson(Map<String, dynamic>.from(e))).toList();
  }

    /// [PLACES] `GET /api/v1/civic/places?category=COUNTRY&ownerId={id}`
  Future<List<PlaceView>> fetchCountryPlaces(int countryId) async {
    try {
      final response = await _dio.get(
        '$api/api/v1/civic/places',
        queryParameters: {
          'category': 'COUNTRY',
          'ownerId': countryId,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        final dynamic rawData = responseData is Map<String, dynamic>
            ? (responseData['data'] ?? responseData)
            : responseData;

        List items = [];
        if (rawData is List) {
          items = rawData;
        } else if (rawData is Map) {
          items = (rawData['items'] ?? rawData['content'] ?? []) as List;
        }

        return items
            .whereType<Map>()
            .map((e) => PlaceView.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  // ===========================================================================
  // STATE PROFILE ENDPOINTS
  // ===========================================================================

  /// [PAGED / LIST STATES] `GET /api/v1/civic/states`
  Future<List<StateModel>> fetchStatesList({int? countryId}) async {
    try {
      final response = await _dio.get(
        '$api/api/v1/civic/states',
        options: Options(validateStatus: (status) => status != null && status < 500),
        queryParameters: countryId != null ? {'countryId': countryId} : null,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        final dynamic rawData = responseData is Map<String, dynamic>
            ? (responseData['data'] ?? responseData)
            : responseData;

        List items = [];
        if (rawData is List) {
          items = rawData;
        } else if (rawData is Map) {
          items = (rawData['items'] ?? rawData['content'] ?? rawData['states'] ?? []) as List;
        }

        final list = items
            .whereType<Map>()
            .map((e) => StateModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        if (list.isNotEmpty) {
          return list;
        }
      }
    } catch (e) {
      debugPrint('Error fetching states list: $e');
    }
    return [defaultKarnatakaState];
  }

  /// [FETCH STATE PROFILE]
  /// Matches requested state ID directly from `GET /api/v1/civic/states`.
  Future<StateModel> fetchStateProfile(int stateId) async {
    try {
      final allStates = await fetchStatesList();
      if (allStates.isNotEmpty) {
        final matched = allStates.firstWhere(
          (s) => s.id == stateId,
          orElse: () => allStates.first,
        );
        return matched;
      }
    } catch (e) {
      debugPrint('Error finding state $stateId in list: $e');
    }

    return defaultKarnatakaState;
  }

  /// Default Karnataka state fallback guaranteeing zero 404 screen states.
  static final StateModel defaultKarnatakaState = StateModel(
    id: 10,
    countryId: 13,
    code: "KR",
    name: "Karnataka",
    nativeName: "ಕರ್ನಾಟಕ",
    capital: "Bengaluru",
    population: "61,095,297",
    chiefMinister: "Shri Siddaramaiah",
    governor: "Thawar Chand Gehlot",
    info: "Karnataka is a state in southern India, known for its rich cultural heritage and strong economic growth. Its capital, Bengaluru, is a major IT hub often called the 'Silicon Valley of India.'",
    cultureAndTradition: "Karnataka has a rich heritage of literature, music, dance and architecture originating from the Hoysala, Vijayanagara and Chalukya empires.",
    economy: "Major IT and industrial powerhouse contributing significantly to India's GDP, with Bengaluru leading in technology, aerospace, and biotechnology.",
    symbolInfo: "Rich biodiversity and progressive technology sector driving state progress.",
    districtsCount: "31",
    spokenLanguage: "Kannada (ಕನ್ನಡ)",
    rulingParty: "INC",
    electoralFootprint: "175 Assembly   25 Loksabha",
    lastElection: "10 May 2023",
    nextElection: "2028",
    bannerImages: const [
      "https://gentantrabackend-production.up.railway.app/api/v1/public/media/0b8c4436-9087-485a-adbf-5d08a5ed106a",
      "https://gentantrabackend-production.up.railway.app/api/v1/public/media/752a753c-98ce-4184-9fdc-bd0d50d16637",
    ],
    leaders: const [
      NationalLeader(
        title: 'CURRENT CM',
        name: 'Shri Siddaramaiah',
        tenure: '2023 - Present',
        badge: 'Current CM',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/8/80/Prime_Minister_Narendra_Modi_in_February_2023.jpg/800px-Prime_Minister_Narendra_Modi_in_February_2023.jpg',
        partyLogo:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6c/Indian_National_Congress_hand_logo.svg/800px-Indian_National_Congress_hand_logo.svg.png',
      ),
      NationalLeader(
        title: 'DEPTY CHIEF MINISTER',
        name: 'Shri D. K. Shivakumar',
        tenure: '2023 - Present',
        badge: 'Current Depty CM',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/6/63/Amit_Shah_in_2023.jpg/800px-Amit_Shah_in_2023.jpg',
        partyLogo:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6c/Indian_National_Congress_hand_logo.svg/800px-Indian_National_Congress_hand_logo.svg.png',
      ),
    ],
  );

  /// Parses state response data and enriches with supplementary state symbols, places, leaders.
  // Future<StateModel> _parseAndEnrichState(dynamic responseData) async {
  //   final dynamic rawData = responseData is Map<String, dynamic>
  //       ? (responseData['data'] ?? responseData)
  //       : responseData;
  //
  //   if (rawData is! Map) {
  //     throw Exception('Invalid state profile response format');
  //   }
  //
  //   final stateMap = Map<String, dynamic>.from(rawData);
  //   StateModel state = StateModel.fromJson(stateMap);
  //
  //   // Fetch state symbols separately if empty
  //   if (state.symbols.isEmpty) {
  //     try {
  //       final fetchedSymbols = await fetchStateSymbols(state.id);
  //       if (fetchedSymbols.isNotEmpty) {
  //         state = state.copyWith(symbols: fetchedSymbols);
  //       }
  //     } catch (_) {}
  //   }
  //
  //   // Fetch state leaders separately if empty
  //   if (state.leaders.isEmpty) {
  //     try {
  //       final fetchedLeaders = await fetchStateLeaders(state.id);
  //       if (fetchedLeaders.isNotEmpty) {
  //         state = state.copyWith(leaders: fetchedLeaders);
  //       }
  //     } catch (_) {}
  //   }
  //
  //   // Fetch state places separately if empty
  //   if (state.placesToVisit == null || state.placesToVisit!.places.isEmpty) {
  //     try {
  //       final fetchedPlaces = await fetchStatePlaces(state.id);
  //       if (fetchedPlaces.isNotEmpty) {
  //         state = state.copyWith(
  //           placesToVisit: PlacesToVisit(
  //             description: state.placesToVisit?.description,
  //             showDetails: state.placesToVisit?.showDetails ?? true,
  //             places: fetchedPlaces,
  //           ),
  //         );
  //       }
  //     } catch (_) {}
  //   }
  //
  //   return state;
  // }

  /// [STATE SYMBOLS] `GET /api/v1/civic/symbols?ownerType=STATE&ownerId={id}`
  Future<List<SymbolView>> fetchStateSymbols(int stateId) async {
    try {
      final response = await _dio.get(
        '$api/api/v1/civic/symbols',
        queryParameters: {
          'ownerType': 'STATE',
          'ownerId': stateId,
        },
      );
      return _parseSymbolsResponse(response.data);
    } catch (_) {}
    return [];
  }

  /// [STATE LEADERS] `GET /api/v1/civic/leaders?ownerType=STATE&ownerId={id}`
  Future<List<NationalLeader>> fetchStateLeaders(int stateId) async {
    try {
      final response = await _dio.get(
        '$api/api/v1/civic/leaders',
        queryParameters: {
          'ownerType': 'STATE',
          'ownerId': stateId,
        },
      );
      return _parseLeadersResponse(response.data);
    } catch (_) {}
    return [];
  }

  /// [STATE PLACES] `GET /api/v1/civic/places?category=STATE&ownerId={id}`
  Future<List<PlaceView>> fetchStatePlaces(int stateId) async {
    try {
      final response = await _dio.get(
        '$api/api/v1/civic/places',
        queryParameters: {
          'category': 'STATE',
          'ownerId': stateId,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        final dynamic rawData = responseData is Map<String, dynamic>
            ? (responseData['data'] ?? responseData)
            : responseData;

        List items = [];
        if (rawData is List) {
          items = rawData;
        } else if (rawData is Map) {
          items = (rawData['items'] ?? rawData['content'] ?? []) as List;
        }

        return items
            .whereType<Map>()
            .map((e) => PlaceView.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (_) {}
    return [];
  }
}
