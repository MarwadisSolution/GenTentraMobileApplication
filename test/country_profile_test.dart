import 'package:flutter_test/flutter_test.dart';
import 'package:gen_tentra_mobile_application/CountryPage/Country_model.dart';
import 'package:gen_tentra_mobile_application/CountryPage/Country_event.dart';
import 'package:gen_tentra_mobile_application/CountryPage/Country_state.dart';

void main() {
  group('Country Profile Model Tests', () {
    test('Parses full CountryView JSON correctly', () {
      final json = {
        'id': 1,
        'name': 'India',
        'capital': 'New Delhi',
        'numericCode': 356,
        'registrationCode': 'IND',
        'unionTerritories': 8,
        'population': '1.4B',
        'president': 'Droupadi Murmu',
        'primeMinister': 'Shri Narendra Modi',
        'independenceDay': '1947-08-15',
        'nationalAnthem': 'Jana Gana Mana',
        'info': 'India is a country in South Asia.',
        'cultureAndTradition': 'Rich and diverse culture.',
        'economy': 'Developing market economy.',
        'bannerImages': ['https://example.com/taj_mahal.jpg'],
        'placesToVisit': {
          'description': 'Must-see places in India',
          'showDetails': true,
          'place': [
            {
              'id': 101,
              'name': 'India Gate',
              'description': 'War memorial in New Delhi',
              'imageUrl': 'https://example.com/india_gate.jpg',
              'ownerId': 1,
              'category': 'CITY',
            }
          ]
        },
        'symbols': [
          {
            'id': 201,
            'ownerType': 'COUNTRY',
            'ownerId': 1,
            'kind': 'FLAG',
            'urls': ['https://example.com/flag.png'],
            'label': 'National Flag',
            'isDefault': true,
            'downloadable': true,
          }
        ]
      };

      final country = CountryModel.fromJson(json);

      expect(country.id, 1);
      expect(country.name, 'India');
      expect(country.capital, 'New Delhi');
      expect(country.numericCode, 356);
      expect(country.registrationCode, 'IND');
      expect(country.unionTerritories, 8);
      expect(country.population, '1.4B');
      expect(country.president, 'Droupadi Murmu');
      expect(country.primeMinister, 'Shri Narendra Modi');
      expect(country.independenceDay, '1947-08-15');
      expect(country.nationalAnthem, 'Jana Gana Mana');
      expect(country.bannerImages.length, 1);
      expect(country.bannerImages.first, 'https://example.com/taj_mahal.jpg');

      // Places
      expect(country.placesToVisit, isNotNull);
      expect(country.placesToVisit!.places.length, 1);
      expect(country.placesToVisit!.places.first.name, 'India Gate');
      expect(country.placesToVisit!.places.first.category, 'CITY');

      // Symbols
      expect(country.symbols.length, 1);
      expect(country.symbols.first.kind, 'FLAG');
      expect(country.symbols.first.downloadable, true);
    });

    test('Handles missing and nullable fields gracefully without crashing', () {
      final json = {
        'id': 2,
        'name': 'Sample Country',
      };

      final country = CountryModel.fromJson(json);

      expect(country.id, 2);
      expect(country.name, 'Sample Country');
      expect(country.capital, isNull);
      expect(country.bannerImages, isEmpty);
      expect(country.placesToVisit, isNull);
      expect(country.symbols, isEmpty);
    });

    test('CountryProfileState copyWith works correctly', () {
      const state = CountryProfileState(
        status: CountryProfileStatus.initial,
      );

      final updated = state.copyWith(
        status: CountryProfileStatus.loading,
        countryId: 1,
      );

      expect(updated.status, CountryProfileStatus.loading);
      expect(updated.countryId, 1);
    });

    test('Handles String booleans and String numbers correctly', () {
      final json = {
        'id': '10',
        'name': 'India',
        'numericCode': '356',
        'unionTerritories': '8',
        'placesToVisit': {
          'description': 'Must-see places',
          'showDetails': 'true',
          'place': [
            {
              'id': '12',
              'name': 'India Gate',
              'ownerId': '1',
            }
          ]
        },
        'symbols': [
          {
            'id': '201',
            'kind': 'FLAG',
            'urls': ['https://example.com/flag.png'],
            'isDefault': 'YES',
            'downloadable': 'true',
          }
        ]
      };

      final country = CountryModel.fromJson(json);

      expect(country.id, 10);
      expect(country.numericCode, 356);
      expect(country.unionTerritories, 8);
      expect(country.placesToVisit!.showDetails, true);
      expect(country.placesToVisit!.places.first.id, 12);
      expect(country.placesToVisit!.places.first.ownerId, 1);
      expect(country.symbols.first.isDefault, true);
      expect(country.symbols.first.downloadable, true);
    });

    test('CountryProfileEvent instantiates as expected', () {
      const event = FetchCountryProfileEvent(10);
      expect(event.countryId, 10);
    });

    test('Parses leaders and cabinet ministers correctly', () {
      final json = {
        'id': 1,
        'name': 'India',
        'leaders': [
          {
            'title': 'PRESIDENTS OF INDIA',
            'name': 'Droupadi Murmu',
            'tenure': '2022 - Present',
            'badge': 'Current President',
            'imageUrl': 'https://example.com/president.jpg',
          }
        ],
        'otherCabinets': [
          {
            'firstName': 'H. D.',
            'lastName': 'Revana',
            'imageUrl': 'https://example.com/revana.jpg',
            'backgroundColor': '#FF5252',
          }
        ]
      };

      final country = CountryModel.fromJson(json);
      expect(country.leaders.length, 1);
      expect(country.leaders.first.name, 'Droupadi Murmu');
      expect(country.leaders.first.badge, 'Current President');
      expect(country.otherCabinets.length, 1);
      expect(country.otherCabinets.first.firstName, 'H. D.');
      expect(country.otherCabinets.first.lastName, 'Revana');
    });
  });
}
