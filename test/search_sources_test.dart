import 'dart:convert';

import 'package:anveshana/domain/home_features.dart';
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
            'firstVisibleDate': '2026-11-01T10:00:00Z',
            'listingUpdate': {
              'listingUpdateReason': 'price_reduced',
              'listingUpdateDate': '2026-11-08T09:00:00Z',
            },
            'displaySize': '738 sq. ft.',
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
    expect((a.listedOn, a.reducedOn, a.sqft), ('2026-11-01', '2026-11-08', 738));
    final b = page.items[1];
    expect((b.listedOn, b.reducedOn, b.sqft), (null, null, null));
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
      expect(find.queryParameters.containsKey('mustHave'), isFalse);

      // Must-haves and never-shows Rightmove knows go in its own filters.
      await reader.search(
        SourceId.rightmove,
        q.copyWith(
          has: [HomeFeature.garden, HomeFeature.driveway, HomeFeature.enSuite],
          never: [HomeFeature.students, HomeFeature.retirement, HomeFeature.auction],
        ),
      );
      expect(asked.last.queryParameters, containsPair('mustHave', 'garden,parking'));
      // Auctions are for sale only; this search is to rent.
      expect(asked.last.queryParameters, containsPair('dontShow', 'student,retirement'));
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

  test('OpenRent: homes past the first twenty get their title and photo, a page at a time', () async {
    // 45 matches; the area page has a card for the first only.
    final ids = [for (var i = 0; i < 45; i++) 600 + i];
    String col(String name, String v) => 'var $name = [${List.filled(ids.length, v).join(',')}];';
    final page =
        '<script>var PROPERTYIDS = [${ids.join(',')}];\n'
        '${col('prices', '700')}\n${col('bedrooms', '2')}\n${col('islivelistBool', '1')}\n</script>'
        '<a href="/property-to-rent/exampletown/x/600" class="search-property-card">'
        '<img src="//images.example/600.jpg" alt="2 Bed Flat, Card Street, EX1" /></a>';
    final asked = <Uri>[];
    final reader = SourceReader(
      MockClient((r) async {
        asked.add(r.url);
        if (r.url.path == '/search/propertiesbyid') {
          return http.Response(
            jsonEncode([
              for (final id in r.url.queryParametersAll['ids']!)
                {
                  'id': int.parse(id),
                  'title': '2 Bed Flat, Road $id, EX2',
                  'imageUrl': '//images.example/$id.jpg',
                },
            ]),
            200,
          );
        }
        return http.Response(page, 200);
      }),
    );
    final q = readRequest('2 bed to rent in Exampletown');
    final first = await reader.search(SourceId.openRent, q);
    expect((first.items.length, first.more), (openRentBatch, true));
    expect(first.items.first.address, '2 Bed Flat, Card Street, EX1');
    expect(first.items[1].address, '2 Bed Flat, Road 601, EX2');
    expect(first.items[1].image, 'https://images.example/601.jpg');
    // The card already known is not asked for again.
    expect(asked.last.queryParametersAll['ids'], isNot(contains('600')));
    final last = await reader.search(SourceId.openRent, q, page: 2);
    expect((last.items.length, last.more), (5, false));
    expect(last.items.every((l) => l.image != null), isTrue);
    // Later pages reuse the area page read for the first.
    expect(asked.where((u) => u.path != '/search/propertiesbyid'), hasLength(1));
  });

  test('a result shows the fullest address its sites give, with the postcode', () {
    Listing ad(String source, String address, {String postcode = ''}) =>
        Listing(source: source, sourceId: '1', url: '', address: address, postcode: postcode);
    final h = FoundHome(ad('openrent', '2 bed flat'))
      ..copies.add(ad('rightmove', 'Castle Street, Exampletown', postcode: 'EX1 1AA'));
    expect(h.address, 'Castle Street, Exampletown, EX1 1AA');
    expect(
      FoundHome(ad('zoopla', 'Flat 1, Castle Street, EX1 1AA')).address,
      'Flat 1, Castle Street, EX1 1AA',
    );
  });

  test('listings keep their postcode when the site gives one', () {
    expect(postcodeIn('Flat 1, EX1 1AA'), 'EX1 1AA');
  });
}
