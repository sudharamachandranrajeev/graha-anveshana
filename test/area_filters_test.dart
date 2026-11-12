import 'dart:convert';

import 'package:anveshana/app/search_controller.dart';
import 'package:anveshana/domain/advert.dart';
import 'package:anveshana/domain/area_checks.dart';
import 'package:anveshana/domain/home_features.dart';
import 'package:anveshana/domain/leasehold.dart';
import 'package:anveshana/domain/listing.dart';
import 'package:anveshana/domain/property_search.dart';
import 'package:anveshana/domain/search_request.dart';
import 'package:anveshana/domain/travel.dart';
import 'package:anveshana/ui/area_checks_card.dart';
import 'package:anveshana/ui/homes_map.dart';
import 'package:anveshana/ui/listing_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

// Made-up homes, places and answers; no real adverts or people.
FoundHome _home(String description, {double? lat, double? lon}) => FoundHome(
  Listing(
    source: 'rightmove',
    sourceId: '1',
    url: 'https://example.test/1',
    address: '1 Sample Street, Leeds',
    price: 900,
    beds: 2,
    description: description,
    lat: lat,
    lon: lon,
  ),
);

/// A rectangle [eastM] metres east-west by [northM] north-south.
List<LatLon> _box(double lat, double lon, double eastM, double northM) {
  final dLon = eastM / 65750, dLat = northM / 110540;
  return [
    (lat: lat, lon: lon),
    (lat: lat, lon: lon + dLon),
    (lat: lat + dLat, lon: lon + dLon),
    (lat: lat + dLat, lon: lon),
    (lat: lat, lon: lon),
  ];
}

final _routeJson = jsonEncode({
  'code': 'Ok',
  'routes': [
    {
      'duration': 2700,
      'distance': 55500,
      'geometry': {
        'coordinates': [
          [-1.55, 53.8],
          [-1.3, 53.6],
          [-1.13, 53.52],
        ],
      },
    },
  ],
});

void main() {
  group('must-haves and never-shows', () {
    test('the advert\'s words say yes, no or nothing', () {
      expect(HomeFeature.garden.said('Lovely rear garden'), Says.yes);
      expect(HomeFeature.garage.said('No garage, on-street parking'), Says.no);
      expect(HomeFeature.petsAllowed.said('Sorry, no pets'), Says.no);
      expect(HomeFeature.enSuite.said('Two double bedrooms'), Says.unknown);
      expect(HomeFeature.houseShare.said('A double room in a quiet street'), Says.unknown);
      expect(HomeFeature.houseShare.said('Room to rent in a friendly house share'), Says.yes);
      expect(HomeFeature.parkHome.said('Holiday lodge on a park'), Says.yes);
      expect(HomeFeature.retirement.said('Sheltered garden to the rear'), Says.unknown);
      expect(HomeFeature.retirement.said('Over 55s development'), Says.yes);
    });

    test('unknown must-haves stay unless strict; a never-show mentioned goes', () {
      const has = [HomeFeature.garden, HomeFeature.driveway];
      expect(passesFeatures('Garden and driveway', has, const []), isTrue);
      expect(passesFeatures('Garden', has, const []), isTrue);
      expect(passesFeatures('Garden', has, const [], strict: true), isFalse);
      expect(passesFeatures('No garden, driveway', has, const []), isFalse);
      expect(passesFeatures('Cash buyers only', const [], const [HomeFeature.cashOnly]), isFalse);
      expect(passesFeatures('Mortgage ready', const [], const [HomeFeature.cashOnly]), isTrue);
    });
  });

  group('drawn area, travel time and the request', () {
    final shape = <LatLon>[(lat: 53.0, lon: -2.0), (lat: 53.0, lon: -1.0), (lat: 54.0, lon: -1.5)];

    test('a point is inside or outside the drawn shape', () {
      expect(insideShape((lat: 53.3, lon: -1.5), shape), isTrue);
      expect(insideShape((lat: 53.9, lon: -1.9), shape), isFalse);
      // Fewer than three corners is no area.
      expect(insideShape((lat: 0, lon: 0), shape.take(2).toList()), isTrue);
    });

    test('the request keeps its filters through saving', () {
      final q = const SearchRequest(area: 'Leeds').copyWith(
        has: [HomeFeature.garden],
        never: [HomeFeature.auction],
        strict: true,
        shape: shape,
        maxMinutes: () => 30,
        travelMode: 'bike',
        travelTo: 'Work',
      );
      final back = SearchRequest.fromJson(jsonDecode(jsonEncode(q.toJson())) as Map<String, Object?>);
      expect(back.has, [HomeFeature.garden]);
      expect(back.never, [HomeFeature.auction]);
      expect(back.strict, isTrue);
      expect(back.shape, shape);
      expect((back.maxMinutes, back.travelMode, back.travelTo), (30, 'bike', 'Work'));
      final plain = SearchRequest.fromJson(const SearchRequest(area: 'Leeds').toJson());
      expect([...plain.has, ...plain.shape], isEmpty);
      expect(plain.maxMinutes, isNull);
    });

    test('homes outside the area, too far away or with a never-show are left out', () {
      final q = SearchRequest(
        area: 'Leeds',
        shape: shape,
        maxMinutes: 30,
        never: const [HomeFeature.students],
      );
      expect(meetsRequest(_home('Nice flat', lat: 53.3, lon: -1.5), q), isTrue);
      expect(meetsRequest(_home('Nice flat', lat: 53.9, lon: -1.9), q), isFalse);
      // No map point: cannot be placed, so it stays.
      expect(meetsRequest(_home('Nice flat'), q), isTrue);
      expect(meetsRequest(_home('Student let', lat: 53.3, lon: -1.5), q), isFalse);
      expect(meetsRequest(_home('Nice flat', lat: 53.3, lon: -1.5)..minutes = 45, q), isFalse);
      expect(meetsRequest(_home('Nice flat', lat: 53.3, lon: -1.5)..minutes = 25, q), isTrue);
    });

    test('travel times: one batched, cached request; only points are sent', () async {
      final asked = <Uri>[];
      final times = TravelTimes(
        MockClient((r) async {
          asked.add(r.url);
          expect(r.headers['user-agent'], routerUserAgent);
          return http.Response(
            jsonEncode({
              'code': 'Ok',
              'durations': [
                [1500],
                [null],
              ],
            }),
            200,
          );
        }),
        spacing: Duration.zero,
      );
      const work = (lat: 53.8, lon: -1.55);
      final homes = <LatLon>[(lat: 53.52, lon: -1.13), (lat: 53.68, lon: -1.5)];
      expect(await times.minutes(TravelMode.bike, homes, work), [25.0, null]);
      expect(await times.minutes(TravelMode.bike, homes, work), [25.0, null]);
      expect(asked, hasLength(1));
      final u = asked.single;
      expect(u.host, 'routing.openstreetmap.de');
      expect(u.path, '/routed-bike/table/v1/cycling/-1.55000,53.80000;-1.13000,53.52000;-1.50000,53.68000');
      expect(u.queryParameters, containsPair('destinations', '0'));
      expect(u.queryParameters, containsPair('sources', '1;2'));
      expect(minutesText(25), '25 min');
      expect(minutesText(70), '1 h 10 min');
      expect(minutesText(120), '2 h');
    });

    test('an answer that is not JSON is the service failing, not a crash', () async {
      final times = TravelTimes(
        MockClient((r) async => http.Response('<html>Bad gateway</html>', 200)),
        spacing: Duration.zero,
      );
      const work = (lat: 53.8, lon: -1.55), home = (lat: 53.52, lon: -1.13);
      expect(times.minutes(TravelMode.bike, [home], work), throwsA(isA<TravelUnavailable>()));
      expect(times.minutesToEach(TravelMode.bike, home, [work]), throwsA(isA<TravelUnavailable>()));
      expect(times.route(TravelMode.bike, work, home), throwsA(isA<TravelUnavailable>()));
    });

    test('a route: its line, time and distance, asked once', () async {
      var calls = 0;
      final times = TravelTimes(
        MockClient((r) async {
          calls++;
          expect(r.url.path, '/routed-car/route/v1/driving/-1.55000,53.80000;-1.13000,53.52000');
          return http.Response(_routeJson, 200);
        }),
        spacing: Duration.zero,
      );
      const work = (lat: 53.8, lon: -1.55), home = (lat: 53.52, lon: -1.13);
      final r = (await times.route(TravelMode.car, work, home))!;
      expect(r.line, [(lat: 53.8, lon: -1.55), (lat: 53.6, lon: -1.3), (lat: 53.52, lon: -1.13)]);
      expect((r.minutes, r.km), (45.0, 55.5));
      await times.route(TravelMode.car, work, home);
      expect(calls, 1);
      // The time is also known to the times table.
      expect(times.known(TravelMode.car, work, home), 45.0);
    });

    testWidgets('a home\'s map shows the route from the place and expands full screen', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            searchHttpProvider.overrideWithValue(MockClient((_) async => http.Response(_routeJson, 200))),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: RouteMap(
                home: MapHome(label: '£850', lat: 53.52, lon: -1.13),
                at: const (lat: 53.52, lon: -1.13),
                from: const (lat: 53.8, lon: -1.55, label: 'Work'),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      expect(find.text('By car from Work: 45 min, 34 mi by road or path (no traffic)'), findsOneWidget);
      await tester.tap(find.text('Expand'));
      await tester.pumpAndSettle();
      expect(find.text('£850 from Work'), findsOneWidget);
      expect(find.text('Directions (bus, train)'), findsOneWidget);
      expect(find.byType(ChoiceChip), findsNWidgets(3));
      // The full page has no Expand of its own.
      expect(find.text('Expand'), findsNothing);
    });

    test('travel times: a router that is down says so', () async {
      final times = TravelTimes(MockClient((_) async => http.Response('', 503)), spacing: Duration.zero);
      expect(
        () => times.minutesToEach(TravelMode.car, (lat: 53.5, lon: -1.1), [(lat: 53.8, lon: -1.5)]),
        throwsA(isA<TravelUnavailable>()),
      );
    });
  });

  group('leasehold costs', () {
    test('Rightmove\'s own fields', () {
      final c = readLeasehold(
        const AdvertDetails(
          facts: {
            'Tenure': 'Leasehold',
            'Lease': '78 years remaining',
            'Service charge': '£1200 per annum',
            'Ground rent': '£240 per annum',
          },
        ),
        thisYear: 2026,
      );
      expect((c.leasehold, c.yearsLeft, c.serviceChargeYear, c.groundRentYear), (true, 78, 1200, 240));
      expect(c.monthly, 120);
      expect(c.missing, isEmpty);
      expect(c.warnings.single, startsWith('Under 80 years'));
    });

    test('words in the description; monthly charges, peppercorn rent, a dated lease', () {
      final c = readLeasehold(
        const AdvertDetails(
          description:
              'Leasehold. Service charge of £95 per month. Ground rent: peppercorn. '
              '125 years from 2005.',
        ),
        thisYear: 2026,
      );
      expect((c.serviceChargeYear, c.groundRentYear, c.yearsLeft), (1140, 0, 104));
      expect(c.warnings, isEmpty);
    });

    test('a leasehold advert that leaves things out; a freehold one', () {
      final c = readLeasehold(const AdvertDetails(facts: {'Tenure': 'Leasehold'}), thisYear: 2026);
      expect(c.missing, ['service charge', 'ground rent', 'years left on the lease']);
      final f = readLeasehold(const AdvertDetails(description: 'Freehold semi'), thisYear: 2026);
      expect(f.leasehold, isFalse);
      expect(f.missing, isEmpty);
    });
  });

  group('area checks', () {
    test('the sun in Leeds: north-east to north-west in summer, low in the south in winter', () {
      final days = sunDays(53.8);
      final summer = days.first, winter = days.last;
      expect((compass(summer.rise), compass(summer.set)), ('north-east', 'north-west'));
      expect(summer.noonHeight.round(), 60);
      expect((compass(winter.rise), compass(winter.set)), ('south-east', 'south-west'));
      expect(winter.noonHeight.round(), 13);
      expect(compass(days[1].rise), 'east');
    });

    test('a building\'s long sides, and the sun they get', () {
      final f = facing(_box(53.8, -1.55, 20, 8))!;
      expect({compass(f.$1), compass(f.$2)}, {'north', 'south'});
      expect(facing(_box(53.8, -1.55, 10, 10)), isNull);
      expect(sunFor(180), 'sun for most of the day');
      expect(sunFor(270), 'afternoon and evening sun');
      expect(sunFor(90), 'morning sun');
      expect(sunFor(0), 'little direct sun, more in summer');
    });

    test('schools: nearest first, named ones only, each once; the point alone is sent', () async {
      final checks = AreaChecks(
        MockClient((r) async {
          final q = Uri.decodeQueryComponent(r.body);
          expect(q, contains('"amenity"="school"'));
          expect(q, contains('around:1609,53.80000,-1.55000'));
          return http.Response(
            jsonEncode({
              'elements': [
                {
                  'type': 'way',
                  'center': {'lat': 53.81, 'lon': -1.55},
                  'tags': {'name': 'Far High School', 'isced:level': '2;3'},
                },
                {
                  'type': 'node',
                  'lat': 53.801,
                  'lon': -1.55,
                  'tags': {'name': 'Near Primary School'},
                },
                {
                  'type': 'way',
                  'center': {'lat': 53.802, 'lon': -1.55},
                  'tags': {'name': 'Near Primary School'},
                },
                {'type': 'node', 'lat': 53.8, 'lon': -1.55, 'tags': <String, String>{}},
              ],
            }),
            200,
          );
        }),
      );
      final got = await checks.schools((lat: 53.8, lon: -1.55));
      expect(got.map((s) => (s.name, s.kind)), [
        ('Near Primary School', 'Primary'),
        ('Far High School', 'Secondary'),
      ]);
      expect(got.first.km, closeTo(0.11, 0.01));
      expect(ofstedSearch('Near Primary School').queryParameters['q'], 'Near Primary School');
    });

    test('the building the point falls in; a busy server says so', () async {
      final other = _box(53.8, -1.56, 20, 8), home = _box(53.79995, -1.55005, 20, 8);
      final checks = AreaChecks(
        MockClient(
          (r) async => http.Response(
            jsonEncode({
              'elements': [
                for (final o in [other, home])
                  {
                    'type': 'way',
                    'geometry': [
                      for (final p in o) {'lat': p.lat, 'lon': p.lon},
                    ],
                  },
              ],
            }),
            200,
          ),
        ),
      );
      final b = await checks.building((lat: 53.8, lon: -1.55));
      expect(b!.first.lat, closeTo(53.79995, 1e-9));
      final busy = AreaChecks(MockClient((_) async => http.Response('', 429)));
      expect(() => busy.schools((lat: 53.8, lon: -1.55)), throwsA(isA<AreaUnavailable>()));
    });

    testWidgets('the card asks nothing until tapped, then lists schools and the facing', (tester) async {
      var calls = 0;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            searchHttpProvider.overrideWithValue(
              MockClient((r) async {
                calls++;
                final q = Uri.decodeQueryComponent(r.body);
                if (q.contains('school')) {
                  return http.Response(
                    jsonEncode({
                      'elements': [
                        {
                          'type': 'node',
                          'lat': 53.801,
                          'lon': -1.55,
                          'tags': {'name': 'Sample Primary School'},
                        },
                      ],
                    }),
                    200,
                  );
                }
                return http.Response(
                  jsonEncode({
                    'elements': [
                      {
                        'type': 'way',
                        'geometry': [
                          for (final p in _box(53.79995, -1.55005, 20, 8)) {'lat': p.lat, 'lon': p.lon},
                        ],
                      },
                    ],
                  }),
                  200,
                );
              }),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(child: AreaChecksCard(at: (lat: 53.8, lon: -1.55))),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Area checks'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Midsummer: the sun rises in the north-east'), findsOneWidget);
      expect(find.text('Coal mining map'), findsOneWidget);
      expect(calls, 0);

      await tester.tap(find.text('Find schools within a mile'));
      await tester.pumpAndSettle();
      expect(find.text('Sample Primary School'), findsOneWidget);
      expect(find.textContaining('does not put a home in its catchment'), findsOneWidget);

      await tester.ensureVisible(find.text('Which way does it face?'));
      await tester.tap(find.text('Which way does it face?'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Its long sides face'), findsOneWidget);
      expect(calls, 2);
    });
  });

  testWidgets('drawing an area on the map: corners by tapping, Done hands them back', (tester) async {
    List<LatLon>? drawn;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 600,
            height: 500,
            child: HomesMap(
              homes: const [],
              centre: (lat: 53.8, lon: -1.55),
              locate: (_) async => const {},
              onDraw: (s) => drawn = s,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Draw an area'));
    await tester.pump();
    expect(find.textContaining('of at least 3'), findsOneWidget);
    for (final at in const [Offset(150, 300), Offset(400, 300), Offset(300, 120)]) {
      await tester.tapAt(at);
      await tester.pump(const Duration(milliseconds: 400));
    }
    expect(find.text('3 corners'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await tester.pump();
    expect(find.textContaining('2 of at least 3'), findsOneWidget);
    await tester.tapAt(const Offset(300, 120));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Done'));
    await tester.pump();
    expect(drawn, hasLength(3));
    expect(find.text('Draw again'), findsNothing); // The parent keeps the shape, not the map.
  });
}
