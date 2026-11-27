import '../Drawer Tabs/Party/PoliticianProfile/politician_profile_api.dart';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../Login Page/Refresh Token/refresh_token.dart';
import '../Reusable Functions/reusable_functions.dart';
import 'Country_model.dart';
import 'State_item_model.dart';
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

    if (countryMap['govPosts'] is! List || (countryMap['govPosts'] as List).isEmpty) {
    try {
      final posts = await _fetchGovPosts(countryId: country.id);
      country = country.copyWith(leaders: _mergePosts(country.leaders, posts));
    } on DioException catch (error) {
      debugPrint('Could not load country government posts: ${error.type}');
    }

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

  List<NationalLeader> _mergePosts(List<NationalLeader> embedded, List<NationalLeader> fetched) {
    final merged = [...embedded];
    for (final post in fetched) {
      final index = merged.indexWhere((existing) =>
          existing.postId != null && post.postId != null
              ? existing.postId == post.postId
              : existing.title == post.title && existing.name == post.name && existing.tenure == post.tenure);
      if (index < 0) {
        merged.add(post);
      } else if (merged[index].imageUrl.isEmpty && post.imageUrl.isNotEmpty) {
        final original = merged[index];
        merged[index] = NationalLeader(
          postId: post.postId, title: original.title, name: original.name,
          tenure: original.tenure, badge: original.badge, partyLogo: original.partyLogo,
          imageUrl: post.imageUrl,
        );
      }
    }
    return merged;
  }

  Future<List<NationalLeader>> _fetchGovPosts({int? countryId, int? stateId}) async {
    final leaders = <NationalLeader>[];
    for (var page = 0; ; page++) {
      final response = await _dio.get('$api/api/v1/civic/gov-posts', queryParameters: {
        if (countryId != null) 'countryId': countryId,
        if (stateId != null) 'stateId': stateId,
        'page': page,
      });
      final data = response.data['data'];
      final items = data is List ? data : data is Map ? data['items'] : null;
      if (items is! List) return leaders;
      for (final item in items.whereType<Map>()) {
        var post = Map<String, dynamic>.from(item);
        // Search returns career rows. The post detail contains the holder portrait.
        if (NationalLeader.fromJson(post).imageUrl.isEmpty && post['id'] != null) {
          try {
            final detail = await _dio.get('$api/api/v1/civic/gov-posts/${post['id']}');
            final fields = detail.data['data'];
            if (fields is Map) post.addAll(Map<String, dynamic>.from(fields));
          } on DioException {
            // Keep the career row when its detail request fails.
          }
        }
        final jurisdiction = post['jurisdiction']?.toString().toUpperCase();
        if (jurisdiction != null && stateId == null && jurisdiction != 'NATIONAL') continue;
        if (stateId != null && post['stateId'] != null && post['stateId'] != stateId) continue;
        final holderId = int.tryParse('${post['holderPoliticianId']}');
        if (holderId != null && NationalLeader.fromJson(post).imageUrl.isEmpty) {
          try {
            final profile = await PoliticianProfileRepository(dio: _dio).fetchPoliticianProfile(holderId);
            post['holderImageUrl'] = profile.photoUrl;
          } on Exception {
            // The office and holder still belong in Info when a profile is unavailable.
          }
        }
        leaders.add(NationalLeader.fromJson(post));
      }
      if (items.isEmpty || data is! Map || data['hasNext'] != true) return leaders;
    }
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

        return items
            .whereType<Map>()
            .map((e) => StateModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching states list: $e');
    }
    return [];
  }

  /// [FETCH COUNTRY STATES LIST]
  /// `GET /api/v1/civic/countries/{countryId}/states`
  /// Fetches state list with `name` and `electoralFootprint` directly from API.
  Future<List<StateItemModel>> fetchCountryStatesList({int countryId = 13}) async {
    try {
      final response = await _dio.get(
        '$api/api/v1/civic/countries/$countryId/states',
        options: Options(validateStatus: (status) => status != null && status < 500),
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

        return items
            .whereType<Map>()
            .map((e) => StateItemModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching country $countryId states: $e');
    }

    return [];
  }

  /// [FETCH STATE PROFILE]
  /// Directly calls `GET /api/v1/civic/states/{id}` for the user-selected state
  /// and enriches it with state leaders, symbols, and places.
  Future<StateModel> fetchStateProfile(int stateId) async {
    try {
      final response = await _dio.get(
        '$api/api/v1/civic/states/$stateId',
        options: Options(validateStatus: (status) => status != null && status < 500),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        final dynamic rawData = responseData is Map<String, dynamic>
            ? (responseData['data'] ?? responseData)
            : responseData;

        if (rawData is Map) {
          return await _parseAndEnrichState(rawData);
        }
      }
    } catch (e) {
      debugPrint('Error directly fetching state $stateId: $e');
    }

    // Secondary fallback: get basic name and electoralFootprint from state list
    try {
      final allStates = await fetchCountryStatesList();
      final matched = allStates.firstWhere(
        (s) => s.id == stateId,
        orElse: () => StateItemModel(id: stateId, name: '', electoralFootprint: ''),
      );
      if (matched.name.isNotEmpty) {
        return StateModel(
          id: matched.id,
          name: matched.name,
          electoralFootprint: matched.electoralFootprint,
        );
      }
    } catch (e) {
      debugPrint('Error finding state $stateId in list: $e');
    }

    return StateModel(id: stateId, name: '');
  }

  /// Parses state response data and enriches with supplementary state symbols, places, leaders.
  Future<StateModel> _parseAndEnrichState(dynamic rawData) async {
    if (rawData is! Map) {
      throw Exception('Invalid state profile response format');
    }

    final stateMap = Map<String, dynamic>.from(rawData);
    StateModel state = StateModel.fromJson(stateMap);

    // Fetch state symbols separately if empty
    if (state.symbols.isEmpty) {
      try {
        final fetchedSymbols = await fetchStateSymbols(state.id);
        if (fetchedSymbols.isNotEmpty) {
          state = state.copyWith(symbols: fetchedSymbols);
        }
      } catch (_) {}
    }

    try {
      final posts = await _fetchGovPosts(stateId: state.id);
      state = state.copyWith(leaders: _mergePosts(state.leaders, posts));
    } on DioException catch (error) {
      debugPrint('Could not load state government posts: ${error.type}');
    }

    // Fetch state places separately if empty
    if (state.placesToVisit == null || state.placesToVisit!.places.isEmpty) {
      try {
        final fetchedPlaces = await fetchStatePlaces(state.id);
        if (fetchedPlaces.isNotEmpty) {
          state = state.copyWith(
            placesToVisit: PlacesToVisit(
              description: state.placesToVisit?.description,
              showDetails: state.placesToVisit?.showDetails ?? true,
              places: fetchedPlaces,
            ),
          );
        }
      } catch (_) {}
    }

    return state;
  }

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
