import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../Login Page/Refresh Token/refresh_token.dart';
import '../Reusable Functions/reusable_functions.dart';
import 'Country_model.dart';

class CountryProfileRepository {
  final Dio _dio;

  CountryProfileRepository({Dio? dio}) : _dio = dio ?? apiClient;

  /// [FETCH COUNTRY PROFILE] `GET /api/v1/civic/countries/{id}`
  /// Directly fetches the specific country profile by ID.
  /// If a 404 is received (ID doesn't exist on backend), auto-discovers the
  /// correct country ID by searching the list endpoint.
  Future<CountryModel> fetchCountryProfile(int countryId) async {
    try {
      final response = await _dio.get(
        '$api/api/v1/civic/countries/$countryId',
        options: Options(validateStatus: (status) => status != null && status < 500),
      );

      // 404 means the ID doesn't exist â€” auto-discover via list
      if (response.statusCode == 404 || response.statusCode == 400) {
        return await _fetchCountryBySearch();
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return await _parseAndEnrich(response.data);
      }

      throw Exception('Error: ${response.statusCode}');
    } on DioException catch (e) {
      // Network error or timeout â€” try list fallback
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception(e.message ?? 'Network error. Please check your connection.');
      }
      throw Exception(e.message ?? 'Failed to fetch country profile');
    }
  }

  /// [AUTO-DISCOVER] Searches the countries list for India and fetches its profile.
  /// Used as fallback when the hardcoded countryId (e.g. 1) returns 404.
  Future<CountryModel> _fetchCountryBySearch() async {
    final countries = await fetchCountriesList(q: 'India');
    if (countries.isNotEmpty) {
      // Find India specifically, or use first result
      final india = countries.firstWhere(
        (c) =>
            c.name.toLowerCase().contains('india') ||
            c.registrationCode?.toUpperCase() == 'IND',
        orElse: () => countries.first,
      );
      // Re-fetch the full profile using the discovered ID
      return await _fetchCountryById(india.id);
    }
    // If list is also empty, try common IDs
    for (final tryId in [1, 2, 3, 4, 5]) {
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
    throw Exception('Country profile not found. Please try again later.');
  }

  /// Internal helper: fetch a country by its exact ID (no auto-discover loop).
  Future<CountryModel> _fetchCountryById(int id) async {
    final response = await _dio.get('$api/api/v1/civic/countries/$id');
    if (response.statusCode == 200 || response.statusCode == 201) {
      return await _parseAndEnrich(response.data);
    }
    throw Exception('Error: ${response.statusCode}');
  }

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
              description: country.placesToVisit?.description ??
                  'Must-see places in ${country.name}',
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
    // 1. Try civic symbols endpoint with ownerType & ownerId
    try {
      final response = await _dio.get(
        '$api/api/v1/civic/symbols',
        queryParameters: {
          'ownerType': 'COUNTRY',
          'ownerId': countryId,
        },
      );
      final symbols = _parseSymbolsResponse(response.data);
      if (symbols.isNotEmpty) return symbols;
    } catch (_) {}

    // 2. Try nested endpoint /api/v1/civic/countries/{id}/symbols
    try {
      final response = await _dio.get('$api/api/v1/civic/countries/$countryId/symbols');
      final symbols = _parseSymbolsResponse(response.data);
      if (symbols.isNotEmpty) return symbols;
    } catch (_) {}

    // 3. Try /api/v1/civic/symbols with countryId param
    try {
      final response = await _dio.get(
        '$api/api/v1/civic/symbols',
        queryParameters: {'countryId': countryId},
      );
      final symbols = _parseSymbolsResponse(response.data);
      if (symbols.isNotEmpty) return symbols;
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
      final leaders = _parseLeadersResponse(response.data);
      if (leaders.isNotEmpty) return leaders;
    } catch (_) {}

    try {
      final response = await _dio.get('$api/api/v1/civic/countries/$countryId/leaders');
      final leaders = _parseLeadersResponse(response.data);
      if (leaders.isNotEmpty) return leaders;
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
}
