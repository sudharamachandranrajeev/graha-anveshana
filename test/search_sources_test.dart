import 'dart:convert';

import 'package:anveshana/domain/listing.dart';
import 'package:anveshana/domain/property_search.dart';
import 'package:anveshana/domain/search_request.dart';
import 'package:anveshana/domain/sources.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

// Made-up pages shaped like each site's own; no real adverts.
String _next(Object data) =>
    '<html><script id="__NEXT_DATA__" type="application/json">${jsonEncode(data)}</script></html>';

final _rightmove = _next({
  'props': {
    'pageProps': {
      'searchResults': {
        'properties': [
          {
            'id': 111,
            'bedrooms': 2,
            'bathrooms': 1,
            'displayAddress': '14 Sample Street, Exampletown, EX1 1AA',
            'price': {'amount': 150, 'frequency': 'weekly'},
            'propertySubType': 'Flat',
            'location': {'latitude': 53.8, 'longitude': -1.55},
            'customer': {'branchDisplayName': 'Example Lettings', 'contactTelephone': '0113 000 0000'},
            'images': [
              {'srcUrl': 'https://media.example/1.jpg'},
            ],
            'displayStatus': '',
            'summary': 'Bright flat with allocated parking',
            'keyFeatures': [
              {'description': 'Gas central heating'},
            ],
            'letAvailableDate': '2027-01-01T00:00:00Z',
          },
          {
            'id': 112,
            'bedrooms': 3,
            'displayAddress': 'Other Road, Exampletown',
            'price': {'amount': 900, 'frequency': 'monthly'},
            'displayStatus': 'Let agreed',
          },
        ],
        'pagination': {'next': '24'},
      },
    },
  },
});

final _otm = _next({
  'props': {
    'pageProps': {
      'initialReduxState': {
        'results': {
          'list': [
            {
              'id': '900',
              'bedrooms': 2,
              'address': 'Sample Street, Exampletown EX1',
              'price': '£650 pcm (£150 pw)',
              'short-price': '£650',
              'details-url': '/details/900/',
              'location': {'lat': 53.80001, 'lon': -1.55001},
              'cover-image': {'default': 'https://media.example/otm.jpg'},
              'property-title': '2 bedroom flat to rent',
              'humanised-property-type': 'Flat',
              'features': ['Parking space'],
              'agent': {'name': 'Example Homes'},
              'main-label': 'Reduced',
            },
          ],
          'paginationControls': {'next': null},
        },
      },
    },
  },
});

const _openRent = '''
<script>
var PROPERTYIDS = [ 501,502];
var prices = [
700,1200];
var bedrooms = [
1,3];
var bathrooms = [
1,2];
var PROPERTYLISTLATITUDES = [
53.81,53.82];
var PROPERTYLISTLONGITUDES = [
-1.56,-1.57];
var propertyTypes = [
2,1];
var isstudio = [
0,0];
var islivelistBool = [
1,1];
var furnished = [
1,0];
var unfurnished = [
0,1];
var parkings = [
0,1];
var gardens = [
0,1];
var pets = [
1,0];
var bills = [
0,0];
var students = [
0,1];
var fireplaces = [
0,0];
</script>
<a href="/property-to-rent/exampletown/1-bed-flat-sample-street/501" class="pli search-property-card text-decoration-none" id="p0">
<div><img class="propertyPic" src="//images.example/501.jpg" alt="1 Bed Flat, Sample Street, EX1" /></div></a>
''';

void main() {
  test('Rightmove: weekly rents become monthly; let agreed is marked', () {
    final page = parseRightmoveSearch(_rightmove, rent: true);
    expect(page.more, isTrue);
    final a = page.items.first;
    expect((a.source, a.sourceId, a.url), ('rightmove', '111', 'https://www.rightmove.co.uk/properties/111'));
    expect((a.price, a.beds, a.postcode, a.agent), (650, 2, 'EX1 1AA', 'Example Lettings'));
    expect(a.description, contains('parking'));
    expect(a.availableFrom, '2027-01-01');
    expect(page.items[1].status, 'letAgreed');
  });

  test('OnTheMarket and OpenRent pages', () {
    final otm = parseOnTheMarketSearch(_otm, rent: true);
    expect(otm.more, isFalse);
    expect((otm.items.single.price, otm.items.single.url), (650, 'https://www.onthemarket.com/details/900/'));
    final or = parseOpenRentSearch(_openRent);
    expect(or.items, hasLength(2));
    final carded = or.items.first, plain = or.items.last;
    expect(
      (carded.address, carded.image),
      ('1 Bed Flat, Sample Street, EX1', 'https://images.example/501.jpg'),
    );
    expect(carded.description, contains('Pets allowed'));
    expect(
      (plain.address, plain.url, plain.furnished),
      ('3 bed house', 'https://www.openrent.co.uk/502', 'Unfurnished'),
    );
    expect(plain.description, allOf(contains('Parking'), contains('Garden')));
  });

  test('the same home on two sites becomes one result', () {
    final homes = <FoundHome>[];
    mergeListings(homes, parseRightmoveSearch(_rightmove, rent: true).items);
    mergeListings(homes, parseOnTheMarketSearch(_otm, rent: true).items);
    expect(homes, hasLength(2));
    expect(homes.first.sources, {'rightmove', 'onthemarket'});
    // Merging the same page again adds nothing.
    mergeListings(homes, parseOnTheMarketSearch(_otm, rent: true).items);
    expect(homes.first.copies, hasLength(2));
  });

  test('two adverts on one site are never folded together', () {
    Listing flat(String id) => Listing(
      source: 'openrent',
      sourceId: id,
      url: 'https://www.openrent.co.uk/$id',
      address: '1 Bed Flat, Sample Building, EX1',
      price: 700,
      beds: 1,
      lat: 53.8,
      lon: -1.5,
    );
    final homes = <FoundHome>[];
    mergeListings(homes, [flat('1'), flat('2')]);
    expect(homes, hasLength(2));
  });

  test('results keep only what answers the request, best first', () {
    final homes = <FoundHome>[];
    mergeListings(homes, [
      ...parseRightmoveSearch(_rightmove, rent: true).items,
      ...parseOpenRentSearch(_openRent).items,
    ]);
    final q = readRequest('2 bed to rent in Exampletown under £800 within 3 miles with parking, no students');
    final ranked = rankHomes(homes, q, centreLat: 53.8, centreLon: -1.55);
    // Let agreed (112), too few beds (501) and students (502) are dropped.
    expect([for (final h in ranked) h.main.sourceId], ['111']);
    expect(ranked.single.km, closeTo(0, 0.01));
  });

  group('reader', () {
    test('Rightmove is searched by its area id, a page at a time', () async {
      final asked = <Uri>[];
      final reader = SourceReader(
        MockClient((r) async {
          asked.add(r.url);
          expect(r.headers['user-agent'], contains('Anveshana'));
          if (r.url.host == 'los.rightmove.co.uk') {
            return http.Response(
              jsonEncode({
                'matches': [
                  {'id': '42', 'type': 'REGION'},
                ],
              }),
              200,
            );
          }
          return http.Response(_rightmove, 200);
        }),
      );
      final q = readRequest('2 bed to rent in Exampletown under £800');
      await reader.search(SourceId.rightmove, q);
      await reader.search(SourceId.rightmove, q, page: 1);
      // The area is looked up once.
      expect(asked.where((u) => u.host == 'los.rightmove.co.uk'), hasLength(1));
      final find = asked.last;
      expect(find.queryParameters, containsPair('locationIdentifier', 'REGION^42'));
      expect(find.queryParameters, containsPair('index', '24'));
      expect(find.queryParameters, containsPair('maxPrice', '800'));
    });

    test('a bot check, no sales on OpenRent, and Zoopla go to the browser', () async {
      final reader = SourceReader(MockClient((_) async => http.Response('blocked', 403)));
      final q = readRequest('flat to rent in Exampletown');
      await expectLater(reader.search(SourceId.onTheMarket, q), throwsA(isA<SourceBlocked>()));
      await expectLater(
        reader.search(SourceId.openRent, readRequest('house for sale in Exampletown')),
        throwsA(isA<SourceSkipped>()),
      );
      await expectLater(
        reader.search(SourceId.zoopla, q),
        throwsA(isA<SourceBlocked>().having((e) => e.url.host, 'host', 'www.zoopla.co.uk')),
      );
    });
  });

  test('listings keep their postcode when the site gives one', () {
    expect(postcodeIn('Flat 1, EX1 1AA'), 'EX1 1AA');
  });
}
