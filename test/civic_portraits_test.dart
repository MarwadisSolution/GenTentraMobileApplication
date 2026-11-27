import 'package:flutter/material.dart';
import 'package:gen_tentra_mobile_application/CountryPage/Country_Info_Page.dart';
import 'package:gen_tentra_mobile_application/CountryPage/civic_portrait.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gen_tentra_mobile_application/CountryPage/Country_api.dart';
import 'package:gen_tentra_mobile_application/CountryPage/Country_model.dart';

void main() {
  testWidgets(
    'Home Minister and the cabinet grid both render their backend portraits',
    (tester) async {
      final country = CountryModel.fromJson({
        'name': 'Test country',
        'govPosts': [
          for (final office in ['Home Minister', 'Cabinet Minister'])
            {
              'title': office,
              'posts': [
                {
                  'holderName': office,
                  'holderImageUrl': '/uploads/$office.jpg',
                },
              ],
            },
        ],
      });
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CountryInfoPage(country: country),
            ),
          ),
        ),
      );
      expect(find.text('HOME MINISTER', skipOffstage: false), findsOneWidget);
      expect(
        find.text('OTHER CABINET MINISTERS', skipOffstage: false),
        findsOneWidget,
      );
      final portraits = tester.widgetList<CivicPortrait>(
        find.byType(CivicPortrait, skipOffstage: false),
      );
      expect(
        portraits.map((p) => p.path),
        containsAll([
          '/uploads/Home Minister.jpg',
          '/uploads/Cabinet Minister.jpg',
        ]),
      );
    },
  );

  test(
    'country keeps office groups and holders with and without portraits',
    () {
      final country = CountryModel.fromJson({
        'govPosts': [
          {
            'title': 'Cabinet Minister',
            'posts': [
              {
                'holderName': 'Current holder',
                'holderImageUrl': '/uploads/portrait.jpg',
              },
              {'holderName': 'Former holder'},
            ],
          },
        ],
      });
      expect(country.leaders.map((p) => p.name), [
        'Current holder',
        'Former holder',
      ]);
      expect(country.leaders.first.title, 'Cabinet Minister');
      expect(country.leaders.first.imageUrl, '/uploads/portrait.jpg');
      expect(country.leaders.last.imageUrl, isEmpty);
    },
  );

  test(
    'state resolves career rows to the holder portrait on the post detail',
    () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (request, handler) {
            dynamic data = [];
            if (request.path.endsWith('/states/7')) {
              data = {'id': 7, 'name': 'Test state'};
            } else if (request.path.endsWith('/gov-posts')) {
              expect(request.queryParameters['stateId'], 7);
              data = {
                'items': [
                  {
                    'id': 42,
                    'govpost': 'Chief Minister',
                    'name': 'Office holder',
                  },
                ],
                'hasNext': false,
              };
            } else if (request.path.endsWith('/gov-posts/42')) {
              data = {
                'holder': {'avatarUrl': '/media/holder.jpg'},
              };
            }
            handler.resolve(
              Response(
                requestOptions: request,
                statusCode: 200,
                data: {'data': data},
              ),
            );
          },
        ),
      );
      final state = await CountryProfileRepository(
        dio: dio,
      ).fetchStateProfile(7);
      expect(state.leaders.single.name, 'Office holder');
      expect(state.leaders.single.imageUrl, '/media/holder.jpg');
    },
  );
}
