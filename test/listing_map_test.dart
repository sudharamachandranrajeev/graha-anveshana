import 'dart:convert';

import 'package:anveshana/app/search_controller.dart';
import 'package:anveshana/app/search_memory.dart';
import 'package:anveshana/domain/listing.dart';
import 'package:anveshana/ui/homes_map.dart';
import 'package:anveshana/ui/listing_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'app_harness.dart';
import 'support.dart';

void main() {
  test('places to measure from: last used first, no repeats, at most 6', () {
    NamedPoint p(String label) => (lat: 54.0, lon: -7.0, label: label);
    var all = <NamedPoint>[];
    for (final l in ['A', 'B', 'C', 'D', 'E', 'F', 'G']) {
      all = placesWith(all, p(l));
    }
    expect(all.map((p) => p.label), ['G', 'F', 'E', 'D', 'C', 'B']);
    all = placesWith(all, p('d'));
    expect(all.map((p) => p.label), ['d', 'G', 'F', 'E', 'C', 'B']);
    final json = jsonEncode([
      {'lat': 54.1, 'lon': -7.2, 'label': 'Work'},
      {'bad': true},
    ]);
    expect(placesFromJson(json), [(lat: 54.1, lon: -7.2, label: 'Work')]);
    expect(placesFromJson('not json'), isEmpty);
    expect(placesFromJson(null), isEmpty);
  });

  test('directions open Google Maps from the place to the home', () {
    final u = directionsUrl((lat: 54.1, lon: -7.2, label: 'Work'), (lat: 54.3, lon: -7.6));
    expect(u.host, 'www.google.com');
    expect(u.queryParameters, {'api': '1', 'origin': '54.1,-7.2', 'destination': '54.3,-7.6'});
  });

  testWidgets('a home\'s page measures it from the home point and from any place', (tester) async {
    final app = AppHarness(tester)..desktop();
    await app.open(
      seed: (book) async {
        await book.setHome((lat: 54.344, lon: -7.638, label: 'Work'));
        await book.importListing(
          parsePropertyPalPage(nextData({'property': samplePropertyPal()})).single,
          today: '2026-10-20',
        );
      },
    );
    await app.run(
      overrides: [
        searchHttpProvider.overrideWithValue(
          MockClient((r) async {
            if (r.url.host == 'api.postcodes.io' &&
                Uri.decodeComponent(r.url.path) == '/postcodes/BT74 7AA') {
              return http.Response(
                jsonEncode({
                  'result': {'latitude': 54.36, 'longitude': -7.638, 'postcode': 'BT74 7AA'},
                }),
                200,
              );
            }
            return http.Response(jsonEncode({'status': 404}), 404);
          }),
        ),
      ],
      maps: true,
    );
    await app.go('Hunt');
    await app.tap(find.textContaining('Sample Street').first);
    expect(find.byType(HomesMap), findsOneWidget);
    expect(find.text('Distance from'), findsOneWidget);
    expect(find.text('0.3 mi (0.5 km) from Work in a straight line.'), findsOneWidget);
    expect(find.text('Directions and travel time'), findsOneWidget);

    await app.tap(find.text('Another place'));
    await tester.enterText(
      find.byType(TextField).at(find.byType(TextField).evaluate().length - 2),
      'BT74 7AA',
    );
    await tester.enterText(find.byType(TextField).last, 'Gym');
    await app.tap(find.widgetWithText(FilledButton, 'Measure'));
    expect(find.widgetWithText(InputChip, 'Gym'), findsOneWidget);
    expect(find.text('0.8 mi (1.3 km) from Gym in a straight line.'), findsOneWidget);

    // The place is remembered for the next home.
    final saved = (await tester.runAsync(() => app.session.db.localSetting('anveshana.distance.places')))!;
    expect(placesFromJson(saved).first.label, 'Gym');
    await app.close();
  });
}
