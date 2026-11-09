import 'dart:convert';

import 'package:anveshana/app/search_controller.dart';
import 'package:anveshana/app/search_memory.dart';
import 'package:anveshana/domain/book.dart';
import 'package:anveshana/domain/listing.dart';
import 'package:anveshana/domain/property_search.dart';
import 'package:anveshana/domain/trash.dart';
import 'package:anveshana/ui/homes_map.dart';
import 'package:anveshana/ui/listing_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'app_harness.dart';
import 'support.dart';

FoundHome _home(String source, String id, {String address = '14 Sample Street, Leeds, LS6 1AA'}) => FoundHome(
  Listing(
    source: source,
    sourceId: id,
    url: 'https://example.test/$id',
    address: address,
    postcode: postcodeIn(address) ?? '',
    price: 850,
    beds: 2,
  ),
);

void main() {
  test('places: added in order, the same name replaced, bad entries skipped', () {
    NamedPoint p(String label, [double lat = 54.0]) => (lat: lat, lon: -7.0, label: label);
    var all = placesWith(const [], p('Work'));
    all = placesWith(all, p('Mum'));
    all = placesWith(all, p('work', 55.0));
    expect(all.map((p) => (p.label, p.lat)), [('work', 55.0), ('Mum', 54.0)]);
    expect(
      placesFromJson([
        {'lat': 54.1, 'lon': -7.2, 'label': 'Work'},
        {'bad': true},
      ]),
      [(lat: 54.1, lon: -7.2, label: 'Work')],
    );
    expect(placesFromJson('not a list'), isEmpty);
    expect(placesFromJson(jsonDecodeOr('not json')), isEmpty);
  });

  test('directions open Google Maps from the place to the home', () {
    final u = directionsUrl((lat: 54.1, lon: -7.2, label: 'Work'), (lat: 54.3, lon: -7.6));
    expect(u.host, 'www.google.com');
    expect(u.queryParameters, {'api': '1', 'origin': '54.1,-7.2', 'destination': '54.3,-7.6'});
  });

  test('a home thrown out stays out: the same advert, and the same home on another site', () {
    final binned = TrashedHome.fromJson(TrashedHome.of(_home('rightmove', '111'), '2026-11-09').toJson())!;
    expect(binned.at, '2026-11-09');
    expect(isTrashed(_home('rightmove', '111'), [binned]), isTrue);
    // Zoopla lists the same home: same address, postcode, beds and price.
    expect(isTrashed(_home('zoopla', '999'), [binned]), isTrue);
    expect(isTrashed(_home('rightmove', '222', address: '2 Other Road, Leeds, LS6 2BB'), [binned]), isFalse);
    expect(isTrashed(_home('rightmove', '111'), const []), isFalse);
  });

  testWidgets('a home\'s page shows its distance from the home point and the profile\'s places', (
    tester,
  ) async {
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
    await app.go('Shortlist');
    await app.tap(find.textContaining('Sample Street').first);
    expect(find.byType(HomesMap), findsOneWidget);
    expect(find.text('Distance from your places'), findsOneWidget);
    expect(find.text('Work: 0.3 mi (0.5 km)'), findsOneWidget);
    expect(find.byTooltip('Directions and travel time from Work'), findsOneWidget);

    await app.tap(find.text('Add a place'));
    await tester.enterText(
      find.byType(TextField).at(find.byType(TextField).evaluate().length - 2),
      'BT74 7AA',
    );
    await tester.enterText(find.byType(TextField).last, 'Gym');
    await app.tap(find.widgetWithText(FilledButton, 'Add'));
    expect(find.text('Gym: 0.8 mi (1.3 km)'), findsOneWidget);

    // The place is the profile's, synced with the user's other devices.
    final saved = (await tester.runAsync(() => app.book.pref<List<Object?>>(PrefKeys.places, const [])))!;
    expect(placesFromJson(saved).single.label, 'Gym');
    await app.tap(find.byType(BackButton));
    await app.go('Profile');
    expect(find.text('Gym'), findsOneWidget);
    await app.close();
  });
}
