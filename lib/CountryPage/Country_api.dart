// Country Profile API Repository
// Manages networking for Country Profile, Places, and Symbols endpoints.
// Endpoints relative to `/api/v1/civic/`.

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

      // 404 means the ID doesn't exist — auto-discover via list
      if (response.statusCode == 404 || response.statusCode == 400) {
        return await _fetchCountryBySearch();
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return await _parseAndEnrich(response.data);
      }

      throw Exception('Error: ${response.statusCode}');
    } on DioException catch (e) {
      // Network error or timeout — try list fallback
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
    try {
      final response = await _dio.get(
        '$api/api/v1/civic/symbols',
        queryParameters: {
          'ownerType': 'COUNTRY',
          'ownerId': countryId,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        final dynamic rawData = responseData is Map<String, dynamic>
            ? (responseData['data'] ?? responseData)
            : responseData;

        if (rawData is List) {
          return rawData
              .whereType<Map>()
              .map((e) => SymbolView.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }

        if (rawData is Map) {
          final items = rawData['items'] ?? rawData['content'] ?? rawData['data'];
          if (items is List) {
            return items
                .whereType<Map>()
                .map((e) => SymbolView.fromJson(Map<String, dynamic>.from(e)))
                .toList();
          }
        }
      }
    } catch (_) {}
    return [];
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
