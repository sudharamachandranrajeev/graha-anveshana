import 'dart:convert';
import 'dart:io';

import 'package:anveshana/db/database.dart';
import 'package:anveshana/domain/listing.dart';
import 'package:anveshana/domain/research.dart';
import 'package:anveshana/domain/watch_client.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('email searches', () {
    test('go to Watch with no path, the kind and the words', () {
      const s = WatchSearch(
        id: 'e1',
        name: 'Headingley flats',
        source: 'email',
        path: '/ignored',
        kind: 'rent',
        keywords: ['garden', '-retirement'],
        maxPrice: 1100,
        minBeds: 2,
        centreLat: 53.82,
        centreLon: -1.58,
        centreLabel: 'LS6',
        radiusKm: 3,
      );
      final j = s.toWatchJson();
      expect(j['source'], 'email');
      expect(j['path'], '');
      expect(j['kind'], 'rent');
      expect(j['keywords'], ['garden', '-retirement']);
      expect(j['centre'], {'lat': 53.82, 'lon': -1.58, 'label': 'LS6'});
      // Round trip through JSON, as the Worker hands it back.
      final back = jsonDecode(jsonEncode(j)) as Map<String, Object?>;
      expect(WatchSearch.fromWatchJson(back).toWatchJson(), j);
    });

    test('PropertyPal searches carry no kind or words', () {
      const s = WatchSearch(id: 'p', name: 'P', path: '/property-to-rent/enniskillen', kind: 'rent');
      final j = s.toWatchJson();
      expect(j['source'], 'propertypal');
      expect(j.containsKey('kind'), isFalse);
      expect(j.containsKey('keywords'), isFalse);
    });

    test('keywordList splits on commas and keeps within the Worker limits', () {
      expect(keywordList(' Garden, -Retirement ,, off street parking, -'), [
        'garden',
        '-retirement',
        'off street parking',
      ]);
      expect(keywordList(List.filled(25, 'x').join(',')).length, 20);
      expect(keywordList('a' * 50).single.length, 40);
    });

    test('alerted adverts keep their portal so they match the pasted advert', () {
      final l = listingFromWatch({
        'id': 'rightmove:123456789',
        'source': 'rightmove',
        'sourceId': '123456789',
        'url': 'https://www.rightmove.co.uk/properties/123456789',
        'address': 'Sample Road, Leeds LS6 1AA',
        'price': 950,
        'status': 'toLet',
      });
      expect(l.source, 'rightmove');
      expect(l.sourceId, '123456789');
      expect(l.postcode, 'LS6 1AA');
      // Older Worker events: PropertyPal, keyed by id.
      final old = listingFromWatch({'id': '5', 'address': 'x'});
      expect((old.source, old.sourceId), ('propertypal', '5'));
    });
  });

  group('whereIs', () {
    Research research(Object Function(Uri u) answer) => Research(
      client: MockClient((req) async {
        final body = answer(req.url);
        return http.Response(jsonEncode(body), body is Map && body.containsKey('error') ? 404 : 200);
      }),
    );

    test('reads a postcode, a district or a place', () async {
      final seen = <String>[];
      final r = research((u) {
        seen.add(Uri.decodeComponent(u.path));
        return switch (Uri.decodeComponent(u.path)) {
          '/postcodes/LS6 1AA' => {
            'result': {'postcode': 'LS6 1AA', 'latitude': 53.82, 'longitude': -1.57},
          },
          '/outcodes/WF8' => {
            'result': {'outcode': 'WF8', 'latitude': 53.69, 'longitude': -1.31},
          },
          '/places' when u.queryParameters['q'] == 'Doncaster' => {
            'result': [
              {'name_1': 'Doncaster', 'latitude': 53.52, 'longitude': -1.13},
            ],
          },
          // Northern Ireland's places come from OpenStreetMap.
          '/search' when u.queryParameters['q'] == 'Exampleville' => [
            {'name': 'Exampleville', 'lat': '54.6', 'lon': '-5.9'},
          ],
          '/search' => <Object?>[],
          _ => {'result': <Object?>[]},
        };
      });
      expect(await r.whereIs('LS6 1AA'), (lat: 53.82, lon: -1.57, label: 'LS6 1AA'));
      expect(await r.whereIs('WF8'), (lat: 53.69, lon: -1.31, label: 'WF8'));
      expect(await r.whereIs(' Doncaster '), (lat: 53.52, lon: -1.13, label: 'Doncaster'));
      expect(await r.whereIs('Nowhere at all'), isNull);
      expect(await r.whereIs('Exampleville'), (lat: 54.6, lon: -5.9, label: 'Exampleville'));
      expect(await r.whereIs(''), isNull);
      expect(seen, [
        '/postcodes/LS6 1AA',
        '/outcodes/WF8',
        '/places',
        '/places',
        '/search',
        '/places',
        '/search',
      ]);
    });

    test('an unknown postcode is null, not an error', () async {
      final r = research((_) => {'status': 404, 'error': 'Postcode not found'});
      expect(await r.whereIs('ZZ9 9ZZ'), isNull);
    });
  });

  test('a version 3 database gains the email search columns', () async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final dir = await Directory.systemTemp.createTemp('anveshana-migrate');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/a.db');

    final v4 = AppDatabase(NativeDatabase(file));
    await v4
        .into(v4.searches)
        .insert(SearchesCompanion.insert(id: 's', name: 'Old', path: '/property-to-rent/enniskillen'));
    // Make it look like a version 3 database.
    for (final c in ['source', 'kind', 'keywords']) {
      await v4.customStatement('ALTER TABLE searches DROP COLUMN $c');
    }
    await v4.customStatement('PRAGMA user_version = 3');
    await v4.close();

    final db = AppDatabase(NativeDatabase(file));
    addTearDown(db.close);
    final s = await db.select(db.searches).getSingle();
    expect((s.name, s.source, s.kind, s.keywords), ('Old', 'propertypal', '', ''));
  });
}
