import 'package:flutter/material.dart';
import 'Country_model.dart';

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim());
  return null;
}

/// [STATE PROFILE MODEL]
/// Defines data structures for State screens matching `GET /api/v1/civic/states`.
class StateModel {
  final int id;
  final int? countryId;
  final String? code;
  final String name;
  final String? nativeName;
  final String? capital;
  final String? population;
  final String? chiefMinister;
  final String? governor;
  final String? info;
  final String? cultureAndTradition;
  final String? economy;
  final String? symbolInfo;
  final String? districtsCount;
  final String? spokenLanguage;
  final String? rulingParty;
  final String? electoralFootprint;
  final String? lastElection;
  final String? nextElection;
  final List<String> bannerImages;
  final PlacesToVisit? placesToVisit;
  final List<SymbolView> symbols;
  final List<dynamic> geographies;
  final List<NationalLeader> leaders;
  final List<CabinetMinister> otherCabinets;
  final int favouriteCount;

  const StateModel({
    required this.id,
    this.countryId,
    this.code,
    required this.name,
    this.nativeName,
    this.capital,
    this.population,
    this.chiefMinister,
    this.governor,
    this.info,
    this.cultureAndTradition,
    this.economy,
    this.symbolInfo,
    this.districtsCount,
    this.spokenLanguage,
    this.rulingParty,
    this.electoralFootprint,
    this.lastElection,
    this.nextElection,
    this.bannerImages = const [],
    this.placesToVisit,
    this.symbols = const [],
    this.geographies = const [],
    this.leaders = const [],
    this.otherCabinets = const [],
    this.favouriteCount = 0,
  });

  factory StateModel.fromJson(Map<String, dynamic> json) {
    // Parse banner images array
    final List<String> banners = [];
    final rawBanners = json['bannerImages'];
    if (rawBanners != null && rawBanners is List) {
      for (final b in rawBanners) {
        if (b != null && b.toString().trim().isNotEmpty) {
          banners.add(b.toString().trim());
        }
      }
    }

    // Parse places
    PlacesToVisit? places;
    if (json['placesToVisit'] != null && json['placesToVisit'] is Map) {
      places = PlacesToVisit.fromJson(
        Map<String, dynamic>.from(json['placesToVisit'] as Map),
      );
    }

    // Parse symbols
    List<SymbolView> symbolsList = [];
    final rawSymbols = json['symbols'] ?? json['symbol'];
    if (rawSymbols != null && rawSymbols is List) {
      symbolsList = rawSymbols
          .whereType<Map>()
          .map((e) => SymbolView.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    // Parse leaders
    List<NationalLeader> leadersList = [];
    final rawLeaders = json['leaders'] ?? json['stateLeaders'] ?? json['nationalLeaders'];
    if (rawLeaders != null && rawLeaders is List) {
      for (final l in rawLeaders) {
        if (l is Map) {
          leadersList.add(NationalLeader.fromJson(Map<String, dynamic>.from(l)));
        }
      }
    }

    // Parse other cabinets
    List<CabinetMinister> cabinetsList = [];
    final rawCabinets = json['otherCabinets'] ??
        json['otherCabinate'] ??
        json['cabinets'] ??
        json['cabinetMinisters'] ??
        json['currentMinisters'];
    if (rawCabinets != null && rawCabinets is List) {
      for (final c in rawCabinets) {
        if (c is Map) {
          cabinetsList.add(CabinetMinister.fromJson(Map<String, dynamic>.from(c)));
        }
      }
    }

    final rawName = json['name']?.toString().trim() ?? '';

    return StateModel(
      id: _parseInt(json['id']) ?? 0,
      countryId: _parseInt(json['countryId']),
      code: json['code']?.toString().trim(),
      name: rawName,
      nativeName: json['nativeName']?.toString().trim(),
      capital: json['capital']?.toString().trim(),
      population: json['population']?.toString().trim(),
      chiefMinister: json['chiefMinister']?.toString().trim(),
      governor: json['governor']?.toString().trim(),
      info: json['info']?.toString().trim(),
      cultureAndTradition: json['cultureAndTradition']?.toString().trim(),
      economy: json['economy']?.toString().trim(),
      symbolInfo: json['symbolInfo']?.toString().trim(),
      districtsCount: json['districtsCount']?.toString().trim() ?? json['districts']?.toString().trim(),
      spokenLanguage: json['spokenLanguage']?.toString().trim() ?? json['language']?.toString().trim(),
      rulingParty: json['rulingParty']?.toString().trim() ?? json['party']?.toString().trim(),
      electoralFootprint: json['electoralFootprint']?.toString().trim(),
      lastElection: json['lastElection']?.toString().trim(),
      nextElection: json['nextElection']?.toString().trim(),
      bannerImages: banners,
      placesToVisit: places,
      symbols: symbolsList,
      geographies: json['geographies'] is List ? (json['geographies'] as List) : const [],
      leaders: leadersList,
      otherCabinets: cabinetsList,
      favouriteCount: _parseInt(json['favouriteCount']) ?? 0,
    );
  }

  StateModel copyWith({
    int? id,
    int? countryId,
    String? code,
    String? name,
    String? nativeName,
    String? capital,
    String? population,
    String? chiefMinister,
    String? governor,
    String? info,
    String? cultureAndTradition,
    String? economy,
    String? symbolInfo,
    String? districtsCount,
    String? spokenLanguage,
    String? rulingParty,
    String? electoralFootprint,
    String? lastElection,
    String? nextElection,
    List<String>? bannerImages,
    PlacesToVisit? placesToVisit,
    List<SymbolView>? symbols,
    List<dynamic>? geographies,
    List<NationalLeader>? leaders,
    List<CabinetMinister>? otherCabinets,
    int? favouriteCount,
  }) {
    return StateModel(
      id: id ?? this.id,
      countryId: countryId ?? this.countryId,
      code: code ?? this.code,
      name: name ?? this.name,
      nativeName: nativeName ?? this.nativeName,
      capital: capital ?? this.capital,
      population: population ?? this.population,
      chiefMinister: chiefMinister ?? this.chiefMinister,
      governor: governor ?? this.governor,
      info: info ?? this.info,
      cultureAndTradition: cultureAndTradition ?? this.cultureAndTradition,
      economy: economy ?? this.economy,
      symbolInfo: symbolInfo ?? this.symbolInfo,
      districtsCount: districtsCount ?? this.districtsCount,
      spokenLanguage: spokenLanguage ?? this.spokenLanguage,
      rulingParty: rulingParty ?? this.rulingParty,
      electoralFootprint: electoralFootprint ?? this.electoralFootprint,
      lastElection: lastElection ?? this.lastElection,
      nextElection: nextElection ?? this.nextElection,
      bannerImages: bannerImages ?? this.bannerImages,
      placesToVisit: placesToVisit ?? this.placesToVisit,
      symbols: symbols ?? this.symbols,
      geographies: geographies ?? this.geographies,
      leaders: leaders ?? this.leaders,
      otherCabinets: otherCabinets ?? this.otherCabinets,
      favouriteCount: favouriteCount ?? this.favouriteCount,
    );
  }

  /// Converts StateModel to CountryModel representation so shared tabs (Flag, Places, Geo)
  /// can be rendered seamlessly without rewriting entire widget trees.
  CountryModel toCountryModel() {
    return CountryModel(
      id: id,
      name: name,
      capital: capital,
      numericCode: _parseInt(code),
      registrationCode: code,
      unionTerritories: null,
      statesCount: districtsCount,
      population: population,
      president: governor,
      primeMinister: chiefMinister,
      info: info,
      cultureAndTradition: cultureAndTradition,
      economy: economy,
      bannerImages: bannerImages,
      placesToVisit: placesToVisit,
      symbols: symbols,
      leaders: leaders,
      otherCabinets: otherCabinets,
    );
  }
}
